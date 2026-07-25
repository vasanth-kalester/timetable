"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { BookOpen, Users, MapPin, Plus, Trash2, Loader2, AlertTriangle } from "lucide-react"
import { useSession } from "next-auth/react"
import { getSubjects, createSubject, deleteSubject, getClasses, createClass, deleteClass, getRooms, createRoom, deleteRoom } from "@/app/actions/timetable"

export default function TimetableManagePage() {
    const { data: session } = useSession()
    const [activeTab, setActiveTab] = useState<'subjects' | 'classes' | 'rooms'>('subjects')

    const [subjects, setSubjects] = useState<any[]>([])
    const [classes, setClasses] = useState<any[]>([])
    const [rooms, setRooms] = useState<any[]>([])

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
            if (activeTab === 'subjects' && dId) {
                const res = await getSubjects(dId)
                if (res.subjects) setSubjects(res.subjects)
            } else if (activeTab === 'classes' && dId) {
                const res = await getClasses(dId)
                if (res.classes) setClasses(res.classes)
            } else if (activeTab === 'rooms') {
                const res = await getRooms(cId)
                if (res.rooms) setRooms(res.rooms)
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
            if (activeTab === 'subjects') {
                if (!departmentId) throw new Error("No department associated.")
                await createSubject({ name: formData.name, code: formData.code, departmentId })
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
            if (activeTab === 'subjects') await deleteSubject(id)
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
                        Add {activeTab === 'subjects' ? 'Subject' : activeTab === 'classes' ? 'Class' : 'Room'}
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
                    className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors flex items-center justify-center gap-2 ${activeTab === 'subjects' ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'}`}
                    onClick={() => { setActiveTab('subjects'); setIsAdding(false); }}
                >
                    <BookOpen className="w-4 h-4" /> Subjects
                </button>
                <button
                    className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors flex items-center justify-center gap-2 ${activeTab === 'classes' ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'}`}
                    onClick={() => { setActiveTab('classes'); setIsAdding(false); }}
                >
                    <Users className="w-4 h-4" /> Classes
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
                        <CardTitle className="text-lg">New {activeTab === 'subjects' ? 'Subject' : activeTab === 'classes' ? 'Class' : 'Room'}</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Name</label>
                                <Input
                                    placeholder={activeTab === 'subjects' ? "e.g. Data Structures" : activeTab === 'classes' ? "e.g. Year 2 - Section A" : "e.g. Room 101"}
                                    value={formData.name}
                                    onChange={e => setFormData({ ...formData, name: e.target.value })}
                                />
                            </div>
                            {activeTab === 'subjects' && (
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
                    ) : (activeTab === 'subjects' && subjects.length === 0) || (activeTab === 'classes' && classes.length === 0) || (activeTab === 'rooms' && rooms.length === 0) ? (
                        <div className="text-center py-12">
                            <h3 className="text-lg font-medium text-slate-300">No data found</h3>
                            <p className="text-slate-500 mt-1">Add some {activeTab} to get started.</p>
                        </div>
                    ) : (
                        <div className="divide-y divide-slate-800/60">
                            {(activeTab === 'subjects' ? subjects : activeTab === 'classes' ? classes : rooms).map((item) => (
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
