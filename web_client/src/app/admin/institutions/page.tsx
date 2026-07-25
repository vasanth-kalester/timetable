"use client"

import { useEffect, useState } from "react"
import { Building2, Search, Plus, MoreVertical, ShieldAlert, CheckCircle2 } from "lucide-react"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/Card"
import { getInstitutions } from "@/app/actions/admin"

import { useRouter } from "next/navigation"

export default function InstitutionsPage() {
    const router = useRouter()
    const [institutions, setInstitutions] = useState<any[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [error, setError] = useState<string | null>(null)

    useEffect(() => {
        async function loadInstitutions() {
            setIsLoading(true)
            const result = await getInstitutions()
            if (result.error) {
                setError(result.error)
            } else if (result.institutions) {
                setInstitutions(result.institutions)
            }
            setIsLoading(false)
        }
        loadInstitutions()
    }, [])

    return (
        <div className="p-6 md:p-8 max-w-7xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Institutions</h1>
                    <p className="text-slate-400 mt-2">Manage all registered colleges and universities on the platform.</p>
                </div>
                <div className="flex items-center gap-3">
                    <div className="relative w-64">
                        <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-500" />
                        <Input placeholder="Search institutions..." className="pl-9 bg-slate-900/50 border-slate-800" />
                    </div>
                    <Button className="bg-indigo-600 hover:bg-indigo-700 text-white" onClick={() => alert("Add Institution feature coming soon!")}>
                        <Plus className="w-4 h-4 mr-2" /> Add Institution
                    </Button>
                </div>
            </div>

            {error && (
                <div className="p-4 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 flex items-center gap-3">
                    <ShieldAlert className="w-5 h-5" />
                    <p>{error}</p>
                </div>
            )}

            <Card className="border-slate-800/60 bg-slate-900/40">
                <CardHeader>
                    <CardTitle>Registered Institutions</CardTitle>
                    <CardDescription>A list of all institutions currently using EduFlow OS.</CardDescription>
                </CardHeader>
                <CardContent>
                    {isLoading ? (
                        <div className="flex justify-center p-8">
                            <div className="w-8 h-8 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin" />
                        </div>
                    ) : institutions.length === 0 ? (
                        <div className="text-center py-12">
                            <Building2 className="w-12 h-12 text-slate-600 mx-auto mb-4" />
                            <h3 className="text-lg font-medium text-slate-300">No institutions found</h3>
                            <p className="text-slate-500 mt-1">Get started by adding a new institution to the platform.</p>
                        </div>
                    ) : (
                        <div className="overflow-x-auto">
                            <table className="w-full text-sm text-left">
                                <thead className="text-xs text-slate-400 uppercase bg-slate-800/50">
                                    <tr>
                                        <th className="px-4 py-3 rounded-tl-lg">Institution Name</th>
                                        <th className="px-4 py-3">Code</th>
                                        <th className="px-4 py-3">Status</th>
                                        <th className="px-4 py-3">Principal</th>
                                        <th className="px-4 py-3">Users</th>
                                        <th className="px-4 py-3">Plan</th>
                                        <th className="px-4 py-3 rounded-tr-lg text-right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {institutions.map((inst) => (
                                        <tr
                                            key={inst.id}
                                            className="border-b border-slate-800/50 hover:bg-slate-800/30 transition-colors cursor-pointer"
                                            onClick={() => router.push(`/admin/institutions/${inst.id}`)}
                                        >
                                            <td className="px-4 py-4 font-medium text-slate-200">{inst.name}</td>
                                            <td className="px-4 py-4 text-slate-400 font-mono">{inst.code}</td>
                                            <td className="px-4 py-4">
                                                <span className="flex items-center gap-1.5 text-emerald-400 bg-emerald-500/10 px-2 py-1 rounded-full w-fit text-xs font-medium border border-emerald-500/20">
                                                    <CheckCircle2 className="w-3 h-3" /> Active
                                                </span>
                                            </td>
                                            <td className="px-4 py-4 text-slate-300">{inst.principal}</td>
                                            <td className="px-4 py-4 text-slate-300">{inst.students + inst.faculty}</td>
                                            <td className="px-4 py-4 text-indigo-400 font-medium">{inst.plan}</td>
                                            <td className="px-4 py-4 text-right">
                                                <Button variant="ghost" size="sm" className="text-indigo-400 hover:text-indigo-300 hover:bg-indigo-500/10">
                                                    View Details
                                                </Button>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </CardContent>
            </Card>
        </div>
    )
}
