"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import {
    Loader2, AlertTriangle, Sparkles, CheckCircle2, XCircle,
    RotateCcw, Save, Coffee, BookOpen, Clock, ChevronRight,
    Users, MapPin
} from "lucide-react"
import { useSession } from "next-auth/react"
import { useRouter } from "next/navigation"
import {
    getClasses, getSubjects, getRooms, getTimetableSlots,
    createTimetableSlot, deleteTimetableSlot
} from "@/app/actions/timetable"
import { getStaff } from "@/app/actions/staff"
import { toast, ToastContainer } from "@/components/ui/Toast"

// ─── Constants ───────────────────────────────────────────────────────────────

const WORKING_DAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
const SCHEDULABLE_TIMES = ["09:00 AM", "10:00 AM", "11:00 AM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"]
const ALL_TIMES = ["09:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"]

// ─── Types ────────────────────────────────────────────────────────────────────

interface GeneratedSlot {
    day: string
    time: string
    classId: string
    subjectId: string
    staffId: string
    roomId: string
}

interface Conflict {
    subjectName: string
    periodsNeeded: number
    periodsScheduled: number
    reason: string
}

type PageState = "loading" | "configure" | "preview" | "saving"

// ─── Colour helper ────────────────────────────────────────────────────────────

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
    let h = 0
    for (const c of id) h = (h * 31 + c.charCodeAt(0)) >>> 0
    return COLORS[h % COLORS.length]
}

// ─── Generation Algorithm ─────────────────────────────────────────────────────

/**
 * Deterministic Fisher-Yates shuffle seeded by a number.
 * Returns a new array — never mutates the input.
 */
function seededShuffle<T>(arr: T[], seed: number): T[] {
    const a = [...arr]
    let s = seed | 0
    for (let i = a.length - 1; i > 0; i--) {
        s = Math.imul(s ^ (s >>> 15), s | 1) ^ (s + Math.imul(s ^ (s >>> 7), s | 61))
        const j = ((s >>> 0) % (i + 1))
        ;[a[i], a[j]] = [a[j], a[i]]
    }
    return a
}

function runGeneration(params: {
    classId: string
    subjects: any[]
    rooms: any[]
    existingSlots: any[]
    seed: number
}): { slots: GeneratedSlot[]; conflicts: Conflict[] } {
    const { classId, subjects, rooms, existingSlots, seed } = params

    // Bookings: "staffId|day|time", "roomId|day|time", "classId|day|time"
    const staffBooked = new Set<string>()
    const roomBooked = new Set<string>()
    const classBooked = new Set<string>()

    // Pre-load bookings from OTHER classes' existing slots
    for (const s of existingSlots) {
        if (s.classId !== classId) {
            staffBooked.add(`${s.staffId}|${s.day}|${s.time}`)
            roomBooked.add(`${s.roomId}|${s.day}|${s.time}`)
        }
        // Don't pre-load this class's own slots — they'll be cleared on save
    }

    const generated: GeneratedSlot[] = []
    const conflicts: Conflict[] = []

    // Build a shuffled pool of all (day, time) combinations
    const allSlotCombos: [string, string][] = []
    for (const day of WORKING_DAYS) {
        for (const time of SCHEDULABLE_TIMES) {
            allSlotCombos.push([day, time])
        }
    }

    // Sort subjects: most hours first (harder to place → schedule early)
    const readySubjects = subjects
        .filter(s => s.staffId)
        .sort((a, b) => (b.hoursPerWeek || 3) - (a.hoursPerWeek || 3))

    for (let si = 0; si < readySubjects.length; si++) {
        const subject = readySubjects[si]
        const needed = Math.min(subject.hoursPerWeek || 3, WORKING_DAYS.length * SCHEDULABLE_TIMES.length)
        let scheduled = 0

        // Each subject gets a slightly different shuffle so periods spread across the week
        const shuffled = seededShuffle(allSlotCombos, seed + si * 997)

        for (const [day, time] of shuffled) {
            if (scheduled >= needed) break

            const classKey = `${classId}|${day}|${time}`
            const staffKey = `${subject.staffId}|${day}|${time}`

            if (classBooked.has(classKey)) continue
            if (staffBooked.has(staffKey)) continue

            // Find first free room
            const freeRoom = rooms.find(r => !roomBooked.has(`${r.id}|${day}|${time}`))
            if (!freeRoom) continue

            // ✅ Assign
            generated.push({ day, time, classId, subjectId: subject.id, staffId: subject.staffId, roomId: freeRoom.id })
            classBooked.add(classKey)
            staffBooked.add(staffKey)
            roomBooked.add(`${freeRoom.id}|${day}|${time}`)
            scheduled++
        }

        if (scheduled < needed) {
            conflicts.push({
                subjectName: subject.name,
                periodsNeeded: needed,
                periodsScheduled: scheduled,
                reason: scheduled === 0 ? "No available slots found" : "Grid too full — try reducing hours/week",
            })
        }
    }

    return { slots: generated, conflicts }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

export default function TimetableSchedulePage() {
    const { data: session } = useSession()
    const router = useRouter()

    const [pageState, setPageState] = useState<PageState>("loading")
    const [error, setError] = useState<string | null>(null)

    const [collegeId, setCollegeId] = useState<string | null>(null)
    const [departmentId, setDepartmentId] = useState<string | null>(null)
    const [classes, setClasses] = useState<any[]>([])
    const [subjects, setSubjects] = useState<any[]>([])
    const [staff, setStaff] = useState<any[]>([])
    const [rooms, setRooms] = useState<any[]>([])
    const [existingSlots, setExistingSlots] = useState<any[]>([])
    const [selectedClass, setSelectedClass] = useState<string>("")

    const [generatedSlots, setGeneratedSlots] = useState<GeneratedSlot[]>([])
    const [conflicts, setConflicts] = useState<Conflict[]>([])

    useEffect(() => {
        if (!session?.user) return
        async function load() {
            const { getProfile } = await import("@/app/actions/settings")
            const result = await getProfile((session!.user as any).id)
            if (result.profile?.college_id) {
                const cId = result.profile.college_id
                const dId = (result.profile as any).department_id || null
                setCollegeId(cId)
                setDepartmentId(dId)

                if (dId) {
                    const [clsRes, rmRes, stfRes, slotRes] = await Promise.all([
                        getClasses(dId),
                        getRooms(cId),
                        getStaff(cId, 'approved', 'faculty', dId),
                        getTimetableSlots(dId),
                    ])

                    if (clsRes.classes && clsRes.classes.length > 0) {
                        setClasses(clsRes.classes)
                        const firstId = clsRes.classes[0].id
                        setSelectedClass(firstId)
                        const subRes = await getSubjects(firstId)
                        if (subRes.subjects) setSubjects(subRes.subjects)
                    }
                    if (rmRes.rooms) setRooms(rmRes.rooms)
                    if (stfRes.staff) setStaff(stfRes.staff)
                    if (slotRes.slots) setExistingSlots(slotRes.slots)
                }
            }
            setPageState("configure")
        }
        load()
    }, [session])

    const handleClassChange = async (classId: string) => {
        setSelectedClass(classId)
        setGeneratedSlots([])
        setConflicts([])
        setPageState("configure")
        const subRes = await getSubjects(classId)
        if (subRes.subjects) setSubjects(subRes.subjects)
    }

    const handleGenerate = () => {
        const seed = Date.now()
        const result = runGeneration({ classId: selectedClass, subjects, rooms, existingSlots, seed })
        setGeneratedSlots(result.slots)
        setConflicts(result.conflicts)
        setPageState("preview")
    }

    const handleSave = async () => {
        setPageState("saving")
        setError(null)
        try {
            // Clear this class's existing slots before saving new ones
            const existing = existingSlots.filter(s => s.classId === selectedClass)
            for (const s of existing) await deleteTimetableSlot(s.id)

            // Bulk-create all generated slots
            for (const slot of generatedSlots) await createTimetableSlot(slot)

            toast(`Timetable saved — ${generatedSlots.length} slots created!`, "success")
            router.push("/timetable")
        } catch (err: any) {
            setError(err.message || "Failed to save timetable.")
            setPageState("preview")
        }
    }

    if (pageState === "loading") {
        return (
            <div className="flex flex-col items-center justify-center py-24 gap-4">
                <Loader2 className="w-10 h-10 animate-spin text-primary" />
                <p className="text-sm text-on-surface-variant">Loading data…</p>
            </div>
        )
    }

    const readySubjects = subjects.filter(s => s.staffId)
    const missingStaffSubjects = subjects.filter(s => !s.staffId)
    const totalHours = readySubjects.reduce((sum, s) => sum + (s.hoursPerWeek || 3), 0)
    const canGenerate = readySubjects.length > 0 && rooms.length > 0

    return (
        <div className="max-w-6xl mx-auto space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <ToastContainer />

            {/* ── Header ── */}
            <div className="flex items-center justify-between flex-wrap gap-3">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-on-surface">Auto-Generate Timetable</h1>
                    <p className="text-on-surface-variant mt-1">
                        Configure subjects &amp; staff, then generate a conflict-free schedule automatically.
                    </p>
                </div>
                <div className="flex items-center gap-3">
                    <label className="text-sm font-medium text-on-surface-variant">Class:</label>
                    <select
                        id="class-selector"
                        className="h-10 rounded-lg border border-outline-variant bg-surface-container-lowest px-3 py-2 text-sm text-on-surface shadow-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                        value={selectedClass}
                        onChange={e => handleClassChange(e.target.value)}
                    >
                        {classes.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                    </select>
                </div>
            </div>

            {/* ── Step indicator ── */}
            <div className="flex items-center gap-2 text-sm flex-wrap">
                <StepBadge n={1} label="Configure" active={pageState === "configure"} done={pageState !== "configure"} />
                <ChevronRight className="w-4 h-4 text-on-surface-variant/40" />
                <StepBadge n={2} label="Review Generated Timetable" active={pageState === "preview"} done={pageState === "saving"} />
                <ChevronRight className="w-4 h-4 text-on-surface-variant/40" />
                <StepBadge n={3} label="Save" active={pageState === "saving"} done={false} />
            </div>

            {error && (
                <div className="p-3 rounded-xl bg-error-container border border-error/20 text-on-error-container text-sm flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4 shrink-0" />{error}
                </div>
            )}

            {/* ══════════════════ STEP 1: CONFIGURE ══════════════════ */}
            {pageState === "configure" && (
                <div className="space-y-5">
                    {/* Stats strip */}
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                        <StatCard icon={BookOpen} value={subjects.length} label="Subjects" color="text-blue-600 bg-blue-50" />
                        <StatCard icon={CheckCircle2} value={readySubjects.length} label="Ready to schedule" color="text-emerald-600 bg-emerald-50" />
                        <StatCard icon={Clock} value={totalHours} label="Total periods / week" color="text-violet-600 bg-violet-50" />
                        <StatCard icon={MapPin} value={rooms.length} label="Rooms available" color="text-amber-600 bg-amber-50" />
                    </div>

                    {/* Subject table */}
                    <Card>
                        <CardHeader className="pb-3">
                            <CardTitle className="text-base">Subject Readiness</CardTitle>
                            <p className="text-sm text-on-surface-variant">
                                Each subject needs a faculty assignment and hours/week. Manage these in{" "}
                                <strong>Manage Data → Subjects</strong>.
                            </p>
                        </CardHeader>
                        <CardContent className="p-0">
                            {subjects.length === 0 ? (
                                <div className="py-14 flex flex-col items-center gap-3 text-center text-on-surface-variant">
                                    <BookOpen className="w-10 h-10 opacity-25" />
                                    <p className="font-medium">No subjects found for this class.</p>
                                    <p className="text-sm">Add subjects in <strong>Manage Data</strong> first.</p>
                                </div>
                            ) : (
                                <>
                                    {/* Table header */}
                                    <div className="grid grid-cols-[1fr_auto_auto] px-5 py-2 border-b border-outline-variant bg-surface-container-low text-xs font-semibold text-on-surface-variant uppercase tracking-wider">
                                        <span>Subject</span>
                                        <span className="text-center w-28">Hrs / Week</span>
                                        <span className="text-right w-48">Faculty</span>
                                    </div>
                                    <div className="divide-y divide-outline-variant">
                                        {subjects.map((subject: any) => {
                                            const assignedStaff = staff.find((s: any) => s.id === subject.staffId)
                                            const isReady = !!subject.staffId
                                            return (
                                                <div key={subject.id} className="grid grid-cols-[1fr_auto_auto] items-center px-5 py-3.5 hover:bg-surface-container-low transition-colors">
                                                    <div className="flex items-center gap-3">
                                                        <span className={`w-2 h-2 rounded-full shrink-0 ${isReady ? "bg-emerald-500" : "bg-amber-400"}`} />
                                                        <div>
                                                            <p className="font-semibold text-sm text-on-surface">{subject.name}</p>
                                                            {subject.code && <p className="text-xs text-on-surface-variant">{subject.code}</p>}
                                                        </div>
                                                    </div>
                                                    <div className="text-center w-28">
                                                        <span className="text-lg font-bold text-on-surface">{subject.hoursPerWeek || 3}</span>
                                                        <span className="text-xs text-on-surface-variant ml-1">periods</span>
                                                    </div>
                                                    <div className="flex justify-end w-48">
                                                        {assignedStaff ? (
                                                            <div className="flex items-center gap-1.5 text-emerald-700 bg-emerald-50 border border-emerald-200 rounded-full px-2.5 py-1 text-xs font-medium">
                                                                <CheckCircle2 className="w-3 h-3 shrink-0" />
                                                                {assignedStaff.first_name} {assignedStaff.last_name}
                                                            </div>
                                                        ) : (
                                                            <div className="flex items-center gap-1.5 text-amber-700 bg-amber-50 border border-amber-200 rounded-full px-2.5 py-1 text-xs font-medium">
                                                                <AlertTriangle className="w-3 h-3 shrink-0" />
                                                                No faculty
                                                            </div>
                                                        )}
                                                    </div>
                                                </div>
                                            )
                                        })}
                                    </div>
                                </>
                            )}
                        </CardContent>
                    </Card>

                    {/* Warnings */}
                    {missingStaffSubjects.length > 0 && (
                        <AlertBanner variant="warning"
                            title={`${missingStaffSubjects.length} subject${missingStaffSubjects.length > 1 ? "s" : ""} missing faculty — will be skipped`}
                            body={`${missingStaffSubjects.map((s: any) => s.name).join(", ")}. Assign faculty in Manage Data → Subjects.`}
                        />
                    )}
                    {rooms.length === 0 && (
                        <AlertBanner variant="error"
                            title="No rooms available"
                            body="Add rooms in Manage Data → Rooms. Rooms are required to generate a timetable."
                        />
                    )}

                    {/* Generate CTA */}
                    <div className="flex justify-end pt-2">
                        <Button
                            id="btn-generate"
                            className="bg-primary hover:bg-primary/90 text-on-primary px-8 py-6 text-base font-semibold shadow-lg shadow-primary/20 gap-2"
                            disabled={!canGenerate}
                            onClick={handleGenerate}
                        >
                            <Sparkles className="w-5 h-5" />
                            Generate Timetable Automatically
                        </Button>
                    </div>
                </div>
            )}

            {/* ══════════════════ STEP 2: PREVIEW ══════════════════ */}
            {(pageState === "preview" || pageState === "saving") && (
                <div className="space-y-5">
                    {/* Result banner */}
                    {conflicts.length === 0 ? (
                        <AlertBanner variant="success"
                            title={`Timetable generated — ${generatedSlots.length} slots, zero conflicts!`}
                            body="Review the grid below. Click Save to persist the timetable, or Regenerate for a different arrangement."
                        />
                    ) : (
                        <AlertBanner variant="warning"
                            title={`${conflicts.length} scheduling conflict${conflicts.length > 1 ? "s" : ""} — ${generatedSlots.length} slots generated`}
                            body={conflicts.map(c => `${c.subjectName}: ${c.periodsScheduled}/${c.periodsNeeded} periods — ${c.reason}`).join(" · ")}
                        />
                    )}

                    {/* Grid */}
                    <Card className="overflow-hidden">
                        <CardContent className="p-0 overflow-auto">
                            <div className="min-w-[700px]">
                                {/* Header row */}
                                <div className="grid grid-cols-6 border-b border-outline-variant bg-surface-container-low sticky top-0 z-10">
                                    <div className="p-3 text-center text-xs font-semibold text-on-surface-variant border-r border-outline-variant uppercase tracking-wider">Time</div>
                                    {WORKING_DAYS.map(d => (
                                        <div key={d} className="p-3 text-center text-sm font-semibold text-on-surface border-r border-outline-variant last:border-0">{d}</div>
                                    ))}
                                </div>

                                <div className="divide-y divide-outline-variant">
                                    {ALL_TIMES.map(time => {
                                        const isLunch = time === "12:00 PM"
                                        return (
                                            <div key={time} className={`grid grid-cols-6 ${isLunch ? "bg-amber-50/50" : ""}`}>
                                                {/* Time label */}
                                                <div className={`p-3 text-center text-xs font-medium border-r border-outline-variant flex flex-col items-center justify-center gap-0.5
                                                    ${isLunch ? "text-amber-600 bg-amber-50" : "text-on-surface-variant bg-surface-container-low"}`}>
                                                    {isLunch && <Coffee className="w-3 h-3 text-amber-400" />}
                                                    <span>{time}</span>
                                                    {isLunch && <span className="text-[10px] text-amber-400">Lunch</span>}
                                                </div>

                                                {WORKING_DAYS.map(day => {
                                                    const slot = generatedSlots.find(s => s.day === day && s.time === time)
                                                    const color = slot ? colorForSubject(slot.subjectId) : null
                                                    const subject = slot ? subjects.find((s: any) => s.id === slot.subjectId) : null
                                                    const staffMember = slot ? staff.find((s: any) => s.id === slot.staffId) : null
                                                    const room = slot ? rooms.find((r: any) => r.id === slot.roomId) : null

                                                    return (
                                                        <div key={`${day}-${time}`} className="p-1.5 border-r border-outline-variant last:border-0 min-h-[90px]">
                                                            {slot ? (
                                                                <div className={`h-full rounded-lg border ${color!.border} ${color!.bg} p-2.5 flex flex-col gap-0.5 shadow-sm`}>
                                                                    <p className={`text-xs font-bold ${color!.text} leading-tight`}>{subject?.name}</p>
                                                                    {staffMember && (
                                                                        <p className="text-[10px] text-on-surface-variant leading-tight">
                                                                            {staffMember.first_name} {staffMember.last_name}
                                                                        </p>
                                                                    )}
                                                                    {room && (
                                                                        <p className="text-[10px] text-on-surface-variant bg-white/50 px-1 rounded w-fit mt-auto">
                                                                            {room.name}
                                                                        </p>
                                                                    )}
                                                                </div>
                                                            ) : isLunch ? (
                                                                <div className="h-full flex items-center justify-center">
                                                                    <span className="text-[10px] text-amber-300">—</span>
                                                                </div>
                                                            ) : (
                                                                <div className="h-full min-h-[72px] rounded-lg border-2 border-dashed border-outline-variant/20" />
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

                    {/* Legend */}
                    <div className="flex items-center gap-4 flex-wrap text-xs text-on-surface-variant">
                        <span className="font-semibold text-on-surface">Subjects:</span>
                        {subjects.filter(s => s.staffId).map((s: any) => {
                            const c = colorForSubject(s.id)
                            return (
                                <span key={s.id} className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full border ${c.border} ${c.bg} ${c.text} font-medium`}>
                                    {s.name}
                                </span>
                            )
                        })}
                    </div>

                    {/* Actions */}
                    <div className="flex items-center justify-between gap-3 flex-wrap pt-2">
                        <Button variant="outline" onClick={() => setPageState("configure")} disabled={pageState === "saving"}>
                            ← Back
                        </Button>
                        <div className="flex gap-3">
                            <Button
                                id="btn-regenerate"
                                variant="outline"
                                className="gap-2"
                                onClick={handleGenerate}
                                disabled={pageState === "saving"}
                            >
                                <RotateCcw className="w-4 h-4" />
                                Regenerate
                            </Button>
                            <Button
                                id="btn-save-timetable"
                                className="bg-primary hover:bg-primary/90 text-on-primary px-6 gap-2 shadow-md shadow-primary/20"
                                onClick={handleSave}
                                disabled={pageState === "saving" || generatedSlots.length === 0}
                            >
                                {pageState === "saving"
                                    ? <><Loader2 className="w-4 h-4 animate-spin" />Saving…</>
                                    : <><Save className="w-4 h-4" />Save Timetable ({generatedSlots.length} slots)</>
                                }
                            </Button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}

// ─── Helper Components ────────────────────────────────────────────────────────

function StepBadge({ n, label, active, done }: { n: number; label: string; active: boolean; done: boolean }) {
    return (
        <div className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-sm font-medium transition-colors
            ${done ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
            : active ? "bg-primary text-on-primary"
            : "bg-surface-container-high text-on-surface-variant"}`}>
            {done ? <CheckCircle2 className="w-3.5 h-3.5" /> : <span className="text-xs font-bold leading-none">{n}</span>}
            {label}
        </div>
    )
}

function StatCard({ icon: Icon, value, label, color }: { icon: any; value: number; label: string; color: string }) {
    return (
        <Card>
            <CardContent className="p-4 flex items-center gap-3">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${color}`}>
                    <Icon className="w-5 h-5" />
                </div>
                <div>
                    <p className="text-2xl font-bold text-on-surface leading-none">{value}</p>
                    <p className="text-xs text-on-surface-variant mt-0.5">{label}</p>
                </div>
            </CardContent>
        </Card>
    )
}

function AlertBanner({ variant, title, body }: { variant: "success" | "warning" | "error"; title: string; body: string }) {
    const styles = {
        success: { wrap: "bg-emerald-50 border-emerald-200 text-emerald-800", icon: <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" /> },
        warning: { wrap: "bg-amber-50 border-amber-200 text-amber-800", icon: <AlertTriangle className="w-4 h-4 text-amber-500 shrink-0 mt-0.5" /> },
        error: { wrap: "bg-red-50 border-red-200 text-red-800", icon: <XCircle className="w-4 h-4 text-red-500 shrink-0 mt-0.5" /> },
    }[variant]
    return (
        <div className={`p-4 rounded-xl border text-sm flex gap-3 ${styles.wrap}`}>
            {styles.icon}
            <div>
                <p className="font-semibold">{title}</p>
                <p className="mt-0.5 opacity-80">{body}</p>
            </div>
        </div>
    )
}
