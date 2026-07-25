"use server"

import prisma from "@/lib/prisma"

export async function getProfile(userId: string) {
    try {
        const user = await prisma.user.findUnique({
            where: { id: userId },
            include: { profile: true }
        })

        if (!user) return { error: "User not found" }

        let college_id = ""
        let college_name = ""
        let college_code = ""

        // Step 1: try to find college via profile.collegeId
        if (user.profile?.collegeId) {
            const college = await prisma.college.findUnique({
                where: { id: user.profile.collegeId }
            })
            if (college) {
                college_id = college.id
                college_name = college.name
                college_code = college.code
            }
        }

        // Step 2: if still no college, fallback to first college in DB
        // This handles fresh setups where the principal hasn't been linked yet
        if (!college_name) {
            const college = await prisma.college.findFirst({
                orderBy: { createdAt: 'asc' }
            })
            if (college) {
                college_id = college.id
                college_name = college.name
                college_code = college.code

                // Automatically link this user's profile to the college if they are staff
                if (user.profile && ['principal', 'hod', 'faculty'].includes(user.role)) {
                    await prisma.profile.update({
                        where: { userId },
                        data: { collegeId: college.id }
                    })
                }
            }
        }

        return {
            profile: {
                first_name: user.profile?.firstName || "",
                last_name: user.profile?.lastName || "",
                role: user.role,
                email: user.email,
                college_id,
                college_name,
                college_code,
                department_id: user.profile?.departmentId || null
            }
        }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch profile" }
    }
}

export async function updateProfile(userId: string, data: { first_name: string, last_name: string }) {
    try {
        await prisma.profile.upsert({
            where: { userId },
            update: {
                firstName: data.first_name,
                lastName: data.last_name
            },
            create: {
                userId,
                firstName: data.first_name,
                lastName: data.last_name
            }
        })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to update profile" }
    }
}

export async function deleteAccount(userId: string) {
    try {
        await prisma.user.delete({ where: { id: userId } })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to delete account" }
    }
}
