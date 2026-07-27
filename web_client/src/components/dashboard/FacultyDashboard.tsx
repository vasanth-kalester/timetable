"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { BookOpen, Clock, Calendar, CheckCircle, Loader2, Plus, X, CalendarOff, UserPlus } from "lucide-react"
import { getFacultyDashboardData } from "@/app/actions/faculty"
import { requestLeave, getFacultyLeaves, getSubstituteAssignments } from "@/app/actions/leave"

export function FacultyDashboard({ firstName }: { firstName: string }) {
    const [data, setData] = useState<any>(null)
    const [leaves, setLeaves] = useState<any[]>([])
    const [assignments, setAssignments] = useState<any[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [isLeaveModalOpen, setIsLeaveModalOpen] = useState(false)
    const [isSubmitting, setIsSubmitting] = useState(false)
    const [leaveForm, setLeaveForm] = useState({ leaveType: "Sick Leave", startDate: "", endDate: "", reason: "" })

    const fetchData = async () => {
        setIsLoading(true)
        const [dashboardRes, leavesRes, assignmentsRes] = await Promise.all([
            getFacultyDashboardData(),
            getFacultyLeaves(),
            getSubstituteAssignments()
        ])

        if (!dashboardRes.error) setData(dashboardRes)
        if (!leavesRes.error) setLeaves(leavesRes.leaves || [])
        if (!assignmentsRes.error) setAssignments(assignmentsRes.assignments || [])

        setIsLoading(false)
    }

    useEffect(() => {
        fetchData()
    }, [])

    const handleRequestLeave = async (e: React.FormEvent) => {
        e.preventDefault()
        setIsSubmitting(true)
        const result = await requestLeave({
            leaveType: leaveForm.leaveType,
            startDate: new Date(leaveForm.startDate),
            endDate: new Date(leaveForm.endDate),
            reason: leaveForm.reason
        })
        if (result.success) {
            setIsLeaveModalOpen(false)
            setLeaveForm({ leaveType: "Sick Leave", startDate: "", endDate: "", reason: "" })
            fetchData()
        } else {
            alert(result.error)
        }
        setIsSubmitting(false)
    }

    const stats = [
        { name: "Classes Today", value: data?.stats?.classesToday?.toString() || "0", icon: BookOpen, color: "text-primary", bg: "bg-primary/10" },
        { name: "Weekly Hours", value: data?.stats?.weeklyHours?.toString() || "0", icon: Clock, color: "text-secondary", bg: "bg-secondary/10" },
        { name: "Pending Tasks", value: data?.stats?.pendingTasks?.toString() || "0", icon: Calendar, color: "text-tertiary", bg: "bg-tertiary/10" },
        { name: "Attendance Marked", value: `${data?.stats?.attendanceMarked || 0}%`, icon: CheckCircle, color: "text-primary", bg: "bg-primary/10" },
    ]

    const classes = data?.classes || []
    const announcements = data?.announcements || []

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-on-surface">Welcome, {firstName}</h1>
                    <p className="text-on-surface-variant mt-2">Here is your schedule and tasks for today.</p>
                </div>
                <div className="flex items-center gap-3">
                    {isLoading && <Loader2 className="w-5 h-5 animate-spin text-primary" />}
                    <Button onClick={() => setIsLeaveModalOpen(true)}>
                        <CalendarOff className="w-4 h-4 mr-2" /> Request Leave
                    </Button>
                </div>
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
                        <CardTitle className="flex items-center gap-2"><Calendar className="w-5 h-5 text-primary" /> Today's Classes</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center py-4"><Loader2 className="w-6 h-6 animate-spin text-outline" /></div>
                            ) : classes.length === 0 ? (
                                <p className="text-sm text-on-surface-variant text-center py-4">No classes scheduled for today.</p>
                            ) : classes.map((item: any) => (
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
                        <CardTitle className="flex items-center gap-2"><UserPlus className="w-5 h-5 text-secondary" /> Substitute Assignments</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center py-4"><Loader2 className="w-6 h-6 animate-spin text-outline" /></div>
                            ) : assignments.length === 0 ? (
                                <p className="text-sm text-on-surface-variant text-center py-4">No substitute assignments.</p>
                            ) : assignments.map((item: any) => (
                                <div key={item.id} className="flex justify-between items-center p-3 bg-surface-container-low rounded-lg border border-outline-variant">
                                    <div>
                                        <p className="font-bold text-on-surface">Period {item.period}</p>
                                        <p className="text-sm text-on-surface-variant">Covering for {item.originalStaff?.name}</p>
                                    </div>
                                    <div className="text-right">
                                        <p className="font-bold text-primary">{new Date(item.date).toLocaleDateString()}</p>
                                        <span className="text-xs font-medium px-2 py-1 rounded-full bg-tertiary/10 text-tertiary border border-tertiary/20">
                                            {item.status}
                                        </span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>

                <Card className="lg:col-span-2">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2"><CalendarOff className="w-5 h-5 text-tertiary" /> My Leave Requests</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="overflow-x-auto">
                            <table className="w-full text-sm text-left">
                                <thead className="text-xs text-on-surface-variant uppercase bg-surface-container-low border-b border-outline-variant">
                                    <tr>
                                        <th className="px-4 py-3">Type</th>
                                        <th className="px-4 py-3">Start Date</th>
                                        <th className="px-4 py-3">End Date</th>
                                        <th className="px-4 py-3">Reason</th>
                                        <th className="px-4 py-3 text-right">Status</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-outline-variant">
                                    {isLoading ? (
                                        <tr><td colSpan={5} className="text-center py-4"><Loader2 className="w-5 h-5 animate-spin mx-auto text-outline" /></td></tr>
                                    ) : leaves.length === 0 ? (
                                        <tr><td colSpan={5} className="text-center py-4 text-on-surface-variant">No leave requests found.</td></tr>
                                    ) : leaves.map((leave) => (
                                        <tr key={leave.id} className="hover:bg-surface-container-low transition-colors">
                                            <td className="px-4 py-3 font-medium text-on-surface">{leave.leaveType}</td>
                                            <td className="px-4 py-3 text-on-surface-variant">{new Date(leave.startDate).toLocaleDateString()}</td>
                                            <td className="px-4 py-3 text-on-surface-variant">{new Date(leave.endDate).toLocaleDateString()}</td>
                                            <td className="px-4 py-3 text-on-surface-variant max-w-[200px] truncate">{leave.reason}</td>
                                            <td className="px-4 py-3 text-right">
                                                <span className={`text-xs font-medium px-2 py-1 rounded-full border ${leave.status === 'Approved' ? 'bg-tertiary/10 text-tertiary border-tertiary/20' :
                                                    leave.status === 'Rejected' ? 'bg-error-container text-on-error-container border-error/20' :
                                                        'bg-secondary/10 text-secondary border-secondary/20'
                                                    }`}>
                                                    {leave.status}
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Request Leave Modal */}
            {isLeaveModalOpen && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
                    <div className="bg-surface-container-lowest border border-outline-variant rounded-xl shadow-2xl w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="flex items-center justify-between p-6 border-b border-outline-variant">
                            <h2 className="text-lg font-semibold text-on-surface">Request Leave</h2>
                            <button onClick={() => setIsLeaveModalOpen(false)} className="text-on-surface-variant hover:text-on-surface transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleRequestLeave} className="p-6 space-y-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-on-surface-variant">Leave Type</label>
                                <select
                                    className="w-full h-10 px-3 rounded-lg bg-surface-container-low border border-outline-variant text-sm text-on-surface focus:outline-none focus:ring-2 focus:ring-primary/50"
                                    value={leaveForm.leaveType}
                                    onChange={(e) => setLeaveForm({ ...leaveForm, leaveType: e.target.value })}
                                >
                                    <option value="Sick Leave">Sick Leave</option>
                                    <option value="Casual Leave">Casual Leave</option>
                                    <option value="Earned Leave">Earned Leave</option>
                                    <option value="On Duty">On Duty (OD)</option>
                                </select>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-on-surface-variant">Start Date</label>
                                    <Input
                                        type="date"
                                        required
                                        value={leaveForm.startDate}
                                        onChange={(e) => setLeaveForm({ ...leaveForm, startDate: e.target.value })}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-on-surface-variant">End Date</label>
                                    <Input
                                        type="date"
                                        required
                                        value={leaveForm.endDate}
                                        onChange={(e) => setLeaveForm({ ...leaveForm, endDate: e.target.value })}
                                    />
                                </div>
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-on-surface-variant">Reason</label>
                                <textarea
                                    required
                                    className="w-full h-24 p-3 rounded-lg bg-surface-container-low border border-outline-variant text-sm text-on-surface focus:outline-none focus:ring-2 focus:ring-primary/50 resize-none"
                                    placeholder="Briefly explain the reason for your leave..."
                                    value={leaveForm.reason}
                                    onChange={(e) => setLeaveForm({ ...leaveForm, reason: e.target.value })}
                                />
                            </div>
                            <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-outline-variant">
                                <Button type="button" variant="ghost" onClick={() => setIsLeaveModalOpen(false)}>
                                    Cancel
                                </Button>
                                <Button type="submit" disabled={isSubmitting}>
                                    {isSubmitting ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
                                    Submit Request
                                </Button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    )
}
