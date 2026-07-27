"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { BarChart3, TrendingUp, Users, BookOpen, Building2, GraduationCap, Loader2 } from "lucide-react"
import { getAnalyticsData } from "@/app/actions/analytics"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts'

const COLORS = ['#6366f1', '#10b981', '#f59e0b', '#ef4444'];

export default function AnalyticsPage() {
    const [data, setData] = useState<any>(null)
    const [isLoading, setIsLoading] = useState(true)

    useEffect(() => {
        getAnalyticsData().then(result => {
            if (!result.error) setData(result)
            setIsLoading(false)
        })
    }, [])

    if (isLoading) {
        return (
            <div className="flex h-full items-center justify-center">
                <Loader2 className="w-8 h-8 animate-spin text-indigo-500" />
            </div>
        )
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-on-surface">Executive Analytics</h1>
                <p className="text-on-surface-variant mt-2">Comprehensive data visualization for campus operations.</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {[
                    { title: "Total Students", value: data?.stats?.totalStudents || 0, trend: "+5%", icon: Users, color: "text-primary", bg: "bg-primary/10" },
                    { title: "Total Faculty", value: data?.stats?.totalFaculty || 0, trend: "+2%", icon: GraduationCap, color: "text-secondary", bg: "bg-secondary/10" },
                    { title: "Departments", value: data?.stats?.totalDepts || 0, trend: "Stable", icon: BookOpen, color: "text-tertiary", bg: "bg-tertiary/10" },
                    { title: "Total Rooms", value: data?.stats?.totalRooms || 0, trend: "Stable", icon: Building2, color: "text-primary", bg: "bg-primary/10" },
                ].map((stat, i) => (
                    <Card key={i}>
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-on-surface-variant">{stat.title}</p>
                                <div className="flex items-baseline gap-2 mt-1">
                                    <p className="text-2xl font-bold text-on-surface">{stat.value}</p>
                                    <span className={`text-xs font-medium ${stat.trend.startsWith('+') ? 'text-tertiary' : 'text-on-surface-variant'}`}>
                                        {stat.trend}
                                    </span>
                                </div>
                            </div>
                            <div className={`p-3 rounded-xl ${stat.bg}`}>
                                <stat.icon className={`w-6 h-6 ${stat.color}`} />
                            </div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <Card className="h-96 flex flex-col">
                    <CardHeader>
                        <CardTitle>Weekly Attendance Trends</CardTitle>
                    </CardHeader>
                    <CardContent className="flex-1 mt-2">
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={data?.attendanceTrends || []}>
                                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f8" vertical={false} />
                                <XAxis dataKey="name" stroke="#737686" fontSize={12} tickLine={false} axisLine={false} />
                                <YAxis stroke="#737686" fontSize={12} tickLine={false} axisLine={false} domain={[0, 100]} />
                                <Tooltip
                                    contentStyle={{ backgroundColor: '#ffffff', borderColor: '#c3c6d7', color: '#151c27' }}
                                    itemStyle={{ color: '#004ac6' }}
                                />
                                <Bar dataKey="attendance" fill="#004ac6" radius={[4, 4, 0, 0]} />
                            </BarChart>
                        </ResponsiveContainer>
                    </CardContent>
                </Card>

                <Card className="h-96 flex flex-col">
                    <CardHeader>
                        <CardTitle>Resource Allocation</CardTitle>
                    </CardHeader>
                    <CardContent className="flex-1 mt-2">
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie
                                    data={data?.resourceAllocation || []}
                                    cx="50%"
                                    cy="50%"
                                    innerRadius={60}
                                    outerRadius={100}
                                    paddingAngle={5}
                                    dataKey="value"
                                >
                                    {(data?.resourceAllocation || []).map((entry: any, index: number) => (
                                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                    ))}
                                </Pie>
                                <Tooltip
                                    contentStyle={{ backgroundColor: '#ffffff', borderColor: '#c3c6d7', color: '#151c27' }}
                                />
                                <Legend verticalAlign="bottom" height={36} iconType="circle" />
                            </PieChart>
                        </ResponsiveContainer>
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}
