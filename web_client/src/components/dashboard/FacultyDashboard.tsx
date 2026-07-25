"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { BookOpen, Clock, Calendar, CheckCircle } from "lucide-react"

export function FacultyDashboard({ firstName }: { firstName: string }) {
    const stats = [
        { name: "Classes Today", value: "3", icon: BookOpen, color: "text-blue-500", bg: "bg-blue-500/10" },
        { name: "Weekly Hours", value: "18", icon: Clock, color: "text-indigo-500", bg: "bg-indigo-500/10" },
        { name: "Pending Tasks", value: "2", icon: Calendar, color: "text-amber-500", bg: "bg-amber-500/10" },
        { name: "Attendance Marked", value: "100%", icon: CheckCircle, color: "text-emerald-500", bg: "bg-emerald-500/10" },
    ]

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-50">Welcome, {firstName}</h1>
                <p className="text-slate-400 mt-2">Here is your schedule and tasks for today.</p>
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
                                <h3 className="text-2xl font-bold text-slate-50">{stat.value}</h3>
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
                            <div className="flex justify-between items-center p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                <div>
                                    <p className="font-bold text-slate-200">Database Systems</p>
                                    <p className="text-sm text-slate-400">CS302 • Room 204</p>
                                </div>
                                <div className="text-right">
                                    <p className="font-bold text-indigo-400">10:00 AM</p>
                                    <p className="text-xs text-slate-500">1 Hour</p>
                                </div>
                            </div>
                            <div className="flex justify-between items-center p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                <div>
                                    <p className="font-bold text-slate-200">Operating Systems</p>
                                    <p className="text-sm text-slate-400">CS305 • Room 205</p>
                                </div>
                                <div className="text-right">
                                    <p className="font-bold text-indigo-400">01:00 PM</p>
                                    <p className="text-xs text-slate-500">2 Hours</p>
                                </div>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2"><CheckCircle className="w-5 h-5 text-emerald-400" /> Recent Announcements</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            <div className="p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                <p className="font-bold text-slate-200">Faculty Meeting</p>
                                <p className="text-sm text-slate-400 mt-1">Mandatory meeting at 4 PM in the Seminar Hall.</p>
                                <p className="text-xs text-slate-500 mt-2">Posted 2 hours ago</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}
