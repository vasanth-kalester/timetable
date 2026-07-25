"use server"

import prisma from "@/lib/prisma"

// --- Subjects ---
export async function getSubjects(departmentId: string) {
    try {
        const subjects = await prisma.subject.findMany({
            where: { departmentId },
            orderBy: { name: 'asc' }
        })
        return { subjects }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch subjects" }
    }
}

export async function createSubject(data: { name: string, code: string, departmentId: string }) {
    try {
        const subject = await prisma.subject.create({ data })
        return { subject }
    } catch (e: any) {
        return { error: e.message || "Failed to create subject" }
    }
}

export async function deleteSubject(id: string) {
    try {
        await prisma.subject.delete({ where: { id } })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to delete subject" }
    }
}

// --- Classes ---
export async function getClasses(departmentId: string) {
    try {
        const classes = await prisma.class.findMany({
            where: { departmentId },
            orderBy: { name: 'asc' }
        })
        return { classes }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch classes" }
    }
}

export async function createClass(data: { name: string, departmentId: string }) {
    try {
        const newClass = await prisma.class.create({ data })
        return { class: newClass }
    } catch (e: any) {
        return { error: e.message || "Failed to create class" }
    }
}

export async function deleteClass(id: string) {
    try {
        await prisma.class.delete({ where: { id } })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to delete class" }
    }
}

// --- Rooms ---
export async function getRooms(collegeId: string) {
    try {
        const rooms = await prisma.room.findMany({
            where: { collegeId },
            orderBy: { name: 'asc' }
        })
        return { rooms }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch rooms" }
    }
}

export async function createRoom(data: { name: string, collegeId: string }) {
    try {
        const room = await prisma.room.create({ data })
        return { room }
    } catch (e: any) {
        return { error: e.message || "Failed to create room" }
    }
}

export async function deleteRoom(id: string) {
    try {
        await prisma.room.delete({ where: { id } })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to delete room" }
    }
}

// --- Timetable Slots ---
export async function getTimetableSlots(departmentId: string) {
    try {
        // Fetch slots for classes in this department
        const classes = await prisma.class.findMany({ where: { departmentId } })
        const classIds = classes.map(c => c.id)

        const slots = await prisma.timetableSlot.findMany({
            where: { classId: { in: classIds } }
        })
        return { slots }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch timetable slots" }
    }
}

export async function createTimetableSlot(data: { day: string, time: string, subjectId: string, staffId: string, classId: string, roomId: string }) {
    try {
        // Basic conflict checking
        const existingStaffSlot = await prisma.timetableSlot.findFirst({
            where: { day: data.day, time: data.time, staffId: data.staffId }
        })
        if (existingStaffSlot) return { error: "Staff is already booked at this time." }

        const existingRoomSlot = await prisma.timetableSlot.findFirst({
            where: { day: data.day, time: data.time, roomId: data.roomId }
        })
        if (existingRoomSlot) return { error: "Room is already booked at this time." }

        const existingClassSlot = await prisma.timetableSlot.findFirst({
            where: { day: data.day, time: data.time, classId: data.classId }
        })
        if (existingClassSlot) return { error: "Class already has a subject scheduled at this time." }

        const slot = await prisma.timetableSlot.create({ data })
        return { slot }
    } catch (e: any) {
        return { error: e.message || "Failed to create timetable slot" }
    }
}

export async function deleteTimetableSlot(id: string) {
    try {
        await prisma.timetableSlot.delete({ where: { id } })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to delete timetable slot" }
    }
}
