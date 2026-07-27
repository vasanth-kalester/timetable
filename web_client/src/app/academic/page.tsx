"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { Search, Plus, BookOpen, GraduationCap, Users, Loader2, X, Trash2, Upload } from "lucide-react"
import { getSubjects, addSubject, editSubject, deleteSubject, bulkImportSubjects } from "@/app/actions/academic"
import { BulkImportModal } from "@/components/academic/BulkImportModal"

export default function AcademicPage() {
    const [subjects, setSubjects] = useState<any[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [isAddModalOpen, setIsAddModalOpen] = useState(false)
    const [isEditModalOpen, setIsEditModalOpen] = useState(false)
    const [isBulkImportOpen, setIsBulkImportOpen] = useState(false)
    const [isSubmitting, setIsSubmitting] = useState(false)
    const [error, setError] = useState<string | null>(null)
    const [newSubject, setNewSubject] = useState({ code: "", name: "", hoursPerWeek: "3" })
    const [editingSubject, setEditingSubject] = useState({ id: "", code: "", name: "", hoursPerWeek: "3" })

    const fetchSubjects = async () => {
        setIsLoading(true)
        const result = await getSubjects()
        if (!result.error) {
            setSubjects(result.subjects || [])
        }
        setIsLoading(false)
    }

    useEffect(() => {
        fetchSubjects()
    }, [])

    const handleAddSubject = async (e: React.FormEvent) => {
        e.preventDefault()
        setError(null)
        if (!newSubject.code || !newSubject.name) return

        setIsSubmitting(true)
        const result = await addSubject({
            ...newSubject,
            hoursPerWeek: parseInt(newSubject.hoursPerWeek) || 3
        })
        if (!result.error) {
            setIsAddModalOpen(false)
            setNewSubject({ code: "", name: "", hoursPerWeek: "3" })
            fetchSubjects() // Refresh list
        } else {
            setError(result.error)
        }
        setIsSubmitting(false)
    }

    const handleEditSubject = async (e: React.FormEvent) => {
        e.preventDefault()
        setError(null)
        if (!editingSubject.code || !editingSubject.name) return

        setIsSubmitting(true)
        const result = await editSubject(editingSubject.id, {
            code: editingSubject.code,
            name: editingSubject.name,
            hoursPerWeek: parseInt(editingSubject.hoursPerWeek) || 3
        })
        if (!result.error) {
            setIsEditModalOpen(false)
            fetchSubjects() // Refresh list
        } else {
            setError(result.error)
        }
        setIsSubmitting(false)
    }

    const handleDeleteSubject = async (id: string) => {
        if (!confirm("Are you sure you want to delete this subject?")) return

        const result = await deleteSubject(id)
        if (!result.error) {
            fetchSubjects()
        } else {
            alert(result.error)
        }
    }

    const openEditModal = (subject: any) => {
        setEditingSubject({
            id: subject.id,
            code: subject.code,
            name: subject.name,
            hoursPerWeek: (subject.hoursPerWeek || 3).toString()
        })
        setError(null)
        setIsEditModalOpen(true)
    }

    const handleBulkImport = async (data: any[]) => {
        const result = await bulkImportSubjects(data)
        if (result.success) {
            fetchSubjects()
        }
        return result
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Academic Management</h1>
                    <p className="text-slate-400 mt-2">Manage subjects, curriculum, and faculty assignments.</p>
                </div>
                <div className="flex items-center gap-3">
                    <Button variant="outline" className="border-slate-700 hover:bg-slate-800" onClick={() => setIsBulkImportOpen(true)}>
                        <Upload className="w-4 h-4 mr-2" /> Bulk Import
                    </Button>
                    <Button className="shadow-lg shadow-indigo-600/20 bg-indigo-600 hover:bg-indigo-700" onClick={() => { setError(null); setIsAddModalOpen(true); }}>
                        <Plus className="w-4 h-4 mr-2" /> Add Subject
                    </Button>
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardContent className="p-6 flex items-center gap-4">
                        <div className="p-3 rounded-xl bg-blue-500/10">
                            <BookOpen className="w-6 h-6 text-blue-500" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-400">Total Subjects</p>
                            <p className="text-2xl font-bold text-slate-50">{isLoading ? "-" : subjects.length}</p>
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardContent className="p-6 flex items-center gap-4">
                        <div className="p-3 rounded-xl bg-indigo-500/10">
                            <GraduationCap className="w-6 h-6 text-indigo-500" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-400">Active Faculty</p>
                            <p className="text-2xl font-bold text-slate-50">0</p>
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardContent className="p-6 flex items-center gap-4">
                        <div className="p-3 rounded-xl bg-emerald-500/10">
                            <Users className="w-6 h-6 text-emerald-500" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-400">Enrolled Students</p>
                            <p className="text-2xl font-bold text-slate-50">0</p>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <Card className="border-slate-800/60 bg-slate-900/40">
                <CardHeader className="flex flex-row items-center justify-between border-b border-slate-800 pb-4">
                    <CardTitle>Subject Directory</CardTitle>
                    <div className="relative w-64">
                        <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-500" />
                        <Input placeholder="Search subjects..." className="pl-9 h-9 bg-slate-800/50" />
                    </div>
                </CardHeader>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm text-left">
                            <thead className="text-xs text-slate-400 uppercase bg-slate-900/50 border-b border-slate-800">
                                <tr>
                                    <th className="px-6 py-4 font-medium">Code</th>
                                    <th className="px-6 py-4 font-medium">Subject Name</th>
                                    <th className="px-6 py-4 font-medium">Hours/Week</th>
                                    <th className="px-6 py-4 font-medium">Primary Faculty</th>
                                    <th className="px-6 py-4 font-medium">Students</th>
                                    <th className="px-6 py-4 font-medium text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-800/50">
                                {isLoading ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-8 text-center">
                                            <Loader2 className="w-6 h-6 animate-spin text-slate-500 mx-auto" />
                                        </td>
                                    </tr>
                                ) : subjects.length === 0 ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-8 text-center text-slate-500">
                                            No subjects found.
                                        </td>
                                    </tr>
                                ) : (
                                    subjects.map((subject) => (
                                        <tr key={subject.id} className="hover:bg-slate-800/30 transition-colors">
                                            <td className="px-6 py-4 font-medium text-indigo-400">{subject.code}</td>
                                            <td className="px-6 py-4 text-slate-200">{subject.name}</td>
                                            <td className="px-6 py-4 text-slate-300">{subject.hoursPerWeek}</td>
                                            <td className="px-6 py-4 text-slate-300">{subject.faculty}</td>
                                            <td className="px-6 py-4 text-slate-300">{subject.students}</td>
                                            <td className="px-6 py-4 text-right">
                                                <Button variant="ghost" size="sm" className="h-8 text-xs mr-2" onClick={() => openEditModal(subject)}>Edit</Button>
                                                <Button variant="ghost" size="sm" className="h-8 text-xs text-red-400 hover:text-red-300 hover:bg-red-500/10" onClick={() => handleDeleteSubject(subject.id)}>
                                                    <Trash2 className="w-4 h-4" />
                                                </Button>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>

            {/* Add Subject Modal */}
            {isAddModalOpen && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
                    <div className="bg-slate-900 border border-slate-800 rounded-xl shadow-2xl w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="flex items-center justify-between p-6 border-b border-slate-800">
                            <h2 className="text-lg font-semibold text-slate-50">Add New Subject</h2>
                            <button onClick={() => setIsAddModalOpen(false)} className="text-slate-400 hover:text-slate-200 transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleAddSubject} className="p-6 space-y-4">
                            {error && (
                                <div className="p-3 bg-red-500/10 border border-red-500/50 rounded-lg text-red-500 text-sm">
                                    {error}
                                </div>
                            )}
                            <div className="space-y-2">
                                <label htmlFor="code" className="text-sm font-medium text-slate-300">Subject Code</label>
                                <Input
                                    id="code"
                                    placeholder="e.g. CS101"
                                    value={newSubject.code}
                                    onChange={(e) => setNewSubject({ ...newSubject, code: e.target.value })}
                                    className="bg-slate-800 border-slate-700"
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label htmlFor="name" className="text-sm font-medium text-slate-300">Subject Name</label>
                                <Input
                                    id="name"
                                    placeholder="e.g. Introduction to Computer Science"
                                    value={newSubject.name}
                                    onChange={(e) => setNewSubject({ ...newSubject, name: e.target.value })}
                                    className="bg-slate-800 border-slate-700"
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label htmlFor="hoursPerWeek" className="text-sm font-medium text-slate-300">Hours Per Week</label>
                                <Input
                                    id="hoursPerWeek"
                                    type="number"
                                    min="1"
                                    max="10"
                                    value={newSubject.hoursPerWeek}
                                    onChange={(e) => setNewSubject({ ...newSubject, hoursPerWeek: e.target.value })}
                                    className="bg-slate-800 border-slate-700"
                                    required
                                />
                            </div>
                            <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-slate-800">
                                <Button type="button" variant="ghost" onClick={() => setIsAddModalOpen(false)}>
                                    Cancel
                                </Button>
                                <Button type="submit" className="bg-indigo-600 hover:bg-indigo-700" disabled={isSubmitting}>
                                    {isSubmitting ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
                                    Add Subject
                                </Button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Edit Subject Modal */}
            {isEditModalOpen && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
                    <div className="bg-slate-900 border border-slate-800 rounded-xl shadow-2xl w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="flex items-center justify-between p-6 border-b border-slate-800">
                            <h2 className="text-lg font-semibold text-slate-50">Edit Subject</h2>
                            <button onClick={() => setIsEditModalOpen(false)} className="text-slate-400 hover:text-slate-200 transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleEditSubject} className="p-6 space-y-4">
                            {error && (
                                <div className="p-3 bg-red-500/10 border border-red-500/50 rounded-lg text-red-500 text-sm">
                                    {error}
                                </div>
                            )}
                            <div className="space-y-2">
                                <label htmlFor="edit-code" className="text-sm font-medium text-slate-300">Subject Code</label>
                                <Input
                                    id="edit-code"
                                    placeholder="e.g. CS101"
                                    value={editingSubject.code}
                                    onChange={(e) => setEditingSubject({ ...editingSubject, code: e.target.value })}
                                    className="bg-slate-800 border-slate-700"
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label htmlFor="edit-name" className="text-sm font-medium text-slate-300">Subject Name</label>
                                <Input
                                    id="edit-name"
                                    placeholder="e.g. Introduction to Computer Science"
                                    value={editingSubject.name}
                                    onChange={(e) => setEditingSubject({ ...editingSubject, name: e.target.value })}
                                    className="bg-slate-800 border-slate-700"
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label htmlFor="edit-hoursPerWeek" className="text-sm font-medium text-slate-300">Hours Per Week</label>
                                <Input
                                    id="edit-hoursPerWeek"
                                    type="number"
                                    min="1"
                                    max="10"
                                    value={editingSubject.hoursPerWeek}
                                    onChange={(e) => setEditingSubject({ ...editingSubject, hoursPerWeek: e.target.value })}
                                    className="bg-slate-800 border-slate-700"
                                    required
                                />
                            </div>
                            <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-slate-800">
                                <Button type="button" variant="ghost" onClick={() => setIsEditModalOpen(false)}>
                                    Cancel
                                </Button>
                                <Button type="submit" className="bg-indigo-600 hover:bg-indigo-700" disabled={isSubmitting}>
                                    {isSubmitting ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
                                    Save Changes
                                </Button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            <BulkImportModal
                isOpen={isBulkImportOpen}
                onClose={() => setIsBulkImportOpen(false)}
                onImport={handleBulkImport}
            />
        </div>
    )
}
