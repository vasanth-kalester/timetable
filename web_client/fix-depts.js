const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function main() {
    const mockDepts = await prisma.department.findMany({
        where: { collegeId: 'mock_college_id' }
    })
    console.log(`Found ${mockDepts.length} mock departments.`)

    if (mockDepts.length > 0) {
        const college = await prisma.college.findFirst()
        if (college) {
            console.log(`Updating mock departments to real college: ${college.name}`)
            await prisma.department.updateMany({
                where: { collegeId: 'mock_college_id' },
                data: { collegeId: college.id }
            })
            console.log('Update complete.')
        }
    }
}

main().finally(() => prisma.$disconnect())
