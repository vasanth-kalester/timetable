"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Users, CheckCircle2, XCircle, Loader2, AlertTriangle, Clock } from "lucide-react"
import { useSession } from "next-auth/react"
import { getStaff, updateStaffApproval, assignCrossDepartment, removeCrossDepartment } from "@/app/actions/staff"
import { getDepartments } from "@/app/actions/departments"

interface StaffProfile {
    id: string
    first_name: string
    last_name: string
    email: string
    role: string
    approval_status: string
    created_at: string
    faculty_id: string | null
    cross_departments: string[]
}

interface Department {
    id: string
    name: string
    code: string
}

export default function StaffPage() {
    const { data: session } = useSession()
    const [activeTab, setActiveTab] = useState<'pending' | 'active'>('pending')
    const [staff, setStaff] = useState<StaffProfile[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [userRole, setUserRole] = useState<string | null>(null)
    const [collegeId, setCollegeId] = useState<string | null>(null)
    const [departmentId, setDepartmentId] = useState<string | null>(null)
    const [error, setError] = useState<string | null>(null)
    const [processingId, setProcessingId] = useState<string | null>(null)
    const [departments, setDepartments] = useState<Department[]>([])
    const [selectedFaculty, setSelectedFaculty] = useState<StaffProfile | null>(null)
    const [isDeptModalOpen, setIsDeptModalOpen] = useState(false)

    useEffect(() => {
        async function loadUserAndCollege() {
            if (session?.user) {
                const role = (session.user as any).role
                setUserRole(role)
                if (role !== 'principal' && role !== 'hod' && activeTab === 'pending') {
                    setActiveTab('active')
                }

                // Fetch real collegeId and departmentId from profile
                const { getProfile } = await import("@/app/actions/settings")
                const result = await getProfile((session.user as any).id)

                if (result.profile?.college_id) {
                    setCollegeId(result.profile.college_id)
                    // We need to fetch departmentId from the profile as well
                    // Since getProfile doesn't return departmentId yet, we'll fetch it directly or update getProfile
                    // For now, let's assume it's in the profile object if we update getProfile
                    setDepartmentId((result.profile as any).department_id || null)

                    // Fetch departments for the college
                    const deptResult = await getDepartments(result.profile.college_id)
                    if (deptResult.departments) {
                        setDepartments(deptResult.departments)
                    }

                    fetchData(result.profile.college_id, role, (result.profile as any).department_id)
                } else {
                    setIsLoading(false)
                }
            }
        }
        loadUserAndCollege()
    }, [session, activeTab])

    const fetchData = async (cId: string, role: string, dId?: string) => {
        setIsLoading(true)
        setError(null)
        try {
            const statusFilter = activeTab === 'pending' ? 'pending' : 'approved'

            let targetRole: string | string[] = 'faculty'
            if (role === 'principal') {
                targetRole = activeTab === 'pending' ? 'hod' : ['hod', 'faculty']
            }

            const result = await getStaff(cId, statusFilter, targetRole, role === 'hod' ? dId : undefined)

            if (result.error) throw new Error(result.error)
            if (result.staff) setStaff(result.staff as any)
        } catch (err: any) {
            console.error(err)
            setError(err.message || "Failed to load staff data.")
        } finally {
            setIsLoading(false)
        }
    }

    const handleApproval = async (id: string, status: 'approved' | 'rejected') => {
        setProcessingId(id)
        try {
            const result = await updateStaffApproval(id, status)
            if (result.error) throw new Error(result.error)

            // Remove the processed user from the current list
            setStaff(staff.filter(s => s.id !== id))
        } catch (err: any) {
            alert(err.message || `Failed to ${status} user.`)
        } finally {
            setProcessingId(null)
        }
    }

    const handleToggleCrossDepartment = async (facultyId: string, deptId: string, isAssigned: boolean) => {
        setProcessingId(`dept-${facultyId}-${deptId}`)
        try {
            if (isAssigned) {
                await removeCrossDepartment(facultyId, deptId)
            } else {
                await assignCrossDepartment(facultyId, deptId)
            }

            // Update local state
            setStaff(staff.map(s => {
                if (s.faculty_id === facultyId) {
                    const newDepts = isAssigned
                        ? s.cross_departments.filter(id => id !== deptId)
                        : [...s.cross_departments, deptId]

                    // Also update selectedFaculty if it's the one being edited
                    if (selectedFaculty?.faculty_id === facultyId) {
                        setSelectedFaculty({ ...s, cross_departments: newDepts })
                    }

                    return { ...s, cross_departments: newDepts }
                }
                return s
            }))
        } catch (err: any) {
            alert(err.message || "Failed to update department assignment.")
        } finally {
            setProcessingId(null)
        }
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500 max-w-5xl mx-auto">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-on-surface">Staff Directory</h1>
                <p className="text-on-surface-variant mt-2">Manage your college's faculty and staff members.</p>
            </div>

            {error && (
                <div className="p-3 rounded-lg bg-error-container border border-error/20 text-on-error-container text-sm flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4" />
                    {error}
                </div>
            )}

            <div className="flex p-1 bg-surface-container-low border border-outline-variant rounded-lg w-full max-w-md">
                {(userRole === 'principal' || userRole === 'hod') && (
                    <button
                        className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors flex items-center justify-center gap-2 ${activeTab === 'pending' ? 'bg-primary text-on-primary shadow' : 'text-on-surface-variant hover:text-on-surface'}`}
                        onClick={() => setActiveTab('pending')}
                    >
                        <Clock className="w-4 h-4" />
                        Pending Approvals
                    </button>
                )}
                <button
                    className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors flex items-center justify-center gap-2 ${activeTab === 'active' ? 'bg-primary text-on-primary shadow' : 'text-on-surface-variant hover:text-on-surface'}`}
                    onClick={() => setActiveTab('active')}
                >
                    <Users className="w-4 h-4" />
                    Active Staff
                </button>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>{activeTab === 'pending' ? 'Pending Registrations' : 'Active Staff Members'}</CardTitle>
                    <CardDescription>
                        {activeTab === 'pending'
                            ? "Review and approve staff members who have requested to join your college."
                            : "View all currently approved staff members."}
                    </CardDescription>
                </CardHeader>
                <CardContent className="p-0">
                    {isLoading ? (
                        <div className="flex justify-center py-12">
                            <Loader2 className="w-8 h-8 animate-spin text-primary" />
                        </div>
                    ) : staff.length === 0 ? (
                        <div className="text-center py-12">
                            {activeTab === 'pending' ? (
                                <>
                                    <CheckCircle2 className="w-12 h-12 text-tertiary/50 mx-auto mb-4" />
                                    <h3 className="text-lg font-medium text-on-surface">All caught up!</h3>
                                    <p className="text-on-surface-variant mt-1">There are no pending staff registrations to review.</p>
                                </>
                            ) : (
                                <>
                                    <Users className="w-12 h-12 text-on-surface-variant mx-auto mb-4" />
                                    <h3 className="text-lg font-medium text-on-surface">No active staff</h3>
                                    <p className="text-on-surface-variant mt-1">You don't have any approved staff members yet.</p>
                                </>
                            )}
                        </div>
                    ) : (
                        <div className="divide-y divide-outline-variant/40">
                            {staff.map((member) => (
                                <div key={member.id} className="p-4 flex flex-col md:flex-row md:items-center justify-between gap-4 hover:bg-surface-container-low transition-colors">
                                    <div className="flex items-center gap-4">
                                        <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center border border-primary/20">
                                            <span className="font-bold text-primary uppercase">
                                                {member.first_name.charAt(0)}{member.last_name.charAt(0)}
                                            </span>
                                        </div>
                                        <div>
                                            <h4 className="font-medium text-on-surface">{member.first_name} {member.last_name}</h4>
                                            <div className="flex items-center gap-2 mt-0.5">
                                                <p className="text-xs text-on-surface-variant">{member.email}</p>
                                                <span className="w-1 h-1 rounded-full bg-outline-variant"></span>
                                                <p className="text-xs font-medium text-primary/80 capitalize">{member.role}</p>
                                            </div>
                                        </div>
                                    </div>

                                    {activeTab === 'pending' && (userRole === 'principal' || userRole === 'hod') && (
                                        <div className="flex items-center gap-2">
                                            <Button
                                                variant="outline"
                                                className="border-error/30 text-error hover:bg-error-container hover:text-error"
                                                onClick={() => handleApproval(member.id, 'rejected')}
                                                disabled={processingId === member.id}
                                            >
                                                {processingId === member.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <XCircle className="w-4 h-4 mr-2" />}
                                                Reject
                                            </Button>
                                            <Button
                                                className="bg-tertiary hover:bg-tertiary/90 text-white"
                                                onClick={() => handleApproval(member.id, 'approved')}
                                                disabled={processingId === member.id}
                                            >
                                                {processingId === member.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle2 className="w-4 h-4 mr-2" />}
                                                Approve
                                            </Button>
                                        </div>
                                    )}

                                    {activeTab === 'active' && member.role === 'faculty' && member.faculty_id && (userRole === 'principal' || userRole === 'hod') && (
                                        <div className="flex items-center gap-2">
                                            <Button
                                                variant="outline"
                                                size="sm"
                                                onClick={() => {
                                                    setSelectedFaculty(member)
                                                    setIsDeptModalOpen(true)
                                                }}
                                            >
                                                Manage Depts
                                            </Button>
                                        </div>
                                    )}
                                </div>
                            ))}
                        </div>
                    )}
                </CardContent>
            </Card>

            {/* Department Management Modal */}
            {isDeptModalOpen && selectedFaculty && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
                    <div className="bg-surface rounded-xl shadow-xl w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="p-6">
                            <h3 className="text-xl font-bold text-on-surface mb-2">
                                Cross-Department Teaching
                            </h3>
                            <p className="text-sm text-on-surface-variant mb-6">
                                Assign {selectedFaculty.first_name} {selectedFaculty.last_name} to teach in other departments.
                            </p>

                            <div className="space-y-3 max-h-[60vh] overflow-y-auto">
                                {departments.map(dept => {
                                    const isAssigned = selectedFaculty.cross_departments.includes(dept.id)
                                    // Don't show their primary department (assuming we know it, or just let them toggle any)
                                    // For now, show all and let them toggle
                                    return (
                                        <div key={dept.id} className="flex items-center justify-between p-3 rounded-lg border border-outline-variant/30 hover:bg-surface-container-low">
                                            <div>
                                                <p className="font-medium text-on-surface">{dept.name}</p>
                                                <p className="text-xs text-on-surface-variant">{dept.code}</p>
                                            </div>
                                            <Button
                                                variant={isAssigned ? "default" : "outline"}
                                                size="sm"
                                                className={isAssigned ? "bg-primary text-on-primary" : ""}
                                                onClick={() => handleToggleCrossDepartment(selectedFaculty.faculty_id!, dept.id, isAssigned)}
                                                disabled={processingId === `dept-${selectedFaculty.faculty_id}-${dept.id}`}
                                            >
                                                {processingId === `dept-${selectedFaculty.faculty_id}-${dept.id}` ? (
                                                    <Loader2 className="w-4 h-4 animate-spin" />
                                                ) : isAssigned ? (
                                                    "Assigned"
                                                ) : (
                                                    "Assign"
                                                )}
                                            </Button>
                                        </div>
                                    )
                                })}
                            </div>
                        </div>
                        <div className="bg-surface-container-low p-4 flex justify-end">
                            <Button variant="outline" onClick={() => setIsDeptModalOpen(false)}>
                                Close
                            </Button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}
