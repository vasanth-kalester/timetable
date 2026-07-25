"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { User, Mail, Building2, Shield, Save, Loader2, AlertTriangle, Trash2 } from "lucide-react"
import { useSession, signOut } from "next-auth/react"
import { getProfile, updateProfile, deleteAccount } from "@/app/actions/settings"
import { useRouter } from "next/navigation"

export default function SettingsPage() {
    const { data: session } = useSession()
    const router = useRouter()
    const [isLoading, setIsLoading] = useState(false)
    const [isSaving, setIsSaving] = useState(false)
    const [isDeleting, setIsDeleting] = useState(false)
    const [showDeleteConfirm, setShowDeleteConfirm] = useState(false)
    const [message, setMessage] = useState<{ type: 'success' | 'error', text: string } | null>(null)

    const [profile, setProfile] = useState({
        first_name: "",
        last_name: "",
        role: "",
        email: "",
        college_id: "",
        college_name: "",
        college_code: ""
    })

    useEffect(() => {
        async function loadProfile() {
            if (session?.user) {
                setIsLoading(true)
                const result = await getProfile((session.user as any).id)

                if (result.profile) {
                    setProfile(result.profile)
                }
                setIsLoading(false)
            }
        }

        loadProfile()
    }, [session])

    const handleSave = async () => {
        setIsSaving(true)
        setMessage(null)

        try {
            if (!session?.user) throw new Error("Not authenticated")

            const result = await updateProfile((session.user as any).id, {
                first_name: profile.first_name,
                last_name: profile.last_name
            })

            if (result.error) throw new Error(result.error)

            setMessage({ type: 'success', text: 'Profile updated successfully.' })
        } catch (error: any) {
            setMessage({ type: 'error', text: error.message || 'Failed to update profile.' })
        } finally {
            setIsSaving(false)
        }
    }

    const handleDeleteAccount = async () => {
        setIsDeleting(true)
        setMessage(null)

        try {
            if (!session?.user) throw new Error("Not authenticated")

            const result = await deleteAccount((session.user as any).id)
            if (result.error) throw new Error(result.error)

            await signOut({ redirect: false })
            router.push("/login")
        } catch (error: any) {
            setMessage({ type: 'error', text: error.message || 'Failed to delete account.' })
            setIsDeleting(false)
            setShowDeleteConfirm(false)
        }
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500 max-w-4xl mx-auto">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-50">Settings</h1>
                <p className="text-slate-400 mt-2">Manage your account settings and preferences.</p>
            </div>

            {message && (
                <div className={`p-4 rounded-lg border ${message.type === 'success' ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-400' : 'bg-red-500/10 border-red-500/20 text-red-400'}`}>
                    {message.text}
                </div>
            )}

            <div className="grid gap-6">
                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <User className="w-5 h-5 text-indigo-400" />
                            Personal Information
                        </CardTitle>
                        <CardDescription>Update your personal details.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        {isLoading ? (
                            <div className="flex justify-center py-8">
                                <Loader2 className="w-8 h-8 animate-spin text-indigo-500" />
                            </div>
                        ) : (
                            <>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div className="space-y-2">
                                        <label className="text-sm font-medium text-slate-300">First Name</label>
                                        <Input
                                            value={profile.first_name}
                                            onChange={e => setProfile({ ...profile, first_name: e.target.value })}
                                        />
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-sm font-medium text-slate-300">Last Name</label>
                                        <Input
                                            value={profile.last_name}
                                            onChange={e => setProfile({ ...profile, last_name: e.target.value })}
                                        />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-slate-300">Email Address</label>
                                    <div className="relative">
                                        <Mail className="absolute left-3 top-2.5 h-4 w-4 text-slate-500" />
                                        <Input value={profile.email} disabled className="pl-9 bg-slate-800/50 text-slate-400" />
                                    </div>
                                    <p className="text-xs text-slate-500">Email address cannot be changed.</p>
                                </div>

                                <div className="pt-4 flex justify-end">
                                    <Button onClick={handleSave} disabled={isSaving} className="bg-indigo-600 hover:bg-indigo-700 text-white">
                                        {isSaving ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : <Save className="w-4 h-4 mr-2" />}
                                        Save Changes
                                    </Button>
                                </div>
                            </>
                        )}
                    </CardContent>
                </Card>

                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Shield className="w-5 h-5 text-indigo-400" />
                            Account Role
                        </CardTitle>
                        <CardDescription>Your current role and permissions.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="p-4 rounded-lg bg-slate-800/50 border border-slate-700/50 flex items-center justify-between">
                            <div>
                                <p className="font-medium text-slate-200 capitalize">{profile.role || "Loading..."}</p>
                                <p className="text-sm text-slate-400 mt-1">This role determines your access level.</p>
                            </div>
                            <div className="p-2 bg-indigo-500/10 rounded-full">
                                <Building2 className="w-6 h-6 text-indigo-400" />
                            </div>
                        </div>
                    </CardContent>
                </Card>

                {profile.role && profile.role !== 'student' && (
                    <Card className="border-slate-800/60 bg-slate-900/40">
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Building2 className="w-5 h-5 text-indigo-400" />
                                College Information
                            </CardTitle>
                            <CardDescription>Your associated institution details.</CardDescription>
                        </CardHeader>
                        <CardContent>
                            {isLoading ? (
                                <div className="flex justify-center py-4">
                                    <Loader2 className="w-6 h-6 animate-spin text-indigo-500" />
                                </div>
                            ) : profile.college_name ? (
                                <div className="p-4 rounded-lg bg-slate-800/50 border border-slate-700/50 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
                                    <div>
                                        <p className="font-medium text-slate-200">{profile.college_name}</p>
                                        <p className="text-sm text-slate-400 mt-1">
                                            {profile.role === 'principal'
                                                ? "Share this code with your staff so they can join your college."
                                                : "This is the college you are currently affiliated with."}
                                        </p>
                                    </div>
                                    {profile.college_code && (
                                        <div className="p-3 bg-slate-950 rounded-lg border border-slate-800 text-center min-w-[120px]">
                                            <p className="text-xs text-slate-500 uppercase tracking-wider font-semibold mb-1">College Code</p>
                                            <p className="text-2xl font-black text-indigo-400 tracking-widest">{profile.college_code}</p>
                                        </div>
                                    )}
                                </div>
                            ) : (
                                <div className="p-4 rounded-lg bg-slate-800/30 border border-slate-700/50 text-center text-slate-500 text-sm">
                                    No college linked to your account yet. Please contact your administrator.
                                </div>
                            )}
                        </CardContent>
                    </Card>
                )}

                <Card className="border-red-500/30 bg-red-500/5 mt-8">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2 text-red-500">
                            <AlertTriangle className="w-5 h-5" />
                            Danger Zone
                        </CardTitle>
                        <CardDescription className="text-red-400/80">
                            Irreversible and destructive actions.
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="flex flex-col md:flex-row gap-4 items-start md:items-center justify-between p-4 rounded-lg bg-red-500/10 border border-red-500/20">
                            <div>
                                <h4 className="font-medium text-red-400">Delete Account</h4>
                                <p className="text-sm text-red-400/70 mt-1">
                                    Permanently delete your account and all associated data.
                                    {profile.role === 'principal' && " This will also delete your entire college and all staff accounts."}
                                </p>
                            </div>

                            {showDeleteConfirm ? (
                                <div className="flex items-center gap-2 w-full md:w-auto">
                                    <Button
                                        variant="outline"
                                        className="border-slate-700 hover:bg-slate-800"
                                        onClick={() => setShowDeleteConfirm(false)}
                                        disabled={isDeleting}
                                    >
                                        Cancel
                                    </Button>
                                    <Button
                                        className="bg-red-600 hover:bg-red-700 text-white"
                                        onClick={handleDeleteAccount}
                                        disabled={isDeleting}
                                    >
                                        {isDeleting ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : <Trash2 className="w-4 h-4 mr-2" />}
                                        Confirm Deletion
                                    </Button>
                                </div>
                            ) : (
                                <Button
                                    className="bg-red-600/20 hover:bg-red-600/30 text-red-400 border border-red-500/30 w-full md:w-auto"
                                    onClick={() => setShowDeleteConfirm(true)}
                                >
                                    Delete Account
                                </Button>
                            )}
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}
