"use server"

import prisma from "@/lib/prisma"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"

export async function getPrincipalDashboardData() {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        const user = await prisma.user.findUnique({
            where: { id: (session.user as any).id },
            include: { profile: true }
        })

        if (!user) return { error: "User not found" }

        // Get the college this principal is linked to
        let college: any = null
        if (user.profile?.collegeId) {
            college = await prisma.college.findUnique({ where: { id: user.profile.collegeId } })
        } else {
            // Fallback: grab the first college (for fresh setups)
            college = await prisma.college.findFirst({ orderBy: { createdAt: 'asc' } })
        }

        // Dept count
        const deptCount = college
            ? await prisma.department.count({ where: { collegeId: college.id } })
            : 0

        // User counts
        const totalUsers = await prisma.user.count()
        const principalCount = await prisma.user.count({ where: { role: "principal" } })
        const facultyCount = await prisma.user.count({ where: { role: "faculty" } })
        const hodCount = await prisma.user.count({ where: { role: "hod" } })
        const studentCount = await prisma.user.count({ where: { role: "student" } })

        // Departments list
        const departments = college
            ? await prisma.department.findMany({ where: { collegeId: college.id } })
            : []

        return {
            college: college ? { name: college.name, code: college.code } : null,
            stats: {
                totalStudents: studentCount,
                totalFaculty: facultyCount + hodCount,
                totalDepartments: deptCount,
                totalUsers,
            },
            departments: departments.map((d: any) => ({
                id: d.id,
                name: d.name,
                code: d.code,
                // These would come from a richer schema in a real app
                // For now show real dept names with zeroed counts
                attendance: 0,
                faculty: 0,
                students: 0,
                pendingLeaves: 0,
                conflicts: 0,
                examPerf: 0,
            })),
        }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch principal dashboard data" }
    }
}
