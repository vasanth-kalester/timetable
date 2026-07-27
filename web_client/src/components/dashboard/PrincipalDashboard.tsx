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

const IconMap: Record<string, any> = {
    Building2, Activity, AlertTriangle, CheckCircle2, Clock, Calendar, BarChart3, FileText, Bell, Settings, Search, ChevronRight, BookOpen, FlaskConical, Wrench, ClipboardList, TrendingUp, TrendingDown, Star, Megaphone, MapPin, LogOut, Shield, Award, Zap, Eye, Check, X, RefreshCw, Download, Loader2, Users, GraduationCap
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

    const realKpiGroups = [
        {
            label: "Academic",
            items: [
                { name: "Total Students", value: dbData?.stats?.totalStudents?.toString() || "0", trend: "", up: true },
                { name: "Total Faculty", value: dbData?.stats?.totalFaculty?.toString() || "0", trend: "", up: true },
                { name: "Departments", value: dbData?.stats?.totalDepartments?.toString() || "0", trend: "", up: true },
                { name: "Active Classes Today", value: "0", trend: "", up: true },
            ]
        },
        {
            label: "Attendance",
            items: [
                { name: "Student Attendance", value: "0%", trend: "", up: true },
                { name: "Faculty Attendance", value: "0%", trend: "", up: true },
                { name: "Classes Conducted", value: "0/0", trend: "", up: true },
                { name: "Pending Attendance", value: "0", trend: "", up: true },
            ]
        },
        {
            label: "Infrastructure",
            items: [
                { name: "Rooms Occupied", value: "0/0", trend: "", up: true },
                { name: "Labs Active", value: "0/0", trend: "", up: true },
                { name: "Available Rooms", value: "0", trend: "", up: true },
                { name: "Maintenance Issues", value: "0", trend: "", up: false },
            ]
        },
        {
            label: "Examinations",
            items: [
                { name: "Upcoming Exams", value: "0", trend: "", up: true },
                { name: "Results Published", value: "0", trend: "", up: true },
                { name: "Pending Evaluations", value: "0", trend: "", up: true },
                { name: "Hall Allocations", value: "Pending", trend: "", up: true },
            ]
        },
        {
            label: "Administration",
            items: [
                { name: "Pending Approvals", value: "0", trend: "", up: false },
                { name: "Leave Requests", value: "0", trend: "", up: false },
                { name: "Room Requests", value: "0", trend: "", up: true },
                { name: "Event Requests", value: "0", trend: "", up: true },
            ]
        }
    ]

    const realDepartments = dbData?.departments || []
    const todayOverview = dbData?.todayOverview || []
    const timeline = dbData?.timeline || []
    const pendingApprovals = dbData?.pendingApprovals || []
    const faculty = dbData?.faculty || []
    const healthScore = dbData?.healthScore || { overall: 0, label: "No Data", breakdown: [] }
    const recentActivity = dbData?.recentActivity || []

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">

            {/* ── Header ─────────────────────────────────── */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-on-surface">
                        {greeting}, Dr. {firstName} 👋
                    </h1>
                    <div className="flex flex-wrap gap-3 mt-2 text-sm text-on-surface-variant">
                        <span className="flex items-center gap-1"><Building2 className="w-3.5 h-3.5" /> {collegeName}</span>
                        <span className="flex items-center gap-1"><BookOpen className="w-3.5 h-3.5" /> AY 2025–26</span>
                        <span className="flex items-center gap-1"><Calendar className="w-3.5 h-3.5" /> {todayStr}</span>
                        <span className="flex items-center gap-1"><Clock className="w-3.5 h-3.5" /> Semester V</span>
                    </div>
                </div>
                <div className="flex items-center gap-2">
                    <Button variant="ghost" size="icon" className="text-on-surface-variant hover:text-primary"><Search className="w-4 h-4" /></Button>
                    <Button variant="ghost" size="icon" className="text-on-surface-variant hover:text-amber-600 relative">
                        <Bell className="w-4 h-4" />
                        <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 bg-error rounded-full" />
                    </Button>
                    <Button variant="ghost" size="icon" className="text-on-surface-variant hover:text-on-surface"><Settings className="w-4 h-4" /></Button>
                </div>
            </div>

            {/* ── Mode Switcher ──────────────────────────── */}
            <div className="flex gap-2 p-1 bg-surface-container-low rounded-xl border border-outline-variant w-fit">
                {(["monitor", "approve", "act"] as const).map(mode => (
                    <button
                        key={mode}
                        onClick={() => setActiveTab(mode)}
                        className={`px-5 py-2 rounded-lg text-sm font-semibold capitalize transition-all ${activeTab === mode
                            ? "bg-primary text-on-primary shadow-lg shadow-primary/20"
                            : "text-on-surface-variant hover:text-on-surface"
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
                        <div className="flex items-center gap-2 text-on-surface-variant text-sm">
                            <Loader2 className="w-4 h-4 animate-spin" /> Loading live data...
                        </div>
                    )}
                    {realKpiGroups.map(group => (
                        <div key={group.label}>
                            <h2 className="text-xs font-bold uppercase tracking-widest text-on-surface-variant mb-3">{group.label}</h2>
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                {group.items.map(kpi => (
                                    <Card key={kpi.name} className="hover:border-outline transition-colors">
                                        <CardContent className="p-4">
                                            <p className="text-xs text-on-surface-variant mb-1">{kpi.name}</p>
                                            <p className="text-2xl font-bold text-on-surface">{kpi.value}</p>
                                            {kpi.trend && kpi.trend !== "stable" && (
                                                <p className={`text-xs flex items-center gap-1 mt-1 ${kpi.up ? "text-tertiary" : "text-error"}`}>
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
                        <Card>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2"><Activity className="w-4 h-4 text-primary" />Today's Campus Overview</CardTitle>
                            </CardHeader>
                            <CardContent className="space-y-3">
                                {todayOverview.length === 0 ? (
                                    <p className="text-sm text-on-surface-variant text-center py-4">No campus events scheduled for today.</p>
                                ) : todayOverview.map((item: any, i: number) => {
                                    const IconComponent = typeof item.icon === 'string' ? IconMap[item.icon] || Activity : item.icon || Activity;
                                    return (
                                        <div key={i} className="flex items-center gap-3">
                                            <IconComponent className={`w-4 h-4 flex-shrink-0 ${item.color}`} />
                                            <span className="text-sm text-on-surface">{item.text}</span>
                                        </div>
                                    )
                                })}
                            </CardContent>
                        </Card>

                        {/* Live Timeline */}
                        <Card>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2"><Clock className="w-4 h-4 text-primary" />Live Campus Timeline</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div className="space-y-4">
                                    {timeline.length === 0 ? (
                                        <p className="text-sm text-on-surface-variant text-center py-4">No timeline events recorded yet.</p>
                                    ) : timeline.map((item: any, i: number) => {
                                        const dotColor = item.type === "success" ? "bg-tertiary"
                                            : item.type === "warning" ? "bg-amber-500"
                                                : item.type === "danger" ? "bg-error" : "bg-primary"
                                        return (
                                            <div key={i} className="flex gap-3 items-start">
                                                <div className="flex flex-col items-center">
                                                    <div className={`w-2.5 h-2.5 rounded-full mt-1 flex-shrink-0 ${dotColor}`} />
                                                    {i < timeline.length - 1 && <div className="w-px flex-1 bg-outline-variant mt-1" style={{ minHeight: 20 }} />}
                                                </div>
                                                <div className="pb-2">
                                                    <p className="text-xs font-mono text-primary">{item.time}</p>
                                                    <p className="text-sm text-on-surface">{item.event}</p>
                                                </div>
                                            </div>
                                        )
                                    })}
                                </div>
                            </CardContent>
                        </Card>

                        {/* Institution Health Score */}
                        <Card>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2"><Star className="w-4 h-4 text-amber-500" />Institution Health Score</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div className="text-center mb-6">
                                    <div className="relative inline-flex items-center justify-center">
                                        <svg className="w-32 h-32 -rotate-90" viewBox="0 0 100 100">
                                            <circle cx="50" cy="50" r="40" fill="none" stroke="var(--color-surface-container-high)" strokeWidth="10" />
                                            <circle cx="50" cy="50" r="40" fill="none" stroke="var(--color-primary)"
                                                strokeWidth="10" strokeLinecap="round"
                                                strokeDasharray={`${healthScore.overall * 2.51} 251`} />
                                        </svg>
                                        <div className="absolute text-center">
                                            <p className="text-3xl font-black text-on-surface">{healthScore.overall}</p>
                                            <p className="text-xs text-on-surface-variant">/ 100</p>
                                        </div>
                                    </div>
                                    <p className="text-tertiary font-bold text-lg mt-1">{healthScore.label}</p>
                                </div>
                                <div className="space-y-2">
                                    {healthScore.breakdown.map((b: any) => (
                                        <div key={b.name}>
                                            <p className="text-xs text-on-surface-variant mb-1">{b.name}</p>
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
                            <h2 className="text-lg font-bold text-on-surface flex items-center gap-2">
                                <Building2 className="w-5 h-5 text-primary" /> Department Performance
                            </h2>
                            <Button variant="ghost" size="sm" className="text-primary hover:text-primary/80">View All <ChevronRight className="w-4 h-4 ml-1" /></Button>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                            {realDepartments.map((dept: any) => (
                                <Card key={dept.name} className="hover:border-primary/40 transition-colors cursor-pointer group">
                                    <CardContent className="p-5">
                                        <div className="flex items-start justify-between mb-3">
                                            <h3 className="font-bold text-on-surface group-hover:text-primary transition-colors">{dept.name}</h3>
                                            <span className={`text-xs font-bold px-2 py-0.5 rounded ${dept.attendance >= 90 ? "bg-tertiary/10 text-tertiary border border-tertiary/20" : dept.attendance >= 80 ? "bg-amber-500/10 text-amber-500 border border-amber-500/20" : "bg-error-container text-on-error-container border border-error/20"}`}>
                                                {dept.attendance}%
                                            </span>
                                        </div>
                                        <AttendanceBar pct={dept.attendance} label="Attendance" />
                                        <div className="grid grid-cols-3 gap-2 mt-3 text-center">
                                            <div>
                                                <p className="text-xs text-on-surface-variant">Faculty</p>
                                                <p className="font-bold text-on-surface">{dept.faculty}</p>
                                            </div>
                                            <div>
                                                <p className="text-xs text-on-surface-variant">Students</p>
                                                <p className="font-bold text-on-surface">{dept.students}</p>
                                            </div>
                                            <div>
                                                <p className="text-xs text-on-surface-variant">Exam %</p>
                                                <p className={`font-bold ${dept.examPerf >= 85 ? "text-tertiary" : "text-amber-500"}`}>{dept.examPerf}%</p>
                                            </div>
                                        </div>
                                        {(dept.pendingLeaves > 0 || dept.conflicts > 0) && (
                                            <div className="flex gap-3 mt-3 pt-3 border-t border-outline-variant">
                                                {dept.pendingLeaves > 0 && <span className="text-xs text-amber-500 flex items-center gap-1"><Clock className="w-3 h-3" />{dept.pendingLeaves} Leaves</span>}
                                                {dept.conflicts > 0 && <span className="text-xs text-error flex items-center gap-1"><AlertTriangle className="w-3 h-3" />{dept.conflicts} Conflicts</span>}
                                            </div>
                                        )}
                                    </CardContent>
                                </Card>
                            ))}
                        </div>
                    </div>

                    {/* Attendance Analytics */}
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2"><BarChart3 className="w-4 h-4 text-primary" />Attendance Analytics</CardTitle>
                            <CardDescription>Department-wise attendance breakdown</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <p className="text-xs font-bold text-on-surface-variant uppercase tracking-wider mb-4">Student Attendance by Dept</p>
                                    {realDepartments.map((dept: any) => (
                                        <AttendanceBar key={dept.name} pct={dept.attendance} label={dept.name} />
                                    ))}
                                </div>
                                <div className="space-y-4">
                                    <div className="p-4 rounded-xl bg-tertiary/10 border border-tertiary/20">
                                        <p className="text-xs text-tertiary font-bold mb-1">Above Threshold (≥90%)</p>
                                        <p className="text-2xl font-black text-tertiary">CSE, IT, ECE</p>
                                    </div>
                                    <div className="p-4 rounded-xl bg-amber-500/10 border border-amber-500/20">
                                        <p className="text-xs text-amber-500 font-bold mb-1">Below Threshold (&lt;85%)</p>
                                        <p className="text-2xl font-black text-amber-500">MECH, EEE</p>
                                    </div>
                                    <div className="p-4 rounded-xl bg-error-container border border-error/20">
                                        <p className="text-xs text-error font-bold mb-1">Missing Attendance Today</p>
                                        <p className="text-2xl font-black text-error">7 Classes</p>
                                    </div>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Faculty Overview */}
                    <Card>
                        <CardHeader>
                            <div className="flex items-center justify-between">
                                <CardTitle className="flex items-center gap-2"><GraduationCap className="w-4 h-4 text-primary" />Faculty Overview</CardTitle>
                                <div className="flex gap-3 text-sm">
                                    <span className="text-tertiary font-bold">178 Present</span>
                                    <span className="text-amber-500 font-bold">6 On Leave</span>
                                    <span className="text-error font-bold">2 Late</span>
                                </div>
                            </div>
                        </CardHeader>
                        <CardContent>
                            <div className="overflow-x-auto">
                                <table className="w-full text-sm">
                                    <thead>
                                        <tr className="text-xs uppercase text-on-surface-variant border-b border-outline-variant">
                                            <th className="text-left py-2">Name</th>
                                            <th className="text-left py-2">Dept</th>
                                            <th className="text-center py-2">Classes Today</th>
                                            <th className="text-center py-2">Workload</th>
                                            <th className="text-center py-2">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {faculty.length === 0 ? (
                                            <tr><td colSpan={5} className="py-6 text-center text-on-surface-variant">No faculty data available.</td></tr>
                                        ) : faculty.map((f: any, i: number) => (
                                            <tr key={i} className="border-b border-outline-variant/40 hover:bg-surface-container-low">
                                                <td className="py-3 font-medium text-on-surface">{f.name}</td>
                                                <td className="py-3 text-on-surface-variant">{f.dept}</td>
                                                <td className="py-3 text-center text-on-surface-variant">{f.classes}</td>
                                                <td className="py-3 text-center">
                                                    <span className={`text-xs font-bold ${f.workload === "High" ? "text-error" : "text-on-surface-variant"}`}>{f.workload}</span>
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
                        <Card>
                            <CardHeader><CardTitle className="flex items-center gap-2 text-base"><Calendar className="w-4 h-4 text-primary" />Timetable Control</CardTitle></CardHeader>
                            <CardContent className="space-y-3">
                                {[
                                    { label: "Current (Published)", status: "Active", color: "text-tertiary" },
                                    { label: "Draft — Sem 6", status: "In Review", color: "text-amber-500" },
                                    { label: "Simulation S6-A", status: "0 Conflicts", color: "text-primary" },
                                ].map((t, i) => (
                                    <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-surface-container-low border border-outline-variant">
                                        <span className="text-sm text-on-surface">{t.label}</span>
                                        <span className={`text-xs font-bold ${t.color}`}>{t.status}</span>
                                    </div>
                                ))}
                                <Button size="sm" className="w-full mt-2" variant="outline" onClick={() => alert("Timetable module coming soon!")}>
                                    Review & Publish
                                </Button>
                            </CardContent>
                        </Card>

                        <Card>
                            <CardHeader><CardTitle className="flex items-center gap-2 text-base"><Building2 className="w-4 h-4 text-primary" />Infrastructure</CardTitle></CardHeader>
                            <CardContent className="space-y-3">
                                {[
                                    { label: "Rooms", value: "124 / 150", sub: "83% occupied" },
                                    { label: "Labs", value: "18 / 22", sub: "82% active" },
                                    { label: "Seminar Halls", value: "3 / 4", sub: "1 reserved" },
                                    { label: "Maintenance", value: "4 open", sub: "2 critical" },
                                ].map((r, i) => (
                                    <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-surface-container-low border border-outline-variant">
                                        <div>
                                            <p className="text-sm font-medium text-on-surface">{r.label}</p>
                                            <p className="text-xs text-on-surface-variant">{r.sub}</p>
                                        </div>
                                        <span className="text-sm font-bold text-on-surface">{r.value}</span>
                                    </div>
                                ))}
                            </CardContent>
                        </Card>

                        <Card>
                            <CardHeader><CardTitle className="flex items-center gap-2 text-base"><ClipboardList className="w-4 h-4 text-primary" />Examinations</CardTitle></CardHeader>
                            <CardContent className="space-y-3">
                                {[
                                    { label: "Upcoming Exams", value: "3" },
                                    { label: "Invigilators Assigned", value: "96 / 98" },
                                    { label: "Hall Allocation", value: "Done ✓" },
                                    { label: "Pending Results", value: "8 Subjects" },
                                    { label: "Avg Pass %", value: "87%" },
                                ].map((e, i) => (
                                    <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-surface-container-low border border-outline-variant">
                                        <span className="text-sm text-on-surface">{e.label}</span>
                                        <span className="text-sm font-bold text-on-surface">{e.value}</span>
                                    </div>
                                ))}
                            </CardContent>
                        </Card>
                    </div>

                    {/* Reports + Resource Utilization */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <Card>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2"><FileText className="w-4 h-4 text-primary" />Reports Center</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div className="grid grid-cols-2 gap-3">
                                    {["Attendance", "Faculty", "Student", "Examination", "Infrastructure", "Timetable"].map(r => (
                                        <Button key={r} variant="outline" size="sm" className="justify-between" onClick={() => alert(`Generating ${r} report...`)}>
                                            <span>{r}</span>
                                            <Download className="w-3 h-3 ml-2 text-on-surface-variant" />
                                        </Button>
                                    ))}
                                </div>
                            </CardContent>
                        </Card>

                        <Card>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2"><BarChart3 className="w-4 h-4 text-primary" />Resource Utilization</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <p className="text-xs font-bold text-on-surface-variant uppercase tracking-wider mb-3">Room Utilization</p>
                                {[
                                    { label: "Morning (8–1)", pct: 91 },
                                    { label: "Afternoon (1–5)", pct: 68 },
                                    { label: "Evening (5–8)", pct: 24 },
                                ].map(r => (
                                    <div key={r.label} className="mb-3">
                                        <div className="flex justify-between text-xs text-on-surface-variant mb-1">
                                            <span>{r.label}</span><span className="font-bold">{r.pct}%</span>
                                        </div>
                                        <div className="h-2.5 bg-surface-container-high rounded-full overflow-hidden">
                                            <div className="h-full bg-primary rounded-full" style={{ width: `${r.pct}%` }} />
                                        </div>
                                    </div>
                                ))}
                            </CardContent>
                        </Card>
                    </div>

                    {/* Recent Activity */}
                    <Card>
                        <CardHeader><CardTitle className="flex items-center gap-2"><Activity className="w-4 h-4 text-primary" />Recent Activity</CardTitle></CardHeader>
                        <CardContent>
                            <div className="space-y-3">
                                {recentActivity.length === 0 ? (
                                    <p className="text-sm text-on-surface-variant text-center py-4">No recent activity.</p>
                                ) : recentActivity.map((a: any, i: number) => {
                                    const IconComponent = typeof a.icon === 'string' ? IconMap[a.icon] || Activity : a.icon || Activity;
                                    return (
                                        <div key={i} className="flex items-center gap-3">
                                            <span className="text-xs font-mono text-primary w-12 flex-shrink-0">{a.time}</span>
                                            <div className="w-6 h-6 rounded-full bg-surface-container-low flex items-center justify-center flex-shrink-0">
                                                <IconComponent className="w-3 h-3 text-on-surface-variant" />
                                            </div>
                                            <span className="text-sm text-on-surface">{a.text}</span>
                                        </div>
                                    )
                                })}
                            </div>
                        </CardContent>
                    </Card>
                </div>
            )}

            {/* ── APPROVE TAB ─────────────────────────── */}
            {activeTab === "approve" && (
                <div className="space-y-6">
                    <div className="flex items-center justify-between">
                        <h2 className="text-xl font-bold text-on-surface">Pending Approvals <span className="ml-2 text-sm font-normal bg-error-container text-on-error-container border border-error/20 px-2 py-0.5 rounded">{pendingApprovals.length}</span></h2>
                        <Button variant="outline" size="sm">Filter</Button>
                    </div>
                    <div className="space-y-3">
                        {pendingApprovals.length === 0 ? (
                            <div className="text-center py-12 bg-surface-container-low border border-outline-variant rounded-xl">
                                <CheckCircle2 className="w-12 h-12 text-on-surface-variant mx-auto mb-3" />
                                <h3 className="text-lg font-medium text-on-surface">All caught up!</h3>
                                <p className="text-on-surface-variant">There are no pending approvals at this time.</p>
                            </div>
                        ) : pendingApprovals.map((item: any, i: number) => (
                            <Card key={i} className="hover:border-primary/40 transition-colors">
                                <CardContent className="p-5">
                                    <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                                        <div className="flex-1">
                                            <div className="flex items-center gap-2 mb-1">
                                                <PriorityBadge p={item.priority} />
                                                <h3 className="font-bold text-on-surface">{item.title}</h3>
                                            </div>
                                            <div className="flex flex-wrap gap-3 text-xs text-on-surface-variant">
                                                <span className="flex items-center gap-1"><Users className="w-3 h-3" />{item.by}</span>
                                                <span className="flex items-center gap-1"><Building2 className="w-3 h-3" />{item.dept}</span>
                                                <span className="flex items-center gap-1"><Calendar className="w-3 h-3" />{item.date}</span>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <Button size="sm" onClick={() => alert(`Approved: ${item.title}`)}>
                                                <Check className="w-3 h-3 mr-1" /> Approve
                                            </Button>
                                            <Button size="sm" variant="outline" className="border-error text-error hover:bg-error-container" onClick={() => alert(`Rejected: ${item.title}`)}>
                                                <X className="w-3 h-3 mr-1" /> Reject
                                            </Button>
                                            <Button size="sm" variant="ghost" className="text-on-surface-variant hover:text-primary" onClick={() => alert(`Details: ${item.title}`)}>
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
                    <h2 className="text-xl font-bold text-on-surface">Quick Actions</h2>
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
                    <Card>
                        <CardHeader><CardTitle className="flex items-center gap-2"><Megaphone className="w-4 h-4 text-amber-500" />Broadcast Notification</CardTitle></CardHeader>
                        <CardContent className="space-y-3">
                            <textarea
                                rows={3}
                                placeholder="Type your campus-wide announcement here..."
                                className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-3 text-sm text-on-surface placeholder-on-surface-variant resize-none focus:outline-none focus:ring-2 focus:ring-primary"
                            />
                            <div className="flex gap-2">
                                <Button onClick={() => alert("Broadcast sent!")}>
                                    <Megaphone className="w-4 h-4 mr-2" /> Send to All
                                </Button>
                                <Button variant="outline">Select Recipients</Button>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Notification Center */}
                    <Card>
                        <CardHeader><CardTitle className="flex items-center gap-2"><Bell className="w-4 h-4 text-error" />Critical Notifications</CardTitle></CardHeader>
                        <CardContent className="space-y-3">
                            {[
                                { text: "Attendance below threshold in MECH Dept (81%)", type: "danger" },
                                { text: "2 Faculty shortage reported for tomorrow", type: "warning" },
                                { text: "Lab 302 projector still not fixed", type: "warning" },
                                { text: "Exam timetable clash detected — S6 EEE", type: "danger" },
                            ].map((n, i) => {
                                const style = n.type === "danger" ? "border-error/20 bg-error-container text-on-error-container"
                                    : "border-amber-500/20 bg-amber-500/10 text-amber-500"
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
