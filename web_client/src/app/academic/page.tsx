"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { Search, Plus, BookOpen, GraduationCap, Users } from "lucide-react"

const subjects: { code: string, name: string, credits: number, faculty: string, students: number }[] = []

export default function AcademicPage() {
    return (
        <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-50">Academic Management</h1>
                    <p className="text-slate-400 mt-2">Manage subjects, curriculum, and faculty assignments.</p>
                </div>
                <Button className="shadow-lg shadow-indigo-600/20">
                    <Plus className="w-4 h-4 mr-2" /> Add Subject
                </Button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardContent className="p-6 flex items-center gap-4">
                        <div className="p-3 rounded-xl bg-blue-500/10">
                            <BookOpen className="w-6 h-6 text-blue-500" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-400">Total Subjects</p>
                            <p className="text-2xl font-bold text-slate-50">0</p>
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardContent className="p-6 flex items-center gap-4">
                        <div className="p-3 rounded-xl bg-indigo-500/10">
                            <GraduationCap className="w-6 h-6 text-indigo-500" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-400">Active Faculty</p>
                            <p className="text-2xl font-bold text-slate-50">0</p>
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-slate-800/60 bg-slate-900/40">
                    <CardContent className="p-6 flex items-center gap-4">
                        <div className="p-3 rounded-xl bg-emerald-500/10">
                            <Users className="w-6 h-6 text-emerald-500" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-400">Enrolled Students</p>
                            <p className="text-2xl font-bold text-slate-50">0</p>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <Card className="border-slate-800/60 bg-slate-900/40">
                <CardHeader className="flex flex-row items-center justify-between border-b border-slate-800 pb-4">
                    <CardTitle>Subject Directory</CardTitle>
                    <div className="relative w-64">
                        <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-500" />
                        <Input placeholder="Search subjects..." className="pl-9 h-9 bg-slate-800/50" />
                    </div>
                </CardHeader>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm text-left">
                            <thead className="text-xs text-slate-400 uppercase bg-slate-900/50 border-b border-slate-800">
                                <tr>
                                    <th className="px-6 py-4 font-medium">Code</th>
                                    <th className="px-6 py-4 font-medium">Subject Name</th>
                                    <th className="px-6 py-4 font-medium">Credits</th>
                                    <th className="px-6 py-4 font-medium">Primary Faculty</th>
                                    <th className="px-6 py-4 font-medium">Students</th>
                                    <th className="px-6 py-4 font-medium text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-800/50">
                                {subjects.length === 0 ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-8 text-center text-slate-500">
                                            No subjects found.
                                        </td>
                                    </tr>
                                ) : (
                                    subjects.map((subject) => (
                                        <tr key={subject.code} className="hover:bg-slate-800/30 transition-colors">
                                            <td className="px-6 py-4 font-medium text-indigo-400">{subject.code}</td>
                                            <td className="px-6 py-4 text-slate-200">{subject.name}</td>
                                            <td className="px-6 py-4 text-slate-300">{subject.credits}</td>
                                            <td className="px-6 py-4 text-slate-300">{subject.faculty}</td>
                                            <td className="px-6 py-4 text-slate-300">{subject.students}</td>
                                            <td className="px-6 py-4 text-right">
                                                <Button variant="ghost" size="sm" className="h-8 text-xs">Edit</Button>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
