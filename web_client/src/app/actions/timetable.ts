"use server"

import prisma from "@/lib/prisma"


// --- Classes ---
export async function getClasses(departmentId: string | null, collegeId?: string) {
    try {
        const whereClause = departmentId
            ? { departmentId }
            : (collegeId ? { department: { collegeId } } : {})

        const classes = await prisma.class.findMany({
            where: whereClause,
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

// --- Subjects ---
export async function getSubjects(classId: string) {
    try {
        const subjects = await prisma.subject.findMany({
            where: { classId },
            orderBy: { name: 'asc' }
        })
        return { subjects }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch subjects" }
    }
}

export async function createSubject(data: { name: string, code: string, classId: string, staffId?: string, hoursPerWeek?: number }) {
    try {
        const subject = await prisma.subject.create({ data })
        return { subject }
    } catch (e: any) {
        return { error: e.message || "Failed to create subject" }
    }
}

export async function updateSubject(id: string, data: { name?: string, code?: string, hoursPerWeek?: number }) {
    try {
        const subject = await prisma.subject.update({ where: { id }, data })
        return { subject }
    } catch (e: any) {
        return { error: e.message || "Failed to update subject" }
    }
}

export async function bulkDeleteSlotsByClass(classId: string) {
    try {
        await prisma.timetableSlot.deleteMany({ where: { classId } })
        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to delete slots" }
    }
}

export async function updateSubjectStaff(id: string, staffId: string | null) {
    try {
        const subject = await prisma.subject.update({
            where: { id },
            data: { staffId }
        })
        return { subject }
    } catch (e: any) {
        return { error: e.message || "Failed to update subject staff" }
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

// --- Department-Wide Generation ---
export async function generateDepartmentTimetable(departmentId: string, collegeId: string) {
    try {
        // 1. Fetch all classes in the department
        const classes = await prisma.class.findMany({ where: { departmentId } })
        if (classes.length === 0) return { error: "No classes found in this department." }
        const classIds = classes.map(c => c.id)

        // 2. Fetch all subjects for those classes
        const subjects = await prisma.subject.findMany({
            where: { classId: { in: classIds } }
        })

        // 3. Fetch all rooms in the college
        const rooms = await prisma.room.findMany({ where: { collegeId } })
        if (rooms.length === 0) return { error: "No rooms available in this college." }

        // 4. Delete existing slots for these classes
        await prisma.timetableSlot.deleteMany({
            where: { classId: { in: classIds } }
        })

        // 5. Setup generation variables
        const WORKING_DAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        const SCHEDULABLE_TIMES = ["09:00 AM", "10:00 AM", "11:00 AM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"]

        const staffBooked = new Set<string>()
        const roomBooked = new Set<string>()
        const classBooked = new Set<string>()

        const allCombos: [string, string][] = []
        for (const day of WORKING_DAYS) {
            for (const time of SCHEDULABLE_TIMES) {
                allCombos.push([day, time])
            }
        }

        // Helper for seeded shuffle
        function seededShuffle<T>(arr: T[], seed: number): T[] {
            const a = [...arr]; let s = seed | 0
            for (let i = a.length - 1; i > 0; i--) {
                s = Math.imul(s ^ (s >>> 15), s | 1) ^ (s + Math.imul(s ^ (s >>> 7), s | 61))
                const j = (s >>> 0) % (i + 1);
                [a[i], a[j]] = [a[j], a[i]]
            }
            return a
        }

        const generatedSlots = []
        let seed = Date.now()

        // 6. Generate slots for each class
        for (const cls of classes) {
            const classSubjects = subjects.filter(s => s.classId === cls.id && s.staffId)
                .sort((a, b) => (b.hoursPerWeek || 3) - (a.hoursPerWeek || 3))

            for (let si = 0; si < classSubjects.length; si++) {
                const subject = classSubjects[si]
                const needed = Math.min(subject.hoursPerWeek || 3, WORKING_DAYS.length * SCHEDULABLE_TIMES.length)
                let scheduled = 0
                const shuffled = seededShuffle(allCombos, seed + si * 997)

                for (const [day, time] of shuffled) {
                    if (scheduled >= needed) break
                    const classKey = `${cls.id}|${day}|${time}`
                    const staffKey = `${subject.staffId}|${day}|${time}`

                    if (classBooked.has(classKey) || staffBooked.has(staffKey)) continue

                    // Find a free room
                    const freeRoom = rooms.find(r => !roomBooked.has(`${r.id}|${day}|${time}`))
                    if (!freeRoom) continue

                    generatedSlots.push({
                        day,
                        time,
                        classId: cls.id,
                        subjectId: subject.id,
                        staffId: subject.staffId!,
                        roomId: freeRoom.id
                    })

                    classBooked.add(classKey)
                    staffBooked.add(staffKey)
                    roomBooked.add(`${freeRoom.id}|${day}|${time}`)
                    scheduled++
                }
            }
            seed += 12345 // Change seed for next class
        }

        // 7. Bulk insert generated slots
        if (generatedSlots.length > 0) {
            await prisma.timetableSlot.createMany({
                data: generatedSlots
            })
        }

        return { success: true, slotsGenerated: generatedSlots.length }
    } catch (e: any) {
        return { error: e.message || "Failed to generate department timetable" }
    }
}
