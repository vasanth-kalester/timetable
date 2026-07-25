"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { BookOpen, Clock, Calendar, Award } from "lucide-react"

export function StudentDashboard({ firstName }: { firstName: string }) {
    const stats = [
        { name: "Classes Today", value: "4", icon: BookOpen, color: "text-blue-500", bg: "bg-blue-500/10" },
        { name: "Attendance", value: "92%", icon: Clock, color: "text-emerald-500", bg: "bg-emerald-500/10" },
        { name: "Upcoming Exams", value: "1", icon: Calendar, color: "text-amber-500", bg: "bg-amber-500/10" },
        { name: "CGPA", value: "8.5", icon: Award, color: "text-purple-500", bg: "bg-purple-500/10" },
    ]

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-50">Welcome, {firstName}</h1>
                <p className="text-slate-400 mt-2">Here is your academic overview for today.</p>
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
                        <CardTitle className="flex items-center gap-2"><Calendar className="w-5 h-5 text-indigo-400" /> Today's Timetable</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            <div className="flex justify-between items-center p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                <div>
                                    <p className="font-bold text-slate-200">Software Engineering</p>
                                    <p className="text-sm text-slate-400">CS401 • Room 301</p>
                                </div>
                                <div className="text-right">
                                    <p className="font-bold text-indigo-400">09:00 AM</p>
                                    <p className="text-xs text-slate-500">Prof. Davis</p>
                                </div>
                            </div>
                            <div className="flex justify-between items-center p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                <div>
                                    <p className="font-bold text-slate-200">Computer Networks</p>
                                    <p className="text-sm text-slate-400">CS405 • Room 302</p>
                                </div>
                                <div className="text-right">
                                    <p className="font-bold text-indigo-400">11:00 AM</p>
                                    <p className="text-xs text-slate-500">Dr. Wilson</p>
                                </div>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2"><Award className="w-5 h-5 text-amber-400" /> Notice Board</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            <div className="p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                <p className="font-bold text-slate-200">Mid-Term Exam Schedule</p>
                                <p className="text-sm text-slate-400 mt-1">The schedule for the upcoming mid-term exams has been published.</p>
                                <p className="text-xs text-slate-500 mt-2">Posted 1 day ago</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}
