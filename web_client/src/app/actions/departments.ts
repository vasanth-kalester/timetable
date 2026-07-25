"use server"

import prisma from "@/lib/prisma"

export async function getDepartments(collegeId: string) {
    try {
        const departments = await prisma.department.findMany({
            where: { collegeId },
            orderBy: { name: 'asc' }
        })
        return { departments }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch departments" }
    }
}

export async function createDepartment(data: { name: string, code: string, collegeId: string }) {
    try {
        const department = await prisma.department.create({
            data
        })
        return { department }
    } catch (e: any) {
        return { error: e.message || "Failed to create department" }
    }
}

export async function updateDepartment(id: string, data: { name: string, code: string }) {
    try {
        const department = await prisma.department.update({
            where: { id },
            data
        })
        return { department }
    } catch (e: any) {
        return { error: e.message || "Failed to update department" }
    }
}

export async function deleteDepartment(id: string) {
    try {
        await prisma.department.delete({
            where: { id }
        })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to delete department" }
    }
}
