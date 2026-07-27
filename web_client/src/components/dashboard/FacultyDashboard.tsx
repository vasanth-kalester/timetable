"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { BookOpen, Clock, Calendar, CheckCircle, Loader2 } from "lucide-react"
import { getFacultyDashboardData } from "@/app/actions/faculty"

export function FacultyDashboard({ firstName }: { firstName: string }) {
    const [data, setData] = useState<any>(null)
    const [isLoading, setIsLoading] = useState(true)

    useEffect(() => {
        getFacultyDashboardData().then(result => {
            if (!result.error) {
                setData(result)
            }
            setIsLoading(false)
        })
    }, [])

    const stats = [
        { name: "Classes Today", value: data?.stats?.classesToday?.toString() || "0", icon: BookOpen, color: "text-blue-500", bg: "bg-blue-500/10" },
        { name: "Weekly Hours", value: data?.stats?.weeklyHours?.toString() || "0", icon: Clock, color: "text-indigo-500", bg: "bg-indigo-500/10" },
        { name: "Pending Tasks", value: data?.stats?.pendingTasks?.toString() || "0", icon: Calendar, color: "text-amber-500", bg: "bg-amber-500/10" },
        { name: "Attendance Marked", value: `${data?.stats?.attendanceMarked || 0}%`, icon: CheckCircle, color: "text-emerald-500", bg: "bg-emerald-500/10" },
    ]

    const classes = data?.classes || []
    const announcements = data?.announcements || []

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Welcome, {firstName}</h1>
                    <p className="text-slate-400 mt-2">Here is your schedule and tasks for today.</p>
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
                        <CardTitle className="flex items-center gap-2"><Calendar className="w-5 h-5 text-indigo-400" /> Today's Classes</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center py-4"><Loader2 className="w-6 h-6 animate-spin text-slate-500" /></div>
                            ) : classes.length === 0 ? (
                                <p className="text-sm text-slate-500 text-center py-4">No classes scheduled for today.</p>
                            ) : classes.map((item: any) => (
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
                        <CardTitle className="flex items-center gap-2"><CheckCircle className="w-5 h-5 text-emerald-400" /> Recent Announcements</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center py-4"><Loader2 className="w-6 h-6 animate-spin text-slate-500" /></div>
                            ) : announcements.length === 0 ? (
                                <p className="text-sm text-slate-500 text-center py-4">No recent announcements.</p>
                            ) : announcements.map((item: any) => (
                                <div key={item.id} className="p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                    <p className="font-bold text-slate-200">{item.title}</p>
                                    <p className="text-sm text-slate-400 mt-1">{item.description}</p>
                                    <p className="text-xs text-slate-500 mt-2">{item.time}</p>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}
