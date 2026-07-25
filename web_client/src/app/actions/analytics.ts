"use server"

import prisma from "@/lib/prisma"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"

export async function getAnalyticsData() {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        // Fetch total counts
        const totalStudents = await prisma.user.count({ where: { role: "student" } })
        const totalFaculty = await prisma.user.count({ where: { role: "faculty" } })
        const totalDepts = await prisma.department.count()
        const totalRooms = await prisma.room.count()

        // Mock historical attendance data for the chart
        const attendanceTrends = [
            { name: "Mon", attendance: 92 },
            { name: "Tue", attendance: 94 },
            { name: "Wed", attendance: 91 },
            { name: "Thu", attendance: 95 },
            { name: "Fri", attendance: 88 },
        ]

        // Mock resource allocation data for the pie chart
        const resourceAllocation = [
            { name: "Classrooms", value: 120 },
            { name: "Laboratories", value: 45 },
            { name: "Seminar Halls", value: 10 },
            { name: "Offices", value: 25 },
        ]

        return {
            stats: {
                totalStudents,
                totalFaculty,
                totalDepts,
                totalRooms,
            },
            attendanceTrends,
            resourceAllocation
        }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch analytics data" }
    }
}
