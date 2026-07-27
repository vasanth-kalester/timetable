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
                    <h1 className="text-3xl font-bold tracking-tight text-on-surface">Institutions</h1>
                    <p className="text-on-surface-variant mt-2">Manage all registered colleges and universities on the platform.</p>
                </div>
                <div className="flex items-center gap-3">
                    <div className="relative w-64">
                        <Search className="absolute left-3 top-2.5 h-4 w-4 text-outline" />
                        <Input placeholder="Search institutions..." className="pl-9 bg-surface-container-low border-outline-variant" />
                    </div>
                    <Button className="bg-indigo-600 hover:bg-indigo-700 text-white" onClick={() => alert("Add Institution feature coming soon!")}>
                        <Plus className="w-4 h-4 mr-2" /> Add Institution
                    </Button>
                </div>
            </div>

            {error && (
                <div className="p-4 rounded-lg bg-error-container border border-error/20 text-on-error-container flex items-center gap-3">
                    <ShieldAlert className="w-5 h-5" />
                    <p>{error}</p>
                </div>
            )}

            <Card>
                <CardHeader>
                    <CardTitle>Registered Institutions</CardTitle>
                    <CardDescription>A list of all institutions currently using EduFlow OS.</CardDescription>
                </CardHeader>
                <CardContent>
                    {isLoading ? (
                        <div className="flex justify-center p-8">
                            <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
                        </div>
                    ) : institutions.length === 0 ? (
                        <div className="text-center py-12">
                            <Building2 className="w-12 h-12 text-on-surface-variant mx-auto mb-4" />
                            <h3 className="text-lg font-medium text-on-surface">No institutions found</h3>
                            <p className="text-on-surface-variant mt-1">Get started by adding a new institution to the platform.</p>
                        </div>
                    ) : (
                        <div className="overflow-x-auto">
                            <table className="w-full text-sm text-left">
                                <thead className="text-xs text-on-surface-variant uppercase bg-surface-container-low border-b border-outline-variant">
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
                                            className="border-b border-outline-variant/40 hover:bg-surface-container-low transition-colors cursor-pointer"
                                            onClick={() => router.push(`/admin/institutions/${inst.id}`)}
                                        >
                                            <td className="px-4 py-4 font-medium text-on-surface">{inst.name}</td>
                                            <td className="px-4 py-4 text-on-surface-variant font-mono">{inst.code}</td>
                                            <td className="px-4 py-4">
                                                <span className="flex items-center gap-1.5 text-tertiary bg-tertiary/10 px-2 py-1 rounded-full w-fit text-xs font-medium border border-tertiary/20">
                                                    <CheckCircle2 className="w-3 h-3" /> Active
                                                </span>
                                            </td>
                                            <td className="px-4 py-4 text-on-surface-variant">{inst.principal}</td>
                                            <td className="px-4 py-4 text-on-surface-variant">{inst.students + inst.faculty}</td>
                                            <td className="px-4 py-4 text-primary font-medium">{inst.plan}</td>
                                            <td className="px-4 py-4 text-right">
                                                <Button variant="ghost" size="sm" className="text-primary hover:text-primary/80 hover:bg-primary/10">
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
