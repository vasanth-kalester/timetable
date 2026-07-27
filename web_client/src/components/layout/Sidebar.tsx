"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { LayoutDashboard, Calendar, GraduationCap, Building2, BarChart3, Settings, LogOut, Network, Layers, Users, X } from "lucide-react"
import { cn } from "@/components/ui/Button"
import { useSession } from "next-auth/react"

const navigation = [
    { name: "Command Center", href: "/admin", icon: LayoutDashboard, roles: ['admin'] },
    { name: "Institutions", href: "/admin/institutions", icon: Building2, roles: ['admin'] },
    { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard, roles: ['principal', 'hod', 'faculty'] },
    { name: "Departments", href: "/departments", icon: Layers, roles: ['principal'] },
    { name: "Staff", href: "/staff", icon: Users, roles: ['principal', 'hod'] },
    { name: "Academic", href: "/academic", icon: GraduationCap, roles: ['principal', 'hod', 'faculty'] },
    { name: "Timetable", href: "/timetable", icon: Calendar, roles: ['principal', 'hod', 'faculty'] },
    { name: "Manage Timetable", href: "/timetable/manage", icon: Settings, roles: ['hod'] },
    { name: "Schedule Timetable", href: "/timetable/schedule", icon: Calendar, roles: ['hod'] },
    { name: "Campus", href: "/campus", icon: Building2, roles: ['principal'] },
    { name: "Analytics", href: "/analytics", icon: BarChart3, roles: ['principal', 'hod', 'faculty', 'admin'] },
]

interface SidebarProps {
    isOpen?: boolean;
    onClose?: () => void;
}

export function Sidebar({ isOpen = false, onClose }: SidebarProps) {
    const pathname = usePathname()
    const { data: session } = useSession()
    const [userRole, setUserRole] = useState<string | null>(null)

    useEffect(() => {
        if (session?.user) {
            setUserRole((session.user as any).role || "student")
        }
    }, [session])

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
                "fixed inset-y-0 left-0 z-50 flex h-full w-64 flex-col bg-slate-900 border-r border-slate-800 transform transition-transform duration-300 ease-in-out md:relative md:translate-x-0",
                isOpen ? "translate-x-0" : "-translate-x-full"
            )}>
                <div className="flex h-16 items-center justify-between px-6 border-b border-slate-800">
                    <div className="flex items-center gap-2">
                        <div className="bg-indigo-600 p-1.5 rounded-lg">
                            <Network className="w-5 h-5 text-white" />
                        </div>
                        <span className="text-lg font-bold text-slate-50 tracking-tight">EduFlow OS</span>
                    </div>
                    {/* Close button for mobile */}
                    <button
                        onClick={onClose}
                        className="md:hidden p-1 text-slate-400 hover:text-slate-200 transition-colors"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                <div className="flex-1 overflow-y-auto py-4 px-3 space-y-1">
                    {(() => {
                        const visibleItems = navigation.filter(item => userRole && item.roles.includes(userRole))
                        const activeItem = visibleItems.reduce((prev, current) => {
                            if (pathname.startsWith(current.href) && current.href.length > (prev?.href.length || 0)) {
                                return current
                            }
                            return prev
                        }, null as any)

                        return visibleItems.map((item) => {
                            const isActive = activeItem?.name === item.name
                            return (
                                <Link
                                    key={item.name}
                                    href={item.href}
                                    onClick={() => {
                                        if (window.innerWidth < 768 && onClose) {
                                            onClose();
                                        }
                                    }}
                                    className={cn(
                                        "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors",
                                        isActive
                                            ? "bg-indigo-600/10 text-indigo-400"
                                            : "text-slate-400 hover:bg-slate-800/50 hover:text-slate-200"
                                    )}
                                >
                                    <item.icon className={cn("w-5 h-5", isActive ? "text-indigo-400" : "text-slate-500")} />
                                    {item.name}
                                </Link>
                            )
                        })
                    })()}
                </div>

                <div className="p-4 border-t border-slate-800 space-y-1">
                    <Link
                        href="/settings"
                        onClick={() => {
                            if (window.innerWidth < 768 && onClose) {
                                onClose();
                            }
                        }}
                        className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-slate-400 hover:bg-slate-800/50 hover:text-slate-200 transition-colors"
                    >
                        <Settings className="w-5 h-5 text-slate-500" />
                        Settings
                    </Link>
                    <Link
                        href="/login"
                        className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-red-400 hover:bg-red-500/10 transition-colors"
                    >
                        <LogOut className="w-5 h-5 text-red-400/70" />
                        Sign Out
                    </Link>
                </div>
            </div>
        </>
    )
}
