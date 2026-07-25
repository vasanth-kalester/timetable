const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function main() {
    const users = await prisma.user.findMany({ include: { profile: true } })
    console.log("=== USERS ===")
    users.forEach(u => {
        console.log(`Email: ${u.email}, Role: ${u.role}`)
        console.log(`  Profile: ${JSON.stringify(u.profile)}`)
    })

    const colleges = await prisma.college.findMany()
    console.log("\n=== COLLEGES ===")
    console.log(colleges)
}

main().finally(() => prisma.$disconnect())
