"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { ChevronLeft, ChevronRight, Filter, Loader2, AlertTriangle } from "lucide-react"
import { useSession } from "next-auth/react"
import { getClasses, getSubjects, getRooms, getTimetableSlots } from "@/app/actions/timetable"

const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
const timeSlots = ["09:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"]

export default function TimetablePage() {
    const { data: session } = useSession()
    const [currentWeek, setCurrentWeek] = useState("Week 12 (Oct 16 - Oct 21)")

    const [isLoading, setIsLoading] = useState(true)
    const [error, setError] = useState<string | null>(null)

    const [classes, setClasses] = useState<any[]>([])
    const [subjects, setSubjects] = useState<any[]>([])
    const [rooms, setRooms] = useState<any[]>([])
    const [slots, setSlots] = useState<any[]>([])

    const [selectedClass, setSelectedClass] = useState<string>("")

    useEffect(() => {
        async function loadData() {
            if (session?.user) {
                const { getProfile } = await import("@/app/actions/settings")
                const result = await getProfile((session.user as any).id)

                if (result.profile?.college_id && (result.profile as any).department_id) {
                    const cId = result.profile.college_id
                    const dId = (result.profile as any).department_id

                    try {
                        const [clsRes, subRes, rmRes, slotRes] = await Promise.all([
                            getClasses(dId),
                            getSubjects(dId),
                            getRooms(cId),
                            getTimetableSlots(dId)
                        ])

                        if (clsRes.classes) {
                            setClasses(clsRes.classes)
                            if (clsRes.classes.length > 0) setSelectedClass(clsRes.classes[0].id)
                        }
                        if (subRes.subjects) setSubjects(subRes.subjects)
                        if (rmRes.rooms) setRooms(rmRes.rooms)
                        if (slotRes.slots) setSlots(slotRes.slots)
                    } catch (err: any) {
                        setError("Failed to load timetable data.")
                    } finally {
                        setIsLoading(false)
                    }
                } else {
                    setIsLoading(false)
                }
            }
        }
        loadData()
    }, [session])

    if (isLoading) {
        return <div className="flex justify-center py-12 h-full items-center"><Loader2 className="w-8 h-8 animate-spin text-indigo-500" /></div>
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500 h-full flex flex-col">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Timetable</h1>
                    <p className="text-slate-400 mt-2">View your academic schedule.</p>
                </div>
                <div className="flex items-center gap-3">
                    <select
                        className="h-9 rounded-md border border-slate-800 bg-slate-950 px-3 py-1 text-sm text-slate-50 mr-4"
                        value={selectedClass}
                        onChange={e => setSelectedClass(e.target.value)}
                    >
                        {classes.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                    </select>

                    <Button variant="outline" size="sm" className="h-9">
                        <Filter className="w-4 h-4 mr-2" /> Filter
                    </Button>
                    <div className="flex items-center bg-slate-900 border border-slate-800 rounded-md p-1">
                        <Button variant="ghost" size="icon" className="h-7 w-7 rounded-sm">
                            <ChevronLeft className="w-4 h-4" />
                        </Button>
                        <span className="text-sm font-medium px-4 text-slate-200">{currentWeek}</span>
                        <Button variant="ghost" size="icon" className="h-7 w-7 rounded-sm">
                            <ChevronRight className="w-4 h-4" />
                        </Button>
                    </div>
                </div>
            </div>

            {error && (
                <div className="p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4" />
                    {error}
                </div>
            )}

            <Card className="flex-1 border-slate-800/60 bg-slate-900/40 overflow-hidden flex flex-col">
                <CardContent className="p-0 flex-1 overflow-auto">
                    <div className="min-w-[800px]">
                        {/* Header Row */}
                        <div className="grid grid-cols-7 border-b border-slate-800 bg-slate-900/80 sticky top-0 z-10">
                            <div className="p-4 text-center text-sm font-medium text-slate-400 border-r border-slate-800">
                                Time
                            </div>
                            {days.map((day) => (
                                <div key={day} className="p-4 text-center text-sm font-medium text-slate-200 border-r border-slate-800 last:border-0">
                                    {day}
                                </div>
                            ))}
                        </div>

                        {/* Time Slots */}
                        <div className="divide-y divide-slate-800">
                            {timeSlots.map((time) => (
                                <div key={time} className="grid grid-cols-7 group">
                                    <div className="p-4 text-center text-xs font-medium text-slate-500 border-r border-slate-800 bg-slate-900/20 group-hover:bg-slate-900/40 transition-colors">
                                        {time}
                                    </div>
                                    {days.map((day) => {
                                        const slot = slots.find(s => s.classId === selectedClass && s.day === day && s.time === time)
                                        return (
                                            <div key={`${day}-${time}`} className="p-2 border-r border-slate-800 last:border-0 min-h-[100px] hover:bg-slate-800/20 transition-colors">
                                                {slot && (
                                                    <div className="h-full rounded-lg border border-indigo-500/30 bg-indigo-500/10 p-3 flex flex-col justify-between shadow-sm">
                                                        <p className="text-sm font-semibold leading-tight text-indigo-100">{subjects.find(s => s.id === slot.subjectId)?.name}</p>
                                                        <div className="mt-2 flex items-center justify-between text-xs opacity-80">
                                                            <span className="text-indigo-200">{rooms.find(r => r.id === slot.roomId)?.name}</span>
                                                        </div>
                                                    </div>
                                                )}
                                            </div>
                                        )
                                    })}
                                </div>
                            ))}
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
