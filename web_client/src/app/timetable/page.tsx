"use client"

import { useState, useEffect } from "react"
import { Card, CardContent } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { ChevronLeft, ChevronRight, Filter, Loader2, AlertTriangle, Printer, Coffee, Sparkles } from "lucide-react"
import { useSession } from "next-auth/react"
import { getClasses, getSubjects, getRooms, getTimetableSlots, generateDepartmentTimetable } from "@/app/actions/timetable"
import { getStaff } from "@/app/actions/staff"

const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
const timeSlots = ["09:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"]
const LUNCH_BREAK = "12:00 PM"

const SUBJECT_COLORS = [
    { border: "border-blue-300", bg: "bg-blue-50", text: "text-blue-700", sub: "text-blue-500" },
    { border: "border-violet-300", bg: "bg-violet-50", text: "text-violet-700", sub: "text-violet-500" },
    { border: "border-emerald-300", bg: "bg-emerald-50", text: "text-emerald-700", sub: "text-emerald-500" },
    { border: "border-amber-300", bg: "bg-amber-50", text: "text-amber-700", sub: "text-amber-500" },
    { border: "border-rose-300", bg: "bg-rose-50", text: "text-rose-700", sub: "text-rose-500" },
    { border: "border-cyan-300", bg: "bg-cyan-50", text: "text-cyan-700", sub: "text-cyan-500" },
    { border: "border-orange-300", bg: "bg-orange-50", text: "text-orange-700", sub: "text-orange-500" },
    { border: "border-pink-300", bg: "bg-pink-50", text: "text-pink-700", sub: "text-pink-500" },
]

function getColorForSubject(subjectId: string) {
    let hash = 0
    for (let i = 0; i < subjectId.length; i++) {
        hash = subjectId.charCodeAt(i) + ((hash << 5) - hash)
    }
    return SUBJECT_COLORS[Math.abs(hash) % SUBJECT_COLORS.length]
}

export default function TimetablePage() {
    const { data: session } = useSession()
    const [currentWeek, setCurrentWeek] = useState("Week 12 (Oct 16 — Oct 21)")
    const [weekOffset, setWeekOffset] = useState(0)

    const [isLoading, setIsLoading] = useState(true)
    const [error, setError] = useState<string | null>(null)

    const [classes, setClasses] = useState<any[]>([])
    const [subjects, setSubjects] = useState<any[]>([])
    const [rooms, setRooms] = useState<any[]>([])
    const [staff, setStaff] = useState<any[]>([])
    const [slots, setSlots] = useState<any[]>([])

    const [selectedClass, setSelectedClass] = useState<string>("")
    const [isGenerating, setIsGenerating] = useState(false)
    const [collegeId, setCollegeId] = useState<string | null>(null)
    const [departmentId, setDepartmentId] = useState<string | null>(null)

    useEffect(() => {
        if (!session?.user) return
        async function loadData() {
            const { getProfile } = await import("@/app/actions/settings")
            const result = await getProfile((session!.user as any).id)

            if (result.profile?.college_id && (result.profile as any).department_id) {
                const cId = result.profile.college_id
                const dId = (result.profile as any).department_id
                setCollegeId(cId)
                setDepartmentId(dId)

                try {
                    const [clsRes, subRes, rmRes, slotRes, stfRes] = await Promise.all([
                        getClasses(dId),
                        getClasses(dId).then(r => r.classes?.[0]?.id ? getSubjects(r.classes[0].id) : { subjects: [] }),
                        getRooms(cId),
                        getTimetableSlots(dId),
                        getStaff(cId, 'approved', 'faculty', dId)
                    ])

                    if (clsRes.classes) {
                        setClasses(clsRes.classes)
                        if (clsRes.classes.length > 0) setSelectedClass(clsRes.classes[0].id)
                    }
                    if (subRes.subjects) setSubjects(subRes.subjects)
                    if (rmRes.rooms) setRooms(rmRes.rooms)
                    if (slotRes.slots) setSlots(slotRes.slots)
                    if (stfRes.staff) setStaff(stfRes.staff)
                } catch {
                    setError("Failed to load timetable data.")
                } finally {
                    setIsLoading(false)
                }
            } else {
                setIsLoading(false)
            }
        }
        loadData()
    }, [session])

    // Load subjects when class changes
    const handleClassChange = async (classId: string) => {
        setSelectedClass(classId)
        const subRes = await getSubjects(classId)
        if (subRes.subjects) setSubjects(subRes.subjects)
    }

    const handleWeekNav = (dir: 1 | -1) => {
        setWeekOffset(prev => prev + dir)
        // In a real app, you'd compute the actual week label from the offset
    }

    const handleGenerateDepartmentTimetable = async () => {
        if (!departmentId || !collegeId) return

        if (!confirm("This will delete all existing timetable slots for this department and generate new ones. Are you sure?")) {
            return
        }

        setIsGenerating(true)
        setError(null)
        try {
            const res = await generateDepartmentTimetable(departmentId, collegeId)
            if (res.error) throw new Error(res.error)

            // Refresh slots
            const slotRes = await getTimetableSlots(departmentId)
            if (slotRes.slots) setSlots(slotRes.slots)

            alert(`Successfully generated ${res.slotsGenerated} slots for the department!`)
        } catch (err: any) {
            setError(err.message || "Failed to generate timetable.")
        } finally {
            setIsGenerating(false)
        }
    }

    const totalSlots = slots.filter(s => s.classId === selectedClass).length
    const filledSlots = totalSlots
    const gridTotal = days.length * (timeSlots.length - 1) // exclude lunch
    const fillPercent = gridTotal > 0 ? Math.round((filledSlots / gridTotal) * 100) : 0

    if (isLoading) {
        return (
            <div className="flex flex-col items-center justify-center py-24 gap-4 h-full">
                <Loader2 className="w-10 h-10 animate-spin text-primary" />
                <p className="text-sm text-on-surface-variant">Loading timetable…</p>
            </div>
        )
    }

    return (
        <div className="space-y-5 animate-in fade-in slide-in-from-bottom-4 duration-500 h-full flex flex-col">
            {/* Header */}
            <div className="flex items-center justify-between flex-wrap gap-3">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-on-surface">Timetable</h1>
                    <p className="text-on-surface-variant mt-1">View your academic schedule for the week.</p>
                </div>
                <div className="flex items-center gap-2 flex-wrap">
                    {/* Class selector */}
                    <select
                        id="class-selector"
                        className="h-9 rounded-lg border border-outline-variant bg-surface-container-lowest px-3 py-1 text-sm text-on-surface shadow-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
                        value={selectedClass}
                        onChange={e => handleClassChange(e.target.value)}
                    >
                        {classes.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                    </select>

                    {/* Week navigator */}
                    <div className="flex items-center bg-surface-container-lowest border border-outline-variant rounded-lg overflow-hidden shadow-sm">
                        <Button variant="ghost" size="icon" className="h-9 w-9 rounded-none border-r border-outline-variant" onClick={() => handleWeekNav(-1)}>
                            <ChevronLeft className="w-4 h-4" />
                        </Button>
                        <span className="text-sm font-medium px-4 text-on-surface whitespace-nowrap">{currentWeek}</span>
                        <Button variant="ghost" size="icon" className="h-9 w-9 rounded-none border-l border-outline-variant" onClick={() => handleWeekNav(1)}>
                            <ChevronRight className="w-4 h-4" />
                        </Button>
                    </div>

                    {/* Generate Department Timetable */}
                    {(session?.user as any)?.role === 'hod' && (
                        <Button
                            variant="default"
                            size="sm"
                            className="h-9 gap-2 bg-primary text-on-primary hover:bg-primary/90"
                            onClick={handleGenerateDepartmentTimetable}
                            disabled={isGenerating}
                        >
                            {isGenerating ? <Loader2 className="w-4 h-4 animate-spin" /> : <Sparkles className="w-4 h-4" />}
                            Generate All
                        </Button>
                    )}

                    {/* Print */}
                    <Button
                        id="btn-print"
                        variant="outline"
                        size="sm"
                        className="h-9 gap-2"
                        onClick={() => window.print()}
                    >
                        <Printer className="w-4 h-4" />
                        Print
                    </Button>
                </div>
            </div>

            {/* Stats strip */}
            {classes.length > 0 && (
                <div className="flex items-center gap-4 text-sm text-on-surface-variant flex-wrap">
                    <div className="flex items-center gap-2">
                        <span className="font-medium text-on-surface">{filledSlots}</span> slots scheduled
                    </div>
                    <div className="flex items-center gap-1">
                        <div className="h-1.5 w-24 rounded-full bg-surface-container-highest overflow-hidden">
                            <div className="h-full bg-primary rounded-full transition-all" style={{ width: `${fillPercent}%` }} />
                        </div>
                        <span>{fillPercent}% filled</span>
                    </div>
                    <div className="ml-auto flex gap-2 items-center text-xs">
                        {SUBJECT_COLORS.slice(0, 4).map((c, i) => (
                            <span key={i} className={`w-3 h-3 rounded-sm inline-block ${c.bg} border ${c.border}`} />
                        ))}
                        <span>Subject colours</span>
                    </div>
                </div>
            )}

            {error && (
                <div className="p-3 rounded-xl bg-error-container border border-error/20 text-on-error-container text-sm flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4" />
                    {error}
                </div>
            )}

            {/* Timetable Grid */}
            <Card className="flex-1 overflow-hidden flex flex-col">
                <CardContent className="p-0 flex-1 overflow-auto">
                    <div className="min-w-[800px]">
                        {/* Header row */}
                        <div className="grid grid-cols-7 border-b border-outline-variant bg-surface-container-low sticky top-0 z-10">
                            <div className="p-4 text-center text-xs font-semibold text-on-surface-variant border-r border-outline-variant uppercase tracking-wider">
                                Time
                            </div>
                            {days.map(day => (
                                <div key={day} className="p-4 text-center text-sm font-semibold text-on-surface border-r border-outline-variant last:border-0">
                                    {day}
                                </div>
                            ))}
                        </div>

                        {/* Rows */}
                        <div className="divide-y divide-outline-variant">
                            {timeSlots.map(time => {
                                const isLunch = time === LUNCH_BREAK
                                return (
                                    <div key={time} className={`grid grid-cols-7 group ${isLunch ? "bg-amber-50/50" : ""}`}>
                                        {/* Time label */}
                                        <div className={`p-3 text-center text-xs font-medium border-r border-outline-variant flex flex-col items-center justify-center gap-0.5
                                            ${isLunch ? "text-amber-600 bg-amber-50" : "text-on-surface-variant bg-surface-container-low"}`}>
                                            {isLunch && <Coffee className="w-3.5 h-3.5 text-amber-400 mb-0.5" />}
                                            <span>{time}</span>
                                            {isLunch && <span className="text-[10px] text-amber-400 font-normal">Lunch</span>}
                                        </div>

                                        {days.map(day => {
                                            const slot = slots.find(s => s.classId === selectedClass && s.day === day && s.time === time)
                                            const color = slot ? getColorForSubject(slot.subjectId) : null
                                            const staffMember = slot ? staff.find(s => s.id === slot.staffId) : null
                                            const room = slot ? rooms.find(r => r.id === slot.roomId) : null
                                            const subject = slot ? subjects.find(s => s.id === slot.subjectId) : null

                                            return (
                                                <div
                                                    key={`${day}-${time}`}
                                                    className={`p-2 border-r border-outline-variant last:border-0 min-h-[95px]
                                                        ${isLunch && !slot ? "bg-amber-50/30" : ""}
                                                        ${!slot && !isLunch ? "hover:bg-surface-container-low transition-colors" : ""}
                                                    `}
                                                >
                                                    {slot ? (
                                                        <div className={`h-full rounded-lg border ${color!.border} ${color!.bg} p-2.5 flex flex-col gap-1 shadow-sm`}>
                                                            <p className={`text-xs font-bold leading-tight ${color!.text}`}>
                                                                {subject?.name ?? "Subject"}
                                                            </p>
                                                            {subject?.code && (
                                                                <span className={`text-[10px] font-medium ${color!.sub}`}>
                                                                    {subject.code}
                                                                </span>
                                                            )}
                                                            {staffMember && (
                                                                <p className="text-[10px] text-on-surface-variant mt-auto leading-tight">
                                                                    {staffMember.first_name} {staffMember.last_name}
                                                                </p>
                                                            )}
                                                            {room && (
                                                                <p className="text-[10px] text-on-surface-variant bg-white/60 px-1 rounded inline-block w-fit">
                                                                    {room.name}
                                                                </p>
                                                            )}
                                                        </div>
                                                    ) : isLunch ? (
                                                        <div className="h-full flex items-center justify-center">
                                                            <span className="text-[10px] text-amber-300">—</span>
                                                        </div>
                                                    ) : (
                                                        /* Empty cell with faint grid hint */
                                                        <div className="h-full min-h-[75px] rounded-lg border-2 border-dashed border-outline-variant/30 group-hover:border-outline-variant/60 transition-colors" />
                                                    )}
                                                </div>
                                            )
                                        })}
                                    </div>
                                )
                            })}
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
