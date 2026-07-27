const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')

const prisma = new PrismaClient({ datasources: { db: { url: 'postgresql://postgres:Kalester%40timetable@db.lzkoegmtltmzisfmggun.supabase.co:5432/postgres' } } })

async function main() {
    const email = 'admin@eduflow.com'
    const password = 'adminpassword'
    const hashedPassword = await bcrypt.hash(password, 10)

    const existingAdmin = await prisma.user.findUnique({
        where: { email }
    })

    if (existingAdmin) {
        console.log('Admin user already exists.')
        return
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

    console.log('Admin user created successfully:', admin.email)
}

main()
    .catch(e => {
        console.error(e)
        process.exit(1)
    })
    .finally(async () => {
        await prisma.$disconnect()
    })
