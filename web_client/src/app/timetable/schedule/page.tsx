"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Loader2, AlertTriangle, Save, Plus } from "lucide-react"
import { useSession } from "next-auth/react"
import { getClasses, getSubjects, getRooms, getTimetableSlots, createTimetableSlot, deleteTimetableSlot } from "@/app/actions/timetable"
import { getStaff } from "@/app/actions/staff"

const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
const timeSlots = ["09:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"]

export default function TimetableSchedulePage() {
    const { data: session } = useSession()
    const [isLoading, setIsLoading] = useState(true)
    const [collegeId, setCollegeId] = useState<string | null>(null)
    const [departmentId, setDepartmentId] = useState<string | null>(null)
    const [error, setError] = useState<string | null>(null)

    const [classes, setClasses] = useState<any[]>([])
    const [subjects, setSubjects] = useState<any[]>([])
    const [rooms, setRooms] = useState<any[]>([])
    const [staff, setStaff] = useState<any[]>([])
    const [slots, setSlots] = useState<any[]>([])

    const [selectedClass, setSelectedClass] = useState<string>("")
    const [isScheduling, setIsScheduling] = useState<{ day: string, time: string } | null>(null)

    // Form state for new slot
    const [newSlot, setNewSlot] = useState({ subjectId: "", staffId: "", roomId: "" })
    const [isSaving, setIsSaving] = useState(false)

    useEffect(() => {
        async function loadUserAndCollege() {
            if (session?.user) {
                const { getProfile } = await import("@/app/actions/settings")
                const result = await getProfile((session.user as any).id)

                if (result.profile?.college_id) {
                    setCollegeId(result.profile.college_id)
                    setDepartmentId((result.profile as any).department_id || null)
                    fetchData(result.profile.college_id, (result.profile as any).department_id)
                } else {
                    setIsLoading(false)
                }
            }
        }
        loadUserAndCollege()
    }, [session])

    const fetchData = async (cId: string, dId: string | null) => {
        setIsLoading(true)
        setError(null)
        try {
            if (dId) {
                const [clsRes, subRes, rmRes, stfRes, slotRes] = await Promise.all([
                    getClasses(dId),
                    getSubjects(dId),
                    getRooms(cId),
                    getStaff(cId, 'approved', 'faculty', dId),
                    getTimetableSlots(dId)
                ])

                if (clsRes.classes) {
                    setClasses(clsRes.classes)
                    if (clsRes.classes.length > 0) setSelectedClass(clsRes.classes[0].id)
                }
                if (subRes.subjects) setSubjects(subRes.subjects)
                if (rmRes.rooms) setRooms(rmRes.rooms)
                if (stfRes.staff) setStaff(stfRes.staff)
                if (slotRes.slots) setSlots(slotRes.slots)
            }
        } catch (err: any) {
            console.error(err)
            setError("Failed to load data.")
        } finally {
            setIsLoading(false)
        }
    }

    const handleSaveSlot = async () => {
        if (!isScheduling || !selectedClass || !newSlot.subjectId || !newSlot.staffId || !newSlot.roomId) {
            setError("Please fill in all fields.")
            return
        }

        setIsSaving(true)
        setError(null)

        try {
            const result = await createTimetableSlot({
                day: isScheduling.day,
                time: isScheduling.time,
                classId: selectedClass,
                subjectId: newSlot.subjectId,
                staffId: newSlot.staffId,
                roomId: newSlot.roomId
            })

            if (result.error) throw new Error(result.error)

            // Refresh slots
            const slotRes = await getTimetableSlots(departmentId!)
            if (slotRes.slots) setSlots(slotRes.slots)

            setIsScheduling(null)
            setNewSlot({ subjectId: "", staffId: "", roomId: "" })
        } catch (err: any) {
            setError(err.message || "Failed to schedule slot.")
        } finally {
            setIsSaving(false)
        }
    }

    const handleDeleteSlot = async (id: string) => {
        if (!confirm("Are you sure you want to remove this class?")) return
        try {
            await deleteTimetableSlot(id)
            const slotRes = await getTimetableSlots(departmentId!)
            if (slotRes.slots) setSlots(slotRes.slots)
        } catch (err: any) {
            alert("Failed to delete slot.")
        }
    }

    if (isLoading) {
        return <div className="flex justify-center py-12"><Loader2 className="w-8 h-8 animate-spin text-indigo-500" /></div>
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500 max-w-6xl mx-auto">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Schedule Timetable</h1>
                    <p className="text-slate-400 mt-2">Assign subjects and staff to classes.</p>
                </div>
                <div className="flex items-center gap-3">
                    <label className="text-sm font-medium text-slate-300">Select Class:</label>
                    <select
                        className="h-10 rounded-md border border-slate-800 bg-slate-950 px-3 py-2 text-sm text-slate-50"
                        value={selectedClass}
                        onChange={e => setSelectedClass(e.target.value)}
                    >
                        {classes.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                    </select>
                </div>
            </div>

            {error && (
                <div className="p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4" />
                    {error}
                </div>
            )}

            <Card className="border-slate-800/60 bg-slate-900/40 overflow-hidden">
                <CardContent className="p-0 overflow-auto">
                    <div className="min-w-[900px]">
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
                                    <div className="p-4 text-center text-xs font-medium text-slate-500 border-r border-slate-800 bg-slate-900/20">
                                        {time}
                                    </div>
                                    {days.map((day) => {
                                        const slot = slots.find(s => s.classId === selectedClass && s.day === day && s.time === time)
                                        const isEditing = isScheduling?.day === day && isScheduling?.time === time

                                        return (
                                            <div key={`${day}-${time}`} className="p-2 border-r border-slate-800 last:border-0 min-h-[120px] relative group/cell">
                                                {isEditing ? (
                                                    <div className="absolute inset-1 bg-slate-950 border border-indigo-500/50 rounded-lg p-2 z-20 flex flex-col gap-2 shadow-xl">
                                                        <select className="text-xs bg-slate-900 border border-slate-800 rounded p-1" value={newSlot.subjectId} onChange={e => setNewSlot({ ...newSlot, subjectId: e.target.value })}>
                                                            <option value="">Subject...</option>
                                                            {subjects.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                                                        </select>
                                                        <select className="text-xs bg-slate-900 border border-slate-800 rounded p-1" value={newSlot.staffId} onChange={e => setNewSlot({ ...newSlot, staffId: e.target.value })}>
                                                            <option value="">Staff...</option>
                                                            {staff.map(s => <option key={s.id} value={s.id}>{s.first_name} {s.last_name}</option>)}
                                                        </select>
                                                        <select className="text-xs bg-slate-900 border border-slate-800 rounded p-1" value={newSlot.roomId} onChange={e => setNewSlot({ ...newSlot, roomId: e.target.value })}>
                                                            <option value="">Room...</option>
                                                            {rooms.map(r => <option key={r.id} value={r.id}>{r.name}</option>)}
                                                        </select>
                                                        <div className="flex gap-1 mt-auto">
                                                            <Button size="sm" variant="outline" className="flex-1 h-6 text-[10px]" onClick={() => setIsScheduling(null)}>Cancel</Button>
                                                            <Button size="sm" className="flex-1 h-6 text-[10px] bg-indigo-600 hover:bg-indigo-700" onClick={handleSaveSlot} disabled={isSaving}>
                                                                {isSaving ? <Loader2 className="w-3 h-3 animate-spin" /> : "Save"}
                                                            </Button>
                                                        </div>
                                                    </div>
                                                ) : slot ? (
                                                    <div className="h-full rounded-lg border border-indigo-500/20 bg-indigo-500/5 p-2 flex flex-col justify-between relative">
                                                        <Button
                                                            variant="ghost"
                                                            size="icon"
                                                            className="absolute top-1 right-1 h-5 w-5 opacity-0 group-hover/cell:opacity-100 text-red-400 hover:text-red-300 hover:bg-red-500/10"
                                                            onClick={() => handleDeleteSlot(slot.id)}
                                                        >
                                                            <AlertTriangle className="w-3 h-3" />
                                                        </Button>
                                                        <p className="text-xs font-semibold text-indigo-300">{subjects.find(s => s.id === slot.subjectId)?.name}</p>
                                                        <div className="mt-2 space-y-1">
                                                            <p className="text-[10px] text-slate-400 truncate">{staff.find(s => s.id === slot.staffId)?.first_name} {staff.find(s => s.id === slot.staffId)?.last_name}</p>
                                                            <p className="text-[10px] text-slate-500 bg-slate-900/50 px-1 rounded inline-block">{rooms.find(r => r.id === slot.roomId)?.name}</p>
                                                        </div>
                                                    </div>
                                                ) : (
                                                    <div className="h-full w-full flex items-center justify-center opacity-0 group-hover/cell:opacity-100 transition-opacity">
                                                        <Button variant="ghost" size="sm" className="h-8 text-xs text-slate-400 hover:text-indigo-400" onClick={() => setIsScheduling({ day, time })}>
                                                            <Plus className="w-3 h-3 mr-1" /> Assign
                                                        </Button>
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
