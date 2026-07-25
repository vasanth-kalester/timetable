"use server"

import prisma from "@/lib/prisma"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"

export async function getAdminDashboardStats() {
    try {
        const session = await getServerSession(authOptions)
        if (!session || (session.user as any).role !== 'admin') {
            return { error: "Unauthorized" }
        }

        const totalInstitutions = await prisma.college.count()
        const activeUsers = await prisma.user.count()

        // Fetch recent institutions
        const recentInstitutions = await prisma.college.findMany({
            take: 5,
            orderBy: { createdAt: 'desc' }
        })

        const institutionsWithStats = await Promise.all(recentInstitutions.map(async (college: any) => {
            const departmentsCount = await prisma.department.count({
                where: { collegeId: college.id }
            })

            return {
                id: college.id,
                name: college.name,
                code: college.code,
                status: "Active",
                principal: "Pending", // Would fetch actual principal if linked
                students: 0, // Real data would come from User table linked to college
                faculty: 0,
                departments: departmentsCount,
                storage: "0 GB",
                plan: "Free"
            }
        }))

        return {
            stats: {
                totalInstitutions,
                activeUsers,
                onlineUsers: Math.floor(activeUsers * 0.1), // Mocking online users as 10% of active
                systemUptime: "99.99%",
                apiRequests: "0",
                storageUsed: "0 GB"
            },
            institutions: institutionsWithStats
        }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch dashboard stats" }
    }
}

export async function getInstitutions() {
    try {
        const session = await getServerSession(authOptions)
        if (!session || (session.user as any).role !== 'admin') {
            return { error: "Unauthorized" }
        }

        const colleges = await prisma.college.findMany({
            orderBy: { createdAt: 'desc' }
        })

        const institutionsWithStats = await Promise.all(colleges.map(async (college: any) => {
            const departmentsCount = await prisma.department.count({
                where: { collegeId: college.id }
            })

            return {
                id: college.id,
                name: college.name,
                code: college.code,
                status: "Active",
                principal: "Pending",
                students: 0,
                faculty: 0,
                departments: departmentsCount,
                storage: "0 GB",
                plan: "Free"
            }
        }))

        return { institutions: institutionsWithStats }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch institutions" }
    }
}

export async function getInstitutionDetails(collegeId: string) {
    try {
        const session = await getServerSession(authOptions)
        if (!session || (session.user as any).role !== 'admin') {
            return { error: "Unauthorized" }
        }

        const college = await prisma.college.findUnique({
            where: { id: collegeId }
        })

        if (!college) return { error: "College not found" }

        const users = await prisma.user.findMany({
            where: {
                profile: {
                    collegeId: collegeId
                }
            },
            include: {
                profile: true
            },
            orderBy: { role: 'asc' }
        })

        const departments = await prisma.department.findMany({
            where: { collegeId: collegeId }
        })

        // Format users
        const formattedUsers = users.map(u => {
            const dept = departments.find((d: any) => d.id === u.profile?.departmentId)
            return {
                id: u.id,
                name: `${u.profile?.firstName || ''} ${u.profile?.lastName || ''}`.trim(),
                email: u.email,
                role: u.role,
                status: u.approvalStatus,
                department: dept ? dept.name : (u.profile?.departmentId || 'N/A'),
                joinedAt: u.createdAt.toISOString()
            }
        })

        return { college, users: formattedUsers }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch institution details" }
    }
}

export async function removeUserFromInstitution(userId: string) {
    try {
        const session = await getServerSession(authOptions)
        if (!session || (session.user as any).role !== 'admin') {
            return { error: "Unauthorized" }
        }

        // For now, we'll just delete the user completely. 
        // In a real app, you might just unlink them by setting collegeId to null.
        await prisma.user.delete({
            where: { id: userId }
        })

        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to remove user" }
    }
}
