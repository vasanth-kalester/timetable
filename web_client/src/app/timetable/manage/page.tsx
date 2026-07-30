"use client"

import { useState, useEffect, useCallback } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { BookOpen, Users, MapPin, Plus, Trash2, Loader2, AlertTriangle, Hash, Layers3, Building2 } from "lucide-react"
import { useSession } from "next-auth/react"
import { getSubjects, createSubject, deleteSubject, updateSubjectStaff, getClasses, createClass, deleteClass, getRooms, createRoom, deleteRoom, updateClassRoom } from "@/app/actions/timetable"
import { getStaff } from "@/app/actions/staff"
import { toast, ToastContainer } from "@/components/ui/Toast"

type Tab = 'classes' | 'rooms' | 'class_subjects'

export default function TimetableManagePage() {
    const { data: session } = useSession()
    const [activeTab, setActiveTab] = useState<Tab>('classes')

    const [subjects, setSubjects] = useState<any[]>([])
    const [classes, setClasses] = useState<any[]>([])
    const [rooms, setRooms] = useState<any[]>([])
    const [staff, setStaff] = useState<any[]>([])
    const [selectedClassForSubjects, setSelectedClassForSubjects] = useState<string>("")

    const [isLoading, setIsLoading] = useState(true)
    const [collegeId, setCollegeId] = useState<string | null>(null)
    const [departmentId, setDepartmentId] = useState<string | null>(null)
    const [error, setError] = useState<string | null>(null)

    // Add form state
    const [isAdding, setIsAdding] = useState(false)
    const [formData, setFormData] = useState({ name: "", code: "", hoursPerWeek: "3", capacity: "" })
    const [isSaving, setIsSaving] = useState(false)

    // Inline delete confirm
    const [deleteConfirmId, setDeleteConfirmId] = useState<string | null>(null)
    const [isDeleting, setIsDeleting] = useState(false)

    useEffect(() => {
        if (!session?.user) return
        async function loadUserAndCollege() {
            const { getProfile } = await import("@/app/actions/settings")
            const result = await getProfile((session!.user as any).id)
            if (result.profile?.college_id) {
                setCollegeId(result.profile.college_id)
                const dId = (result.profile as any).department_id || null
                setDepartmentId(dId)
                fetchData(result.profile.college_id, dId, activeTab)
            } else {
                setIsLoading(false)
            }
        }
        loadUserAndCollege()
    }, [session, activeTab])

    const fetchData = useCallback(async (cId: string, dId: string | null, tab: Tab) => {
        setIsLoading(true)
        setError(null)
        try {
            if (tab === 'classes') {
                const [clsRes, roomRes] = await Promise.all([
                    getClasses(dId, cId),
                    getRooms(cId)
                ])
                if (clsRes.classes) setClasses(clsRes.classes)
                if (roomRes.rooms) setRooms(roomRes.rooms)
            } else if (tab === 'rooms') {
                const res = await getRooms(cId)
                if (res.rooms) setRooms(res.rooms)
            } else if (tab === 'class_subjects') {
                const [clsRes, stfRes] = await Promise.all([
                    getClasses(dId, cId),
                    getStaff(cId, 'approved', 'faculty', dId || undefined)
                ])
                if (clsRes.classes) {
                    setClasses(clsRes.classes)
                    const classId = selectedClassForSubjects || (clsRes.classes[0]?.id ?? "")
                    if (classId) {
                        if (!selectedClassForSubjects) setSelectedClassForSubjects(classId)
                        const subRes = await getSubjects(classId)
                        if (subRes.subjects) setSubjects(subRes.subjects)
                    }
                }
                if (stfRes.staff) setStaff(stfRes.staff)
            }
        } catch {
            setError("Failed to load data.")
        } finally {
            setIsLoading(false)
        }
    }, [selectedClassForSubjects])

    const handleSave = async () => {
        if (!formData.name.trim()) {
            setError("Name is required.")
            return
        }
        setIsSaving(true)
        setError(null)
        try {
            if (activeTab === 'class_subjects') {
                if (!selectedClassForSubjects) throw new Error("No class selected.")
                await createSubject({
                    name: formData.name,
                    code: formData.code,
                    classId: selectedClassForSubjects,
                })
            } else if (activeTab === 'classes') {
                if (!departmentId) throw new Error("No department associated.")
                await createClass({ name: formData.name, departmentId })
            } else if (activeTab === 'rooms') {
                if (!collegeId) throw new Error("No college associated.")
                await createRoom({ name: formData.name, collegeId })
            }
            setFormData({ name: "", code: "", hoursPerWeek: "3", capacity: "" })
            setIsAdding(false)
            await fetchData(collegeId!, departmentId, activeTab)
            toast(`${activeTab === 'class_subjects' ? 'Subject' : activeTab === 'classes' ? 'Class' : 'Room'} added successfully!`, "success")
        } catch (err: any) {
            setError(err.message || "Failed to save.")
        } finally {
            setIsSaving(false)
        }
    }

    const handleDelete = async (id: string) => {
        setIsDeleting(true)
        try {
            if (activeTab === 'class_subjects') await deleteSubject(id)
            else if (activeTab === 'classes') await deleteClass(id)
            else await deleteRoom(id)
            setDeleteConfirmId(null)
            await fetchData(collegeId!, departmentId, activeTab)
            toast("Item deleted.", "success")
        } catch {
            toast("Failed to delete item.", "error")
        } finally {
            setIsDeleting(false)
        }
    }

    const switchTab = (tab: Tab) => {
        setActiveTab(tab)
        setIsAdding(false)
        setDeleteConfirmId(null)
        setError(null)
    }

    const tabLabel = activeTab === 'class_subjects' ? 'Subject' : activeTab === 'classes' ? 'Class' : 'Room'
    const classCount = classes.length
    const roomCount = rooms.length
    const subjectCount = subjects.length

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500 max-w-5xl mx-auto">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-on-surface">Manage Timetable Data</h1>
                    <p className="text-on-surface-variant mt-1">Add classes, subjects, and rooms used in scheduling.</p>
                </div>
                {!isAdding && (
                    <Button
                        id="btn-add-item"
                        onClick={() => { setIsAdding(true); setError(null) }}
                        className="bg-primary hover:bg-primary/90 text-on-primary shadow-sm"
                    >
                        <Plus className="w-4 h-4 mr-2" />
                        Add {tabLabel}
                    </Button>
                )}
            </div>

            {/* Error Banner */}
            {error && (
                <div className="p-3 rounded-xl bg-error-container border border-error/20 text-on-error-container text-sm flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4 shrink-0" />
                    {error}
                </div>
            )}

            {/* Tab Bar */}
            <div className="flex gap-1 p-1 bg-surface-container-high rounded-xl w-fit">
                {([
                    { id: 'classes', label: 'Classes', icon: Users, count: classCount },
                    { id: 'class_subjects', label: 'Subjects', icon: BookOpen, count: subjectCount },
                    { id: 'rooms', label: 'Rooms', icon: MapPin, count: roomCount },
                ] as { id: Tab; label: string; icon: any; count: number }[]).map(tab => (
                    <button
                        key={tab.id}
                        id={`tab-${tab.id}`}
                        className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all
                            ${activeTab === tab.id
                                ? "bg-surface-container-lowest text-on-surface shadow-sm"
                                : "text-on-surface-variant hover:text-on-surface hover:bg-surface-container"
                            }`}
                        onClick={() => switchTab(tab.id)}
                    >
                        <tab.icon className="w-4 h-4" />
                        {tab.label}
                        {tab.count > 0 && (
                            <span className={`text-[11px] font-semibold px-1.5 py-0.5 rounded-full min-w-[20px] text-center
                                ${activeTab === tab.id ? "bg-primary text-on-primary" : "bg-surface-container-highest text-on-surface-variant"}`}>
                                {tab.count}
                            </span>
                        )}
                    </button>
                ))}
            </div>

            {/* Add Form Card */}
            {isAdding && (
                <Card className="border-primary/30 bg-primary/5 animate-in slide-in-from-top-2 duration-200">
                    <CardHeader className="pb-3">
                        <CardTitle className="text-base text-on-surface">
                            New {tabLabel}
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-on-surface">Name *</label>
                                <Input
                                    id="form-name"
                                    placeholder={
                                        activeTab === 'class_subjects' ? "e.g. Data Structures"
                                            : activeTab === 'classes' ? "e.g. Year 2 — Section A"
                                                : "e.g. Room 101"
                                    }
                                    value={formData.name}
                                    onChange={e => setFormData(prev => ({ ...prev, name: e.target.value }))}
                                    onKeyDown={e => e.key === 'Enter' && handleSave()}
                                />
                            </div>

                            {activeTab === 'class_subjects' && (
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-on-surface flex items-center gap-1">
                                        <Hash className="w-3.5 h-3.5" /> Subject Code
                                    </label>
                                    <Input
                                        id="form-code"
                                        placeholder="e.g. CS201"
                                        value={formData.code}
                                        onChange={e => setFormData(prev => ({ ...prev, code: e.target.value }))}
                                        onKeyDown={e => e.key === 'Enter' && handleSave()}
                                    />
                                </div>
                            )}

                            {activeTab === 'rooms' && (
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-on-surface flex items-center gap-1">
                                        <Layers3 className="w-3.5 h-3.5" /> Capacity (optional)
                                    </label>
                                    <Input
                                        id="form-capacity"
                                        type="number"
                                        placeholder="e.g. 60"
                                        value={formData.capacity}
                                        onChange={e => setFormData(prev => ({ ...prev, capacity: e.target.value }))}
                                    />
                                </div>
                            )}
                        </div>

                        <div className="flex justify-end gap-3 mt-6">
                            <Button
                                variant="outline"
                                onClick={() => { setIsAdding(false); setError(null) }}
                                disabled={isSaving}
                            >
                                Cancel
                            </Button>
                            <Button
                                id="btn-save-item"
                                className="bg-primary hover:bg-primary/90 text-on-primary"
                                onClick={handleSave}
                                disabled={isSaving}
                            >
                                {isSaving ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : <Plus className="w-4 h-4 mr-2" />}
                                {isSaving ? "Saving…" : `Add ${tabLabel}`}
                            </Button>
                        </div>
                    </CardContent>
                </Card>
            )}

            {/* Data Card */}
            <Card>
                <CardContent className="p-0">
                    {isLoading ? (
                        <div className="flex flex-col items-center justify-center py-16 gap-3">
                            <Loader2 className="w-8 h-8 animate-spin text-primary" />
                            <p className="text-sm text-on-surface-variant">Loading…</p>
                        </div>

                    ) : activeTab === 'class_subjects' ? (
                        /* Subjects Tab */
                        <div className="p-6 space-y-5">
                            {/* Class selector */}
                            <div className="flex items-center gap-3">
                                <label className="text-sm font-semibold text-on-surface whitespace-nowrap">Viewing subjects for:</label>
                                <select
                                    id="class-subject-selector"
                                    className="h-10 rounded-xl border border-outline-variant bg-surface-container-low px-3 py-2 text-sm text-on-surface focus:outline-none focus:ring-2 focus:ring-primary/30"
                                    value={selectedClassForSubjects}
                                    onChange={async e => {
                                        setSelectedClassForSubjects(e.target.value)
                                        setIsLoading(true)
                                        const subRes = await getSubjects(e.target.value)
                                        if (subRes.subjects) setSubjects(subRes.subjects)
                                        setIsLoading(false)
                                    }}
                                >
                                    {classes.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                                </select>
                            </div>

                            {subjects.length === 0 ? (
                                <EmptyState
                                    icon={<BookOpen className="w-10 h-10 text-on-surface-variant/30" />}
                                    title="No subjects yet"
                                    description="Add subjects to this class so they can be scheduled on the timetable."
                                    cta="Add Subject"
                                    onCta={() => setIsAdding(true)}
                                />
                            ) : (
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                                    {subjects.map(subject => (
                                        <div key={subject.id} className="p-4 rounded-xl border border-outline-variant bg-surface-container-lowest hover:border-primary/30 hover:shadow-sm transition-all group">
                                            <div className="flex justify-between items-start mb-3">
                                                <div>
                                                    <h4 className="font-semibold text-on-surface">{subject.name}</h4>
                                                    {subject.code && (
                                                        <span className="text-xs text-on-surface-variant bg-surface-container px-1.5 py-0.5 rounded-md mt-0.5 inline-block">
                                                            {subject.code}
                                                        </span>
                                                    )}
                                                </div>

                                                {deleteConfirmId === subject.id ? (
                                                    <div className="flex gap-1 shrink-0">
                                                        <button
                                                            className="text-[11px] px-2 py-1 rounded-md border border-outline-variant text-on-surface-variant hover:bg-surface-container transition-colors"
                                                            onClick={() => setDeleteConfirmId(null)}
                                                            disabled={isDeleting}
                                                        >
                                                            Cancel
                                                        </button>
                                                        <button
                                                            className="text-[11px] px-2 py-1 rounded-md bg-error text-on-error hover:bg-error/90 transition-colors flex items-center gap-1"
                                                            onClick={() => handleDelete(subject.id)}
                                                            disabled={isDeleting}
                                                        >
                                                            {isDeleting ? <Loader2 className="w-3 h-3 animate-spin" /> : <Trash2 className="w-3 h-3" />}
                                                            Delete
                                                        </button>
                                                    </div>
                                                ) : (
                                                    <button
                                                        className="opacity-0 group-hover:opacity-100 transition-opacity p-1.5 rounded-lg text-on-surface-variant hover:text-error hover:bg-error/10"
                                                        onClick={() => setDeleteConfirmId(subject.id)}
                                                    >
                                                        <Trash2 className="w-4 h-4" />
                                                    </button>
                                                )}
                                            </div>

                                            <div className="space-y-1">
                                                <label className="text-xs font-medium text-on-surface-variant">Assigned Faculty</label>
                                                <select
                                                    className="w-full h-9 rounded-lg border border-outline-variant bg-surface-container-low px-3 py-1 text-sm text-on-surface focus:outline-none focus:ring-2 focus:ring-primary/30"
                                                    value={subject.staffId || ""}
                                                    onChange={async e => {
                                                        const staffId = e.target.value || null
                                                        await updateSubjectStaff(subject.id, staffId)
                                                        const subRes = await getSubjects(selectedClassForSubjects)
                                                        if (subRes.subjects) setSubjects(subRes.subjects)
                                                    }}
                                                >
                                                    <option value="">— Unassigned —</option>
                                                    {staff.map(s => <option key={s.id} value={s.id}>{s.first_name} {s.last_name}</option>)}
                                                </select>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                    ) : (activeTab === 'classes' && classes.length === 0) || (activeTab === 'rooms' && rooms.length === 0) ? (
                        <div className="py-6 px-6">
                            <EmptyState
                                icon={activeTab === 'classes'
                                    ? <Users className="w-10 h-10 text-on-surface-variant/30" />
                                    : <Building2 className="w-10 h-10 text-on-surface-variant/30" />
                                }
                                title={`No ${activeTab} yet`}
                                description={
                                    activeTab === 'classes'
                                        ? "Add class groups (e.g. Year 2 — Section A) to start assigning subjects."
                                        : "Add classrooms or labs to assign as venues during scheduling."
                                }
                                cta={`Add ${tabLabel}`}
                                onCta={() => setIsAdding(true)}
                            />
                        </div>

                    ) : (
                        /* Classes / Rooms list */
                        <div className="divide-y divide-outline-variant">
                            {(activeTab === 'classes' ? classes : rooms).map(item => (
                                <div key={item.id} className="px-5 py-4 flex items-center justify-between hover:bg-surface-container-low transition-colors group">
                                    <div className="flex items-center gap-3">
                                        <div className="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                                            {activeTab === 'classes'
                                                ? <Users className="w-4 h-4 text-primary" />
                                                : <MapPin className="w-4 h-4 text-primary" />
                                            }
                                        </div>
                                        <div>
                                            <h4 className="font-semibold text-on-surface text-sm">{item.name}</h4>
                                            {item.code && <p className="text-xs text-on-surface-variant mt-0.5">Code: {item.code}</p>}
                                        </div>
                                    </div>

                                    {deleteConfirmId === item.id ? (
                                        <div className="flex gap-2 items-center">
                                            <span className="text-xs text-on-surface-variant mr-1">Delete this {tabLabel.toLowerCase()}?</span>
                                            <button
                                                className="text-[11px] px-2 py-1 rounded-md border border-outline-variant text-on-surface-variant hover:bg-surface-container transition-colors"
                                                onClick={() => setDeleteConfirmId(null)}
                                                disabled={isDeleting}
                                            >
                                                Cancel
                                            </button>
                                            <button
                                                className="text-[11px] px-3 py-1 rounded-md bg-error text-on-error hover:bg-error/90 transition-colors flex items-center gap-1"
                                                onClick={() => handleDelete(item.id)}
                                                disabled={isDeleting}
                                            >
                                                {isDeleting ? <Loader2 className="w-3 h-3 animate-spin" /> : <Trash2 className="w-3 h-3" />}
                                                Delete
                                            </button>
                                        </div>
                                    ) : (
                                        <div className="flex items-center gap-3">
                                            {activeTab === 'classes' && (
                                                <div className="flex items-center gap-2 mr-2">
                                                    <label className="text-xs font-medium text-on-surface-variant">Room:</label>
                                                    <select
                                                        className="w-32 h-8 rounded-md border border-outline-variant bg-surface-container-low px-2 text-xs text-on-surface focus:outline-none focus:ring-1 focus:ring-primary/30"
                                                        value={item.roomId || ""}
                                                        onChange={async e => {
                                                            const roomId = e.target.value || null
                                                            const res = await updateClassRoom(item.id, roomId)
                                                            if (res.error) {
                                                                toast(res.error, "error")
                                                            } else {
                                                                toast("Room mapped successfully", "success")
                                                            }
                                                            await fetchData(collegeId!, departmentId, activeTab)
                                                        }}
                                                    >
                                                        <option value="">— Any —</option>
                                                        {rooms.map(r => {
                                                            const isAssignedToOther = classes.some(c => c.roomId === r.id && c.id !== item.id)
                                                            return (
                                                                <option key={r.id} value={r.id} disabled={isAssignedToOther}>
                                                                    {r.name} {isAssignedToOther ? "(Assigned)" : ""}
                                                                </option>
                                                            )
                                                        })}
                                                    </select>
                                                </div>
                                            )}
                                            <button
                                                className="opacity-0 group-hover:opacity-100 transition-opacity p-2 rounded-lg text-on-surface-variant hover:text-error hover:bg-error/10"
                                                onClick={() => setDeleteConfirmId(item.id)}
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                    )}
                                </div>
                            ))}
                        </div>
                    )}
                </CardContent>
            </Card>

            <ToastContainer />
        </div>
    )
}

function EmptyState({ icon, title, description, cta, onCta }: {
    icon: React.ReactNode
    title: string
    description: string
    cta: string
    onCta: () => void
}) {
    return (
        <div className="flex flex-col items-center justify-center py-14 gap-4 text-center">
            <div className="w-20 h-20 rounded-2xl bg-surface-container-high flex items-center justify-center">
                {icon}
            </div>
            <div>
                <h3 className="text-base font-semibold text-on-surface">{title}</h3>
                <p className="text-sm text-on-surface-variant mt-1 max-w-sm mx-auto">{description}</p>
            </div>
            <Button
                className="mt-1 bg-primary hover:bg-primary/90 text-on-primary"
                onClick={onCta}
            >
                <Plus className="w-4 h-4 mr-2" />
                {cta}
            </Button>
        </div>
    )
}
