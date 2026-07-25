"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { History, PlayCircle, Users, Building2, RefreshCw, Calendar } from "lucide-react"
import { getSemesterReplayData } from "@/app/actions/replay"

export default function SemesterReplayPage() {
    const [selectedYear, setSelectedYear] = useState("2025-2026")
    const [selectedSemester, setSelectedSemester] = useState("Odd Semester")
    const [isReplaying, setIsReplaying] = useState(false)
    const [replayData, setReplayData] = useState<any>(null)
    const [isLoading, setIsLoading] = useState(false)

    const handleStartReplay = async () => {
        setIsLoading(true)
        const result = await getSemesterReplayData(selectedYear, selectedSemester)
        if (!result.error) {
            setReplayData(result)
            setIsReplaying(true)
        }
        setIsLoading(false)
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-50">Semester Replay</h1>
                <p className="text-slate-400 mt-2">Reconstruct and review the operational data, timetable, and events of a past semester.</p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Controls */}
                <Card className="border-slate-800/60 bg-slate-900/40 lg:col-span-1 h-fit">
                    <CardHeader>
                        <CardTitle className="text-lg">Select Semester</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="space-y-2">
                            <label className="text-sm font-medium text-slate-400">Academic Year</label>
                            <select
                                className="w-full bg-slate-800 border border-slate-700 rounded-md p-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                value={selectedYear}
                                onChange={(e) => setSelectedYear(e.target.value)}
                            >
                                <option value="2024-2025">2024-2025</option>
                                <option value="2025-2026">2025-2026</option>
                            </select>
                        </div>
                        <div className="space-y-2">
                            <label className="text-sm font-medium text-slate-400">Semester</label>
                            <select
                                className="w-full bg-slate-800 border border-slate-700 rounded-md p-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                value={selectedSemester}
                                onChange={(e) => setSelectedSemester(e.target.value)}
                            >
                                <option value="Odd Semester">Odd Semester</option>
                                <option value="Even Semester">Even Semester</option>
                            </select>
                        </div>
                        <Button
                            className="w-full mt-4 bg-indigo-600 hover:bg-indigo-700 text-white"
                            onClick={handleStartReplay}
                            disabled={isLoading}
                        >
                            {isLoading ? "Loading..." : <><PlayCircle className="w-4 h-4 mr-2" /> Start Replay</>}
                        </Button>
                    </CardContent>
                </Card>

                {/* Replay View */}
                <div className="lg:col-span-2 space-y-6">
                    {!isReplaying ? (
                        <Card className="border-slate-800/60 bg-slate-900/40 h-96 flex flex-col items-center justify-center">
                            <History className="w-16 h-16 text-slate-600 mb-4" />
                            <p className="text-slate-400">Select a semester and start the replay.</p>
                        </Card>
                    ) : (
                        <>
                            {/* Summary Cards */}
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <Card className="border-purple-500/20 bg-purple-500/5">
                                    <CardContent className="p-4">
                                        <Users className="w-5 h-5 text-purple-400 mb-2" />
                                        <p className="text-2xl font-bold text-purple-400">{replayData?.reconstruction?.averageFacultyWorkload}%</p>
                                        <p className="text-xs text-slate-400">Avg Workload</p>
                                    </CardContent>
                                </Card>
                                <Card className="border-blue-500/20 bg-blue-500/5">
                                    <CardContent className="p-4">
                                        <Building2 className="w-5 h-5 text-blue-400 mb-2" />
                                        <p className="text-2xl font-bold text-blue-400">{replayData?.reconstruction?.averageRoomUtilization}%</p>
                                        <p className="text-xs text-slate-400">Avg Utilization</p>
                                    </CardContent>
                                </Card>
                                <Card className="border-amber-500/20 bg-amber-500/5">
                                    <CardContent className="p-4">
                                        <RefreshCw className="w-5 h-5 text-amber-400 mb-2" />
                                        <p className="text-2xl font-bold text-amber-400">{replayData?.reconstruction?.totalSubstitutions}</p>
                                        <p className="text-xs text-slate-400">Substitutions</p>
                                    </CardContent>
                                </Card>
                            </div>

                            {/* Timeline */}
                            <Card className="border-slate-800/60 bg-slate-900/40">
                                <CardHeader>
                                    <CardTitle className="text-lg flex items-center gap-2"><Calendar className="w-5 h-5 text-indigo-400" /> Operational Timeline</CardTitle>
                                </CardHeader>
                                <CardContent>
                                    <div className="space-y-6">
                                        {replayData?.reconstruction?.operationalEvents.map((event: any, i: number) => (
                                            <div key={i} className="flex gap-4">
                                                <div className="flex flex-col items-center">
                                                    <div className="w-3 h-3 rounded-full bg-indigo-500 mt-1" />
                                                    {i < replayData.reconstruction.operationalEvents.length - 1 && (
                                                        <div className="w-px h-full bg-slate-700 my-1" />
                                                    )}
                                                </div>
                                                <div className="pb-4">
                                                    <p className="text-xs font-bold text-indigo-400">{event.date}</p>
                                                    <p className="text-lg font-bold text-slate-200 mt-1">{event.event}</p>
                                                    <p className="text-sm text-slate-400 mt-1">Impact: {event.impact}</p>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                </CardContent>
                            </Card>
                        </>
                    )}
                </div>
            </div>
        </div>
    )
}
