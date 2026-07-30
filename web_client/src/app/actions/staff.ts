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

        // Fetch corresponding faculty records to get cross-department info
        const emails = users.map(u => u.email)
        const faculties = await prisma.faculty.findMany({
            where: { email: { in: emails } },
            include: { crossDepartments: true }
        })

        const facultyMap = new Map()
        faculties.forEach(f => facultyMap.set(f.email, f))

        const staff = users.map(u => {
            const faculty = facultyMap.get(u.email)
            return {
                id: u.id,
                first_name: u.profile?.firstName || "",
                last_name: u.profile?.lastName || "",
                email: u.email,
                role: u.role,
                approval_status: u.approvalStatus,
                created_at: u.createdAt.toISOString(),
                faculty_id: faculty?.id || null,
                cross_departments: faculty?.crossDepartments?.map((cd: any) => cd.departmentId) || []
            }
        })

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

export async function assignCrossDepartment(facultyId: string, departmentId: string) {
    try {
        await prisma.crossDepartmentTeaching.create({
            data: {
                facultyId,
                departmentId
            }
        })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to assign cross-department teaching" }
    }
}

export async function removeCrossDepartment(facultyId: string, departmentId: string) {
    try {
        await prisma.crossDepartmentTeaching.deleteMany({
            where: {
                facultyId,
                departmentId
            }
        })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to remove cross-department teaching" }
    }
}
