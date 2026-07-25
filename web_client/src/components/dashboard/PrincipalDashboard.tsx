"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import {
    Users, GraduationCap, Building2, Activity, AlertTriangle, CheckCircle2, Clock,
    Calendar, BarChart3, FileText, Bell, Settings, Search, ChevronRight, BookOpen,
    FlaskConical, Wrench, ClipboardList, TrendingUp, TrendingDown, Star, Megaphone,
    MapPin, LogOut, Shield, Award, Zap, Eye, Check, X, RefreshCw, Download, Loader2
} from "lucide-react"
import { getPrincipalDashboardData } from "@/app/actions/principal"

// ─── Data ────────────────────────────────────────────────────
const kpiGroups = [
    {
        label: "Academic",
        items: [
            { name: "Total Students", value: "3,840", trend: "+12", up: true },
            { name: "Total Faculty", value: "186", trend: "+3", up: true },
            { name: "Departments", value: "8", trend: "stable", up: true },
            { name: "Active Classes Today", value: "198", trend: "-2", up: false },
        ]
    },
    {
        label: "Attendance",
        items: [
            { name: "Student Attendance", value: "92%", trend: "+1%", up: true },
            { name: "Faculty Attendance", value: "96%", trend: "stable", up: true },
            { name: "Classes Conducted", value: "191/198", trend: "", up: true },
            { name: "Pending Attendance", value: "7", trend: "-5", up: true },
        ]
    },
    {
        label: "Infrastructure",
        items: [
            { name: "Rooms Occupied", value: "124/150", trend: "", up: true },
            { name: "Labs Active", value: "18/22", trend: "", up: true },
            { name: "Available Rooms", value: "26", trend: "+4", up: true },
            { name: "Maintenance Issues", value: "4", trend: "+2", up: false },
        ]
    },
    {
        label: "Examinations",
        items: [
            { name: "Upcoming Exams", value: "3", trend: "", up: true },
            { name: "Results Published", value: "12", trend: "+2", up: true },
            { name: "Pending Evaluations", value: "8", trend: "-3", up: true },
            { name: "Hall Allocations", value: "Done", trend: "", up: true },
        ]
    },
    {
        label: "Administration",
        items: [
            { name: "Pending Approvals", value: "12", trend: "+3", up: false },
            { name: "Leave Requests", value: "5", trend: "", up: false },
            { name: "Room Requests", value: "3", trend: "", up: true },
            { name: "Event Requests", value: "4", trend: "", up: true },
        ]
    }
]

const todayOverview = [
    { icon: CheckCircle2, text: "198 Classes Scheduled", color: "text-emerald-400" },
    { icon: CheckCircle2, text: "191 Classes Completed", color: "text-emerald-400" },
    { icon: AlertTriangle, text: "6 Faculty on Leave", color: "text-amber-400" },
    { icon: RefreshCw, text: "2 Substitute Classes", color: "text-blue-400" },
    { icon: Wrench, text: "4 Maintenance Issues", color: "text-red-400" },
    { icon: GraduationCap, text: "3 Guest Lectures", color: "text-indigo-400" },
    { icon: BookOpen, text: "1 Seminar", color: "text-purple-400" },
]

const timeline = [
    { time: "08:30", event: "Faculty Attendance Completed", type: "success" },
    { time: "09:00", event: "Classes Started", type: "success" },
    { time: "09:40", event: "Projector Failure — Room B203", type: "warning" },
    { time: "10:15", event: "Faculty Leave Approved — Dr. Rao", type: "info" },
    { time: "11:00", event: "Hackathon Started — CS Dept", type: "success" },
    { time: "12:20", event: "Classroom Changed — EEE 3A", type: "info" },
    { time: "01:15", event: "Emergency Notification Sent", type: "danger" },
]

const pendingApprovals = [
    { title: "Faculty Leave — Dr. Priya", dept: "CSE", date: "24 Jul", priority: "High", by: "Prof. Priya Nair", status: "Pending" },
    { title: "Room Booking — Seminar Hall", dept: "ECE", date: "25 Jul", priority: "Medium", by: "HOD Shankar", status: "Pending" },
    { title: "Timetable Publication — S5", dept: "IT", date: "23 Jul", priority: "High", by: "Timetable Committee", status: "Review" },
    { title: "Event Approval — Tech Fest", dept: "All", date: "30 Jul", priority: "High", by: "Student Council", status: "Pending" },
    { title: "Exam Schedule — Nov 2026", dept: "All", date: "26 Jul", priority: "Medium", by: "Exam Cell", status: "Pending" },
]

const departments = [
    { name: "Computer Science", attendance: 94, faculty: 28, students: 612, pendingLeaves: 2, conflicts: 0, examPerf: 91 },
    { name: "Electronics", attendance: 91, faculty: 25, students: 510, pendingLeaves: 2, conflicts: 1, examPerf: 88 },
    { name: "Mechanical", attendance: 81, faculty: 22, students: 450, pendingLeaves: 3, conflicts: 2, examPerf: 79 },
    { name: "Civil", attendance: 88, faculty: 18, students: 380, pendingLeaves: 0, conflicts: 0, examPerf: 85 },
    { name: "Information Technology", attendance: 93, faculty: 20, students: 540, pendingLeaves: 1, conflicts: 0, examPerf: 90 },
    { name: "Electrical", attendance: 86, faculty: 16, students: 320, pendingLeaves: 2, conflicts: 1, examPerf: 83 },
]

const faculty = [
    { name: "Dr. Priya Nair", dept: "CSE", classes: 3, workload: "Normal", status: "Present" },
    { name: "Prof. Shankar M", dept: "ECE", classes: 4, workload: "High", status: "Present" },
    { name: "Dr. Rao K", dept: "MECH", classes: 0, workload: "—", status: "On Leave" },
    { name: "Ms. Divya S", dept: "CIVIL", classes: 2, workload: "Normal", status: "Present" },
    { name: "Mr. Arun P", dept: "IT", classes: 3, workload: "Normal", status: "Late" },
]

const healthScore = {
    overall: 94,
    label: "Excellent",
    breakdown: [
        { name: "Attendance", score: 93 },
        { name: "Infrastructure", score: 97 },
        { name: "Scheduling", score: 96 },
        { name: "Exams", score: 91 },
        { name: "Operations", score: 95 },
    ]
}

const recentActivity = [
    { time: "09:15", text: "Faculty Leave Approved", icon: Check },
    { time: "09:40", text: "Room B203 Booking Changed", icon: RefreshCw },
    { time: "10:20", text: "Exam Schedule Published", icon: FileText },
    { time: "11:00", text: "Attendance Completed — CSE", icon: CheckCircle2 },
    { time: "12:45", text: "Tech Fest Event Approved", icon: Award },
]

const quickActions = [
    { label: "View Timetable", icon: Calendar, color: "bg-indigo-600 hover:bg-indigo-700" },
    { label: "Approve Leaves", icon: CheckCircle2, color: "bg-emerald-600 hover:bg-emerald-700" },
    { label: "Publish Timetable", icon: Zap, color: "bg-purple-600 hover:bg-purple-700" },
    { label: "View Reports", icon: BarChart3, color: "bg-blue-600 hover:bg-blue-700" },
    { label: "Broadcast Notice", icon: Megaphone, color: "bg-amber-600 hover:bg-amber-700" },
    { label: "Schedule Event", icon: MapPin, color: "bg-cyan-600 hover:bg-cyan-700" },
    { label: "Exam Report", icon: FileText, color: "bg-red-600 hover:bg-red-700" },
    { label: "Delegation", icon: LogOut, color: "bg-slate-600 hover:bg-slate-700" },
]

// ─── Helpers ─────────────────────────────────────────────────
function PriorityBadge({ p }: { p: string }) {
    const cls = p === "High" ? "bg-red-500/10 text-red-400 border-red-500/20"
        : p === "Medium" ? "bg-amber-500/10 text-amber-400 border-amber-500/20"
            : "bg-slate-500/10 text-slate-400 border-slate-500/20"
    return <span className={`px-2 py-0.5 text-xs font-bold rounded border ${cls}`}>{p}</span>
}

function StatusBadge({ s }: { s: string }) {
    const cls = s === "Present" ? "text-emerald-400"
        : s === "On Leave" ? "text-amber-400"
            : s === "Late" ? "text-red-400"
                : "text-slate-400"
    return <span className={`text-sm font-medium ${cls}`}>{s}</span>
}

function HealthBar({ score }: { score: number }) {
    const color = score >= 90 ? "bg-emerald-500" : score >= 75 ? "bg-amber-500" : "bg-red-500"
    return (
        <div className="flex items-center gap-3">
            <div className="flex-1 h-2 bg-slate-800 rounded-full overflow-hidden">
                <div className={`h-full rounded-full ${color}`} style={{ width: `${score}%` }} />
            </div>
            <span className="text-sm font-bold text-slate-300 w-8 text-right">{score}</span>
        </div>
    )
}

function AttendanceBar({ pct, label }: { pct: number; label: string }) {
    const color = pct >= 90 ? "bg-emerald-500" : pct >= 80 ? "bg-amber-500" : "bg-red-500"
    return (
        <div className="mb-3">
            <div className="flex justify-between text-xs text-slate-400 mb-1">
                <span>{label}</span><span className="font-bold">{pct}%</span>
            </div>
            <div className="h-2 bg-slate-800 rounded-full overflow-hidden">
                <div className={`h-full rounded-full transition-all ${color}`} style={{ width: `${pct}%` }} />
            </div>
        </div>
    )
}

// ─── Main Component ───────────────────────────────────────────
export function PrincipalDashboard({ firstName }: { firstName: string }) {
    const [activeTab, setActiveTab] = useState<"monitor" | "approve" | "act">("monitor")
    const [dbData, setDbData] = useState<any>(null)
    const [isLoading, setIsLoading] = useState(true)

    useEffect(() => {
        getPrincipalDashboardData().then(result => {
            if (!result.error) setDbData(result)
            setIsLoading(false)
        })
    }, [])

    const now = new Date()
    const hour = now.getHours()
    const greeting = hour < 12 ? "Good Morning" : hour < 17 ? "Good Afternoon" : "Good Evening"
    const todayStr = now.toLocaleDateString("en-IN", { weekday: "long", day: "numeric", month: "long", year: "numeric" })

    const collegeName = dbData?.college?.name || "Your Institution"

    // Override mock KPI items with real DB values where available
    const realKpiGroups = kpiGroups.map(group => {
        if (group.label === "Academic") {
            return {
                ...group, items: [
                    { name: "Total Students", value: dbData?.stats?.totalStudents?.toString() || "0", trend: "stable", up: true },
                    { name: "Total Faculty", value: dbData?.stats?.totalFaculty?.toString() || "0", trend: "stable", up: true },
                    { name: "Departments", value: dbData?.stats?.totalDepartments?.toString() || "0", trend: "stable", up: true },
                    { name: "Active Classes Today", value: "0", trend: "pending", up: true },
                ]
            }
        }
        return group
    })

    const realDepartments = dbData?.departments?.length > 0 ? dbData.departments : departments

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">

            {/* ── Header ─────────────────────────────────── */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">
                        {greeting}, Dr. {firstName} 👋
                    </h1>
                    <div className="flex flex-wrap gap-3 mt-2 text-sm text-slate-400">
                        <span className="flex items-center gap-1"><Building2 className="w-3.5 h-3.5" /> {collegeName}</span>
                        <span className="flex items-center gap-1"><BookOpen className="w-3.5 h-3.5" /> AY 2025–26</span>
                        <span className="flex items-center gap-1"><Calendar className="w-3.5 h-3.5" /> {todayStr}</span>
                        <span className="flex items-center gap-1"><Clock className="w-3.5 h-3.5" /> Semester V</span>
                    </div>
                </div>
                <div className="flex items-center gap-2">
                    <Button variant="ghost" size="icon" className="text-slate-400 hover:text-indigo-400"><Search className="w-4 h-4" /></Button>
                    <Button variant="ghost" size="icon" className="text-slate-400 hover:text-amber-400 relative">
                        <Bell className="w-4 h-4" />
                        <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 bg-red-500 rounded-full" />
                    </Button>
                    <Button variant="ghost" size="icon" className="text-slate-400 hover:text-slate-200"><Settings className="w-4 h-4" /></Button>
                </div>
            </div>

            {/* ── Mode Switcher ──────────────────────────── */}
            <div className="flex gap-2 p-1 bg-slate-900/60 rounded-xl border border-slate-800 w-fit">
                {(["monitor", "approve", "act"] as const).map(mode => (
                    <button
                        key={mode}
                        onClick={() => setActiveTab(mode)}
                        className={`px-5 py-2 rounded-lg text-sm font-semibold capitalize transition-all ${activeTab === mode
                            ? "bg-indigo-600 text-white shadow-lg shadow-indigo-600/20"
                            : "text-slate-400 hover:text-slate-200"
                            }`}
                    >
                        {mode === "monitor" ? "📊 Monitor" : mode === "approve" ? "✅ Approve" : "⚡ Act"}
                    </button>
                ))}
            </div>

            {/* ── MONITOR TAB ───────────────────────────── */}
            {activeTab === "monitor" && (
                <div className="space-y-8">

                    {/* KPI Groups */}
                    {isLoading && (
                        <div className="flex items-center gap-2 text-slate-500 text-sm">
                            <Loader2 className="w-4 h-4 animate-spin" /> Loading live data...
                        </div>
                    )}
                    {realKpiGroups.map(group => (
                        <div key={group.label}>
                            <h2 className="text-xs font-bold uppercase tracking-widest text-slate-500 mb-3">{group.label}</h2>
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                {group.items.map(kpi => (
                                    <Card key={kpi.name} className="border-slate-800/60 bg-slate-900/40 hover:bg-slate-800/40 transition-colors">
                                        <CardContent className="p-4">
                                            <p className="text-xs text-slate-500 mb-1">{kpi.name}</p>
                                            <p className="text-2xl font-bold text-slate-50">{kpi.value}</p>
                                            {kpi.trend && kpi.trend !== "stable" && (
                                                <p className={`text-xs flex items-center gap-1 mt-1 ${kpi.up ? "text-emerald-400" : "text-red-400"}`}>
                                                    {kpi.up ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
                                                    {kpi.trend}
                                                </p>
                                            )}
                                        </CardContent>
                                    </Card>
                                ))}
                            </div>
                        </div>
                    ))}

                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">

                        {/* Today's Overview */}
                        <Card className="border-slate-800/60 bg-slate-900/40">
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2"><Activity className="w-4 h-4 text-indigo-400" />Today's Campus Overview</CardTitle>
                            </CardHeader>
                            <CardContent className="space-y-3">
                                {todayOverview.map((item, i) => (
                                    <div key={i} className="flex items-center gap-3">
                                        <item.icon className={`w-4 h-4 flex-shrink-0 ${item.color}`} />
                                        <span className="text-sm text-slate-300">{item.text}</span>
                                    </div>
                                ))}
                            </CardContent>
                        </Card>

                        {/* Live Timeline */}
                        <Card className="border-slate-800/60 bg-slate-900/40">
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2"><Clock className="w-4 h-4 text-indigo-400" />Live Campus Timeline</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div className="space-y-4">
                                    {timeline.map((item, i) => {
                                        const dotColor = item.type === "success" ? "bg-emerald-500"
                                            : item.type === "warning" ? "bg-amber-500"
                                                : item.type === "danger" ? "bg-red-500" : "bg-blue-500"
                                        return (
                                            <div key={i} className="flex gap-3 items-start">
                                                <div className="flex flex-col items-center">
                                                    <div className={`w-2.5 h-2.5 rounded-full mt-1 flex-shrink-0 ${dotColor}`} />
                                                    {i < timeline.length - 1 && <div className="w-px flex-1 bg-slate-800 mt-1" style={{ minHeight: 20 }} />}
                                                </div>
                                                <div className="pb-2">
                                                    <p className="text-xs font-mono text-indigo-400">{item.time}</p>
                                                    <p className="text-sm text-slate-300">{item.event}</p>
                                                </div>
                                            </div>
                                        )
                                    })}
                                </div>
                            </CardContent>
                        </Card>

                        {/* Institution Health Score */}
                        <Card className="border-indigo-500/20 bg-slate-900/40">
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2"><Star className="w-4 h-4 text-amber-400" />Institution Health Score</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div className="text-center mb-6">
                                    <div className="relative inline-flex items-center justify-center">
                                        <svg className="w-32 h-32 -rotate-90" viewBox="0 0 100 100">
                                            <circle cx="50" cy="50" r="40" fill="none" stroke="rgb(30,41,59)" strokeWidth="10" />
                                            <circle cx="50" cy="50" r="40" fill="none" stroke="rgb(99,102,241)"
                                                strokeWidth="10" strokeLinecap="round"
                                                strokeDasharray={`${healthScore.overall * 2.51} 251`} />
                                        </svg>
                                        <div className="absolute text-center">
                                            <p className="text-3xl font-black text-slate-50">{healthScore.overall}</p>
                                            <p className="text-xs text-slate-500">/ 100</p>
                                        </div>
                                    </div>
                                    <p className="text-emerald-400 font-bold text-lg mt-1">{healthScore.label}</p>
                                </div>
                                <div className="space-y-2">
                                    {healthScore.breakdown.map(b => (
                                        <div key={b.name}>
                                            <p className="text-xs text-slate-500 mb-1">{b.name}</p>
                                            <HealthBar score={b.score} />
                                        </div>
                                    ))}
                                </div>
                            </CardContent>
                        </Card>
                    </div>

                    {/* Dept Performance */}
                    <div>
                        <div className="flex items-center justify-between mb-4">
                            <h2 className="text-lg font-bold text-slate-50 flex items-center gap-2">
                                <Building2 className="w-5 h-5 text-indigo-400" /> Department Performance
                            </h2>
                            <Button variant="ghost" size="sm" className="text-indigo-400 hover:text-indigo-300">View All <ChevronRight className="w-4 h-4 ml-1" /></Button>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                            {departments.map(dept => (
                                <Card key={dept.name} className="border-slate-800/60 bg-slate-900/40 hover:border-indigo-500/40 transition-colors cursor-pointer group">
                                    <CardContent className="p-5">
                                        <div className="flex items-start justify-between mb-3">
                                            <h3 className="font-bold text-slate-200 group-hover:text-indigo-400 transition-colors">{dept.name}</h3>
                                            <span className={`text-xs font-bold px-2 py-0.5 rounded ${dept.attendance >= 90 ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20" : dept.attendance >= 80 ? "bg-amber-500/10 text-amber-400 border border-amber-500/20" : "bg-red-500/10 text-red-400 border border-red-500/20"}`}>
                                                {dept.attendance}%
                                            </span>
                                        </div>
                                        <AttendanceBar pct={dept.attendance} label="Attendance" />
                                        <div className="grid grid-cols-3 gap-2 mt-3 text-center">
                                            <div>
                                                <p className="text-xs text-slate-500">Faculty</p>
                                                <p className="font-bold text-slate-300">{dept.faculty}</p>
                                            </div>
                                            <div>
                                                <p className="text-xs text-slate-500">Students</p>
                                                <p className="font-bold text-slate-300">{dept.students}</p>
                                            </div>
                                            <div>
                                                <p className="text-xs text-slate-500">Exam %</p>
                                                <p className={`font-bold ${dept.examPerf >= 85 ? "text-emerald-400" : "text-amber-400"}`}>{dept.examPerf}%</p>
                                            </div>
                                        </div>
                                        {(dept.pendingLeaves > 0 || dept.conflicts > 0) && (
                                            <div className="flex gap-3 mt-3 pt-3 border-t border-slate-800">
                                                {dept.pendingLeaves > 0 && <span className="text-xs text-amber-400 flex items-center gap-1"><Clock className="w-3 h-3" />{dept.pendingLeaves} Leaves</span>}
                                                {dept.conflicts > 0 && <span className="text-xs text-red-400 flex items-center gap-1"><AlertTriangle className="w-3 h-3" />{dept.conflicts} Conflicts</span>}
                                            </div>
                                        )}
                                    </CardContent>
                                </Card>
                            ))}
                        </div>
                    </div>

                    {/* Attendance Analytics */}
                    <Card className="border-slate-800/60 bg-slate-900/40">
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2"><BarChart3 className="w-4 h-4 text-indigo-400" />Attendance Analytics</CardTitle>
                            <CardDescription>Department-wise attendance breakdown</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <p className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-4">Student Attendance by Dept</p>
                                    {departments.map(dept => (
                                        <AttendanceBar key={dept.name} pct={dept.attendance} label={dept.name} />
                                    ))}
                                </div>
                                <div className="space-y-4">
                                    <div className="p-4 rounded-xl bg-emerald-500/5 border border-emerald-500/20">
                                        <p className="text-xs text-emerald-400 font-bold mb-1">Above Threshold (≥90%)</p>
                                        <p className="text-2xl font-black text-emerald-400">CSE, IT, ECE</p>
                                    </div>
                                    <div className="p-4 rounded-xl bg-amber-500/5 border border-amber-500/20">
                                        <p className="text-xs text-amber-400 font-bold mb-1">Below Threshold (&lt;85%)</p>
                                        <p className="text-2xl font-black text-amber-400">MECH, EEE</p>
                                    </div>
                                    <div className="p-4 rounded-xl bg-red-500/5 border border-red-500/20">
                                        <p className="text-xs text-red-400 font-bold mb-1">Missing Attendance Today</p>
                                        <p className="text-2xl font-black text-red-400">7 Classes</p>
                                    </div>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Faculty Overview */}
                    <Card className="border-slate-800/60 bg-slate-900/40">
                        <CardHeader>
                            <div className="flex items-center justify-between">
                                <CardTitle className="flex items-center gap-2"><GraduationCap className="w-4 h-4 text-indigo-400" />Faculty Overview</CardTitle>
                                <div className="flex gap-3 text-sm">
                                    <span className="text-emerald-400 font-bold">178 Present</span>
                                    <span className="text-amber-400 font-bold">6 On Leave</span>
                                    <span className="text-red-400 font-bold">2 Late</span>
                                </div>
                            </div>
                        </CardHeader>
                        <CardContent>
                            <div className="overflow-x-auto">
                                <table className="w-full text-sm">
                                    <thead>
                                        <tr className="text-xs uppercase text-slate-500 border-b border-slate-800">
                                            <th className="text-left py-2">Name</th>
                                            <th className="text-left py-2">Dept</th>
                                            <th className="text-center py-2">Classes Today</th>
                                            <th className="text-center py-2">Workload</th>
                                            <th className="text-center py-2">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {faculty.map((f, i) => (
                                            <tr key={i} className="border-b border-slate-800/40 hover:bg-slate-800/20">
                                                <td className="py-3 font-medium text-slate-200">{f.name}</td>
                                                <td className="py-3 text-slate-400">{f.dept}</td>
                                                <td className="py-3 text-center text-slate-300">{f.classes}</td>
                                                <td className="py-3 text-center">
                                                    <span className={`text-xs font-bold ${f.workload === "High" ? "text-red-400" : "text-slate-400"}`}>{f.workload}</span>
                                                </td>
                                                <td className="py-3 text-center"><StatusBadge s={f.status} /></td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Timetable + Infrastructure + Examination row */}
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <Card className="border-slate-800/60 bg-slate-900/40">
                            <CardHeader><CardTitle className="flex items-center gap-2 text-base"><Calendar className="w-4 h-4 text-indigo-400" />Timetable Control</CardTitle></CardHeader>
                            <CardContent className="space-y-3">
                                {[
                                    { label: "Current (Published)", status: "Active", color: "text-emerald-400" },
                                    { label: "Draft — Sem 6", status: "In Review", color: "text-amber-400" },
                                    { label: "Simulation S6-A", status: "0 Conflicts", color: "text-blue-400" },
                                ].map((t, i) => (
                                    <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-slate-800/30 border border-slate-800/50">
                                        <span className="text-sm text-slate-300">{t.label}</span>
                                        <span className={`text-xs font-bold ${t.color}`}>{t.status}</span>
                                    </div>
                                ))}
                                <Button size="sm" className="w-full mt-2 bg-indigo-600/20 text-indigo-400 hover:bg-indigo-600 hover:text-white transition-colors" onClick={() => alert("Timetable module coming soon!")}>
                                    Review & Publish
                                </Button>
                            </CardContent>
                        </Card>

                        <Card className="border-slate-800/60 bg-slate-900/40">
                            <CardHeader><CardTitle className="flex items-center gap-2 text-base"><Building2 className="w-4 h-4 text-indigo-400" />Infrastructure</CardTitle></CardHeader>
                            <CardContent className="space-y-3">
                                {[
                                    { label: "Rooms", value: "124 / 150", sub: "83% occupied" },
                                    { label: "Labs", value: "18 / 22", sub: "82% active" },
                                    { label: "Seminar Halls", value: "3 / 4", sub: "1 reserved" },
                                    { label: "Maintenance", value: "4 open", sub: "2 critical" },
                                ].map((r, i) => (
                                    <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-slate-800/30 border border-slate-800/50">
                                        <div>
                                            <p className="text-sm font-medium text-slate-300">{r.label}</p>
                                            <p className="text-xs text-slate-500">{r.sub}</p>
                                        </div>
                                        <span className="text-sm font-bold text-slate-200">{r.value}</span>
                                    </div>
                                ))}
                            </CardContent>
                        </Card>

                        <Card className="border-slate-800/60 bg-slate-900/40">
                            <CardHeader><CardTitle className="flex items-center gap-2 text-base"><ClipboardList className="w-4 h-4 text-indigo-400" />Examinations</CardTitle></CardHeader>
                            <CardContent className="space-y-3">
                                {[
                                    { label: "Upcoming Exams", value: "3" },
                                    { label: "Invigilators Assigned", value: "96 / 98" },
                                    { label: "Hall Allocation", value: "Done ✓" },
                                    { label: "Pending Results", value: "8 Subjects" },
                                    { label: "Avg Pass %", value: "87%" },
                                ].map((e, i) => (
                                    <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-slate-800/30 border border-slate-800/50">
                                        <span className="text-sm text-slate-300">{e.label}</span>
                                        <span className="text-sm font-bold text-slate-200">{e.value}</span>
                                    </div>
                                ))}
                            </CardContent>
                        </Card>
                    </div>

                    {/* Reports + Resource Utilization */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <Card className="border-slate-800/60 bg-slate-900/40">
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2"><FileText className="w-4 h-4 text-indigo-400" />Reports Center</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div className="grid grid-cols-2 gap-3">
                                    {["Attendance", "Faculty", "Student", "Examination", "Infrastructure", "Timetable"].map(r => (
                                        <Button key={r} variant="outline" size="sm" className="border-slate-700 hover:bg-slate-800 justify-between" onClick={() => alert(`Generating ${r} report...`)}>
                                            <span>{r}</span>
                                            <Download className="w-3 h-3 ml-2 text-slate-500" />
                                        </Button>
                                    ))}
                                </div>
                            </CardContent>
                        </Card>

                        <Card className="border-slate-800/60 bg-slate-900/40">
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2"><BarChart3 className="w-4 h-4 text-indigo-400" />Resource Utilization</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <p className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">Room Utilization</p>
                                {[
                                    { label: "Morning (8–1)", pct: 91 },
                                    { label: "Afternoon (1–5)", pct: 68 },
                                    { label: "Evening (5–8)", pct: 24 },
                                ].map(r => (
                                    <div key={r.label} className="mb-3">
                                        <div className="flex justify-between text-xs text-slate-400 mb-1">
                                            <span>{r.label}</span><span className="font-bold">{r.pct}%</span>
                                        </div>
                                        <div className="h-2.5 bg-slate-800 rounded-full overflow-hidden">
                                            <div className="h-full bg-indigo-500 rounded-full" style={{ width: `${r.pct}%` }} />
                                        </div>
                                    </div>
                                ))}
                            </CardContent>
                        </Card>
                    </div>

                    {/* Recent Activity */}
                    <Card className="border-slate-800/60 bg-slate-900/40">
                        <CardHeader><CardTitle className="flex items-center gap-2"><Activity className="w-4 h-4 text-indigo-400" />Recent Activity</CardTitle></CardHeader>
                        <CardContent>
                            <div className="space-y-3">
                                {recentActivity.map((a, i) => (
                                    <div key={i} className="flex items-center gap-3">
                                        <span className="text-xs font-mono text-indigo-400 w-12 flex-shrink-0">{a.time}</span>
                                        <div className="w-6 h-6 rounded-full bg-slate-800 flex items-center justify-center flex-shrink-0">
                                            <a.icon className="w-3 h-3 text-slate-400" />
                                        </div>
                                        <span className="text-sm text-slate-300">{a.text}</span>
                                    </div>
                                ))}
                            </div>
                        </CardContent>
                    </Card>
                </div>
            )}

            {/* ── APPROVE TAB ─────────────────────────── */}
            {activeTab === "approve" && (
                <div className="space-y-6">
                    <div className="flex items-center justify-between">
                        <h2 className="text-xl font-bold text-slate-50">Pending Approvals <span className="ml-2 text-sm font-normal bg-red-500/10 text-red-400 border border-red-500/20 px-2 py-0.5 rounded">{pendingApprovals.length}</span></h2>
                        <Button variant="outline" size="sm" className="border-slate-700 text-slate-400">Filter</Button>
                    </div>
                    <div className="space-y-3">
                        {pendingApprovals.map((item, i) => (
                            <Card key={i} className="border-slate-800/60 bg-slate-900/40 hover:border-slate-700 transition-colors">
                                <CardContent className="p-5">
                                    <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                                        <div className="flex-1">
                                            <div className="flex items-center gap-2 mb-1">
                                                <PriorityBadge p={item.priority} />
                                                <h3 className="font-bold text-slate-200">{item.title}</h3>
                                            </div>
                                            <div className="flex flex-wrap gap-3 text-xs text-slate-500">
                                                <span className="flex items-center gap-1"><Users className="w-3 h-3" />{item.by}</span>
                                                <span className="flex items-center gap-1"><Building2 className="w-3 h-3" />{item.dept}</span>
                                                <span className="flex items-center gap-1"><Calendar className="w-3 h-3" />{item.date}</span>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <Button size="sm" className="bg-emerald-600 hover:bg-emerald-700 text-white" onClick={() => alert(`Approved: ${item.title}`)}>
                                                <Check className="w-3 h-3 mr-1" /> Approve
                                            </Button>
                                            <Button size="sm" variant="outline" className="border-red-500/30 text-red-400 hover:bg-red-500/10" onClick={() => alert(`Rejected: ${item.title}`)}>
                                                <X className="w-3 h-3 mr-1" /> Reject
                                            </Button>
                                            <Button size="sm" variant="ghost" className="text-slate-400 hover:text-indigo-400" onClick={() => alert(`Details: ${item.title}`)}>
                                                <Eye className="w-3 h-3 mr-1" /> Details
                                            </Button>
                                        </div>
                                    </div>
                                </CardContent>
                            </Card>
                        ))}
                    </div>
                </div>
            )}

            {/* ── ACT TAB ──────────────────────────────── */}
            {activeTab === "act" && (
                <div className="space-y-6">
                    <h2 className="text-xl font-bold text-slate-50">Quick Actions</h2>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                        {quickActions.map(action => (
                            <button
                                key={action.label}
                                onClick={() => alert(`${action.label} — coming soon!`)}
                                className={`flex flex-col items-center justify-center p-6 rounded-xl text-white font-semibold text-sm gap-3 transition-all hover:scale-105 hover:shadow-lg ${action.color}`}
                            >
                                <action.icon className="w-7 h-7" />
                                {action.label}
                            </button>
                        ))}
                    </div>

                    {/* Broadcast Notice */}
                    <Card className="border-slate-800/60 bg-slate-900/40">
                        <CardHeader><CardTitle className="flex items-center gap-2"><Megaphone className="w-4 h-4 text-amber-400" />Broadcast Notification</CardTitle></CardHeader>
                        <CardContent className="space-y-3">
                            <textarea
                                rows={3}
                                placeholder="Type your campus-wide announcement here..."
                                className="w-full bg-slate-800/50 border border-slate-700 rounded-lg p-3 text-sm text-slate-200 placeholder-slate-500 resize-none focus:outline-none focus:ring-2 focus:ring-indigo-500"
                            />
                            <div className="flex gap-2">
                                <Button className="bg-amber-600 hover:bg-amber-700 text-white" onClick={() => alert("Broadcast sent!")}>
                                    <Megaphone className="w-4 h-4 mr-2" /> Send to All
                                </Button>
                                <Button variant="outline" className="border-slate-700 text-slate-400">Select Recipients</Button>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Notification Center */}
                    <Card className="border-slate-800/60 bg-slate-900/40">
                        <CardHeader><CardTitle className="flex items-center gap-2"><Bell className="w-4 h-4 text-red-400" />Critical Notifications</CardTitle></CardHeader>
                        <CardContent className="space-y-3">
                            {[
                                { text: "Attendance below threshold in MECH Dept (81%)", type: "danger" },
                                { text: "2 Faculty shortage reported for tomorrow", type: "warning" },
                                { text: "Lab 302 projector still not fixed", type: "warning" },
                                { text: "Exam timetable clash detected — S6 EEE", type: "danger" },
                            ].map((n, i) => {
                                const style = n.type === "danger" ? "border-red-500/20 bg-red-500/5 text-red-400"
                                    : "border-amber-500/20 bg-amber-500/5 text-amber-400"
                                return (
                                    <div key={i} className={`flex items-start gap-3 p-3 rounded-lg border ${style}`}>
                                        <AlertTriangle className="w-4 h-4 flex-shrink-0 mt-0.5" />
                                        <p className="text-sm">{n.text}</p>
                                    </div>
                                )
                            })}
                        </CardContent>
                    </Card>
                </div>
            )}
        </div>
    )
}
