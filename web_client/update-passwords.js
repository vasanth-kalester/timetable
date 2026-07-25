const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')
const prisma = new PrismaClient()

async function main() {
    console.log('Updating passwords...')
    const passwordHash = await bcrypt.hash('pass1234', 10)

    const result = await prisma.user.updateMany({
        data: {
            passwordHash
        }
    })

    console.log(`Successfully updated ${result.count} users' passwords to pass1234.`)
}

main()
    .catch(e => {
        console.error(e)
        process.exit(1)
    })
    .finally(async () => {
        await prisma.$disconnect()
    })
