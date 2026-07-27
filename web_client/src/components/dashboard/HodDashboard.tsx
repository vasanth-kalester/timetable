"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Users, GraduationCap, Building2, Activity, Calendar, Clock, AlertTriangle, Loader2, X, CheckCircle2, XCircle } from "lucide-react"
import { getHodDashboardData } from "@/app/actions/hod"
import { getPendingLeaves, approveLeave } from "@/app/actions/leave"

export function HodDashboard({ firstName }: { firstName: string }) {
    const [data, setData] = useState<any>(null)
    const [pendingLeaves, setPendingLeaves] = useState<any[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [selectedLeave, setSelectedLeave] = useState<any>(null)
    const [isSubmitting, setIsSubmitting] = useState(false)

    const fetchData = async () => {
        setIsLoading(true)
        const [dashboardRes, leavesRes] = await Promise.all([
            getHodDashboardData(),
            getPendingLeaves()
        ])

        if (!dashboardRes.error) setData(dashboardRes)
        if (!leavesRes.error) setPendingLeaves(leavesRes.leaves || [])

        setIsLoading(false)
    }

    useEffect(() => {
        fetchData()
    }, [])

    const handleApproveLeave = async (status: "Approved" | "Rejected") => {
        if (!selectedLeave) return
        setIsSubmitting(true)

        // In a full implementation, we would collect substitute allocations here.
        // For now, we just approve/reject the leave.
        const result = await approveLeave(selectedLeave.id, status)

        if (result.success) {
            setSelectedLeave(null)
            fetchData()
        } else {
            alert(result.error)
        }
        setIsSubmitting(false)
    }

    const stats = [
        { name: "Department Students", value: data?.stats?.students?.toString() || "0", icon: Users, color: "text-blue-500", bg: "bg-blue-500/10" },
        { name: "Department Faculty", value: data?.stats?.faculty?.toString() || "0", icon: GraduationCap, color: "text-indigo-500", bg: "bg-indigo-500/10" },
        { name: "Active Courses", value: data?.stats?.activeCourses?.toString() || "0", icon: Building2, color: "text-emerald-500", bg: "bg-emerald-500/10" },
        { name: "Avg. Attendance", value: `${data?.stats?.avgAttendance || 0}%`, icon: Activity, color: "text-purple-500", bg: "bg-purple-500/10" },
    ]

    const schedule = data?.schedule || []

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
                        <CardTitle className="flex items-center gap-2"><AlertTriangle className="w-5 h-5 text-amber-400" /> Pending Leave Approvals</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center py-4"><Loader2 className="w-6 h-6 animate-spin text-slate-500" /></div>
                            ) : pendingLeaves.length === 0 ? (
                                <p className="text-sm text-slate-500 text-center py-4">No pending leave requests.</p>
                            ) : pendingLeaves.map((leave: any) => (
                                <div key={leave.id} className="flex justify-between items-center p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                    <div>
                                        <p className="font-bold text-slate-200">{leave.faculty?.name}</p>
                                        <p className="text-sm text-slate-400">{leave.leaveType} • {new Date(leave.startDate).toLocaleDateString()}</p>
                                    </div>
                                    <Button size="sm" className="bg-indigo-600 hover:bg-indigo-700 text-white" onClick={() => setSelectedLeave(leave)}>
                                        Review
                                    </Button>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Review Leave Modal */}
            {selectedLeave && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
                    <div className="bg-slate-900 border border-slate-800 rounded-xl shadow-2xl w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="flex items-center justify-between p-6 border-b border-slate-800">
                            <h2 className="text-lg font-semibold text-slate-50">Review Leave Request</h2>
                            <button onClick={() => setSelectedLeave(null)} className="text-slate-400 hover:text-slate-200 transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <div className="p-6 space-y-4">
                            <div>
                                <p className="text-sm text-slate-400">Faculty Member</p>
                                <p className="font-medium text-slate-200">{selectedLeave.faculty?.name}</p>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <p className="text-sm text-slate-400">Leave Type</p>
                                    <p className="font-medium text-slate-200">{selectedLeave.leaveType}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-slate-400">Duration</p>
                                    <p className="font-medium text-slate-200">
                                        {new Date(selectedLeave.startDate).toLocaleDateString()} - {new Date(selectedLeave.endDate).toLocaleDateString()}
                                    </p>
                                </div>
                            </div>
                            <div>
                                <p className="text-sm text-slate-400">Reason</p>
                                <div className="p-3 bg-slate-800/50 rounded-lg border border-slate-700 mt-1">
                                    <p className="text-sm text-slate-300">{selectedLeave.reason}</p>
                                </div>
                            </div>

                            <div className="bg-indigo-500/10 border border-indigo-500/20 rounded-lg p-4 mt-4">
                                <p className="text-sm text-indigo-300 font-medium mb-2">Substitute Allocation</p>
                                <p className="text-xs text-indigo-400/80">
                                    In a full implementation, you would select substitute teachers for {selectedLeave.faculty?.name}'s classes here before approving.
                                </p>
                            </div>

                            <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-slate-800">
                                <Button
                                    type="button"
                                    variant="outline"
                                    className="border-red-500/50 text-red-400 hover:bg-red-500/10 hover:text-red-300"
                                    onClick={() => handleApproveLeave("Rejected")}
                                    disabled={isSubmitting}
                                >
                                    <XCircle className="w-4 h-4 mr-2" /> Reject
                                </Button>
                                <Button
                                    type="button"
                                    className="bg-emerald-600 hover:bg-emerald-700 text-white"
                                    onClick={() => handleApproveLeave("Approved")}
                                    disabled={isSubmitting}
                                >
                                    {isSubmitting ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : <CheckCircle2 className="w-4 h-4 mr-2" />}
                                    Approve Leave
                                </Button>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}
