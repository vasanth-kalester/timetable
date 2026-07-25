"use client"

import { useEffect, useState } from "react"
import { Bell, Search, Settings, LogOut } from "lucide-react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { Input } from "@/components/ui/Input"
import { signOut, useSession } from "next-auth/react"

export function Topbar() {
    const { data: session } = useSession()
    const [profile, setProfile] = useState<{ first_name: string, last_name: string, role: string, email: string, college_code?: string } | null>(null)
    const [isDropdownOpen, setIsDropdownOpen] = useState(false)
    const router = useRouter()

    useEffect(() => {
        if (session?.user) {
            // Fetch profile data from a new API route or Server Action
            // For now, we'll just use the session data
            setProfile({
                first_name: (session.user as any).name?.split(' ')[0] || "User",
                last_name: (session.user as any).name?.split(' ')[1] || "",
                role: (session.user as any).role || "student",
                email: session.user.email || "",
            })
        }
    }, [session])

    const fullName = profile ? `${profile.first_name} ${profile.last_name}` : "User"
    const initials = profile ? `${profile.first_name?.[0] || ""}${profile.last_name?.[0] || ""}`.toUpperCase() : "U"
    const roleDisplay = profile ? profile.role.charAt(0).toUpperCase() + profile.role.slice(1) : "Loading..."

    const handleSignOut = async () => {
        await signOut({ redirect: false })
        router.push("/login")
    }

    return (
        <header className="h-16 flex items-center justify-between px-8 bg-slate-900/50 backdrop-blur-md border-b border-slate-800 sticky top-0 z-50">
            <div className="flex items-center w-96">
                <div className="relative w-full">
                    <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-500" />
                    <Input
                        placeholder="Search students, courses, or resources..."
                        className="pl-9 h-9 bg-slate-800/50 border-slate-700/50 focus-visible:ring-indigo-500/50 rounded-full"
                    />
                </div>
            </div>

            <div className="flex items-center gap-4">
                <button className="relative p-2 text-slate-400 hover:text-slate-200 transition-colors rounded-full hover:bg-slate-800">
                    <Bell className="w-5 h-5" />
                    <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-indigo-500 rounded-full ring-2 ring-slate-900" />
                </button>

                <div className="h-8 w-px bg-slate-800 mx-2" />

                <div className="relative">
                    <div
                        className="flex items-center gap-3 cursor-pointer hover:bg-slate-800/50 p-1.5 rounded-lg transition-colors"
                        onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                    >
                        <div className="text-right hidden md:block">
                            <p className="text-sm font-medium text-slate-200 leading-none">{fullName}</p>
                            <p className="text-xs text-slate-500 mt-1">{roleDisplay}</p>
                        </div>
                        <div className="w-9 h-9 rounded-full bg-indigo-600 flex items-center justify-center text-white font-semibold shadow-inner">
                            {initials}
                        </div>
                    </div>

                    {isDropdownOpen && (
                        <>
                            <div
                                className="fixed inset-0 z-40"
                                onClick={() => setIsDropdownOpen(false)}
                            />
                            <div className="absolute right-0 mt-2 w-56 rounded-xl border border-slate-800 bg-slate-900/95 backdrop-blur-xl shadow-xl z-50 overflow-hidden animate-in fade-in slide-in-from-top-2">
                                <div className="p-3 border-b border-slate-800">
                                    <p className="text-sm font-medium text-slate-200">{fullName}</p>
                                    <p className="text-xs text-slate-500 truncate mt-0.5">{profile?.email}</p>
                                    {profile?.college_code && (
                                        <div className="mt-2 inline-flex items-center gap-1.5 px-2 py-1 rounded bg-indigo-500/10 border border-indigo-500/20">
                                            <span className="text-[10px] font-semibold text-indigo-400/70 uppercase tracking-wider">Code</span>
                                            <span className="text-xs font-bold text-indigo-400 tracking-widest">{profile.college_code}</span>
                                        </div>
                                    )}
                                </div>
                                <div className="p-1.5">
                                    <Link
                                        href="/settings"
                                        className="flex items-center gap-2 px-2.5 py-2 text-sm text-slate-300 hover:text-slate-100 hover:bg-slate-800 rounded-lg transition-colors"
                                        onClick={() => setIsDropdownOpen(false)}
                                    >
                                        <Settings className="w-4 h-4 text-slate-400" />
                                        Settings
                                    </Link>
                                </div>
                                <div className="p-1.5 border-t border-slate-800">
                                    <button
                                        onClick={handleSignOut}
                                        className="w-full flex items-center gap-2 px-2.5 py-2 text-sm text-red-400 hover:bg-red-500/10 rounded-lg transition-colors"
                                    >
                                        <LogOut className="w-4 h-4 text-red-400/70" />
                                        Sign Out
                                    </button>
                                </div>
                            </div>
                        </>
                    )}
                </div>
            </div>
        </header>
    )
}
