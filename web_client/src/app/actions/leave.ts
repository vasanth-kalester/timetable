"use server"

import prisma from "@/lib/prisma"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"

export async function requestLeave(data: { leaveType: string, startDate: Date, endDate: Date, reason: string }) {
    try {
        const session = await getServerSession(authOptions)
        if (!session || !session.user?.email) return { error: "Unauthorized" }

        const faculty = await prisma.faculty.findUnique({
            where: { email: session.user.email }
        })

        if (!faculty) return { error: "Faculty profile not found" }

        const leave = await prisma.leave.create({
            data: {
                facultyId: faculty.id,
                leaveType: data.leaveType,
                startDate: data.startDate,
                endDate: data.endDate,
                reason: data.reason,
                status: "Pending"
            }
        })

        return { success: true, leave }
    } catch (e: any) {
        return { error: e.message || "Failed to request leave" }
    }
}

export async function getFacultyLeaves() {
    try {
        const session = await getServerSession(authOptions)
        if (!session || !session.user?.email) return { error: "Unauthorized" }

        const faculty = await prisma.faculty.findUnique({
            where: { email: session.user.email }
        })

        if (!faculty) return { error: "Faculty profile not found" }

        const leaves = await prisma.leave.findMany({
            where: { facultyId: faculty.id },
            orderBy: { createdAt: 'desc' }
        })

        return { leaves }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch leaves" }
    }
}

export async function getPendingLeaves() {
    try {
        const session = await getServerSession(authOptions)
        if (!session || !session.user?.email) return { error: "Unauthorized" }

        // HODs can see leaves for their department
        const hod = await prisma.faculty.findUnique({
            where: { email: session.user.email }
        })

        if (!hod) return { error: "HOD profile not found" }

        const leaves = await prisma.leave.findMany({
            where: {
                status: "Pending",
                faculty: {
                    departmentId: hod.departmentId
                }
            },
            include: {
                faculty: true
            },
            orderBy: { createdAt: 'asc' }
        })

        return { leaves }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch pending leaves" }
    }
}

export async function approveLeave(leaveId: string, status: "Approved" | "Rejected", substituteAllocations?: any[]) {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        const leave = await prisma.leave.update({
            where: { id: leaveId },
            data: { status }
        })

        if (status === "Approved" && substituteAllocations && substituteAllocations.length > 0) {
            // Create substitute allocations
            await prisma.substituteAllocation.createMany({
                data: substituteAllocations.map(alloc => ({
                    leaveId: leaveId,
                    originalStaffId: leave.facultyId,
                    substituteId: alloc.substituteId,
                    date: new Date(alloc.date),
                    period: alloc.period,
                    classId: alloc.classId,
                    subjectId: alloc.subjectId,
                    status: "Assigned"
                }))
            })
        }

        return { success: true, leave }
    } catch (e: any) {
        return { error: e.message || "Failed to update leave status" }
    }
}

export async function getSubstituteAssignments() {
    try {
        const session = await getServerSession(authOptions)
        if (!session || !session.user?.email) return { error: "Unauthorized" }

        const faculty = await prisma.faculty.findUnique({
            where: { email: session.user.email }
        })

        if (!faculty) return { error: "Faculty profile not found" }

        const assignments = await prisma.substituteAllocation.findMany({
            where: { substituteId: faculty.id },
            include: {
                originalStaff: true,
                leave: true
            },
            orderBy: { date: 'asc' }
        })

        return { assignments }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch substitute assignments" }
    }
}
