"use client"

import { useSession } from "next-auth/react"
import { useEffect, useState } from "react"
import { Card, CardContent } from "@/components/ui/Card"
import { Users, GraduationCap, Building2, Activity } from "lucide-react"
import { PrincipalDashboard } from "@/components/dashboard/PrincipalDashboard"

const hodStats = [
    { name: "Department Students", value: "0", icon: Users, color: "text-blue-500", bg: "bg-blue-500/10" },
    { name: "Department Faculty", value: "0", icon: GraduationCap, color: "text-indigo-500", bg: "bg-indigo-500/10" },
    { name: "Active Courses", value: "0", icon: Building2, color: "text-emerald-500", bg: "bg-emerald-500/10" },
    { name: "Avg. Attendance", value: "0%", icon: Activity, color: "text-purple-500", bg: "bg-purple-500/10" },
]

export default function DashboardPage() {
    const { data: session } = useSession()
    const [firstName, setFirstName] = useState("User")
    const [userRole, setUserRole] = useState<string | null>(null)

    useEffect(() => {
        if (session?.user) {
            setFirstName((session.user as any).name?.split(' ')[0] || "User")
            setUserRole((session.user as any).role || "student")
        }
    }, [session])

    if (userRole === 'principal') {
        return <PrincipalDashboard firstName={firstName} />
    }

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-50">Welcome back, {firstName}</h1>
                <p className="text-slate-400 mt-2">Here's what's happening today.</p>
            </div>

            {userRole === 'hod' && (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                    {hodStats.map((stat) => (
                        <Card key={stat.name} className="border-slate-800/60 bg-slate-900/40 hover:bg-slate-800/40 transition-colors">
                            <CardContent className="p-6 flex items-center gap-4">
                                <div className={`p-3 rounded-xl ${stat.bg}`}>
                                    <stat.icon className={`w-6 h-6 ${stat.color}`} />
                                </div>
                                <div>
                                    <p className="text-sm font-medium text-slate-400">{stat.name}</p>
                                    <h3 className="text-2xl font-bold text-slate-50">{stat.value}</h3>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}
        </div>
    )
}
