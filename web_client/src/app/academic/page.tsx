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
                    <h1 className="text-3xl font-bold tracking-tight text-on-surface">Academic Management</h1>
                    <p className="text-on-surface-variant mt-2">Manage subjects, curriculum, and faculty assignments.</p>
                </div>
                <div className="flex items-center gap-3">
                    <Button variant="outline" onClick={() => setIsBulkImportOpen(true)}>
                        <Upload className="w-4 h-4 mr-2" /> Bulk Import
                    </Button>
                    <Button onClick={() => { setError(null); setIsAddModalOpen(true); }}>
                        <Plus className="w-4 h-4 mr-2" /> Add Subject
                    </Button>
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <Card>
                    <CardContent className="p-6 flex items-center gap-4">
                        <div className="p-3 rounded-xl bg-primary/10">
                            <BookOpen className="w-6 h-6 text-primary" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-on-surface-variant">Total Subjects</p>
                            <p className="text-2xl font-bold text-on-surface">{isLoading ? "-" : subjects.length}</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-6 flex items-center gap-4">
                        <div className="p-3 rounded-xl bg-secondary/10">
                            <GraduationCap className="w-6 h-6 text-secondary" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-on-surface-variant">Active Faculty</p>
                            <p className="text-2xl font-bold text-on-surface">0</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-6 flex items-center gap-4">
                        <div className="p-3 rounded-xl bg-tertiary/10">
                            <Users className="w-6 h-6 text-tertiary" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-on-surface-variant">Enrolled Students</p>
                            <p className="text-2xl font-bold text-on-surface">0</p>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <Card>
                <CardHeader className="flex flex-row items-center justify-between border-b border-outline-variant pb-4">
                    <CardTitle>Subject Directory</CardTitle>
                    <div className="relative w-64">
                        <Search className="absolute left-3 top-2.5 h-4 w-4 text-outline" />
                        <Input placeholder="Search subjects..." className="pl-9 h-9 bg-surface-container-low border-outline-variant" />
                    </div>
                </CardHeader>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm text-left">
                            <thead className="text-xs text-on-surface-variant uppercase bg-surface-container-low border-b border-outline-variant">
                                <tr>
                                    <th className="px-6 py-4 font-medium">Code</th>
                                    <th className="px-6 py-4 font-medium">Subject Name</th>
                                    <th className="px-6 py-4 font-medium">Hours/Week</th>
                                    <th className="px-6 py-4 font-medium">Primary Faculty</th>
                                    <th className="px-6 py-4 font-medium">Students</th>
                                    <th className="px-6 py-4 font-medium text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-outline-variant">
                                {isLoading ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-8 text-center">
                                            <Loader2 className="w-6 h-6 animate-spin text-outline mx-auto" />
                                        </td>
                                    </tr>
                                ) : subjects.length === 0 ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-8 text-center text-on-surface-variant">
                                            No subjects found.
                                        </td>
                                    </tr>
                                ) : (
                                    subjects.map((subject) => (
                                        <tr key={subject.id} className="hover:bg-surface-container-low transition-colors">
                                            <td className="px-6 py-4 font-medium text-primary">{subject.code}</td>
                                            <td className="px-6 py-4 text-on-surface">{subject.name}</td>
                                            <td className="px-6 py-4 text-on-surface-variant">{subject.hoursPerWeek}</td>
                                            <td className="px-6 py-4 text-on-surface-variant">{subject.faculty}</td>
                                            <td className="px-6 py-4 text-on-surface-variant">{subject.students}</td>
                                            <td className="px-6 py-4 text-right">
                                                <Button variant="ghost" size="sm" className="h-8 text-xs mr-2" onClick={() => openEditModal(subject)}>Edit</Button>
                                                <Button variant="ghost" size="sm" className="h-8 text-xs text-error hover:text-on-error-container hover:bg-error-container" onClick={() => handleDeleteSubject(subject.id)}>
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
                    <div className="bg-surface-container-lowest border border-outline-variant rounded-xl shadow-2xl w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="flex items-center justify-between p-6 border-b border-outline-variant">
                            <h2 className="text-lg font-semibold text-on-surface">Add New Subject</h2>
                            <button onClick={() => setIsAddModalOpen(false)} className="text-on-surface-variant hover:text-on-surface transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleAddSubject} className="p-6 space-y-4">
                            {error && (
                                <div className="p-3 bg-error-container border border-error/50 rounded-lg text-on-error-container text-sm">
                                    {error}
                                </div>
                            )}
                            <div className="space-y-2">
                                <label htmlFor="code" className="text-sm font-medium text-on-surface-variant">Subject Code</label>
                                <Input
                                    id="code"
                                    placeholder="e.g. CS101"
                                    value={newSubject.code}
                                    onChange={(e) => setNewSubject({ ...newSubject, code: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label htmlFor="name" className="text-sm font-medium text-on-surface-variant">Subject Name</label>
                                <Input
                                    id="name"
                                    placeholder="e.g. Introduction to Computer Science"
                                    value={newSubject.name}
                                    onChange={(e) => setNewSubject({ ...newSubject, name: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label htmlFor="hoursPerWeek" className="text-sm font-medium text-on-surface-variant">Hours Per Week</label>
                                <Input
                                    id="hoursPerWeek"
                                    type="number"
                                    min="1"
                                    max="10"
                                    value={newSubject.hoursPerWeek}
                                    onChange={(e) => setNewSubject({ ...newSubject, hoursPerWeek: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-outline-variant">
                                <Button type="button" variant="ghost" onClick={() => setIsAddModalOpen(false)}>
                                    Cancel
                                </Button>
                                <Button type="submit" disabled={isSubmitting}>
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
                    <div className="bg-surface-container-lowest border border-outline-variant rounded-xl shadow-2xl w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="flex items-center justify-between p-6 border-b border-outline-variant">
                            <h2 className="text-lg font-semibold text-on-surface">Edit Subject</h2>
                            <button onClick={() => setIsEditModalOpen(false)} className="text-on-surface-variant hover:text-on-surface transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleEditSubject} className="p-6 space-y-4">
                            {error && (
                                <div className="p-3 bg-error-container border border-error/50 rounded-lg text-on-error-container text-sm">
                                    {error}
                                </div>
                            )}
                            <div className="space-y-2">
                                <label htmlFor="edit-code" className="text-sm font-medium text-on-surface-variant">Subject Code</label>
                                <Input
                                    id="edit-code"
                                    placeholder="e.g. CS101"
                                    value={editingSubject.code}
                                    onChange={(e) => setEditingSubject({ ...editingSubject, code: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label htmlFor="edit-name" className="text-sm font-medium text-on-surface-variant">Subject Name</label>
                                <Input
                                    id="edit-name"
                                    placeholder="e.g. Introduction to Computer Science"
                                    value={editingSubject.name}
                                    onChange={(e) => setEditingSubject({ ...editingSubject, name: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label htmlFor="edit-hoursPerWeek" className="text-sm font-medium text-on-surface-variant">Hours Per Week</label>
                                <Input
                                    id="edit-hoursPerWeek"
                                    type="number"
                                    min="1"
                                    max="10"
                                    value={editingSubject.hoursPerWeek}
                                    onChange={(e) => setEditingSubject({ ...editingSubject, hoursPerWeek: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-outline-variant">
                                <Button type="button" variant="ghost" onClick={() => setIsEditModalOpen(false)}>
                                    Cancel
                                </Button>
                                <Button type="submit" disabled={isSubmitting}>
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
