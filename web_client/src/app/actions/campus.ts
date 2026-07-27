"use server"

import prisma from "@/lib/prisma"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"

export async function getRooms() {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        const classrooms = await prisma.classroom.findMany()
        const laboratories = await prisma.laboratory.findMany()
        const buildings = await prisma.building.findMany()

        const buildingMap = new Map(buildings.map(b => [b.id, b.name]))

        const mappedClassrooms = classrooms.map(c => ({
            id: c.id,
            name: c.roomNumber,
            type: "Classroom",
            capacity: c.capacity.toString(),
            status: c.status === "active" ? "Available" : c.status,
            equipment: [
                ...(c.isSmart ? ["Smart Board"] : []),
                ...(c.hasProjector ? ["Projector"] : []),
                ...(c.hasAC ? ["AC"] : [])
            ],
            block: buildingMap.get(c.buildingId) || "Main Block",
            floor: "1" // Default floor as it's not in schema
        }))

        const mappedLaboratories = laboratories.map(l => ({
            id: l.id,
            name: l.name,
            type: "Laboratory",
            capacity: l.capacity.toString(),
            status: l.status === "active" ? "Available" : l.status,
            equipment: ["Lab Equipment"],
            block: buildingMap.get(l.buildingId) || "Main Block",
            floor: "1"
        }))

        return { rooms: [...mappedClassrooms, ...mappedLaboratories] }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch rooms" }
    }
}

export async function addRoom(data: { name: string, type: string, capacity: string, block: string, floor: string }) {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        // Find or create building
        let building = await prisma.building.findFirst({
            where: { name: data.block }
        })

        if (!building) {
            building = await prisma.building.create({
                data: {
                    name: data.block,
                    code: data.block.substring(0, 3).toUpperCase() + Math.random().toString(36).substring(2, 5).toUpperCase(),
                    type: "academic"
                }
            })
        }

        if (data.type === "Laboratory") {
            // Need a department for laboratory
            let dept = await prisma.department.findFirst()
            if (!dept) {
                dept = await prisma.department.create({
                    data: {
                        name: "General",
                        code: "GEN"
                    }
                })
            }

            const lab = await prisma.laboratory.create({
                data: {
                    name: data.name,
                    code: data.name.toUpperCase().replace(/\s+/g, '_') + '_' + Math.random().toString(36).substring(2, 5).toUpperCase(),
                    capacity: parseInt(data.capacity) || 30,
                    labType: "General",
                    buildingId: building.id,
                    departmentId: dept.id,
                    status: "active"
                }
            })
            return { success: true, room: lab }
        } else {
            const classroom = await prisma.classroom.create({
                data: {
                    roomNumber: data.name,
                    capacity: parseInt(data.capacity) || 60,
                    isSmart: true,
                    hasProjector: true,
                    hasAC: false,
                    buildingId: building.id,
                    status: "active"
                }
            })
            return { success: true, room: classroom }
        }
    } catch (e: any) {
        return { error: e.message || "Failed to add room" }
    }
}
