"use server"

import prisma from "@/lib/prisma"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"

export async function getHodDashboardData() {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        const user = await prisma.user.findUnique({
            where: { id: (session.user as any).id },
            include: { profile: true }
        })

        if (!user || !user.profile?.departmentId) {
            return { error: "Department not found for this HOD" }
        }

        const departmentId = user.profile.departmentId

        // Fetch department stats
        const studentCount = await prisma.user.count({
            where: {
                role: "student",
                profile: { departmentId }
            }
        })

        const facultyCount = await prisma.faculty.count({
            where: { departmentId }
        })

        // Fetch active courses (sessions) for the department
        const activeCoursesCount = await prisma.session.count({
            where: { departmentId }
        })

        // Fetch pending leave requests for the department's faculty
        const pendingLeaves = await prisma.leave.findMany({
            where: {
                status: "Pending",
                faculty: { departmentId }
            },
            include: {
                faculty: true
            },
            take: 5
        })

        const mappedPendingApprovals = pendingLeaves.map(leave => {
            const diffTime = Math.abs(leave.endDate.getTime() - leave.startDate.getTime())
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1
            return {
                id: leave.id,
                title: "Leave Request",
                subtitle: `${leave.faculty.name} • ${diffDays} Day${diffDays > 1 ? 's' : ''}`,
                type: "leave"
            }
        })

        // Fetch today's schedule (mocked for now since we don't have a direct way to query "today" easily without complex date math on TimetableEntry)
        // Let's just fetch some sessions for the department
        const sessions = await prisma.session.findMany({
            where: { departmentId },
            take: 2,
            include: {
                timetableEntries: true
            }
        })

        const mappedSchedule = sessions.map((session, index) => {
            const times = ["09:00 AM", "11:00 AM", "01:30 PM", "03:00 PM"]
            return {
                id: session.id,
                title: session.sessionCode || "Department Session",
                subtitle: `${session.sessionType} • Room ${session.homeClassroomId || "TBD"}`,
                time: times[index % times.length],
                duration: `${session.duration} Hour${session.duration > 1 ? 's' : ''}`
            }
        })

        return {
            stats: {
                students: studentCount,
                faculty: facultyCount,
                activeCourses: activeCoursesCount,
                avgAttendance: Math.floor(Math.random() * 15) + 80 // Mock attendance for now
            },
            schedule: mappedSchedule,
            pendingApprovals: mappedPendingApprovals
        }

    } catch (e: any) {
        return { error: e.message || "Failed to fetch HOD dashboard data" }
    }
}
