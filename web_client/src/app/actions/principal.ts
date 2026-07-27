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

        // Departments list with real stats
        const departments = college
            ? await prisma.department.findMany({ where: { collegeId: college.id } })
            : []

        const deptStats = await Promise.all(departments.map(async (d) => {
            const facultyCount = await prisma.faculty.count({ where: { departmentId: d.id } })
            const studentCount = await prisma.user.count({
                where: {
                    role: "student",
                    profile: { departmentId: d.id }
                }
            })
            const pendingLeaves = await prisma.leave.count({
                where: {
                    status: "Pending",
                    faculty: { departmentId: d.id }
                }
            })

            return {
                id: d.id,
                name: d.name,
                code: d.code,
                attendance: Math.floor(Math.random() * 15) + 80, // Mock attendance for now
                faculty: facultyCount,
                students: studentCount,
                pendingLeaves: pendingLeaves,
                conflicts: 0,
                examPerf: Math.floor(Math.random() * 20) + 75, // Mock exam perf
            }
        }))

        // Faculty list
        const faculty = await prisma.faculty.findMany({
            take: 10,
            orderBy: { createdAt: 'desc' },
            include: {
                leaves: {
                    where: { status: "Approved" }
                }
            }
        })

        const mappedFaculty = faculty.map(f => {
            const dept = departments.find(d => d.id === f.departmentId)
            const isOnLeave = f.leaves.some(l => new Date() >= l.startDate && new Date() <= l.endDate)
            return {
                name: f.name,
                dept: dept?.code || "Unknown",
                classes: Math.floor(Math.random() * 3) + 1, // Mock classes today
                workload: "Normal",
                status: isOnLeave ? "On Leave" : "Present"
            }
        })

        // Infrastructure stats
        const totalClassrooms = await prisma.classroom.count()
        const totalLabs = await prisma.laboratory.count()
        const totalRooms = totalClassrooms + totalLabs

        const healthScore = {
            overall: totalRooms > 0 && departments.length > 0 ? 85 : 40,
            label: totalRooms > 0 && departments.length > 0 ? "Good" : "Needs Setup",
            breakdown: [
                { name: "Attendance", score: 85 },
                { name: "Infrastructure", score: totalRooms > 0 ? 100 : 0 },
                { name: "Scheduling", score: 75 },
                { name: "Exams", score: 90 },
                { name: "Operations", score: 80 },
            ]
        }

        return {
            college: college ? { name: college.name, code: college.code } : null,
            stats: {
                totalStudents: studentCount,
                totalFaculty: facultyCount + hodCount,
                totalDepartments: deptCount,
                totalUsers,
            },
            departments: deptStats,
            todayOverview: [
                { text: `${totalRooms} rooms available for scheduling`, type: "info", color: "text-blue-400", icon: "Building2" }
            ],
            timeline: [],
            pendingApprovals: [],
            faculty: mappedFaculty,
            healthScore,
            recentActivity: [],
        }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch principal dashboard data" }
    }
}
