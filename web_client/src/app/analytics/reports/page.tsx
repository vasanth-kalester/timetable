"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { FileText, Download, Loader2, CheckCircle } from "lucide-react"

export default function ReportBuilderPage() {
    const [isGenerating, setIsGenerating] = useState(false)
    const [isDone, setIsDone] = useState(false)

    const handleGenerate = () => {
        setIsGenerating(true)
        setIsDone(false)
        setTimeout(() => {
            setIsGenerating(false)
            setIsDone(true)
        }, 2000)
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-50">Custom Report Builder</h1>
                <p className="text-slate-400 mt-2">Select filters and export formats to generate detailed operational reports.</p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Configuration Panel */}
                <Card className="border-slate-800/60 bg-slate-900/40 lg:col-span-1 h-fit">
                    <CardHeader>
                        <CardTitle className="text-lg flex items-center gap-2"><FileText className="w-5 h-5 text-indigo-400" /> Configuration</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="space-y-2">
                            <label className="text-sm font-medium text-slate-400">Report Type</label>
                            <select className="w-full bg-slate-800 border border-slate-700 rounded-md p-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                                <option>Faculty Workload</option>
                                <option>Room Utilization</option>
                                <option>Timetable Quality</option>
                            </select>
                        </div>
                        <div className="space-y-2">
                            <label className="text-sm font-medium text-slate-400">Academic Year</label>
                            <select className="w-full bg-slate-800 border border-slate-700 rounded-md p-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                                <option>2025-2026</option>
                                <option>2024-2025</option>
                            </select>
                        </div>
                        <div className="space-y-2">
                            <label className="text-sm font-medium text-slate-400">Department (Optional)</label>
                            <select className="w-full bg-slate-800 border border-slate-700 rounded-md p-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                                <option>All Departments</option>
                                <option>Computer Science</option>
                                <option>Mechanical</option>
                            </select>
                        </div>

                        <div className="pt-4">
                            <label className="text-sm font-medium text-slate-400 block mb-2">Export Format</label>
                            <div className="flex gap-2">
                                <label className="flex items-center gap-2 text-slate-300">
                                    <input type="radio" name="format" defaultChecked className="text-indigo-600 focus:ring-indigo-500 bg-slate-800 border-slate-700" /> PDF
                                </label>
                                <label className="flex items-center gap-2 text-slate-300 ml-4">
                                    <input type="radio" name="format" className="text-indigo-600 focus:ring-indigo-500 bg-slate-800 border-slate-700" /> Excel
                                </label>
                            </div>
                        </div>

                        <Button
                            className="w-full mt-6 bg-indigo-600 hover:bg-indigo-700 text-white"
                            onClick={handleGenerate}
                            disabled={isGenerating}
                        >
                            {isGenerating ? (
                                <><Loader2 className="w-4 h-4 mr-2 animate-spin" /> Generating...</>
                            ) : (
                                <><Download className="w-4 h-4 mr-2" /> Generate Report</>
                            )}
                        </Button>
                    </CardContent>
                </Card>

                {/* Preview Area */}
                <div className="lg:col-span-2">
                    <Card className="border-slate-800/60 bg-slate-900/40 h-full min-h-[400px] flex flex-col items-center justify-center">
                        {isDone ? (
                            <div className="text-center space-y-4">
                                <CheckCircle className="w-16 h-16 text-emerald-500 mx-auto" />
                                <h3 className="text-xl font-bold text-slate-200">Report Generated Successfully!</h3>
                                <p className="text-slate-400">Your report is ready to download.</p>
                                <Button className="bg-emerald-600 hover:bg-emerald-700 text-white mt-4">
                                    <Download className="w-4 h-4 mr-2" /> Download Now
                                </Button>
                            </div>
                        ) : (
                            <div className="text-center space-y-4">
                                <FileText className="w-16 h-16 text-slate-600 mx-auto" />
                                <h3 className="text-xl font-bold text-slate-200">Report Preview</h3>
                                <p className="text-slate-400">Configure and generate a report to see the preview here.</p>
                            </div>
                        )}
                    </Card>
                </div>
            </div>
        </div>
    )
}
