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
        { name: "Department Students", value: data?.stats?.students?.toString() || "0", icon: Users, color: "text-primary", bg: "bg-primary/10" },
        { name: "Department Faculty", value: data?.stats?.faculty?.toString() || "0", icon: GraduationCap, color: "text-secondary", bg: "bg-secondary/10" },
        { name: "Active Courses", value: data?.stats?.activeCourses?.toString() || "0", icon: Building2, color: "text-tertiary", bg: "bg-tertiary/10" },
        { name: "Avg. Attendance", value: `${data?.stats?.avgAttendance || 0}%`, icon: Activity, color: "text-primary", bg: "bg-primary/10" },
    ]

    const schedule = data?.schedule || []

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-on-surface">Welcome back, Prof. {firstName}</h1>
                    <p className="text-on-surface-variant mt-2">Here is your department overview for today.</p>
                </div>
                {isLoading && <Loader2 className="w-5 h-5 animate-spin text-primary" />}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                {stats.map((stat) => (
                    <Card key={stat.name}>
                        <CardContent className="p-6 flex items-center gap-4">
                            <div className={`p-3 rounded-xl ${stat.bg}`}>
                                <stat.icon className={`w-6 h-6 ${stat.color}`} />
                            </div>
                            <div>
                                <p className="text-sm font-medium text-on-surface-variant">{stat.name}</p>
                                <h3 className="text-2xl font-bold text-on-surface">{isLoading ? "-" : stat.value}</h3>
                            </div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2"><Calendar className="w-5 h-5 text-primary" /> Today's Schedule</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center py-4"><Loader2 className="w-6 h-6 animate-spin text-outline" /></div>
                            ) : schedule.length === 0 ? (
                                <p className="text-sm text-on-surface-variant text-center py-4">No schedule for today.</p>
                            ) : schedule.map((item: any) => (
                                <div key={item.id} className="flex justify-between items-center p-3 bg-surface-container-low rounded-lg border border-outline-variant">
                                    <div>
                                        <p className="font-bold text-on-surface">{item.title}</p>
                                        <p className="text-sm text-on-surface-variant">{item.subtitle}</p>
                                    </div>
                                    <div className="text-right">
                                        <p className="font-bold text-primary">{item.time}</p>
                                        <p className="text-xs text-outline">{item.duration}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2"><AlertTriangle className="w-5 h-5 text-error" /> Pending Leave Approvals</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center py-4"><Loader2 className="w-6 h-6 animate-spin text-outline" /></div>
                            ) : pendingLeaves.length === 0 ? (
                                <p className="text-sm text-on-surface-variant text-center py-4">No pending leave requests.</p>
                            ) : pendingLeaves.map((leave: any) => (
                                <div key={leave.id} className="flex justify-between items-center p-3 bg-surface-container-low rounded-lg border border-outline-variant">
                                    <div>
                                        <p className="font-bold text-on-surface">{leave.faculty?.name}</p>
                                        <p className="text-sm text-on-surface-variant">{leave.leaveType} • {new Date(leave.startDate).toLocaleDateString()}</p>
                                    </div>
                                    <Button size="sm" onClick={() => setSelectedLeave(leave)}>
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
                    <div className="bg-surface-container-lowest border border-outline-variant rounded-xl shadow-2xl w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="flex items-center justify-between p-6 border-b border-outline-variant">
                            <h2 className="text-lg font-semibold text-on-surface">Review Leave Request</h2>
                            <button onClick={() => setSelectedLeave(null)} className="text-on-surface-variant hover:text-on-surface transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <div className="p-6 space-y-4">
                            <div>
                                <p className="text-sm text-on-surface-variant">Faculty Member</p>
                                <p className="font-medium text-on-surface">{selectedLeave.faculty?.name}</p>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <p className="text-sm text-on-surface-variant">Leave Type</p>
                                    <p className="font-medium text-on-surface">{selectedLeave.leaveType}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-on-surface-variant">Duration</p>
                                    <p className="font-medium text-on-surface">
                                        {new Date(selectedLeave.startDate).toLocaleDateString()} - {new Date(selectedLeave.endDate).toLocaleDateString()}
                                    </p>
                                </div>
                            </div>
                            <div>
                                <p className="text-sm text-on-surface-variant">Reason</p>
                                <div className="p-3 bg-surface-container-low rounded-lg border border-outline-variant mt-1">
                                    <p className="text-sm text-on-surface">{selectedLeave.reason}</p>
                                </div>
                            </div>

                            <div className="bg-primary/10 border border-primary/20 rounded-lg p-4 mt-4">
                                <p className="text-sm text-primary font-medium mb-2">Substitute Allocation</p>
                                <p className="text-xs text-primary/80">
                                    In a full implementation, you would select substitute teachers for {selectedLeave.faculty?.name}'s classes here before approving.
                                </p>
                            </div>

                            <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-outline-variant">
                                <Button
                                    type="button"
                                    variant="outline"
                                    className="border-error text-error hover:bg-error-container hover:text-on-error-container"
                                    onClick={() => handleApproveLeave("Rejected")}
                                    disabled={isSubmitting}
                                >
                                    <XCircle className="w-4 h-4 mr-2" /> Reject
                                </Button>
                                <Button
                                    type="button"
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
