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
        { name: "Total Institutions", value: stats?.totalInstitutions || "0", icon: Building2, color: "text-primary", bg: "bg-primary/10" },
        { name: "Active Users", value: stats?.activeUsers || "0", icon: Users, color: "text-secondary", bg: "bg-secondary/10" },
        { name: "Online Users", value: stats?.onlineUsers || "0", icon: Globe, color: "text-tertiary", bg: "bg-tertiary/10" },
        { name: "System Uptime", value: stats?.systemUptime || "0%", icon: Activity, color: "text-primary", bg: "bg-primary/10" },
        { name: "API Requests Today", value: stats?.apiRequests || "0", icon: Server, color: "text-error", bg: "bg-error/10" },
        { name: "Storage Used", value: stats?.storageUsed || "0", icon: HardDrive, color: "text-secondary", bg: "bg-secondary/10" },
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
                    <h1 className="text-3xl font-bold tracking-tight text-on-surface">Platform Command Center</h1>
                    <p className="text-on-surface-variant mt-2">Welcome back, Super Admin {firstName}. Here is the platform status.</p>
                </div>
                <div className="flex items-center gap-3">
                    <div className="relative w-64">
                        <Search className="absolute left-3 top-2.5 h-4 w-4 text-outline" />
                        <Input placeholder="Global Search..." className="pl-9 bg-surface-container-low border-outline-variant" />
                    </div>
                </div>
            </div>

            {/* Platform KPIs */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
                {platformKPIs.map((stat) => (
                    <Card key={stat.name}>
                        <CardContent className="p-4 flex flex-col items-center justify-center text-center">
                            <div className={`p-3 rounded-xl ${stat.bg} mb-3`}>
                                <stat.icon className={`w-6 h-6 ${stat.color}`} />
                            </div>
                            <p className="text-sm font-medium text-on-surface-variant">{stat.name}</p>
                            <h3 className="text-2xl font-bold text-on-surface mt-1">
                                {isLoading ? <span className="animate-pulse bg-surface-container-low h-6 w-12 rounded inline-block"></span> : stat.value}
                            </h3>
                        </CardContent>
                    </Card>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Institution Overview */}
                <Card className="lg:col-span-2">
                    <CardHeader className="flex flex-row items-center justify-between">
                        <div>
                            <CardTitle className="flex items-center gap-2">
                                <Building2 className="w-5 h-5 text-primary" />
                                Institution Overview
                            </CardTitle>
                            <CardDescription>Manage registered colleges and universities.</CardDescription>
                        </div>
                        <Button size="sm" onClick={() => alert("Create Institution feature coming soon!")}>Create Institution</Button>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {isLoading ? (
                                <div className="flex justify-center p-8">
                                    <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
                                </div>
                            ) : institutions.length === 0 ? (
                                <div className="text-center py-8">
                                    <p className="text-on-surface-variant">No institutions found.</p>
                                </div>
                            ) : institutions.map((inst, i) => (
                                <div key={i} className="flex flex-col md:flex-row md:items-center justify-between p-4 rounded-xl bg-surface-container-low border border-outline-variant hover:border-primary/30 transition-colors">
                                    <div className="mb-4 md:mb-0">
                                        <div className="flex items-center gap-2 mb-1">
                                            <h4 className="font-bold text-on-surface text-lg">{inst.name}</h4>
                                            <span className={`px-2 py-0.5 rounded text-xs font-bold ${inst.status === 'Active' ? 'bg-tertiary/10 text-tertiary border border-tertiary/20' : 'bg-error-container text-on-error-container border border-error/20'}`}>
                                                {inst.status}
                                            </span>
                                        </div>
                                        <p className="text-sm text-on-surface-variant">Principal: {inst.principal}</p>
                                    </div>
                                    <div className="flex items-center gap-6 text-sm">
                                        <div className="text-center">
                                            <p className="text-outline mb-1">Users</p>
                                            <p className="font-medium text-on-surface-variant">{inst.students}</p>
                                        </div>
                                        <div className="text-center">
                                            <p className="text-outline mb-1">Storage</p>
                                            <p className="font-medium text-on-surface-variant">{inst.storage}</p>
                                        </div>
                                        <div className="text-center">
                                            <p className="text-outline mb-1">Plan</p>
                                            <p className="font-medium text-primary">{inst.plan}</p>
                                        </div>
                                        <Button variant="ghost" size="sm" onClick={() => alert(`Managing ${inst.name}`)}>Manage</Button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>

                {/* System Health & Security */}
                <div className="space-y-6">
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Activity className="w-5 h-5 text-tertiary" />
                                System Health
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="grid grid-cols-2 gap-4">
                                {systemHealth.map((sys, i) => (
                                    <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-surface-container-low border border-outline-variant">
                                        <span className="text-sm text-on-surface-variant">{sys.name}</span>
                                        <CheckCircle2 className="w-4 h-4 text-tertiary" />
                                    </div>
                                ))}
                            </div>
                        </CardContent>
                    </Card>

                    <Card className="border-error/20 bg-error-container/10">
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2 text-on-surface">
                                <ShieldCheck className="w-5 h-5 text-error" />
                                Security Center
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="space-y-3">
                                {securityAlerts.map((alert, i) => (
                                    <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-surface-container-low border border-outline-variant">
                                        <span className="text-sm text-on-surface-variant">{alert.name}</span>
                                        <span className={`font-bold ${alert.type === 'danger' ? 'text-error' : 'text-error'}`}>{alert.value}</span>
                                    </div>
                                ))}
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </div>

            {/* Quick Actions */}
            <Card>
                <CardHeader>
                    <CardTitle>Quick Actions</CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="flex flex-wrap gap-4">
                        <Button variant="outline" onClick={() => alert("Create Institution feature coming soon!")}>
                            <Building2 className="w-4 h-4 mr-2" /> Create Institution
                        </Button>
                        <Button variant="outline" onClick={() => alert("Create Principal feature coming soon!")}>
                            <Users className="w-4 h-4 mr-2" /> Create Principal
                        </Button>
                        <Button variant="outline" onClick={() => alert("Broadcast Notification feature coming soon!")}>
                            <Bell className="w-4 h-4 mr-2" /> Broadcast Notification
                        </Button>
                        <Button variant="outline" onClick={() => alert("Backup started successfully!")}>
                            <Database className="w-4 h-4 mr-2" /> Run Backup
                        </Button>
                        <Button variant="outline" onClick={() => alert("View Logs feature coming soon!")}>
                            <FileText className="w-4 h-4 mr-2" /> View Logs
                        </Button>
                        <Button variant="outline" onClick={() => alert("System Settings feature coming soon!")}>
                            <Settings className="w-4 h-4 mr-2" /> System Settings
                        </Button>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
