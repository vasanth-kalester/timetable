"use client"

import { useEffect, useState } from "react"
import { useParams, useRouter } from "next/navigation"
import { Building2, ArrowLeft, ShieldAlert, Trash2, Loader2, Users, GraduationCap, UserCog } from "lucide-react"
import { Button } from "@/components/ui/Button"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/Card"
import { getInstitutionDetails, removeUserFromInstitution } from "@/app/actions/admin"

export default function InstitutionDetailsPage() {
    const params = useParams()
    const router = useRouter()
    const collegeId = params.id as string

    const [college, setCollege] = useState<any>(null)
    const [users, setUsers] = useState<any[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [error, setError] = useState<string | null>(null)
    const [processingId, setProcessingId] = useState<string | null>(null)

    useEffect(() => {
        async function loadDetails() {
            setIsLoading(true)
            const result = await getInstitutionDetails(collegeId)
            if (result.error) {
                setError(result.error)
            } else {
                setCollege(result.college)
                setUsers(result.users || [])
            }
            setIsLoading(false)
        }
        loadDetails()
    }, [collegeId])

    const handleRemoveUser = async (userId: string) => {
        if (!confirm("Are you sure you want to remove this user? This action cannot be undone.")) return

        setProcessingId(userId)
        try {
            const result = await removeUserFromInstitution(userId)
            if (result.error) throw new Error(result.error)

            // Remove from local state
            setUsers(users.filter(u => u.id !== userId))
        } catch (err: any) {
            alert(err.message || "Failed to remove user.")
        } finally {
            setProcessingId(null)
        }
    }

    if (isLoading) {
        return <div className="flex justify-center py-24"><Loader2 className="w-8 h-8 animate-spin text-indigo-500" /></div>
    }

    if (error || !college) {
        return (
            <div className="p-6 md:p-8 max-w-7xl mx-auto space-y-6">
                <Button variant="ghost" onClick={() => router.push('/admin/institutions')} className="mb-4 text-on-surface-variant hover:text-on-surface">
                    <ArrowLeft className="w-4 h-4 mr-2" /> Back to Institutions
                </Button>
                <div className="p-4 rounded-lg bg-error-container border border-error/20 text-on-error-container flex items-center gap-3">
                    <ShieldAlert className="w-5 h-5" />
                    <p>{error || "College not found"}</p>
                </div>
            </div>
        )
    }

    const principals = users.filter(u => u.role === 'principal')
    const hods = users.filter(u => u.role === 'hod')
    const faculty = users.filter(u => u.role === 'faculty')

    const renderUserList = (title: string, userList: any[], icon: any) => (
        <Card className="mt-6">
            <CardHeader className="pb-3 border-b border-outline-variant/60">
                <div className="flex items-center gap-2">
                    {icon}
                    <CardTitle className="text-lg">{title}</CardTitle>
                    <span className="ml-auto bg-surface-container-high text-on-surface-variant text-xs py-0.5 px-2 rounded-full">{userList.length}</span>
                </div>
            </CardHeader>
            <CardContent className="p-0">
                {userList.length === 0 ? (
                    <div className="p-6 text-center text-on-surface-variant text-sm">No users found in this category.</div>
                ) : (
                    <div className="divide-y divide-outline-variant/60">
                        {userList.map(user => (
                            <div key={user.id} className="p-4 flex items-center justify-between hover:bg-surface-container-low transition-colors">
                                <div>
                                    <h4 className="font-medium text-on-surface">{user.name || "Unnamed User"}</h4>
                                    <div className="flex items-center gap-2 mt-1 text-xs text-on-surface-variant">
                                        <span>{user.email}</span>
                                        {user.department !== 'N/A' && (
                                            <>
                                                <span className="w-1 h-1 rounded-full bg-outline-variant"></span>
                                                <span>Dept ID: {user.department}</span>
                                            </>
                                        )}
                                        <span className="w-1 h-1 rounded-full bg-outline-variant"></span>
                                        <span className={`capitalize ${user.status === 'approved' ? 'text-tertiary/80' : 'text-amber-500/80'}`}>
                                            {user.status}
                                        </span>
                                    </div>
                                </div>
                                <Button
                                    variant="ghost"
                                    size="icon"
                                    className="text-on-surface-variant hover:text-error hover:bg-error-container"
                                    onClick={() => handleRemoveUser(user.id)}
                                    disabled={processingId === user.id}
                                >
                                    {processingId === user.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 className="w-4 h-4" />}
                                </Button>
                            </div>
                        ))}
                    </div>
                )}
            </CardContent>
        </Card>
    )

    return (
        <div className="p-6 md:p-8 max-w-5xl mx-auto space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <Button variant="ghost" onClick={() => router.push('/admin/institutions')} className="mb-2 text-on-surface-variant hover:text-on-surface -ml-4">
                <ArrowLeft className="w-4 h-4 mr-2" /> Back to Institutions
            </Button>

            <div className="flex items-start justify-between">
                <div>
                    <div className="flex items-center gap-3 mb-2">
                        <div className="p-2 bg-primary/10 rounded-lg border border-primary/20">
                            <Building2 className="w-6 h-6 text-primary" />
                        </div>
                        <h1 className="text-3xl font-bold tracking-tight text-on-surface">{college.name}</h1>
                    </div>
                    <p className="text-on-surface-variant flex items-center gap-2">
                        <span className="font-mono text-primary bg-primary/10 px-2 py-0.5 rounded text-sm border border-primary/20">Code: {college.code}</span>
                        <span>•</span>
                        <span>{users.length} Total Members</span>
                    </p>
                </div>
            </div>

            <div className="grid grid-cols-1 gap-6 mt-8">
                {renderUserList("Principals", principals, <ShieldAlert className="w-5 h-5 text-amber-500" />)}
                {renderUserList("Heads of Department (HODs)", hods, <UserCog className="w-5 h-5 text-primary" />)}
                {renderUserList("Faculty Members", faculty, <GraduationCap className="w-5 h-5 text-tertiary" />)}
            </div>
        </div>
    )
}
