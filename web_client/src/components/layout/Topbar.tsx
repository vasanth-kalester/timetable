"use client"

import { useEffect, useState } from "react"
import { Bell, Search, Settings, LogOut, Menu } from "lucide-react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { Input } from "@/components/ui/Input"
import { signOut, useSession } from "next-auth/react"

interface TopbarProps {
    onMenuClick?: () => void;
}

export function Topbar({ onMenuClick }: TopbarProps) {
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
        <header className="h-16 flex items-center justify-between px-4 md:px-8 bg-surface-container-lowest/80 backdrop-blur-md border-b border-outline-variant sticky top-0 z-40">
            <div className="flex items-center gap-2 md:gap-4 w-full md:w-96">
                <button
                    onClick={onMenuClick}
                    className="md:hidden p-2 text-on-surface-variant hover:text-on-surface transition-colors rounded-lg hover:bg-surface-container-low"
                >
                    <Menu className="w-5 h-5" />
                </button>
                <div className="relative w-full max-w-[200px] md:max-w-full">
                    <Search className="absolute left-3 top-2.5 h-4 w-4 text-outline" />
                    <Input
                        placeholder="Search..."
                        className="pl-9 h-9 bg-surface-container-low border-outline-variant focus-visible:ring-primary/50 rounded-full text-sm md:placeholder:text-on-surface-variant placeholder:text-transparent md:placeholder:text-on-surface-variant"
                    />
                </div>
            </div>

            <div className="flex items-center gap-2 md:gap-4">
                <button className="relative p-2 text-on-surface-variant hover:text-on-surface transition-colors rounded-full hover:bg-surface-container-low">
                    <Bell className="w-5 h-5" />
                    <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-primary rounded-full ring-2 ring-surface-container-lowest" />
                </button>

                <div className="h-8 w-px bg-outline-variant mx-1 md:mx-2" />

                <div className="relative">
                    <div
                        className="flex items-center gap-3 cursor-pointer hover:bg-surface-container-low p-1.5 rounded-lg transition-colors"
                        onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                    >
                        <div className="text-right hidden md:block">
                            <p className="text-sm font-medium text-on-surface leading-none">{fullName}</p>
                            <p className="text-xs text-on-surface-variant mt-1">{roleDisplay}</p>
                        </div>
                        <div className="w-9 h-9 rounded-full bg-primary flex items-center justify-center text-on-primary font-semibold shadow-inner">
                            {initials}
                        </div>
                    </div>

                    {isDropdownOpen && (
                        <>
                            <div
                                className="fixed inset-0 z-40"
                                onClick={() => setIsDropdownOpen(false)}
                            />
                            <div className="absolute right-0 mt-2 w-56 rounded-xl border border-outline-variant bg-surface-container-lowest shadow-xl z-50 overflow-hidden animate-in fade-in slide-in-from-top-2">
                                <div className="p-3 border-b border-outline-variant">
                                    <p className="text-sm font-medium text-on-surface">{fullName}</p>
                                    <p className="text-xs text-on-surface-variant truncate mt-0.5">{profile?.email}</p>
                                    {profile?.college_code && (
                                        <div className="mt-2 inline-flex items-center gap-1.5 px-2 py-1 rounded bg-primary-container border border-primary-container">
                                            <span className="text-[10px] font-semibold text-on-primary-container uppercase tracking-wider">Code</span>
                                            <span className="text-xs font-bold text-on-primary-container tracking-widest">{profile.college_code}</span>
                                        </div>
                                    )}
                                </div>
                                <div className="p-1.5">
                                    <Link
                                        href="/settings"
                                        className="flex items-center gap-2 px-2.5 py-2 text-sm text-on-surface-variant hover:text-on-surface hover:bg-surface-container-low rounded-lg transition-colors"
                                        onClick={() => setIsDropdownOpen(false)}
                                    >
                                        <Settings className="w-4 h-4 text-outline" />
                                        Settings
                                    </Link>
                                </div>
                                <div className="p-1.5 border-t border-outline-variant">
                                    <button
                                        onClick={handleSignOut}
                                        className="w-full flex items-center gap-2 px-2.5 py-2 text-sm text-error hover:bg-error-container hover:text-on-error-container rounded-lg transition-colors"
                                    >
                                        <LogOut className="w-4 h-4" />
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
