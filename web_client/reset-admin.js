const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')

const prisma = new PrismaClient()

async function main() {
    const email = 'admin@eduflow.com'
    const password = 'adminpassword'
    const hashedPassword = await bcrypt.hash(password, 10)

    const user = await prisma.user.update({
        where: { email },
        data: { passwordHash: hashedPassword }
    })

    console.log("Password reset successfully for:", user.email)
}

main()
    .catch(e => console.error(e))
    .finally(() => prisma.$disconnect())
