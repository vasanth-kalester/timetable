"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { LayoutDashboard, Calendar, GraduationCap, Building2, BarChart3, Settings, LogOut, Network, Layers, Users } from "lucide-react"
import { cn } from "@/components/ui/Button"

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

import { useSession } from "next-auth/react"

export function Sidebar() {
    const pathname = usePathname()
    const { data: session } = useSession()
    const [userRole, setUserRole] = useState<string | null>(null)

    useEffect(() => {
        if (session?.user) {
            setUserRole((session.user as any).role || "student")
        }
    }, [session])

    return (
        <div className="flex h-full w-64 flex-col bg-slate-900 border-r border-slate-800">
            <div className="flex h-16 items-center gap-2 px-6 border-b border-slate-800">
                <div className="bg-indigo-600 p-1.5 rounded-lg">
                    <Network className="w-5 h-5 text-white" />
                </div>
                <span className="text-lg font-bold text-slate-50 tracking-tight">EduFlow OS</span>
            </div>

            <div className="flex-1 overflow-y-auto py-4 px-3 space-y-1">
                {navigation.filter(item => userRole && item.roles.includes(userRole)).map((item) => {
                    const isActive = pathname.startsWith(item.href)
                    return (
                        <Link
                            key={item.name}
                            href={item.href}
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
                })}
            </div>

            <div className="p-4 border-t border-slate-800 space-y-1">
                <Link
                    href="/settings"
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
    )
}
