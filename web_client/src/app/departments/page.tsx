"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { Layers, Plus, Pencil, Trash2, Loader2, AlertTriangle } from "lucide-react"
import { useSession } from "next-auth/react"
import { getDepartments, createDepartment, updateDepartment, deleteDepartment } from "@/app/actions/departments"

interface Department {
    id: string
    name: string
    code: string
    createdAt?: Date
}

export default function DepartmentsPage() {
    const { data: session } = useSession()
    const [departments, setDepartments] = useState<Department[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [userRole, setUserRole] = useState<string | null>(null)
    const [collegeId, setCollegeId] = useState<string | null>(null)

    // Form state
    const [isAdding, setIsAdding] = useState(false)
    const [editingId, setEditingId] = useState<string | null>(null)
    const [formData, setFormData] = useState({ name: "", code: "" })
    const [isSaving, setIsSaving] = useState(false)
    const [error, setError] = useState<string | null>(null)

    useEffect(() => {
        async function loadUserAndCollege() {
            if (session?.user) {
                setUserRole((session.user as any).role)

                // Fetch real collegeId from profile
                const { getProfile } = await import("@/app/actions/settings")
                const result = await getProfile((session.user as any).id)

                if (result.profile?.college_id) {
                    setCollegeId(result.profile.college_id)
                    fetchData(result.profile.college_id)
                } else {
                    setIsLoading(false)
                }
            }
        }
        loadUserAndCollege()
    }, [session])

    const fetchData = async (cId: string) => {
        setIsLoading(true)
        try {
            const result = await getDepartments(cId)
            if (result.departments) {
                setDepartments(result.departments as any)
            }
        } catch (err) {
            console.error(err)
        } finally {
            setIsLoading(false)
        }
    }

    const handleSave = async () => {
        if (!formData.name || !formData.code) {
            setError("Please fill in all fields.")
            return
        }
        if (!collegeId) {
            setError("No college associated with your account.")
            return
        }

        setIsSaving(true)
        setError(null)

        try {
            if (editingId) {
                const result = await updateDepartment(editingId, { name: formData.name, code: formData.code })
                if (result.error) throw new Error(result.error)
            } else {
                const result = await createDepartment({ name: formData.name, code: formData.code, collegeId })
                if (result.error) throw new Error(result.error)
            }

            setFormData({ name: "", code: "" })
            setIsAdding(false)
            setEditingId(null)
            await fetchData(collegeId)
        } catch (err: any) {
            setError(err.message || "Failed to save department.")
        } finally {
            setIsSaving(false)
        }
    }

    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to delete this department?")) return

        try {
            const result = await deleteDepartment(id)
            if (result.error) throw new Error(result.error)
            if (collegeId) await fetchData(collegeId)
        } catch (err: any) {
            alert(err.message || "Failed to delete department.")
        }
    }

    const startEdit = (dept: Department) => {
        setFormData({ name: dept.name, code: dept.code })
        setEditingId(dept.id)
        setIsAdding(true)
        setError(null)
    }

    const cancelEdit = () => {
        setFormData({ name: "", code: "" })
        setEditingId(null)
        setIsAdding(false)
        setError(null)
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500 max-w-5xl mx-auto">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-on-surface">Departments</h1>
                    <p className="text-on-surface-variant mt-2">Manage academic departments and faculties.</p>
                </div>
                {userRole === 'principal' && !isAdding && (
                    <Button onClick={() => setIsAdding(true)}>
                        <Plus className="w-4 h-4 mr-2" />
                        Add Department
                    </Button>
                )}
            </div>

            {error && (
                <div className="p-3 rounded-lg bg-error-container border border-error/20 text-on-error-container text-sm flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4" />
                    {error}
                </div>
            )}

            {isAdding && (
                <Card className="border-primary/30 bg-primary/5">
                    <CardHeader>
                        <CardTitle className="text-lg">{editingId ? "Edit Department" : "New Department"}</CardTitle>
                        <CardDescription>Enter the department details below.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-on-surface-variant">Department Name</label>
                                <Input
                                    placeholder="e.g. Computer Science"
                                    value={formData.name}
                                    onChange={e => setFormData({ ...formData, name: e.target.value })}
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-on-surface-variant">Department Code</label>
                                <Input
                                    placeholder="e.g. CS"
                                    value={formData.code}
                                    onChange={e => setFormData({ ...formData, code: e.target.value })}
                                />
                            </div>
                        </div>
                        <div className="flex justify-end gap-3 mt-6">
                            <Button variant="outline" onClick={cancelEdit} disabled={isSaving}>Cancel</Button>
                            <Button onClick={handleSave} disabled={isSaving}>
                                {isSaving ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
                                Save Department
                            </Button>
                        </div>
                    </CardContent>
                </Card>
            )}

            <Card>
                <CardContent className="p-0">
                    {isLoading ? (
                        <div className="flex justify-center py-12">
                            <Loader2 className="w-8 h-8 animate-spin text-primary" />
                        </div>
                    ) : departments.length === 0 ? (
                        <div className="text-center py-12">
                            <Layers className="w-12 h-12 text-on-surface-variant mx-auto mb-4" />
                            <h3 className="text-lg font-medium text-on-surface">No departments found</h3>
                            <p className="text-on-surface-variant mt-1">
                                {userRole === 'principal' ? "Get started by adding your first department." : "Your college hasn't added any departments yet."}
                            </p>
                        </div>
                    ) : (
                        <div className="divide-y divide-outline-variant/40">
                            {departments.map((dept) => (
                                <div key={dept.id} className="p-4 flex items-center justify-between hover:bg-surface-container-low transition-colors">
                                    <div className="flex items-center gap-4">
                                        <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center border border-primary/20">
                                            <span className="font-bold text-primary">{dept.code}</span>
                                        </div>
                                        <div>
                                            <h4 className="font-medium text-on-surface">{dept.name}</h4>
                                            <p className="text-xs text-on-surface-variant mt-0.5">ID: {dept.id.split('-')[0]}</p>
                                        </div>
                                    </div>
                                    {userRole === 'principal' && (
                                        <div className="flex items-center gap-2">
                                            <Button variant="ghost" size="icon" className="text-on-surface-variant hover:text-primary" onClick={() => startEdit(dept)}>
                                                <Pencil className="w-4 h-4" />
                                            </Button>
                                            <Button variant="ghost" size="icon" className="text-on-surface-variant hover:text-error" onClick={() => handleDelete(dept.id)}>
                                                <Trash2 className="w-4 h-4" />
                                            </Button>
                                        </div>
                                    )}
                                </div>
                            ))}
                        </div>
                    )}
                </CardContent>
            </Card>
        </div>
    )
}
