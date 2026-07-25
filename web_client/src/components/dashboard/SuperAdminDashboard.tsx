"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/Card"
import { Building2, Users, Activity, ShieldCheck, Server, Database, Bell, HardDrive, AlertTriangle, CheckCircle2, Search, Settings, FileText, Globe } from "lucide-react"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { getAdminDashboardStats } from "@/app/actions/admin"

export function SuperAdminDashboard({ firstName }: { firstName: string }) {
    const [stats, setStats] = useState<any>(null)
    const [institutions, setInstitutions] = useState<any[]>([])
    const [isLoading, setIsLoading] = useState(true)

    useEffect(() => {
        async function loadData() {
            setIsLoading(true)
            const result = await getAdminDashboardStats()
            if (result.stats) {
                setStats(result.stats)
                setInstitutions(result.institutions)
            }
            setIsLoading(false)
        }
        loadData()
    }, [])

    const platformKPIs = [
        { name: "Total Institutions", value: stats?.totalInstitutions || "0", icon: Building2, color: "text-blue-500", bg: "bg-blue-500/10" },
        { name: "Active Users", value: stats?.activeUsers || "0", icon: Users, color: "text-indigo-500", bg: "bg-indigo-500/10" },
        { name: "Online Users", value: stats?.onlineUsers || "0", icon: Globe, color: "text-emerald-500", bg: "bg-emerald-500/10" },
        { name: "System Uptime", value: stats?.systemUptime || "0%", icon: Activity, color: "text-purple-500", bg: "bg-purple-500/10" },
        { name: "API Requests Today", value: stats?.apiRequests || "0", icon: Server, color: "text-amber-500", bg: "bg-amber-500/10" },
        { name: "Storage Used", value: stats?.storageUsed || "0", icon: HardDrive, color: "text-cyan-500", bg: "bg-cyan-500/10" },
    ]

    const systemHealth = [
        { name: "API", status: "Healthy" },
        { name: "Database", status: "Healthy" },
        { name: "Notification Service", status: "Healthy" },
        { name: "Storage", status: "Healthy" },
        { name: "Backup", status: "Healthy" },
        { name: "Scheduler", status: "Healthy" },
    ]

    const securityAlerts = [
        { name: "Failed Logins Today", value: "0", type: "warning" },
        { name: "Locked Accounts", value: "0", type: "danger" },
        { name: "Suspicious Activity", value: "0", type: "danger" },
    ]

    return (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Platform Command Center</h1>
                    <p className="text-slate-400 mt-2">Welcome back, Super Admin {firstName}. Here is the platform status.</p>
                </div>
                <div className="flex items-center gap-3">
                    <div className="relative w-64">
                        <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-500" />
                        <Input placeholder="Global Search..." className="pl-9 bg-slate-900/50 border-slate-800" />
                    </div>
                </div>
            </div>

            {/* Platform KPIs */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
                {platformKPIs.map((stat) => (
                    <Card key={stat.name} className="border-slate-800/60 bg-slate-900/40 hover:bg-slate-800/40 transition-colors">
                        <CardContent className="p-4 flex flex-col items-center justify-center text-center">
                            <div className={`p-3 rounded-xl ${stat.bg} mb-3`}>
                                <stat.icon className={`w-6 h-6 ${stat.color}`} />
                            </div>
                            <p className="text-sm font-medium text-slate-400">{stat.name}</p>
                            <h3 className="text-2xl font-bold text-slate-50 mt-1">
                                {isLoading ? <span className="animate-pulse bg-slate-800 h-6 w-12 rounded inline-block"></span> : stat.value}
                            </h3>
                        </CardContent>
                    </Card>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Institution Overview */}
                <Card className="border-slate-800/60 bg-slate-900/40 lg:col-span-2">
                    <CardHeader className="flex flex-row items-center justify-between">
                        <div>
                            <CardTitle className="flex items-center gap-2">
                                <Building2 className="w-5 h-5 text-indigo-400" />
                                Institution Overview
                            </CardTitle>
                            <CardDescription>Manage registered colleges and universities.</CardDescription>
                        </div>
                        <Button size="sm" className="bg-indigo-600 hover:bg-indigo-700 text-white" onClick={() => alert("Create Institution feature coming soon!")}>Create Institution</Button>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center p-8">
                                    <div className="w-8 h-8 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin" />
                                </div>
                            ) : institutions.length === 0 ? (
                                <div className="text-center py-8">
                                    <p className="text-slate-500">No institutions found.</p>
                                </div>
                            ) : institutions.map((inst, i) => (
                                <div key={i} className="flex flex-col md:flex-row md:items-center justify-between p-4 rounded-xl bg-slate-800/30 border border-slate-800/50 hover:border-indigo-500/30 transition-colors">
                                    <div className="mb-4 md:mb-0">
                                        <div className="flex items-center gap-2 mb-1">
                                            <h4 className="font-bold text-slate-200 text-lg">{inst.name}</h4>
                                            <span className={`px-2 py-0.5 rounded text-xs font-bold ${inst.status === 'Active' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-amber-500/10 text-amber-400 border border-amber-500/20'}`}>
                                                {inst.status}
                                            </span>
                                        </div>
                                        <p className="text-sm text-slate-400">Principal: {inst.principal}</p>
                                    </div>
                                    <div className="flex items-center gap-6 text-sm">
                                        <div className="text-center">
                                            <p className="text-slate-500 mb-1">Users</p>
                                            <p className="font-medium text-slate-300">{inst.students}</p>
                                        </div>
                                        <div className="text-center">
                                            <p className="text-slate-500 mb-1">Storage</p>
                                            <p className="font-medium text-slate-300">{inst.storage}</p>
                                        </div>
                                        <div className="text-center">
                                            <p className="text-slate-500 mb-1">Plan</p>
                                            <p className="font-medium text-indigo-400">{inst.plan}</p>
                                        </div>
                                        <Button variant="ghost" size="sm" className="text-slate-400 hover:text-indigo-400" onClick={() => alert(`Managing ${inst.name}`)}>Manage</Button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>

                {/* System Health & Security */}
                <div className="space-y-6">
                    <Card className="border-slate-800/60 bg-slate-900/40">
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Activity className="w-5 h-5 text-emerald-400" />
                                System Health
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="grid grid-cols-2 gap-4">
                                {systemHealth.map((sys, i) => (
                                    <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-slate-800/30 border border-slate-800/50">
                                        <span className="text-sm text-slate-300">{sys.name}</span>
                                        <CheckCircle2 className="w-4 h-4 text-emerald-500" />
                                    </div>
                                ))}
                            </div>
                        </CardContent>
                    </Card>

                    <Card className="border-red-500/20 bg-slate-900/40">
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2 text-slate-200">
                                <ShieldCheck className="w-5 h-5 text-red-400" />
                                Security Center
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="space-y-3">
                                {securityAlerts.map((alert, i) => (
                                    <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-slate-800/30 border border-slate-800/50">
                                        <span className="text-sm text-slate-300">{alert.name}</span>
                                        <span className={`font-bold ${alert.type === 'danger' ? 'text-red-400' : 'text-amber-400'}`}>{alert.value}</span>
                                    </div>
                                ))}
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </div>

            {/* Quick Actions */}
            <Card className="border-slate-800/60 bg-slate-900/40">
                <CardHeader>
                    <CardTitle>Quick Actions</CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="flex flex-wrap gap-4">
                        <Button variant="outline" className="border-slate-700 hover:bg-slate-800 hover:text-indigo-400" onClick={() => alert("Create Institution feature coming soon!")}>
                            <Building2 className="w-4 h-4 mr-2" /> Create Institution
                        </Button>
                        <Button variant="outline" className="border-slate-700 hover:bg-slate-800 hover:text-indigo-400" onClick={() => alert("Create Principal feature coming soon!")}>
                            <Users className="w-4 h-4 mr-2" /> Create Principal
                        </Button>
                        <Button variant="outline" className="border-slate-700 hover:bg-slate-800 hover:text-indigo-400" onClick={() => alert("Broadcast Notification feature coming soon!")}>
                            <Bell className="w-4 h-4 mr-2" /> Broadcast Notification
                        </Button>
                        <Button variant="outline" className="border-slate-700 hover:bg-slate-800 hover:text-indigo-400" onClick={() => alert("Backup started successfully!")}>
                            <Database className="w-4 h-4 mr-2" /> Run Backup
                        </Button>
                        <Button variant="outline" className="border-slate-700 hover:bg-slate-800 hover:text-indigo-400" onClick={() => alert("View Logs feature coming soon!")}>
                            <FileText className="w-4 h-4 mr-2" /> View Logs
                        </Button>
                        <Button variant="outline" className="border-slate-700 hover:bg-slate-800 hover:text-indigo-400" onClick={() => alert("System Settings feature coming soon!")}>
                            <Settings className="w-4 h-4 mr-2" /> System Settings
                        </Button>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
