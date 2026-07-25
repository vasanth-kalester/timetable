"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { BarChart3, TrendingUp, Users, BookOpen } from "lucide-react"

export default function AnalyticsPage() {
    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-50">Analytics & Insights</h1>
                <p className="text-slate-400 mt-2">Comprehensive data visualization for campus operations.</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {[
                    { title: "Average Attendance", value: "0%", trend: "0%", icon: Users, color: "text-blue-500" },
                    { title: "Resource Utilization", value: "0%", trend: "0%", icon: BarChart3, color: "text-indigo-500" },
                    { title: "Course Completion", value: "0%", trend: "0%", icon: BookOpen, color: "text-emerald-500" },
                    { title: "Overall Performance", value: "N/A", trend: "Stable", icon: TrendingUp, color: "text-purple-500" },
                ].map((stat, i) => (
                    <Card key={i} className="border-slate-800/60 bg-slate-900/40">
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-slate-400">{stat.title}</p>
                                <div className="flex items-baseline gap-2 mt-1">
                                    <p className="text-2xl font-bold text-slate-50">{stat.value}</p>
                                    <span className={`text-xs font-medium ${stat.trend.startsWith('+') ? 'text-emerald-400' : 'text-slate-400'}`}>
                                        {stat.trend}
                                    </span>
                                </div>
                            </div>
                            <div className={`p-3 rounded-xl bg-slate-800 ${stat.color}`}>
                                <stat.icon className="w-6 h-6" />
                            </div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <Card className="border-slate-800/60 bg-slate-900/40 h-96 flex flex-col">
                    <CardHeader>
                        <CardTitle>Attendance Trends</CardTitle>
                    </CardHeader>
                    <CardContent className="flex-1 flex items-center justify-center border-t border-slate-800/50 mt-2">
                        <div className="text-center space-y-2">
                            <BarChart3 className="w-12 h-12 text-slate-600 mx-auto" />
                            <p className="text-slate-400 text-sm">No data available.</p>
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-800/60 bg-slate-900/40 h-96 flex flex-col">
                    <CardHeader>
                        <CardTitle>Resource Allocation</CardTitle>
                    </CardHeader>
                    <CardContent className="flex-1 flex items-center justify-center border-t border-slate-800/50 mt-2">
                        <div className="text-center space-y-2">
                            <div className="w-32 h-32 rounded-full border-8 border-slate-800 mx-auto" />
                            <p className="text-slate-400 text-sm mt-4">No data available.</p>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}
