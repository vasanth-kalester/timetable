"use server"

import prisma from "@/lib/prisma"

export async function getStaff(collegeId: string, status: string, targetRole: string | string[], departmentId?: string) {
    try {
        const whereClause: any = {
            role: Array.isArray(targetRole) ? { in: targetRole } : targetRole,
            approvalStatus: status,
            profile: {
                collegeId: collegeId
            }
        }

        if (departmentId) {
            whereClause.profile.departmentId = departmentId
        }

        const users = await prisma.user.findMany({
            where: whereClause,
            include: {
                profile: true
            },
            orderBy: { createdAt: 'desc' }
        })

        const staff = users.map(u => ({
            id: u.id,
            first_name: u.profile?.firstName || "",
            last_name: u.profile?.lastName || "",
            email: u.email,
            role: u.role,
            approval_status: u.approvalStatus,
            created_at: u.createdAt.toISOString()
        }))

        return { staff }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch staff" }
    }
}

export async function updateStaffApproval(id: string, status: string) {
    try {
        await prisma.user.update({
            where: { id },
            data: { approvalStatus: status }
        })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to update staff" }
    }
}
