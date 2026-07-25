"use server"

import prisma from "@/lib/prisma"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"

export async function getSemesterReplayData(academicYear: string, semester: string) {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        // In a real app, this would query historical snapshots from the database based on the year and semester.
        // For demonstration, we return mock data that simulates the reconstructed semester.

        return {
            academicYear,
            semester,
            reconstruction: {
                publishedTimetableId: `tt_${academicYear.replace('-', '_')}_${semester.toLowerCase().replace(' ', '_')}_final`,
                averageFacultyWorkload: 80.5,
                averageRoomUtilization: 78.0,
                majorRevisions: 3,
                totalSubstitutions: 145,
                operationalEvents: [
                    { date: "2025-09-15", event: "Mid-Term Exams Started", impact: "Timetable Frozen" },
                    { date: "2025-10-02", event: "National Holiday", impact: "Classes Cancelled" },
                    { date: "2025-11-20", event: "Annual Sports Day", impact: "Afternoon Classes Cancelled" }
                ]
            }
        }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch replay data" }
    }
}
