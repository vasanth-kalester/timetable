"use client"

import { useState, useEffect, useCallback } from "react"
import { useSession } from "next-auth/react"
import { useRouter } from "next/navigation"
import {
    Loader2, AlertTriangle, CheckCircle2, Plus, Trash2, Sparkles,
    RotateCcw, Save, Coffee, ChevronRight, Users, MapPin, BookOpen,
    UserRound, Hash, Clock, XCircle, Pencil, X
} from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { toast, ToastContainer } from "@/components/ui/Toast"
import {
    getClasses, createClass,
    getSubjects, createSubject, deleteSubject, updateSubjectStaff, updateSubject,
    getRooms, createRoom,
    getTimetableSlots, createTimetableSlot, bulkDeleteSlotsByClass
} from "@/app/actions/timetable"
import { getStaff } from "@/app/actions/staff"

// ─── Constants ───────────────────────────────────────────────────────────────
const WORKING_DAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
const SCHEDULABLE_TIMES = ["09:00 AM", "10:00 AM", "11:00 AM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"]
const ALL_DISPLAY_TIMES = ["09:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"]

const COLORS = [
    { border: "border-blue-300", bg: "bg-blue-50", text: "text-blue-700" },
    { border: "border-violet-300", bg: "bg-violet-50", text: "text-violet-700" },
    { border: "border-emerald-300", bg: "bg-emerald-50", text: "text-emerald-700" },
    { border: "border-amber-300", bg: "bg-amber-50", text: "text-amber-700" },
    { border: "border-rose-300", bg: "bg-rose-50", text: "text-rose-700" },
    { border: "border-cyan-300", bg: "bg-cyan-50", text: "text-cyan-700" },
    { border: "border-orange-300", bg: "bg-orange-50", text: "text-orange-700" },
    { border: "border-pink-300", bg: "bg-pink-50", text: "text-pink-700" },
]
function colorForSubject(id: string) {
    let h = 0; for (const c of id) h = (h * 31 + c.charCodeAt(0)) >>> 0
    return COLORS[h % COLORS.length]
}

// ─── Shuffle helper ───────────────────────────────────────────────────────────
function seededShuffle<T>(arr: T[], seed: number): T[] {
    const a = [...arr]; let s = seed | 0
    for (let i = a.length - 1; i > 0; i--) {
        s = Math.imul(s ^ (s >>> 15), s | 1) ^ (s + Math.imul(s ^ (s >>> 7), s | 61))
        const j = (s >>> 0) % (i + 1);
        [a[i], a[j]] = [a[j], a[i]]
    }
    return a
}

// ─── Generation algorithm ─────────────────────────────────────────────────────
interface GeneratedSlot { day: string; time: string; classId: string; subjectId: string; staffId: string; roomId: string }
interface Conflict { subjectName: string; periodsNeeded: number; periodsScheduled: number; reason: string }

function runGeneration(params: {
    classId: string; classRoomId: string; subjects: any[]; rooms: any[]; existingSlots: any[]; seed: number
}): { slots: GeneratedSlot[]; conflicts: Conflict[] } {
    const { classId, classRoomId, subjects, rooms, existingSlots, seed } = params

    const staffBooked = new Set<string>()
    const roomBooked = new Set<string>()
    const classBooked = new Set<string>()

    // Pre-load other classes' bookings to avoid staff/room conflicts
    for (const s of existingSlots) {
        if (s.classId !== classId) {
            staffBooked.add(`${s.staffId}|${s.day}|${s.time}`)
            roomBooked.add(`${s.roomId}|${s.day}|${s.time}`)
        }
    }

    const allCombos: [string, string][] = []
    for (const day of WORKING_DAYS) for (const time of SCHEDULABLE_TIMES) allCombos.push([day, time])

    const generated: GeneratedSlot[] = []
    const conflicts: Conflict[] = []

    const readySubjects = subjects.filter(s => s.staffId).sort((a, b) => (b.hoursPerWeek || 3) - (a.hoursPerWeek || 3))

    for (let si = 0; si < readySubjects.length; si++) {
        const subject = readySubjects[si]
        const needed = Math.min(subject.hoursPerWeek || 3, WORKING_DAYS.length * SCHEDULABLE_TIMES.length)
        let scheduled = 0
        const shuffled = seededShuffle(allCombos, seed + si * 997)

        for (const [day, time] of shuffled) {
            if (scheduled >= needed) break
            const classKey = `${classId}|${day}|${time}`
            const staffKey = `${subject.staffId}|${day}|${time}`
            if (classBooked.has(classKey) || staffBooked.has(staffKey)) continue

            // Prefer the class's fixed room; fall back to any free room
            let roomId = classRoomId
            if (roomId && roomBooked.has(`${roomId}|${day}|${time}`)) {
                const alt = rooms.find(r => !roomBooked.has(`${r.id}|${day}|${time}`))
                if (!alt) continue
                roomId = alt.id
            } else if (!roomId) {
                const free = rooms.find(r => !roomBooked.has(`${r.id}|${day}|${time}`))
                if (!free) continue
                roomId = free.id
            }

            generated.push({ day, time, classId, subjectId: subject.id, staffId: subject.staffId, roomId })
            classBooked.add(classKey)
            staffBooked.add(staffKey)
            roomBooked.add(`${roomId}|${day}|${time}`)
            scheduled++
        }

        if (scheduled < needed) {
            conflicts.push({ subjectName: subject.name, periodsNeeded: needed, periodsScheduled: scheduled, reason: scheduled === 0 ? "No free slot found" : "Could not fill all periods" })
        }
    }
    return { slots: generated, conflicts }
}

// ─── Main Page ────────────────────────────────────────────────────────────────
type WizardStep = 1 | 2 | 3 | 4 | 5
type GenState = "idle" | "preview" | "saving"

export default function TimetableSetupPage() {
    const { data: session } = useSession()
    const router = useRouter()

    const [loading, setLoading] = useState(true)
    const [step, setStep] = useState<WizardStep>(1)
    const [genState, setGenState] = useState<GenState>("idle")
    const [error, setError] = useState<string | null>(null)

    // Server data
    const [collegeId, setCollegeId] = useState<string | null>(null)
    const [departmentId, setDepartmentId] = useState<string | null>(null)
    const [allClasses, setAllClasses] = useState<any[]>([])
    const [allRooms, setAllRooms] = useState<any[]>([])
    const [allStaff, setAllStaff] = useState<any[]>([])
    const [existingSlots, setExistingSlots] = useState<any[]>([])

    // Wizard selections
    const [selectedClass, setSelectedClass] = useState<any | null>(null)   // { id, name }
    const [selectedRoom, setSelectedRoom] = useState<any | null>(null)     // { id, name }
    const [subjects, setSubjects] = useState<any[]>([])                    // subjects for the selected class

    // Generation output
    const [generatedSlots, setGeneratedSlots] = useState<GeneratedSlot[]>([])
    const [conflicts, setConflicts] = useState<Conflict[]>([])

    // ── Initial load ──────────────────────────────────────────────────────────
    useEffect(() => {
        if (!session?.user) return
        ;(async () => {
            const { getProfile } = await import("@/app/actions/settings")
            const res = await getProfile((session.user as any).id)
            const cId = res.profile?.college_id ?? null
            const dId = (res.profile as any)?.department_id ?? null
            setCollegeId(cId); setDepartmentId(dId)

            if (cId && dId) {
                const [clsRes, rmRes, stfRes, slotRes] = await Promise.all([
                    getClasses(dId), getRooms(cId),
                    getStaff(cId, 'approved', 'faculty', dId),
                    getTimetableSlots(dId),
                ])
                if (clsRes.classes) setAllClasses(clsRes.classes)
                if (rmRes.rooms) setAllRooms(rmRes.rooms)
                if (stfRes.staff) setAllStaff(stfRes.staff)
                if (slotRes.slots) setExistingSlots(slotRes.slots)
            }
            setLoading(false)
        })()
    }, [session])

    const loadSubjects = useCallback(async (classId: string) => {
        const res = await getSubjects(classId)
        if (res.subjects) setSubjects(res.subjects)
    }, [])

    const handleSaveAll = async () => {
        if (!selectedClass) return
        setGenState("saving")
        setError(null)
        try {
            await bulkDeleteSlotsByClass(selectedClass.id)
            for (const slot of generatedSlots) {
                const r = await createTimetableSlot(slot)
                if (r.error) throw new Error(r.error)
            }
            toast(`Timetable saved — ${generatedSlots.length} slots created!`, "success")
            router.push("/timetable")
        } catch (e: any) {
            setError(e.message); setGenState("preview")
        }
    }

    if (loading) return (
        <div className="flex flex-col items-center justify-center py-24 gap-4">
            <Loader2 className="w-10 h-10 animate-spin text-primary" />
            <p className="text-sm text-on-surface-variant">Loading…</p>
        </div>
    )

    return (
        <div className="max-w-4xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-10">
            <ToastContainer />

            {/* ── Header ── */}
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-on-surface">Timetable Setup Wizard</h1>
                <p className="text-on-surface-variant mt-1">
                    Set up everything from scratch — class → classroom → subjects → staff → generate.
                </p>
            </div>

            {/* ── Step Progress Bar ── */}
            <StepProgress current={step} />

            {/* ── Error ── */}
            {error && (
                <div className="p-3 rounded-xl bg-error-container border border-error/20 text-on-error-container text-sm flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4 shrink-0" />{error}
                </div>
            )}

            {/* ══ STEP 1: Select / Create Class ══ */}
            {step === 1 && (
                <Step1Class
                    classes={allClasses}
                    departmentId={departmentId!}
                    collegeId={collegeId!}
                    selectedClass={selectedClass}
                    onClassSelected={async (cls) => {
                        setSelectedClass(cls)
                        setSelectedRoom(null)
                        setSubjects([])
                        setGeneratedSlots([])
                        setConflicts([])
                        await loadSubjects(cls.id)
                    }}
                    onClassCreated={(cls) => setAllClasses(prev => [...prev, cls])}
                    onNext={() => setStep(2)}
                />
            )}

            {/* ══ STEP 2: Assign Classroom ══ */}
            {step === 2 && (
                <Step2Room
                    rooms={allRooms}
                    collegeId={collegeId!}
                    selectedRoom={selectedRoom}
                    className={selectedClass?.name ?? ""}
                    onRoomSelected={setSelectedRoom}
                    onRoomCreated={(r) => setAllRooms(prev => [...prev, r])}
                    onBack={() => setStep(1)}
                    onNext={() => setStep(3)}
                />
            )}

            {/* ══ STEP 3: Add Subjects ══ */}
            {step === 3 && (
                <Step3Subjects
                    subjects={subjects}
                    classId={selectedClass?.id ?? ""}
                    onSubjectsChange={setSubjects}
                    onBack={() => setStep(2)}
                    onNext={() => setStep(4)}
                />
            )}

            {/* ══ STEP 4: Assign Staff ══ */}
            {step === 4 && (
                <Step4Staff
                    subjects={subjects}
                    staff={allStaff}
                    onSubjectsChange={setSubjects}
                    onBack={() => setStep(3)}
                    onNext={() => {
                        setGenState("idle")
                        setGeneratedSlots([])
                        setConflicts([])
                        setStep(5)
                    }}
                />
            )}

            {/* ══ STEP 5: Generate & Save ══ */}
            {step === 5 && (
                <Step5Generate
                    subjects={subjects}
                    staff={allStaff}
                    rooms={allRooms}
                    classId={selectedClass?.id ?? ""}
                    className={selectedClass?.name ?? ""}
                    classRoomId={selectedRoom?.id ?? ""}
                    classRoomName={selectedRoom?.name ?? ""}
                    existingSlots={existingSlots}
                    genState={genState}
                    generatedSlots={generatedSlots}
                    conflicts={conflicts}
                    onGenerate={() => {
                        const seed = Date.now()
                        const result = runGeneration({
                            classId: selectedClass!.id,
                            classRoomId: selectedRoom?.id ?? "",
                            subjects, rooms: allRooms, existingSlots, seed
                        })
                        setGeneratedSlots(result.slots)
                        setConflicts(result.conflicts)
                        setGenState("preview")
                    }}
                    onRegenerate={() => {
                        const seed = Date.now()
                        const result = runGeneration({
                            classId: selectedClass!.id,
                            classRoomId: selectedRoom?.id ?? "",
                            subjects, rooms: allRooms, existingSlots, seed
                        })
                        setGeneratedSlots(result.slots)
                        setConflicts(result.conflicts)
                    }}
                    onSave={handleSaveAll}
                    onBack={() => setStep(4)}
                />
            )}
        </div>
    )
}

// ─── Step Progress ────────────────────────────────────────────────────────────
const STEPS = ["Class", "Classroom", "Subjects", "Staff", "Generate"]
function StepProgress({ current }: { current: WizardStep }) {
    return (
        <div className="flex items-center gap-0">
            {STEPS.map((label, i) => {
                const n = i + 1
                const done = current > n
                const active = current === n
                return (
                    <div key={n} className="flex items-center flex-1 last:flex-none">
                        <div className="flex flex-col items-center gap-1.5">
                            <div className={`w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold border-2 transition-all
                                ${done ? "bg-emerald-500 border-emerald-500 text-white"
                                : active ? "bg-primary border-primary text-on-primary"
                                : "bg-surface-container-high border-outline-variant text-on-surface-variant"}`}>
                                {done ? <CheckCircle2 className="w-4 h-4" /> : n}
                            </div>
                            <span className={`text-xs font-medium whitespace-nowrap ${active ? "text-primary" : done ? "text-emerald-600" : "text-on-surface-variant"}`}>
                                {label}
                            </span>
                        </div>
                        {i < STEPS.length - 1 && (
                            <div className={`flex-1 h-0.5 mx-2 mb-5 rounded-full transition-colors ${done ? "bg-emerald-400" : "bg-outline-variant"}`} />
                        )}
                    </div>
                )
            })}
        </div>
    )
}

// ─── Step 1: Class ────────────────────────────────────────────────────────────
function Step1Class({ classes, departmentId, selectedClass, onClassSelected, onClassCreated, onNext }: any) {
    const [isCreating, setIsCreating] = useState(false)
    const [newName, setNewName] = useState("")
    const [saving, setSaving] = useState(false)
    const [err, setErr] = useState<string | null>(null)

    const handleCreate = async () => {
        if (!newName.trim()) { setErr("Class name is required."); return }
        setSaving(true); setErr(null)
        const res = await createClass({ name: newName.trim(), departmentId })
        if (res.error) { setErr(res.error); setSaving(false); return }
        onClassCreated(res.class)
        onClassSelected(res.class)
        setIsCreating(false); setNewName(""); setSaving(false)
        toast("Class created!", "success")
    }

    return (
        <StepCard
            icon={<Users className="w-5 h-5 text-primary" />}
            title="Step 1 — Select or Create a Class"
            description="Choose an existing class, or create a new one for this department."
        >
            {/* Existing classes */}
            {classes.length > 0 && (
                <div className="space-y-2">
                    <p className="text-sm font-semibold text-on-surface">Existing Classes</p>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                        {classes.map((cls: any) => (
                            <button
                                key={cls.id}
                                onClick={() => onClassSelected(cls)}
                                className={`text-left p-4 rounded-xl border-2 transition-all font-medium text-sm
                                    ${selectedClass?.id === cls.id
                                        ? "border-primary bg-primary/5 text-primary"
                                        : "border-outline-variant hover:border-primary/30 hover:bg-surface-container-low text-on-surface"
                                    }`}
                            >
                                <div className="flex items-center justify-between">
                                    <span>{cls.name}</span>
                                    {selectedClass?.id === cls.id && <CheckCircle2 className="w-4 h-4 text-primary" />}
                                </div>
                            </button>
                        ))}
                    </div>
                </div>
            )}

            {/* Divider */}
            {classes.length > 0 && <Divider label="or" />}

            {/* Create new */}
            {isCreating ? (
                <div className="space-y-3 p-4 rounded-xl border border-primary/30 bg-primary/5">
                    <p className="text-sm font-semibold text-on-surface">New Class Name</p>
                    <Input
                        id="new-class-name"
                        placeholder="e.g. Year 2 — Section A"
                        value={newName}
                        onChange={e => setNewName(e.target.value)}
                        onKeyDown={e => e.key === "Enter" && handleCreate()}
                        autoFocus
                    />
                    {err && <p className="text-xs text-error">{err}</p>}
                    <div className="flex gap-2">
                        <Button variant="outline" onClick={() => setIsCreating(false)} disabled={saving}>Cancel</Button>
                        <Button className="bg-primary text-on-primary hover:bg-primary/90" onClick={handleCreate} disabled={saving}>
                            {saving ? <Loader2 className="w-4 h-4 mr-1 animate-spin" /> : <Plus className="w-4 h-4 mr-1" />}
                            Create Class
                        </Button>
                    </div>
                </div>
            ) : (
                <button
                    className="w-full py-3 rounded-xl border-2 border-dashed border-outline-variant hover:border-primary/40 hover:bg-surface-container-low text-on-surface-variant hover:text-primary text-sm font-medium flex items-center justify-center gap-2 transition-all"
                    onClick={() => setIsCreating(true)}
                >
                    <Plus className="w-4 h-4" /> Create New Class
                </button>
            )}

            <StepFooter
                onNext={onNext}
                nextDisabled={!selectedClass}
                nextLabel="Next: Assign Classroom →"
            />
        </StepCard>
    )
}

// ─── Step 2: Classroom ────────────────────────────────────────────────────────
function Step2Room({ rooms, collegeId, selectedRoom, className, onRoomSelected, onRoomCreated, onBack, onNext }: any) {
    const [isCreating, setIsCreating] = useState(false)
    const [newName, setNewName] = useState("")
    const [saving, setSaving] = useState(false)
    const [err, setErr] = useState<string | null>(null)

    const handleCreate = async () => {
        if (!newName.trim()) { setErr("Room name is required."); return }
        setSaving(true); setErr(null)
        const res = await createRoom({ name: newName.trim(), collegeId })
        if (res.error) { setErr(res.error); setSaving(false); return }
        onRoomCreated(res.room)
        onRoomSelected(res.room)
        setIsCreating(false); setNewName(""); setSaving(false)
        toast("Room created!", "success")
    }

    return (
        <StepCard
            icon={<MapPin className="w-5 h-5 text-primary" />}
            title="Step 2 — Assign a Fixed Classroom"
            description={`Select the classroom permanently assigned to ${className}. All periods for this class will be scheduled in this room by default.`}
        >
            {/* Room list */}
            {rooms.length > 0 && (
                <div className="space-y-2">
                    <p className="text-sm font-semibold text-on-surface">Available Rooms</p>
                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
                        {rooms.map((r: any) => (
                            <button
                                key={r.id}
                                onClick={() => onRoomSelected(r)}
                                className={`text-left p-4 rounded-xl border-2 transition-all text-sm font-medium
                                    ${selectedRoom?.id === r.id
                                        ? "border-primary bg-primary/5 text-primary"
                                        : "border-outline-variant hover:border-primary/30 hover:bg-surface-container-low text-on-surface"
                                    }`}
                            >
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center gap-2">
                                        <MapPin className="w-3.5 h-3.5 shrink-0 opacity-50" />
                                        {r.name}
                                    </div>
                                    {selectedRoom?.id === r.id && <CheckCircle2 className="w-4 h-4 text-primary" />}
                                </div>
                            </button>
                        ))}
                    </div>
                </div>
            )}

            {rooms.length > 0 && <Divider label="or create a new room" />}

            {isCreating ? (
                <div className="space-y-3 p-4 rounded-xl border border-primary/30 bg-primary/5">
                    <p className="text-sm font-semibold text-on-surface">New Room Name</p>
                    <Input
                        id="new-room-name"
                        placeholder="e.g. Room 301, CS Lab 1"
                        value={newName}
                        onChange={e => setNewName(e.target.value)}
                        onKeyDown={e => e.key === "Enter" && handleCreate()}
                        autoFocus
                    />
                    {err && <p className="text-xs text-error">{err}</p>}
                    <div className="flex gap-2">
                        <Button variant="outline" onClick={() => setIsCreating(false)} disabled={saving}>Cancel</Button>
                        <Button className="bg-primary text-on-primary hover:bg-primary/90" onClick={handleCreate} disabled={saving}>
                            {saving ? <Loader2 className="w-4 h-4 mr-1 animate-spin" /> : <Plus className="w-4 h-4 mr-1" />}
                            Add Room
                        </Button>
                    </div>
                </div>
            ) : (
                <button
                    className="w-full py-3 rounded-xl border-2 border-dashed border-outline-variant hover:border-primary/40 hover:bg-surface-container-low text-on-surface-variant hover:text-primary text-sm font-medium flex items-center justify-center gap-2 transition-all"
                    onClick={() => setIsCreating(true)}
                >
                    <Plus className="w-4 h-4" /> Add New Room
                </button>
            )}

            {/* Skip notice */}
            <p className="text-xs text-on-surface-variant text-center">
                No fixed room? You can skip — the generator will pick any free room per slot.
            </p>

            <StepFooter
                onBack={onBack}
                onNext={onNext}
                nextDisabled={false}
                nextLabel="Next: Add Subjects →"
                onSkip={() => { onRoomSelected(null); onNext() }}
                skipLabel="Skip (no fixed room)"
            />
        </StepCard>
    )
}

// ─── Step 3: Subjects ─────────────────────────────────────────────────────────
function Step3Subjects({ subjects, classId, onSubjectsChange, onBack, onNext }: any) {
    const [form, setForm] = useState({ name: "", code: "", hoursPerWeek: 3 })
    const [saving, setSaving] = useState(false)
    const [deleting, setDeleting] = useState<string | null>(null)
    const [err, setErr] = useState<string | null>(null)
    const [editId, setEditId] = useState<string | null>(null)
    const [editHours, setEditHours] = useState(3)

    const handleAdd = async () => {
        if (!form.name.trim()) { setErr("Subject name is required."); return }
        setSaving(true); setErr(null)
        const res = await createSubject({ name: form.name.trim(), code: form.code.trim(), classId, hoursPerWeek: form.hoursPerWeek })
        if (res.error) { setErr(res.error); setSaving(false); return }
        onSubjectsChange((prev: any[]) => [...prev, res.subject])
        setForm({ name: "", code: "", hoursPerWeek: 3 }); setSaving(false)
        toast("Subject added!", "success")
    }

    const handleDelete = async (id: string) => {
        setDeleting(id)
        await deleteSubject(id)
        onSubjectsChange((prev: any[]) => prev.filter(s => s.id !== id))
        setDeleting(null)
        toast("Subject removed.", "success")
    }

    const handleEditHours = async (id: string) => {
        await updateSubject(id, { hoursPerWeek: editHours })
        onSubjectsChange((prev: any[]) => prev.map(s => s.id === id ? { ...s, hoursPerWeek: editHours } : s))
        setEditId(null)
        toast("Hours updated.", "success")
    }

    return (
        <StepCard
            icon={<BookOpen className="w-5 h-5 text-primary" />}
            title="Step 3 — Add Subjects"
            description="Add all subjects for this class with their weekly period count."
        >
            {/* Add form */}
            <div className="p-4 rounded-xl border border-outline-variant bg-surface-container-low space-y-3">
                <p className="text-sm font-semibold text-on-surface">Add a Subject</p>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div className="sm:col-span-1 space-y-1">
                        <label className="text-xs font-medium text-on-surface-variant">Subject Name *</label>
                        <Input
                            id="subject-name"
                            placeholder="e.g. Data Structures"
                            value={form.name}
                            onChange={e => setForm(p => ({ ...p, name: e.target.value }))}
                            onKeyDown={e => e.key === "Enter" && handleAdd()}
                        />
                    </div>
                    <div className="space-y-1">
                        <label className="text-xs font-medium text-on-surface-variant flex items-center gap-1"><Hash className="w-3 h-3" />Code</label>
                        <Input
                            id="subject-code"
                            placeholder="e.g. CS201"
                            value={form.code}
                            onChange={e => setForm(p => ({ ...p, code: e.target.value }))}
                        />
                    </div>
                    <div className="space-y-1">
                        <label className="text-xs font-medium text-on-surface-variant flex items-center gap-1"><Clock className="w-3 h-3" />Periods / Week</label>
                        <Input
                            id="subject-hours"
                            type="number"
                            min={1} max={7}
                            value={form.hoursPerWeek}
                            onChange={e => setForm(p => ({ ...p, hoursPerWeek: Number(e.target.value) }))}
                        />
                    </div>
                </div>
                {err && <p className="text-xs text-error">{err}</p>}
                <Button
                    id="btn-add-subject"
                    className="bg-primary text-on-primary hover:bg-primary/90"
                    onClick={handleAdd}
                    disabled={saving}
                >
                    {saving ? <Loader2 className="w-4 h-4 mr-1 animate-spin" /> : <Plus className="w-4 h-4 mr-1" />}
                    Add Subject
                </Button>
            </div>

            {/* Subject list */}
            {subjects.length > 0 ? (
                <div className="space-y-2">
                    <p className="text-sm font-semibold text-on-surface">{subjects.length} Subject{subjects.length > 1 ? "s" : ""} Added</p>
                    <div className="divide-y divide-outline-variant border border-outline-variant rounded-xl overflow-hidden">
                        {subjects.map((s: any) => (
                            <div key={s.id} className="flex items-center justify-between px-4 py-3 hover:bg-surface-container-low transition-colors">
                                <div className="flex items-center gap-3">
                                    <div className={`w-2 h-2 rounded-full ${colorForSubject(s.id).border.replace("border-", "bg-")}`} />
                                    <div>
                                        <p className="text-sm font-semibold text-on-surface">{s.name}</p>
                                        {s.code && <p className="text-xs text-on-surface-variant">{s.code}</p>}
                                    </div>
                                </div>
                                <div className="flex items-center gap-3">
                                    {editId === s.id ? (
                                        <div className="flex items-center gap-1.5">
                                            <input
                                                type="number" min={1} max={7}
                                                className="w-14 h-8 rounded-lg border border-primary px-2 text-sm text-center focus:outline-none"
                                                value={editHours}
                                                onChange={e => setEditHours(Number(e.target.value))}
                                            />
                                            <button onClick={() => handleEditHours(s.id)} className="text-xs font-medium text-primary hover:underline">Save</button>
                                            <button onClick={() => setEditId(null)} className="text-xs text-on-surface-variant hover:underline">Cancel</button>
                                        </div>
                                    ) : (
                                        <button
                                            className="text-xs font-semibold px-2.5 py-1 rounded-full bg-surface-container border border-outline-variant text-on-surface hover:border-primary/40 transition-colors flex items-center gap-1"
                                            onClick={() => { setEditId(s.id); setEditHours(s.hoursPerWeek || 3) }}
                                            title="Edit periods per week"
                                        >
                                            <Clock className="w-3 h-3" />
                                            {s.hoursPerWeek || 3} periods/wk
                                            <Pencil className="w-2.5 h-2.5 opacity-50" />
                                        </button>
                                    )}
                                    <button
                                        className="p-1.5 rounded-lg text-on-surface-variant hover:text-error hover:bg-error/10 transition-colors"
                                        onClick={() => handleDelete(s.id)}
                                        disabled={deleting === s.id}
                                    >
                                        {deleting === s.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 className="w-4 h-4" />}
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            ) : (
                <div className="py-10 flex flex-col items-center gap-2 text-on-surface-variant">
                    <BookOpen className="w-9 h-9 opacity-20" />
                    <p className="text-sm">No subjects added yet. Add at least one above.</p>
                </div>
            )}

            <StepFooter
                onBack={onBack}
                onNext={onNext}
                nextDisabled={subjects.length === 0}
                nextLabel="Next: Assign Staff →"
            />
        </StepCard>
    )
}

// ─── Step 4: Staff ────────────────────────────────────────────────────────────
function Step4Staff({ subjects, staff, onSubjectsChange, onBack, onNext }: any) {
    const [saving, setSaving] = useState<string | null>(null)

    const handleAssign = async (subjectId: string, staffId: string | null) => {
        setSaving(subjectId)
        await updateSubjectStaff(subjectId, staffId)
        onSubjectsChange((prev: any[]) => prev.map(s => s.id === subjectId ? { ...s, staffId } : s))
        setSaving(null)
    }

    const ready = subjects.filter((s: any) => s.staffId).length
    const total = subjects.length

    return (
        <StepCard
            icon={<UserRound className="w-5 h-5 text-primary" />}
            title="Step 4 — Assign Faculty to Each Subject"
            description="Each subject needs a faculty member. The generator will use these assignments when scheduling."
        >
            {/* Progress bar */}
            <div className="space-y-1">
                <div className="flex justify-between text-xs text-on-surface-variant">
                    <span>{ready} / {total} subjects assigned</span>
                    <span>{Math.round(ready / Math.max(total, 1) * 100)}%</span>
                </div>
                <div className="h-2 rounded-full bg-surface-container-highest overflow-hidden">
                    <div className="h-full bg-primary rounded-full transition-all" style={{ width: `${ready / Math.max(total, 1) * 100}%` }} />
                </div>
            </div>

            {/* Assignment rows */}
            <div className="divide-y divide-outline-variant border border-outline-variant rounded-xl overflow-hidden">
                {subjects.map((s: any) => {
                    const assigned = staff.find((st: any) => st.id === s.staffId)
                    return (
                        <div key={s.id} className="flex items-center justify-between px-4 py-3.5 gap-4 hover:bg-surface-container-low transition-colors">
                            <div className="flex items-center gap-3 flex-1 min-w-0">
                                <span className={`w-2 h-2 rounded-full shrink-0 ${s.staffId ? "bg-emerald-500" : "bg-amber-400"}`} />
                                <div className="min-w-0">
                                    <p className="text-sm font-semibold text-on-surface truncate">{s.name}</p>
                                    {s.code && <p className="text-xs text-on-surface-variant">{s.code} · {s.hoursPerWeek || 3} periods/wk</p>}
                                </div>
                            </div>
                            <div className="flex items-center gap-2 shrink-0">
                                {saving === s.id && <Loader2 className="w-3.5 h-3.5 animate-spin text-primary" />}
                                <select
                                    className="h-9 rounded-xl border border-outline-variant bg-surface-container-low px-3 text-sm text-on-surface focus:outline-none focus:ring-2 focus:ring-primary/30 min-w-[180px]"
                                    value={s.staffId || ""}
                                    onChange={e => handleAssign(s.id, e.target.value || null)}
                                    disabled={saving === s.id}
                                >
                                    <option value="">— Assign Faculty —</option>
                                    {staff.map((st: any) => (
                                        <option key={st.id} value={st.id}>{st.first_name} {st.last_name}</option>
                                    ))}
                                </select>
                            </div>
                        </div>
                    )
                })}
            </div>

            {ready < total && (
                <div className="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4 shrink-0 text-amber-500" />
                    {total - ready} subject{total - ready > 1 ? "s" : ""} without faculty will be skipped during generation.
                </div>
            )}

            <StepFooter
                onBack={onBack}
                onNext={onNext}
                nextDisabled={ready === 0}
                nextLabel="Next: Generate Timetable →"
            />
        </StepCard>
    )
}

// ─── Step 5: Generate & Save ──────────────────────────────────────────────────
function Step5Generate({ subjects, staff, rooms, classId, className, classRoomId, classRoomName, existingSlots, genState, generatedSlots, conflicts, onGenerate, onRegenerate, onSave, onBack }: any) {
    const readyCount = subjects.filter((s: any) => s.staffId).length
    const totalPeriods = subjects.filter((s: any) => s.staffId).reduce((sum: number, s: any) => sum + (s.hoursPerWeek || 3), 0)

    return (
        <StepCard
            icon={<Sparkles className="w-5 h-5 text-primary" />}
            title="Step 5 — Generate Timetable"
            description="Review your configuration and generate a conflict-free weekly timetable automatically."
        >
            {genState === "idle" && (
                <>
                    {/* Summary */}
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                        <SummaryBadge icon={Users} label="Class" value={className} />
                        <SummaryBadge icon={MapPin} label="Classroom" value={classRoomName || "Auto-assign"} />
                        <SummaryBadge icon={BookOpen} label="Subjects" value={`${readyCount} ready`} />
                        <SummaryBadge icon={Clock} label="Total Periods" value={`${totalPeriods}/week`} />
                    </div>

                    <div className="flex justify-center pt-4">
                        <Button
                            id="btn-generate"
                            className="bg-primary hover:bg-primary/90 text-on-primary px-10 py-6 text-base font-bold shadow-xl shadow-primary/20 gap-2"
                            onClick={onGenerate}
                            disabled={readyCount === 0}
                        >
                            <Sparkles className="w-5 h-5" />
                            Generate Timetable
                        </Button>
                    </div>

                    <StepFooter onBack={onBack} nextDisabled />
                </>
            )}

            {(genState === "preview" || genState === "saving") && (
                <>
                    {/* Result banners */}
                    {conflicts.length === 0 ? (
                        <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm flex items-start gap-3">
                            <CheckCircle2 className="w-5 h-5 text-emerald-500 shrink-0 mt-0.5" />
                            <div>
                                <p className="font-bold">All {generatedSlots.length} slots generated — zero conflicts!</p>
                                <p className="text-emerald-700 mt-0.5 text-xs">Every subject's periods are placed without any staff or room clashes.</p>
                            </div>
                        </div>
                    ) : (
                        <div className="p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm flex items-start gap-3">
                            <AlertTriangle className="w-5 h-5 text-amber-500 shrink-0 mt-0.5" />
                            <div>
                                <p className="font-bold">{generatedSlots.length} slots generated · {conflicts.length} conflict{conflicts.length > 1 ? "s" : ""}</p>
                                <ul className="mt-1 space-y-0.5 text-amber-700 text-xs">
                                    {conflicts.map((c: Conflict, i: number) => (
                                        <li key={i}>{c.subjectName}: {c.periodsScheduled}/{c.periodsNeeded} periods — {c.reason}</li>
                                    ))}
                                </ul>
                                <p className="mt-1.5 text-amber-600 text-xs">Try Regenerate or reduce hours/week for conflicting subjects.</p>
                            </div>
                        </div>
                    )}

                    {/* Timetable grid preview */}
                    <PreviewGrid generatedSlots={generatedSlots} subjects={subjects} staff={staff} rooms={rooms} />

                    {/* Legend */}
                    <div className="flex items-center gap-3 flex-wrap text-xs text-on-surface-variant">
                        <span className="font-semibold text-on-surface">Legend:</span>
                        {subjects.filter((s: any) => s.staffId).map((s: any) => {
                            const c = colorForSubject(s.id)
                            return (
                                <span key={s.id} className={`px-2.5 py-0.5 rounded-full border ${c.border} ${c.bg} ${c.text} font-medium`}>
                                    {s.name}
                                </span>
                            )
                        })}
                    </div>

                    {/* Action buttons */}
                    <div className="flex items-center justify-between gap-3 flex-wrap pt-2">
                        <Button variant="outline" onClick={onBack} disabled={genState === "saving"}>← Back</Button>
                        <div className="flex gap-3">
                            <Button variant="outline" className="gap-2" onClick={onRegenerate} disabled={genState === "saving"}>
                                <RotateCcw className="w-4 h-4" /> Regenerate
                            </Button>
                            <Button
                                id="btn-save"
                                className="bg-primary hover:bg-primary/90 text-on-primary px-6 gap-2 shadow-lg shadow-primary/20"
                                onClick={onSave}
                                disabled={genState === "saving" || generatedSlots.length === 0}
                            >
                                {genState === "saving" ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                                {genState === "saving" ? "Saving…" : `Save Timetable (${generatedSlots.length} slots)`}
                            </Button>
                        </div>
                    </div>
                </>
            )}
        </StepCard>
    )
}

// ─── Preview Grid ──────────────────────────────────────────────────────────────
function PreviewGrid({ generatedSlots, subjects, staff, rooms }: any) {
    return (
        <Card className="overflow-hidden">
            <CardContent className="p-0 overflow-auto">
                <div className="min-w-[660px]">
                    <div className="grid grid-cols-6 border-b border-outline-variant bg-surface-container-low sticky top-0 z-10">
                        <div className="p-3 text-center text-xs font-semibold text-on-surface-variant border-r border-outline-variant uppercase tracking-wider">Time</div>
                        {WORKING_DAYS.map(d => (
                            <div key={d} className="p-3 text-center text-sm font-semibold text-on-surface border-r border-outline-variant last:border-0">{d}</div>
                        ))}
                    </div>
                    <div className="divide-y divide-outline-variant">
                        {ALL_DISPLAY_TIMES.map(time => {
                            const isLunch = time === "12:00 PM"
                            return (
                                <div key={time} className={`grid grid-cols-6 ${isLunch ? "bg-amber-50/40" : ""}`}>
                                    <div className={`p-2.5 text-center text-xs font-medium border-r border-outline-variant flex flex-col items-center justify-center gap-0.5
                                        ${isLunch ? "text-amber-600 bg-amber-50" : "text-on-surface-variant bg-surface-container-low"}`}>
                                        {isLunch && <Coffee className="w-3 h-3 text-amber-400" />}
                                        {time}
                                        {isLunch && <span className="text-[10px] text-amber-400">Lunch</span>}
                                    </div>
                                    {WORKING_DAYS.map(day => {
                                        const slot = generatedSlots.find((s: any) => s.day === day && s.time === time)
                                        const color = slot ? colorForSubject(slot.subjectId) : null
                                        const subject = slot ? subjects.find((s: any) => s.id === slot.subjectId) : null
                                        const staffMember = slot ? staff.find((s: any) => s.id === slot.staffId) : null
                                        const room = slot ? rooms.find((r: any) => r.id === slot.roomId) : null
                                        return (
                                            <div key={`${day}-${time}`} className="p-1.5 border-r border-outline-variant last:border-0 min-h-[82px]">
                                                {slot ? (
                                                    <div className={`h-full rounded-lg border ${color!.border} ${color!.bg} p-2 flex flex-col gap-0.5 shadow-sm`}>
                                                        <p className={`text-xs font-bold leading-tight ${color!.text}`}>{subject?.name}</p>
                                                        {staffMember && <p className="text-[10px] text-on-surface-variant">{staffMember.first_name} {staffMember.last_name}</p>}
                                                        {room && <p className="text-[10px] text-on-surface-variant mt-auto">{room.name}</p>}
                                                    </div>
                                                ) : isLunch ? (
                                                    <div className="h-full flex items-center justify-center"><span className="text-[10px] text-amber-300">—</span></div>
                                                ) : (
                                                    <div className="h-full min-h-[65px] rounded-lg border-2 border-dashed border-outline-variant/20" />
                                                )}
                                            </div>
                                        )
                                    })}
                                </div>
                            )
                        })}
                    </div>
                </div>
            </CardContent>
        </Card>
    )
}

// ─── Shared components ────────────────────────────────────────────────────────
function StepCard({ icon, title, description, children }: { icon: React.ReactNode; title: string; description: string; children: React.ReactNode }) {
    return (
        <Card className="overflow-hidden">
            <CardHeader className="border-b border-outline-variant bg-surface-container-low pb-4">
                <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center">{icon}</div>
                    <div>
                        <CardTitle className="text-base">{title}</CardTitle>
                        <p className="text-xs text-on-surface-variant mt-0.5">{description}</p>
                    </div>
                </div>
            </CardHeader>
            <CardContent className="p-6 space-y-6">{children}</CardContent>
        </Card>
    )
}

function StepFooter({ onBack, onNext, nextDisabled, nextLabel = "Next →", onSkip, skipLabel }: any) {
    return (
        <div className="flex items-center justify-between pt-2 border-t border-outline-variant">
            {onBack ? (
                <Button variant="outline" onClick={onBack}>← Back</Button>
            ) : <div />}
            <div className="flex gap-3">
                {onSkip && (
                    <Button variant="outline" onClick={onSkip} className="text-on-surface-variant">
                        {skipLabel}
                    </Button>
                )}
                {onNext && (
                    <Button
                        className="bg-primary hover:bg-primary/90 text-on-primary"
                        onClick={onNext}
                        disabled={nextDisabled}
                    >
                        {nextLabel}
                    </Button>
                )}
            </div>
        </div>
    )
}

function Divider({ label }: { label: string }) {
    return (
        <div className="flex items-center gap-3">
            <div className="flex-1 h-px bg-outline-variant" />
            <span className="text-xs text-on-surface-variant">{label}</span>
            <div className="flex-1 h-px bg-outline-variant" />
        </div>
    )
}

function SummaryBadge({ icon: Icon, label, value }: { icon: any; label: string; value: string }) {
    return (
        <div className="p-4 rounded-xl border border-outline-variant bg-surface-container-lowest">
            <div className="flex items-center gap-2 mb-2">
                <Icon className="w-4 h-4 text-primary" />
                <span className="text-xs font-medium text-on-surface-variant">{label}</span>
            </div>
            <p className="text-sm font-bold text-on-surface">{value}</p>
        </div>
    )
}
