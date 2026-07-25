"use server"

import prisma from "@/lib/prisma"
import bcrypt from "bcryptjs"

export async function registerPrincipal(data: any) {
    const { firstName, lastName, email, password, collegeName, collegeAddress } = data

    try {
        const existingUser = await prisma.user.findUnique({ where: { email } })
        if (existingUser) {
            return { error: "Email already in use" }
        }

        const passwordHash = await bcrypt.hash(password, 10)
        const newCode = Math.floor(1000 + Math.random() * 9000).toString()

        const college = await prisma.college.create({
            data: {
                name: collegeName,
                address: collegeAddress,
                code: newCode,
            }
        })

        const user = await prisma.user.create({
            data: {
                email,
                passwordHash,
                role: "principal",
                profile: {
                    create: {
                        firstName,
                        lastName,
                    }
                }
            }
        })

        return { success: true, code: newCode }
    } catch (e: any) {
        return { error: e.message || "Failed to register" }
    }
}

export async function findCollege(code: string) {
    try {
        const college = await prisma.college.findUnique({
            where: { code }
        })
        if (!college) return { error: "College not found" }

        const departments = await prisma.department.findMany({
            where: { collegeId: college.id }
        })

        return { college, departments }
    } catch (e: any) {
        return { error: e.message || "Failed to find college" }
    }
}

export async function registerStaff(data: any) {
    const { firstName, lastName, email, password, role, collegeId, departmentId } = data

    try {
        const existingUser = await prisma.user.findUnique({ where: { email } })
        if (existingUser) {
            return { error: "Email already in use" }
        }

        const passwordHash = await bcrypt.hash(password, 10)

        const user = await prisma.user.create({
            data: {
                email,
                passwordHash,
                role,
                profile: {
                    create: {
                        firstName,
                        lastName,
                        collegeId,
                        departmentId
                    }
                }
            }
        })

        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to register" }
    }
}
