"use server"

import prisma from "@/lib/prisma"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"

export async function getFacultyDashboardData() {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        const user = await prisma.user.findUnique({
            where: { id: (session.user as any).id },
            include: { profile: true }
        })

        if (!user) return { error: "User not found" }

        // Find the faculty record associated with this user's email
        const faculty = await prisma.faculty.findUnique({
            where: { email: user.email }
        })

        if (!faculty) {
            return { error: "Faculty record not found" }
        }

        // Fetch today's classes (sessions) for this faculty
        const sessions = await prisma.session.findMany({
            where: { facultyId: faculty.id },
            take: 3, // Just take a few for now
            include: {
                timetableEntries: true
            }
        })

        const mappedClasses = sessions.map((session, index) => {
            const times = ["10:00 AM", "01:00 PM", "03:00 PM"]
            return {
                id: session.id,
                title: session.sessionCode || "Class Session",
                subtitle: `${session.sessionType} • Room ${session.homeClassroomId || "TBD"}`,
                time: times[index % times.length],
                duration: `${session.duration} Hour${session.duration > 1 ? 's' : ''}`
            }
        })

        // Fetch recent announcements (mocked for now as there's no Notification/Announcement model linked to faculty directly in a simple way)
        const announcements = await prisma.notification.findMany({
            where: { userId: user.id },
            orderBy: { createdAt: 'desc' },
            take: 2
        })

        const mappedAnnouncements = announcements.length > 0 ? announcements.map(a => ({
            id: a.id,
            title: a.title,
            description: a.message,
            time: "Recently"
        })) : [
            {
                id: "1",
                title: "Welcome to EduFlow",
                description: "Please update your scheduling profile and availability.",
                time: "System"
            }
        ]

        // Calculate stats
        const classesToday = sessions.length
        const weeklyHours = sessions.reduce((acc, curr) => acc + curr.duration, 0) * 3 // Mock multiplier for weekly

        // Pending tasks could be pending leave requests or incomplete profile
        const pendingLeaves = await prisma.leave.count({
            where: { facultyId: faculty.id, status: "Pending" }
        })
        const pendingTasks = pendingLeaves + (faculty.schedulingReadiness === "Draft" ? 1 : 0)

        return {
            stats: {
                classesToday,
                weeklyHours,
                pendingTasks,
                attendanceMarked: 100 // Mock for now
            },
            classes: mappedClasses,
            announcements: mappedAnnouncements
        }

    } catch (e: any) {
        return { error: e.message || "Failed to fetch faculty dashboard data" }
    }
}
