"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { BookOpen, Users, MapPin, Plus, Trash2, Loader2, AlertTriangle } from "lucide-react"
import { useSession } from "next-auth/react"
import { getSubjects, createSubject, deleteSubject, updateSubjectStaff, getClasses, createClass, deleteClass, getRooms, createRoom, deleteRoom } from "@/app/actions/timetable"
import { getStaff } from "@/app/actions/staff"

export default function TimetableManagePage() {
    const { data: session } = useSession()
    const [activeTab, setActiveTab] = useState<'classes' | 'rooms' | 'class_subjects'>('classes')

    const [subjects, setSubjects] = useState<any[]>([])
    const [classes, setClasses] = useState<any[]>([])
    const [rooms, setRooms] = useState<any[]>([])
    const [staff, setStaff] = useState<any[]>([])
    const [selectedClassForSubjects, setSelectedClassForSubjects] = useState<string>("")

    const [isLoading, setIsLoading] = useState(true)
    const [collegeId, setCollegeId] = useState<string | null>(null)
    const [departmentId, setDepartmentId] = useState<string | null>(null)
    const [error, setError] = useState<string | null>(null)

    // Form state
    const [isAdding, setIsAdding] = useState(false)
    const [formData, setFormData] = useState({ name: "", code: "" })
    const [isSaving, setIsSaving] = useState(false)

    useEffect(() => {
        async function loadUserAndCollege() {
            if (session?.user) {
                const { getProfile } = await import("@/app/actions/settings")
                const result = await getProfile((session.user as any).id)

                if (result.profile?.college_id) {
                    setCollegeId(result.profile.college_id)
                    setDepartmentId((result.profile as any).department_id || null)
                    fetchData(result.profile.college_id, (result.profile as any).department_id)
                } else {
                    setIsLoading(false)
                }
            }
        }
        loadUserAndCollege()
    }, [session, activeTab])

    const fetchData = async (cId: string, dId: string | null) => {
        setIsLoading(true)
        setError(null)
        try {
            if (activeTab === 'classes' && dId) {
                const res = await getClasses(dId)
                if (res.classes) setClasses(res.classes)
            } else if (activeTab === 'rooms') {
                const res = await getRooms(cId)
                if (res.rooms) setRooms(res.rooms)
            } else if (activeTab === 'class_subjects' && dId) {
                const [clsRes, stfRes] = await Promise.all([
                    getClasses(dId),
                    getStaff(cId, 'approved', 'faculty', dId)
                ])
                if (clsRes.classes) {
                    setClasses(clsRes.classes)
                    if (clsRes.classes.length > 0 && !selectedClassForSubjects) {
                        setSelectedClassForSubjects(clsRes.classes[0].id)
                        const subRes = await getSubjects(clsRes.classes[0].id)
                        if (subRes.subjects) setSubjects(subRes.subjects)
                    } else if (selectedClassForSubjects) {
                        const subRes = await getSubjects(selectedClassForSubjects)
                        if (subRes.subjects) setSubjects(subRes.subjects)
                    }
                }
                if (stfRes.staff) setStaff(stfRes.staff)
            }
        } catch (err: any) {
            console.error(err)
            setError("Failed to load data.")
        } finally {
            setIsLoading(false)
        }
    }

    const handleSave = async () => {
        if (!formData.name) {
            setError("Please fill in the name.")
            return
        }

        setIsSaving(true)
        setError(null)

        try {
            if (activeTab === 'class_subjects') {
                if (!selectedClassForSubjects) throw new Error("No class selected.")
                await createSubject({ name: formData.name, code: formData.code, classId: selectedClassForSubjects })
            } else if (activeTab === 'classes') {
                if (!departmentId) throw new Error("No department associated.")
                await createClass({ name: formData.name, departmentId })
            } else if (activeTab === 'rooms') {
                if (!collegeId) throw new Error("No college associated.")
                await createRoom({ name: formData.name, collegeId })
            }

            setFormData({ name: "", code: "" })
            setIsAdding(false)
            await fetchData(collegeId!, departmentId)
        } catch (err: any) {
            setError(err.message || "Failed to save.")
        } finally {
            setIsSaving(false)
        }
    }

    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to delete this item?")) return
        try {
            if (activeTab === 'class_subjects') await deleteSubject(id)
            else if (activeTab === 'classes') await deleteClass(id)
            else if (activeTab === 'rooms') await deleteRoom(id)

            await fetchData(collegeId!, departmentId)
        } catch (err: any) {
            alert("Failed to delete.")
        }
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500 max-w-5xl mx-auto">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Manage Timetable Data</h1>
                    <p className="text-slate-400 mt-2">Add subjects, classes, and rooms for scheduling.</p>
                </div>
                {!isAdding && (
                    <Button onClick={() => setIsAdding(true)} className="bg-indigo-600 hover:bg-indigo-700 text-white">
                        <Plus className="w-4 h-4 mr-2" />
                        Add {activeTab === 'class_subjects' ? 'Subject' : activeTab === 'classes' ? 'Class' : 'Room'}
                    </Button>
                )}
            </div>

            {error && (
                <div className="p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4" />
                    {error}
                </div>
            )}

            <div className="flex p-1 bg-slate-800/50 rounded-lg w-full max-w-md">
                <button
                    className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors flex items-center justify-center gap-2 ${activeTab === 'classes' ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'}`}
                    onClick={() => { setActiveTab('classes'); setIsAdding(false); }}
                >
                    <Users className="w-4 h-4" /> Classes
                </button>
                <button
                    className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors flex items-center justify-center gap-2 ${activeTab === 'class_subjects' ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'}`}
                    onClick={() => { setActiveTab('class_subjects'); setIsAdding(false); }}
                >
                    <BookOpen className="w-4 h-4" /> Class Subjects
                </button>
                <button
                    className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors flex items-center justify-center gap-2 ${activeTab === 'rooms' ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'}`}
                    onClick={() => { setActiveTab('rooms'); setIsAdding(false); }}
                >
                    <MapPin className="w-4 h-4" /> Rooms
                </button>
            </div>

            {isAdding && (
                <Card className="border-indigo-500/30 bg-indigo-500/5">
                    <CardHeader>
                        <CardTitle className="text-lg">New {activeTab === 'class_subjects' ? 'Subject' : activeTab === 'classes' ? 'Class' : 'Room'}</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Name</label>
                                <Input
                                    placeholder={activeTab === 'class_subjects' ? "e.g. Data Structures" : activeTab === 'classes' ? "e.g. Year 2 - Section A" : "e.g. Room 101"}
                                    value={formData.name}
                                    onChange={e => setFormData({ ...formData, name: e.target.value })}
                                />
                            </div>
                            {activeTab === 'class_subjects' && (
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-slate-300">Code</label>
                                    <Input
                                        placeholder="e.g. CS201"
                                        value={formData.code}
                                        onChange={e => setFormData({ ...formData, code: e.target.value })}
                                    />
                                </div>
                            )}
                        </div>
                        <div className="flex justify-end gap-3 mt-6">
                            <Button variant="outline" onClick={() => setIsAdding(false)} disabled={isSaving}>Cancel</Button>
                            <Button className="bg-indigo-600 hover:bg-indigo-700 text-white" onClick={handleSave} disabled={isSaving}>
                                {isSaving ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
                                Save
                            </Button>
                        </div>
                    </CardContent>
                </Card>
            )}

            <Card className="border-slate-800/60 bg-slate-900/40">
                <CardContent className="p-0">
                    {isLoading ? (
                        <div className="flex justify-center py-12">
                            <Loader2 className="w-8 h-8 animate-spin text-indigo-500" />
                        </div>
                    ) : activeTab === 'class_subjects' ? (
                        <div className="p-6 space-y-6">
                            <div className="flex items-center gap-4">
                                <label className="text-sm font-medium text-slate-300">Select Class:</label>
                                <select
                                    className="h-10 rounded-md border border-slate-800 bg-slate-950 px-3 py-2 text-sm text-slate-50"
                                    value={selectedClassForSubjects}
                                    onChange={async (e) => {
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
                                <div className="text-center py-12 border border-dashed border-slate-800 rounded-lg">
                                    <h3 className="text-lg font-medium text-slate-300">No subjects added</h3>
                                    <p className="text-slate-500 mt-1">Click "Add Subject" to create subjects for this class.</p>
                                </div>
                            ) : (
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    {subjects.map(subject => {
                                        return (
                                            <div key={subject.id} className="p-4 rounded-lg border border-slate-800 bg-slate-900/50 flex flex-col gap-3 group">
                                                <div className="flex justify-between items-start">
                                                    <div>
                                                        <h4 className="font-medium text-slate-200">{subject.name}</h4>
                                                        <span className="text-xs text-slate-500">{subject.code}</span>
                                                    </div>
                                                    <Button variant="ghost" size="icon" className="text-slate-500 hover:text-red-400 opacity-0 group-hover:opacity-100 transition-opacity h-8 w-8" onClick={() => handleDelete(subject.id)}>
                                                        <Trash2 className="w-4 h-4" />
                                                    </Button>
                                                </div>
                                                <select
                                                    className="w-full h-9 rounded-md border border-slate-700 bg-slate-950 px-3 py-1 text-sm text-slate-300"
                                                    value={subject.staffId || ""}
                                                    onChange={async (e) => {
                                                        const staffId = e.target.value || null
                                                        await updateSubjectStaff(subject.id, staffId)
                                                        const subRes = await getSubjects(selectedClassForSubjects)
                                                        if (subRes.subjects) setSubjects(subRes.subjects)
                                                    }}
                                                >
                                                    <option value="">Unassigned Staff</option>
                                                    {staff.map(s => <option key={s.id} value={s.id}>{s.first_name} {s.last_name}</option>)}
                                                </select>
                                            </div>
                                        )
                                    })}
                                </div>
                            )}
                        </div>
                    ) : (activeTab === 'classes' && classes.length === 0) || (activeTab === 'rooms' && rooms.length === 0) ? (
                        <div className="text-center py-12">
                            <h3 className="text-lg font-medium text-slate-300">No data found</h3>
                            <p className="text-slate-500 mt-1">Add some {activeTab} to get started.</p>
                        </div>
                    ) : (
                        <div className="divide-y divide-slate-800/60">
                            {(activeTab === 'classes' ? classes : rooms).map((item) => (
                                <div key={item.id} className="p-4 flex items-center justify-between hover:bg-slate-800/30 transition-colors">
                                    <div>
                                        <h4 className="font-medium text-slate-200">{item.name}</h4>
                                        {item.code && <p className="text-xs text-slate-500 mt-0.5">Code: {item.code}</p>}
                                    </div>
                                    <Button variant="ghost" size="icon" className="text-slate-400 hover:text-red-400" onClick={() => handleDelete(item.id)}>
                                        <Trash2 className="w-4 h-4" />
                                    </Button>
                                </div>
                            ))}
                        </div>
                    )}
                </CardContent>
            </Card>
        </div>
    )
}
