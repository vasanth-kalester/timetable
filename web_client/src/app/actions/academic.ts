"use server"

import prisma from "@/lib/prisma"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"

export async function getSubjects() {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        const subjects = await prisma.subject.findMany({
            orderBy: { createdAt: 'desc' }
        })

        // Fetch faculty names for the subjects
        const facultyIds = subjects.map(s => s.staffId).filter(Boolean) as string[]
        const faculty = await prisma.faculty.findMany({
            where: { id: { in: facultyIds } }
        })
        const facultyMap = new Map(faculty.map(f => [f.id, f.name]))

        const mappedSubjects = subjects.map(s => ({
            id: s.id,
            code: s.code,
            name: s.name,
            credits: (s as any).hoursPerWeek || 3, // Using hoursPerWeek as credits for display
            hoursPerWeek: (s as any).hoursPerWeek || 3,
            faculty: s.staffId ? facultyMap.get(s.staffId) || "Unknown" : "Unassigned",
            students: 0 // Default since we don't have direct mapping in legacy schema
        }))

        return { subjects: mappedSubjects }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch subjects" }
    }
}

export async function addSubject(data: { code: string, name: string, hoursPerWeek: number }) {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        // Create a dummy class if needed since classId is required in legacy Subject model
        let defaultClass = await prisma.class.findFirst()
        if (!defaultClass) {
            let dept = await prisma.department.findFirst()
            if (!dept) {
                // Create a fallback department if none exists
                dept = await prisma.department.create({
                    data: {
                        name: "General Department",
                        code: "GEN"
                    }
                })
            }

            defaultClass = await prisma.class.create({
                data: {
                    name: "General Class",
                    departmentId: dept.id
                }
            })
        }

        const subject = await prisma.subject.create({
            data: {
                code: data.code,
                name: data.name,
                hoursPerWeek: data.hoursPerWeek,
                classId: defaultClass.id
            } as any
        })

        return { success: true, subject }
    } catch (e: any) {
        return { error: e.message || "Failed to add subject" }
    }
}

export async function editSubject(id: string, data: { code: string, name: string, hoursPerWeek: number }) {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        const subject = await prisma.subject.update({
            where: { id },
            data: {
                code: data.code,
                name: data.name,
                hoursPerWeek: data.hoursPerWeek,
            } as any
        })

        return { success: true, subject }
    } catch (e: any) {
        return { error: e.message || "Failed to edit subject" }
    }
}

export async function deleteSubject(id: string) {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        await prisma.subject.delete({
            where: { id }
        })

        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to delete subject" }
    }
}
