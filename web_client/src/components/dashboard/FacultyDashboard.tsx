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
                <div className="flex items-center gap-3">
                    {isLoading && <Loader2 className="w-5 h-5 animate-spin text-indigo-500" />}
                    <Button className="bg-indigo-600 hover:bg-indigo-700" onClick={() => setIsLeaveModalOpen(true)}>
                        <CalendarOff className="w-4 h-4 mr-2" /> Request Leave
                    </Button>
                </div>
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
                        <CardTitle className="flex items-center gap-2"><UserPlus className="w-5 h-5 text-emerald-400" /> Substitute Assignments</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center py-4"><Loader2 className="w-6 h-6 animate-spin text-slate-500" /></div>
                            ) : assignments.length === 0 ? (
                                <p className="text-sm text-slate-500 text-center py-4">No substitute assignments.</p>
                            ) : assignments.map((item: any) => (
                                <div key={item.id} className="flex justify-between items-center p-3 bg-slate-800/30 rounded-lg border border-slate-800/50">
                                    <div>
                                        <p className="font-bold text-slate-200">Period {item.period}</p>
                                        <p className="text-sm text-slate-400">Covering for {item.originalStaff?.name}</p>
                                    </div>
                                    <div className="text-right">
                                        <p className="font-bold text-indigo-400">{new Date(item.date).toLocaleDateString()}</p>
                                        <span className="text-xs font-medium px-2 py-1 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                            {item.status}
                                        </span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-800/60 bg-slate-900/40 lg:col-span-2">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2"><CalendarOff className="w-5 h-5 text-amber-400" /> My Leave Requests</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="overflow-x-auto">
                            <table className="w-full text-sm text-left">
                                <thead className="text-xs text-slate-400 uppercase bg-slate-900/50 border-b border-slate-800">
                                    <tr>
                                        <th className="px-4 py-3">Type</th>
                                        <th className="px-4 py-3">Start Date</th>
                                        <th className="px-4 py-3">End Date</th>
                                        <th className="px-4 py-3">Reason</th>
                                        <th className="px-4 py-3 text-right">Status</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-slate-800/50">
                                    {isLoading ? (
                                        <tr><td colSpan={5} className="text-center py-4"><Loader2 className="w-5 h-5 animate-spin mx-auto text-slate-500" /></td></tr>
                                    ) : leaves.length === 0 ? (
                                        <tr><td colSpan={5} className="text-center py-4 text-slate-500">No leave requests found.</td></tr>
                                    ) : leaves.map((leave) => (
                                        <tr key={leave.id} className="hover:bg-slate-800/30">
                                            <td className="px-4 py-3 font-medium text-slate-200">{leave.leaveType}</td>
                                            <td className="px-4 py-3 text-slate-300">{new Date(leave.startDate).toLocaleDateString()}</td>
                                            <td className="px-4 py-3 text-slate-300">{new Date(leave.endDate).toLocaleDateString()}</td>
                                            <td className="px-4 py-3 text-slate-400 max-w-[200px] truncate">{leave.reason}</td>
                                            <td className="px-4 py-3 text-right">
                                                <span className={`text-xs font-medium px-2 py-1 rounded-full border ${leave.status === 'Approved' ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' :
                                                        leave.status === 'Rejected' ? 'bg-red-500/10 text-red-400 border-red-500/20' :
                                                            'bg-amber-500/10 text-amber-400 border-amber-500/20'
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
                    <div className="bg-slate-900 border border-slate-800 rounded-xl shadow-2xl w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="flex items-center justify-between p-6 border-b border-slate-800">
                            <h2 className="text-lg font-semibold text-slate-50">Request Leave</h2>
                            <button onClick={() => setIsLeaveModalOpen(false)} className="text-slate-400 hover:text-slate-200 transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleRequestLeave} className="p-6 space-y-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Leave Type</label>
                                <select
                                    className="w-full h-10 px-3 rounded-md bg-slate-800 border border-slate-700 text-sm text-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500/50"
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
                                    <label className="text-sm font-medium text-slate-300">Start Date</label>
                                    <Input
                                        type="date"
                                        required
                                        className="bg-slate-800 border-slate-700"
                                        value={leaveForm.startDate}
                                        onChange={(e) => setLeaveForm({ ...leaveForm, startDate: e.target.value })}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-slate-300">End Date</label>
                                    <Input
                                        type="date"
                                        required
                                        className="bg-slate-800 border-slate-700"
                                        value={leaveForm.endDate}
                                        onChange={(e) => setLeaveForm({ ...leaveForm, endDate: e.target.value })}
                                    />
                                </div>
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Reason</label>
                                <textarea
                                    required
                                    className="w-full h-24 p-3 rounded-md bg-slate-800 border border-slate-700 text-sm text-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 resize-none"
                                    placeholder="Briefly explain the reason for your leave..."
                                    value={leaveForm.reason}
                                    onChange={(e) => setLeaveForm({ ...leaveForm, reason: e.target.value })}
                                />
                            </div>
                            <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-slate-800">
                                <Button type="button" variant="ghost" onClick={() => setIsLeaveModalOpen(false)}>
                                    Cancel
                                </Button>
                                <Button type="submit" className="bg-indigo-600 hover:bg-indigo-700" disabled={isSubmitting}>
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
