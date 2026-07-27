"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Users, GraduationCap, Building2, Activity, Calendar, Clock, AlertTriangle, Loader2 } from "lucide-react"
import { getHodDashboardData } from "@/app/actions/hod"

export function HodDashboard({ firstName }: { firstName: string }) {
    const [data, setData] = useState<any>(null)
    const [isLoading, setIsLoading] = useState(true)

    useEffect(() => {
        getHodDashboardData().then(result => {
            if (!result.error) {
                setData(result)
            }
            setIsLoading(false)
        })
    }, [])

    const stats = [
        { name: "Department Students", value: data?.stats?.students?.toString() || "0", icon: Users, color: "text-blue-500", bg: "bg-blue-500/10" },
        { name: "Department Faculty", value: data?.stats?.faculty?.toString() || "0", icon: GraduationCap, color: "text-indigo-500", bg: "bg-indigo-500/10" },
        { name: "Active Courses", value: data?.stats?.activeCourses?.toString() || "0", icon: Building2, color: "text-emerald-500", bg: "bg-emerald-500/10" },
        { name: "Avg. Attendance", value: `${data?.stats?.avgAttendance || 0}%`, icon: Activity, color: "text-purple-500", bg: "bg-purple-500/10" },
    ]

    const schedule = data?.schedule || []
    const pendingApprovals = data?.pendingApprovals || []

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Welcome back, Prof. {firstName}</h1>
                    <p className="text-slate-400 mt-2">Here is your department overview for today.</p>
                </div>
                {isLoading && <Loader2 className="w-5 h-5 animate-spin text-indigo-500" />}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                {stats.map((stat) => (
                    <Card key={stat.name} className="border-slate-800/60 bg-slate-900/40 hover:bg-slate-800/40 transition-colors">
                        <CardContent className="p-6 flex items-center gap-4">
                            <div className={`p-3 rounded-xl ${stat.bg}`}>
                                <stat.icon className={`w-6 h-6 ${stat.color}`} />
                            </div>
                            <div>
                                <p className="text-sm font-medium text-slate-400">{stat.name}</p>
                                <h3 className="text-2xl font-bold text-slate-50">{isLoading ? "-" : stat.value}</h3>
                            </div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2"><Calendar className="w-5 h-5 text-indigo-400" /> Today's Schedule</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center py-4"><Loader2 className="w-6 h-6 animate-spin text-slate-500" /></div>
                            ) : schedule.length === 0 ? (
                                <p className="text-sm text-slate-500 text-center py-4">No schedule for today.</p>
                            ) : schedule.map((item: any) => (
                                <div key={item.id} className="flex justify-between items-center p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                    <div>
                                        <p className="font-bold text-slate-200">{item.title}</p>
                                        <p className="text-sm text-slate-400">{item.subtitle}</p>
                                    </div>
                                    <div className="text-right">
                                        <p className="font-bold text-indigo-400">{item.time}</p>
                                        <p className="text-xs text-slate-500">{item.duration}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2"><AlertTriangle className="w-5 h-5 text-amber-400" /> Pending Approvals</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center py-4"><Loader2 className="w-6 h-6 animate-spin text-slate-500" /></div>
                            ) : pendingApprovals.length === 0 ? (
                                <p className="text-sm text-slate-500 text-center py-4">No pending approvals.</p>
                            ) : pendingApprovals.map((item: any) => (
                                <div key={item.id} className="flex justify-between items-center p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                    <div>
                                        <p className="font-bold text-slate-200">{item.title}</p>
                                        <p className="text-sm text-slate-400">{item.subtitle}</p>
                                    </div>
                                    <button className="px-3 py-1 bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-bold rounded">Review</button>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}
