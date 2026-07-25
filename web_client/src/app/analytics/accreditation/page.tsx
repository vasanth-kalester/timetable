"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { CheckCircle, AlertTriangle, Download, Award } from "lucide-react"

const metrics = [
    { indicator: "Faculty-Student Ratio", value: "1:15", target: "1:20", status: "Compliant" },
    { indicator: "Classroom Availability", value: "100%", target: "100%", status: "Compliant" },
    { indicator: "Laboratory Adequacy", value: "95%", target: "100%", status: "Warning" },
    { indicator: "Teaching Load Distribution", value: "Even", target: "Even", status: "Compliant" },
]

export default function AccreditationCenterPage() {
    const [selectedBody, setSelectedBody] = useState("AICTE")

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Accreditation Center</h1>
                    <p className="text-slate-400 mt-2">Track compliance indicators against target values for accreditation bodies.</p>
                </div>
                <Button className="bg-indigo-600 hover:bg-indigo-700 text-white">
                    <Download className="w-4 h-4 mr-2" /> Generate Evidence Report
                </Button>
            </div>

            {/* Body Selector */}
            <div className="flex gap-2 p-1 bg-slate-900/60 rounded-xl border border-slate-800 w-fit">
                {["AICTE", "NBA", "NAAC"].map(body => (
                    <button
                        key={body}
                        onClick={() => setSelectedBody(body)}
                        className={`px-5 py-2 rounded-lg text-sm font-semibold transition-all ${selectedBody === body
                                ? "bg-indigo-600 text-white shadow-lg shadow-indigo-600/20"
                                : "text-slate-400 hover:text-slate-200"
                            }`}
                    >
                        {body}
                    </button>
                ))}
            </div>

            {/* Overall Status */}
            <div className="p-6 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center gap-6">
                <CheckCircle className="w-12 h-12 text-emerald-500 flex-shrink-0" />
                <div>
                    <h2 className="text-xl font-bold text-emerald-500">{selectedBody} Status: Ready for Audit</h2>
                    <p className="text-emerald-400/80 mt-1">Most key indicators are currently meeting or exceeding requirements.</p>
                </div>
            </div>

            {/* Metrics Table */}
            <Card className="border-slate-800/60 bg-slate-900/40">
                <CardHeader>
                    <CardTitle className="flex items-center gap-2"><Award className="w-5 h-5 text-indigo-400" /> Key Indicators</CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm">
                            <thead>
                                <tr className="text-xs uppercase text-slate-500 border-b border-slate-800">
                                    <th className="text-left py-3 px-4">Indicator</th>
                                    <th className="text-left py-3 px-4">Current Value</th>
                                    <th className="text-left py-3 px-4">Target</th>
                                    <th className="text-center py-3 px-4">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                {metrics.map((metric, i) => {
                                    const isCompliant = metric.status === "Compliant"
                                    const color = isCompliant ? "text-emerald-400" : "text-amber-400"
                                    const bg = isCompliant ? "bg-emerald-500/10 border-emerald-500/20" : "bg-amber-500/10 border-amber-500/20"
                                    const Icon = isCompliant ? CheckCircle : AlertTriangle

                                    return (
                                        <tr key={i} className="border-b border-slate-800/40 hover:bg-slate-800/20">
                                            <td className="py-4 px-4 font-medium text-slate-200">{metric.indicator}</td>
                                            <td className="py-4 px-4 font-bold text-slate-300">{metric.value}</td>
                                            <td className="py-4 px-4 text-slate-400">{metric.target}</td>
                                            <td className="py-4 px-4 text-center">
                                                <div className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full border text-xs font-bold ${color} ${bg}`}>
                                                    <Icon className="w-3.5 h-3.5" />
                                                    {metric.status}
                                                </div>
                                            </td>
                                        </tr>
                                    )
                                })}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
