const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')

const prisma = new PrismaClient()

async function main() {
    const email = 'admin@eduflow.com'
    const password = 'adminpassword'

    const user = await prisma.user.findUnique({
        where: { email }
    })

    if (!user) {
        console.log("User not found")
        return
    }

    console.log("User found:", user.email)
    console.log("Role:", user.role)

    const isCorrectPassword = await bcrypt.compare(password, user.passwordHash)
    console.log("Password match:", isCorrectPassword)
}

main()
    .catch(e => console.error(e))
    .finally(() => prisma.$disconnect())
