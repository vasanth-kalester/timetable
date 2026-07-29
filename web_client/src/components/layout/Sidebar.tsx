"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import {
    LayoutDashboard, Calendar, GraduationCap, Building2, BarChart3,
    Settings, LogOut, Network, Layers, Users, X, ChevronDown, ChevronRight,
    Pencil, ListTodo, Sparkles
} from "lucide-react"
import { cn } from "@/components/ui/Button"
import { useSession } from "next-auth/react"

const navigation = [
    { name: "Command Center", href: "/admin", icon: LayoutDashboard, roles: ['admin'] },
    { name: "Institutions", href: "/admin/institutions", icon: Building2, roles: ['admin'] },
    { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard, roles: ['principal', 'hod', 'faculty'] },
    { name: "Departments", href: "/departments", icon: Layers, roles: ['principal'] },
    { name: "Staff", href: "/staff", icon: Users, roles: ['principal', 'hod'] },
    { name: "Academic", href: "/academic", icon: GraduationCap, roles: ['principal', 'hod', 'faculty'] },
    // Timetable is handled separately as a collapsible group
    { name: "Campus", href: "/campus", icon: Building2, roles: ['principal'] },
    { name: "Analytics", href: "/analytics", icon: BarChart3, roles: ['principal', 'hod', 'faculty', 'admin'] },
]

// Timetable sub-nav items per role
const timetableSubNav = [
    { name: "View Timetable", href: "/timetable", icon: Calendar, roles: ['principal', 'hod', 'faculty'] },
    { name: "Setup Wizard", href: "/timetable/setup", icon: Sparkles, roles: ['principal', 'hod'] },
    { name: "Manage Data", href: "/timetable/manage", icon: ListTodo, roles: ['principal', 'hod'] },
]

interface SidebarProps {
    isOpen?: boolean;
    onClose?: () => void;
}

export function Sidebar({ isOpen = false, onClose }: SidebarProps) {
    const pathname = usePathname()
    const { data: session } = useSession()
    const [userRole, setUserRole] = useState<string | null>(null)

    const isTimetablePath = pathname.startsWith("/timetable")
    const [timetableOpen, setTimetableOpen] = useState(true)

    useEffect(() => {
        if (session?.user) {
            setUserRole((session.user as any).role || "student")
        }
    }, [session])

    useEffect(() => {
        if (isTimetablePath) setTimetableOpen(true)
    }, [pathname, isTimetablePath])

    const visibleSubNav = timetableSubNav.filter(item => userRole && item.roles.includes(userRole))
    const hasTimetableAccess = visibleSubNav.length > 0

    return (
        <>
            {/* Mobile Overlay */}
            {isOpen && (
                <div
                    className="fixed inset-0 bg-black/50 z-40 md:hidden backdrop-blur-sm"
                    onClick={onClose}
                />
            )}

            {/* Sidebar */}
            <div className={cn(
                "fixed inset-y-0 left-0 z-50 flex h-full w-64 flex-col bg-surface-container-lowest border-r border-outline-variant transform transition-transform duration-300 ease-in-out md:relative md:translate-x-0",
                isOpen ? "translate-x-0" : "-translate-x-full"
            )}>
                {/* Logo */}
                <div className="flex h-16 items-center justify-between px-6 border-b border-outline-variant shrink-0">
                    <div className="flex items-center gap-2">
                        <div className="bg-primary p-1.5 rounded-lg">
                            <Network className="w-5 h-5 text-on-primary" />
                        </div>
                        <span className="text-lg font-bold text-on-surface tracking-tight">EduFlow OS</span>
                    </div>
                    <button
                        onClick={onClose}
                        className="md:hidden p-1 text-on-surface-variant hover:text-on-surface transition-colors"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                {/* Nav */}
                <div className="flex-1 overflow-y-auto py-4 px-3 space-y-0.5">
                    {navigation.filter(item => userRole && item.roles.includes(userRole)).map(item => {
                        const isActive = pathname === item.href || (pathname.startsWith(item.href + "/") && item.href !== "/admin")
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                onClick={() => { if (window.innerWidth < 768 && onClose) onClose() }}
                                className={cn(
                                    "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors",
                                    isActive
                                        ? "bg-primary-container text-on-primary-container"
                                        : "text-on-surface-variant hover:bg-surface-container-low hover:text-on-surface"
                                )}
                            >
                                <item.icon className={cn("w-5 h-5 shrink-0", isActive ? "text-on-primary-container" : "text-outline")} />
                                {item.name}
                            </Link>
                        )
                    })}

                    {/* Timetable collapsible section */}
                    {hasTimetableAccess && (
                        <div>
                            <button
                                className={cn(
                                    "w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors",
                                    isTimetablePath
                                        ? "bg-primary-container text-on-primary-container"
                                        : "text-on-surface-variant hover:bg-surface-container-low hover:text-on-surface"
                                )}
                                onClick={() => setTimetableOpen(prev => !prev)}
                            >
                                <Calendar className={cn("w-5 h-5 shrink-0", isTimetablePath ? "text-on-primary-container" : "text-outline")} />
                                <span className="flex-1 text-left">Timetable</span>
                                {timetableOpen
                                    ? <ChevronDown className="w-4 h-4 shrink-0 opacity-60" />
                                    : <ChevronRight className="w-4 h-4 shrink-0 opacity-60" />
                                }
                            </button>

                            {/* Sub-items */}
                            {timetableOpen && (
                                <div className="ml-4 mt-0.5 space-y-0.5 border-l border-outline-variant pl-3">
                                    {visibleSubNav.map(item => {
                                        // Exact match for /timetable, prefix for sub-pages
                                        const isActive = item.href === "/timetable"
                                            ? pathname === "/timetable"
                                            : pathname.startsWith(item.href)
                                        return (
                                            <Link
                                                key={item.name}
                                                href={item.href}
                                                onClick={() => { if (window.innerWidth < 768 && onClose) onClose() }}
                                                className={cn(
                                                    "flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors",
                                                    isActive
                                                        ? "bg-primary/10 text-primary"
                                                        : "text-on-surface-variant hover:bg-surface-container-low hover:text-on-surface"
                                                )}
                                            >
                                                <item.icon className={cn("w-4 h-4 shrink-0", isActive ? "text-primary" : "text-outline")} />
                                                {item.name}
                                            </Link>
                                        )
                                    })}
                                </div>
                            )}
                        </div>
                    )}
                </div>

                {/* Bottom links */}
                <div className="p-4 border-t border-outline-variant space-y-1 shrink-0">
                    <Link
                        href="/settings"
                        onClick={() => { if (window.innerWidth < 768 && onClose) onClose() }}
                        className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-on-surface-variant hover:bg-surface-container-low hover:text-on-surface transition-colors"
                    >
                        <Settings className="w-5 h-5 text-outline" />
                        Settings
                    </Link>
                    <Link
                        href="/login"
                        className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-error hover:bg-error-container hover:text-on-error-container transition-colors"
                    >
                        <LogOut className="w-5 h-5" />
                        Sign Out
                    </Link>
                </div>
            </div>
        </>
    )
}
