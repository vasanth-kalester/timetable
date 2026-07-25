"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { CheckCircle, XCircle, Clock, Bell, Megaphone, Eye, Loader2 } from "lucide-react"

const mockApprovals = [
    { id: 1, title: "Faculty Leave — Dr. Priya", dept: "CSE", date: "24 Jul", priority: "High", by: "Prof. Priya Nair", status: "Pending" },
    { id: 2, title: "Room Booking — Seminar Hall", dept: "ECE", date: "25 Jul", priority: "Medium", by: "HOD Shankar", status: "Pending" },
    { id: 3, title: "Timetable Publication — S5", dept: "IT", date: "23 Jul", priority: "High", by: "Timetable Committee", status: "Review" },
]

const mockAnnouncements = [
    { id: 1, title: "Mid-Term Exam Schedule", content: "The schedule for the upcoming mid-term exams has been published.", date: "1 day ago", author: "Exam Cell" },
    { id: 2, title: "Faculty Meeting", content: "Mandatory meeting at 4 PM in the Seminar Hall.", date: "2 hours ago", author: "Principal" },
]

export default function WorkflowPage() {
    const [activeTab, setActiveTab] = useState<'approvals' | 'announcements'>('approvals')
    const [approvals, setApprovals] = useState(mockApprovals)
    const [processingId, setProcessingId] = useState<number | null>(null)

    const handleApproval = (id: number, status: 'approved' | 'rejected') => {
        setProcessingId(id)
        setTimeout(() => {
            setApprovals(approvals.filter(a => a.id !== id))
            setProcessingId(null)
        }, 1000)
    }

    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500 max-w-5xl mx-auto">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-50">Workflow & Communication</h1>
                <p className="text-slate-400 mt-2">Manage approvals, notifications, and campus-wide announcements.</p>
            </div>

            <div className="flex p-1 bg-slate-800/50 rounded-lg w-full max-w-md">
                <button
                    className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors flex items-center justify-center gap-2 ${activeTab === 'approvals' ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'}`}
                    onClick={() => setActiveTab('approvals')}
                >
                    <CheckCircle className="w-4 h-4" />
                    Approval Inbox
                </button>
                <button
                    className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors flex items-center justify-center gap-2 ${activeTab === 'announcements' ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'}`}
                    onClick={() => setActiveTab('announcements')}
                >
                    <Megaphone className="w-4 h-4" />
                    Announcements
                </button>
            </div>

            {activeTab === 'approvals' && (
                <div className="space-y-4">
                    {approvals.length === 0 ? (
                        <Card className="border-slate-800/60 bg-slate-900/40 py-12 text-center">
                            <CheckCircle className="w-12 h-12 text-emerald-500/50 mx-auto mb-4" />
                            <h3 className="text-lg font-medium text-slate-300">Inbox Zero!</h3>
                            <p className="text-slate-500 mt-1">You have no pending approvals.</p>
                        </Card>
                    ) : (
                        approvals.map((item) => (
                            <Card key={item.id} className="border-slate-800/60 bg-slate-900/40 hover:border-slate-700 transition-colors">
                                <CardContent className="p-5">
                                    <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                                        <div className="flex-1">
                                            <div className="flex items-center gap-2 mb-1">
                                                <span className={`px-2 py-0.5 text-xs font-bold rounded border ${item.priority === 'High' ? 'bg-red-500/10 text-red-400 border-red-500/20' : 'bg-amber-500/10 text-amber-400 border-amber-500/20'
                                                    }`}>
                                                    {item.priority}
                                                </span>
                                                <h3 className="font-bold text-slate-200">{item.title}</h3>
                                            </div>
                                            <div className="flex flex-wrap gap-3 text-xs text-slate-500 mt-2">
                                                <span className="flex items-center gap-1"><Clock className="w-3 h-3" /> {item.date}</span>
                                                <span className="flex items-center gap-1">By: {item.by} ({item.dept})</span>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <Button
                                                size="sm"
                                                className="bg-emerald-600 hover:bg-emerald-700 text-white"
                                                onClick={() => handleApproval(item.id, 'approved')}
                                                disabled={processingId === item.id}
                                            >
                                                {processingId === item.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle className="w-4 h-4 mr-2" />} Approve
                                            </Button>
                                            <Button
                                                size="sm"
                                                variant="outline"
                                                className="border-red-500/30 text-red-400 hover:bg-red-500/10"
                                                onClick={() => handleApproval(item.id, 'rejected')}
                                                disabled={processingId === item.id}
                                            >
                                                {processingId === item.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <XCircle className="w-4 h-4 mr-2" />} Reject
                                            </Button>
                                            <Button size="sm" variant="ghost" className="text-slate-400 hover:text-indigo-400">
                                                <Eye className="w-4 h-4" />
                                            </Button>
                                        </div>
                                    </div>
                                </CardContent>
                            </Card>
                        ))
                    )}
                </div>
            )}

            {activeTab === 'announcements' && (
                <div className="space-y-4">
                    <div className="flex justify-end mb-4">
                        <Button className="bg-indigo-600 hover:bg-indigo-700 text-white">
                            <Megaphone className="w-4 h-4 mr-2" /> New Announcement
                        </Button>
                    </div>
                    {mockAnnouncements.map((item) => (
                        <Card key={item.id} className="border-slate-800/60 bg-slate-900/40">
                            <CardContent className="p-5">
                                <div className="flex items-start gap-4">
                                    <div className="w-10 h-10 rounded-full bg-indigo-500/10 flex items-center justify-center flex-shrink-0 border border-indigo-500/20">
                                        <Bell className="w-5 h-5 text-indigo-400" />
                                    </div>
                                    <div>
                                        <h3 className="font-bold text-slate-200">{item.title}</h3>
                                        <p className="text-sm text-slate-400 mt-1">{item.content}</p>
                                        <div className="flex items-center gap-3 text-xs text-slate-500 mt-3">
                                            <span className="font-medium text-indigo-400/80">{item.author}</span>
                                            <span className="w-1 h-1 rounded-full bg-slate-700"></span>
                                            <span>{item.date}</span>
                                        </div>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}
        </div>
    )
}
