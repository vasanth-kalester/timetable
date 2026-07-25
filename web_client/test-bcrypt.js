const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')
const prisma = new PrismaClient()

async function main() {
    const user = await prisma.user.findUnique({ where: { email: 'admin@eduflow.com' } })
    console.log('User found:', !!user)
    if (user) {
        const isMatch = await bcrypt.compare('adminpassword', user.passwordHash)
        console.log('Password match:', isMatch)
    }
}

main().finally(() => prisma.$disconnect())
