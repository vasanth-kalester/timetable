"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Building2, Monitor, MapPin, CheckCircle2, XCircle, Users, Plus, X, Loader2 } from "lucide-react"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { getRooms, addRoom } from "@/app/actions/campus"

export default function CampusPage() {
    const [rooms, setRooms] = useState<{ id: string, name: string, type: string, capacity: string, status: string, equipment: string[], block: string, floor: string }[]>([])
    const [isAddingRoom, setIsAddingRoom] = useState(false)
    const [newRoom, setNewRoom] = useState({ name: "", type: "Classroom", capacity: "", block: "A", floor: "1" })
    const [isLoading, setIsLoading] = useState(true)
    const [isSaving, setIsSaving] = useState(false)

    const fetchRooms = async () => {
        setIsLoading(true)
        const result = await getRooms()
        if (result.rooms) {
            setRooms(result.rooms)
        }
        setIsLoading(false)
    }

    useEffect(() => {
        fetchRooms()
    }, [])

    const handleAddRoom = async () => {
        if (!newRoom.name || !newRoom.capacity) return

        setIsSaving(true)
        const result = await addRoom(newRoom)

        if (result.success) {
            await fetchRooms()
            setIsAddingRoom(false)
            setNewRoom({ name: "", type: "Classroom", capacity: "", block: "A", floor: "1" })
        } else {
            alert(result.error || "Failed to add room")
        }
        setIsSaving(false)
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Campus Infrastructure</h1>
                    <p className="text-slate-400 mt-2">Monitor and manage campus resources and room allocations.</p>
                </div>
                <Button onClick={() => setIsAddingRoom(true)} className="bg-indigo-600 hover:bg-indigo-700 text-white">
                    <Plus className="w-4 h-4 mr-2" /> Add Room
                </Button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {[
                    { title: "Total Rooms", value: rooms.length.toString(), icon: Building2, color: "text-blue-500" },
                    { title: "Available Now", value: rooms.filter(r => r.status === 'Available').length.toString(), icon: CheckCircle2, color: "text-emerald-500" },
                    { title: "In Use", value: rooms.filter(r => r.status === 'In Use').length.toString(), icon: Users, color: "text-amber-500" },
                    { title: "Maintenance", value: rooms.filter(r => r.status === 'Maintenance').length.toString(), icon: XCircle, color: "text-red-500" },
                ].map((stat, i) => (
                    <Card key={i} className="border-slate-800/60 bg-slate-900/40">
                        <CardContent className="p-6 flex items-center gap-4">
                            <div className={`p-3 rounded-xl bg-slate-800 ${stat.color}`}>
                                <stat.icon className="w-6 h-6" />
                            </div>
                            <div>
                                <p className="text-sm font-medium text-slate-400">{stat.title}</p>
                                <p className="text-2xl font-bold text-slate-50">{isLoading ? "-" : stat.value}</p>
                            </div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            {isAddingRoom && (
                <Card className="border-indigo-500/30 bg-indigo-500/5">
                    <CardHeader className="flex flex-row items-center justify-between pb-2">
                        <CardTitle className="text-lg text-indigo-400">Add New Room / Lab</CardTitle>
                        <Button variant="ghost" size="sm" onClick={() => setIsAddingRoom(false)} className="h-8 w-8 p-0">
                            <X className="h-4 w-4" />
                        </Button>
                    </CardHeader>
                    <CardContent>
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 items-end">
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Room Name</label>
                                <Input placeholder="e.g. Room 101" value={newRoom.name} onChange={e => setNewRoom({ ...newRoom, name: e.target.value })} />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Type</label>
                                <select
                                    className="flex h-10 w-full rounded-md border border-slate-800 bg-slate-950 px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-slate-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-indigo-500 disabled:cursor-not-allowed disabled:opacity-50 text-slate-50"
                                    value={newRoom.type}
                                    onChange={e => setNewRoom({ ...newRoom, type: e.target.value })}
                                >
                                    <option value="Classroom">Classroom</option>
                                    <option value="Laboratory">Laboratory</option>
                                    <option value="Lecture Hall">Lecture Hall</option>
                                    <option value="Auditorium">Auditorium</option>
                                </select>
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Capacity</label>
                                <Input type="number" placeholder="e.g. 60" value={newRoom.capacity} onChange={e => setNewRoom({ ...newRoom, capacity: e.target.value })} />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Block & Floor</label>
                                <div className="flex gap-2">
                                    <Input placeholder="Block" value={newRoom.block} onChange={e => setNewRoom({ ...newRoom, block: e.target.value })} className="w-1/2" />
                                    <Input placeholder="Floor" value={newRoom.floor} onChange={e => setNewRoom({ ...newRoom, floor: e.target.value })} className="w-1/2" />
                                </div>
                            </div>
                            <Button onClick={handleAddRoom} disabled={isSaving} className="w-full bg-indigo-600 hover:bg-indigo-700 text-white h-10">
                                {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : "Save Room"}
                            </Button>
                        </div>
                    </CardContent>
                </Card>
            )}

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {isLoading ? (
                    <div className="lg:col-span-2 p-12 flex justify-center">
                        <Loader2 className="w-8 h-8 animate-spin text-indigo-500" />
                    </div>
                ) : rooms.length === 0 ? (
                    <div className="lg:col-span-2 p-8 text-center text-slate-500 border border-slate-800/60 bg-slate-900/40 rounded-xl">
                        No rooms available. Click &quot;Add Room&quot; to create one.
                    </div>
                ) : (
                    rooms.map((room) => (
                        <Card key={room.id} className="border-slate-800/60 bg-slate-900/40 hover:bg-slate-900/60 transition-colors">
                            <CardHeader className="flex flex-row items-start justify-between pb-2">
                                <div>
                                    <CardTitle className="text-lg">{room.name}</CardTitle>
                                    <div className="flex items-center gap-2 mt-1 text-sm text-slate-400">
                                        <MapPin className="w-3.5 h-3.5" /> Block {room.block}, Floor {room.floor}
                                    </div>
                                </div>
                                <span className={`px-2.5 py-1 rounded-full text-xs font-medium border ${room.status === 'Available' ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' :
                                    room.status === 'In Use' ? 'bg-amber-500/10 text-amber-400 border-amber-500/20' :
                                        'bg-red-500/10 text-red-400 border-red-500/20'
                                    }`}>
                                    {room.status}
                                </span>
                            </CardHeader>
                            <CardContent>
                                <div className="flex items-center gap-6 mt-4 pt-4 border-t border-slate-800/50">
                                    <div className="flex flex-col">
                                        <span className="text-xs text-slate-500">Type</span>
                                        <span className="text-sm font-medium text-slate-300">{room.type}</span>
                                    </div>
                                    <div className="flex flex-col">
                                        <span className="text-xs text-slate-500">Capacity</span>
                                        <span className="text-sm font-medium text-slate-300">{room.capacity} Seats</span>
                                    </div>
                                    <div className="flex flex-col flex-1">
                                        <span className="text-xs text-slate-500">Equipment</span>
                                        <div className="flex items-center gap-1 mt-0.5">
                                            <Monitor className="w-3.5 h-3.5 text-slate-400" />
                                            <span className="text-sm font-medium text-slate-300 truncate">{room.equipment.length > 0 ? room.equipment.join(", ") : "None"}</span>
                                        </div>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                    ))
                )}
            </div>
        </div>
    )
}
