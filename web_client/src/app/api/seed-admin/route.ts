import { NextResponse } from "next/server"
import { PrismaClient } from "@prisma/client"
import bcrypt from "bcryptjs"

const prisma = new PrismaClient()

export async function GET() {
    try {
        const email = 'admin@eduflow.com'
        const password = 'adminpassword'
        const hashedPassword = await bcrypt.hash(password, 10)

        const existingAdmin = await prisma.user.findUnique({
            where: { email }
        })

        if (existingAdmin) {
            return NextResponse.json({ message: "Admin user already exists." })
        }

        const admin = await prisma.user.create({
            data: {
                email,
                passwordHash: hashedPassword,
                role: 'admin',
                profile: {
                    create: {
                        firstName: 'Super',
                        lastName: 'Admin'
                    }
                }
            }
        })

        return NextResponse.json({ message: "Admin user created successfully!", email: admin.email })
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 })
    }
}
