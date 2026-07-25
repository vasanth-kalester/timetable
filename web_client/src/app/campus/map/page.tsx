"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Map, Users, Building2, AlertTriangle, CheckCircle2 } from "lucide-react"

// Mock grid data for the campus map (10x10 grid)
const generateGrid = () => {
    const grid = []
    for (let i = 0; i < 10; i++) {
        const row = []
        for (let j = 0; j < 10; j++) {
            // Randomly assign room types and statuses for demonstration
            const isRoom = Math.random() > 0.3
            const status = isRoom ? (Math.random() > 0.7 ? 'occupied' : Math.random() > 0.9 ? 'maintenance' : 'available') : 'empty'
            row.push({ id: `${i}-${j}`, x: i, y: j, isRoom, status, name: isRoom ? `Room ${i}${j}` : '' })
        }
        grid.push(row)
    }
    return grid
}

export default function CampusMapPage() {
    const [grid] = useState(generateGrid())
    const [selectedRoom, setSelectedRoom] = useState<any>(null)

    const getStatusColor = (status: string) => {
        switch (status) {
            case 'occupied': return 'bg-amber-500 hover:bg-amber-400'
            case 'available': return 'bg-emerald-500 hover:bg-emerald-400'
            case 'maintenance': return 'bg-red-500 hover:bg-red-400'
            default: return 'bg-slate-800/50'
        }
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-50">Campus Digital Twin</h1>
                <p className="text-slate-400 mt-2">Interactive 2D map of campus infrastructure and real-time occupancy.</p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Map Area */}
                <div className="lg:col-span-2">
                    <Card className="border-slate-800/60 bg-slate-900/40 h-full">
                        <CardHeader className="flex flex-row items-center justify-between">
                            <CardTitle className="flex items-center gap-2"><Map className="w-5 h-5 text-indigo-400" /> Main Block - Floor 1</CardTitle>
                            <div className="flex gap-4 text-xs font-medium">
                                <span className="flex items-center gap-1 text-emerald-400"><div className="w-3 h-3 rounded-full bg-emerald-500"></div> Available</span>
                                <span className="flex items-center gap-1 text-amber-400"><div className="w-3 h-3 rounded-full bg-amber-500"></div> Occupied</span>
                                <span className="flex items-center gap-1 text-red-400"><div className="w-3 h-3 rounded-full bg-red-500"></div> Maintenance</span>
                            </div>
                        </CardHeader>
                        <CardContent>
                            <div className="aspect-square w-full max-w-2xl mx-auto border border-slate-800 rounded-xl overflow-hidden bg-slate-950 p-4">
                                <div className="grid grid-cols-10 grid-rows-10 gap-2 h-full w-full">
                                    {grid.map((row, i) => (
                                        row.map((cell, j) => (
                                            <div
                                                key={cell.id}
                                                onClick={() => cell.isRoom && setSelectedRoom(cell)}
                                                className={`rounded-md transition-all duration-200 ${cell.isRoom ? 'cursor-pointer shadow-sm' : ''} ${getStatusColor(cell.status)} ${selectedRoom?.id === cell.id ? 'ring-2 ring-white scale-110 z-10' : ''}`}
                                                title={cell.name}
                                            />
                                        ))
                                    ))}
                                </div>
                            </div>
                        </CardContent>
                    </Card>
                </div>

                {/* Details Panel */}
                <div className="lg:col-span-1">
                    <Card className="border-slate-800/60 bg-slate-900/40 h-full">
                        <CardHeader>
                            <CardTitle>Room Details</CardTitle>
                        </CardHeader>
                        <CardContent>
                            {selectedRoom ? (
                                <div className="space-y-6">
                                    <div className="text-center pb-6 border-b border-slate-800">
                                        <div className={`w-16 h-16 mx-auto rounded-2xl flex items-center justify-center mb-4 ${selectedRoom.status === 'occupied' ? 'bg-amber-500/20 text-amber-500' :
                                                selectedRoom.status === 'available' ? 'bg-emerald-500/20 text-emerald-500' :
                                                    'bg-red-500/20 text-red-500'
                                            }`}>
                                            <Building2 className="w-8 h-8" />
                                        </div>
                                        <h2 className="text-2xl font-bold text-slate-50">{selectedRoom.name}</h2>
                                        <p className="text-slate-400 capitalize">{selectedRoom.status}</p>
                                    </div>

                                    {selectedRoom.status === 'occupied' && (
                                        <div className="space-y-4">
                                            <div className="flex items-center gap-3 p-3 rounded-lg bg-slate-800/50">
                                                <Users className="w-5 h-5 text-indigo-400" />
                                                <div>
                                                    <p className="text-sm font-medium text-slate-200">Current Class</p>
                                                    <p className="text-xs text-slate-400">CS301 - Data Structures</p>
                                                </div>
                                            </div>
                                            <div className="flex items-center gap-3 p-3 rounded-lg bg-slate-800/50">
                                                <CheckCircle2 className="w-5 h-5 text-emerald-400" />
                                                <div>
                                                    <p className="text-sm font-medium text-slate-200">Faculty</p>
                                                    <p className="text-xs text-slate-400">Dr. Smith</p>
                                                </div>
                                            </div>
                                        </div>
                                    )}

                                    {selectedRoom.status === 'maintenance' && (
                                        <div className="flex items-start gap-3 p-4 rounded-lg bg-red-500/10 border border-red-500/20">
                                            <AlertTriangle className="w-5 h-5 text-red-400 mt-0.5" />
                                            <div>
                                                <p className="text-sm font-bold text-red-400">Maintenance Required</p>
                                                <p className="text-xs text-red-400/80 mt-1">Projector bulb replacement pending. Scheduled for today at 4:00 PM.</p>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            ) : (
                                <div className="h-64 flex flex-col items-center justify-center text-center text-slate-500">
                                    <Map className="w-12 h-12 mb-4 opacity-50" />
                                    <p>Select a room on the map to view its details and current status.</p>
                                </div>
                            )}
                        </CardContent>
                    </Card>
                </div>
            </div>
        </div>
    )
}
