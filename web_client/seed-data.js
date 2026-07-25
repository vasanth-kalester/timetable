const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')
const prisma = new PrismaClient()

async function main() {
    console.log('Starting data seed...')

    // 1. Find SSMIET college
    const college = await prisma.college.findFirst({
        where: { name: 'SSMIET' }
    })

    if (!college) {
        console.error('SSMIET college not found. Please create it first.')
        return
    }

    console.log(`Found college: ${college.name} (${college.id})`)

    // 2. Create Departments
    const deptNames = ['CSE', 'CSBS', 'IT', 'CYS', 'ECE', 'EEE', 'MECH', 'CIVIL', 'MATHS', 'PHYSICS', 'ENGLISH', 'CHEMISTRY']
    const departments = []

    for (const name of deptNames) {
        const code = name.substring(0, 4).toUpperCase()

        // Check if department exists
        let dept = await prisma.department.findFirst({
            where: { name, collegeId: college.id }
        })

        if (!dept) {
            dept = await prisma.department.create({
                data: {
                    name,
                    code,
                    collegeId: college.id
                }
            })
            console.log(`Created department: ${name}`)
        } else {
            console.log(`Department already exists: ${name}`)
        }
        departments.push(dept)
    }

    // 3. Create Staff for each department
    const passwordHash = await bcrypt.hash('password123', 10)

    for (const dept of departments) {
        console.log(`Creating staff for ${dept.name}...`)

        // Create 1 HOD
        const hodEmail = `hod.${dept.code.toLowerCase()}@ssmiet.edu`
        let hod = await prisma.user.findUnique({ where: { email: hodEmail } })

        if (!hod) {
            await prisma.user.create({
                data: {
                    email: hodEmail,
                    passwordHash,
                    role: 'hod',
                    approvalStatus: 'approved',
                    profile: {
                        create: {
                            firstName: 'HOD',
                            lastName: dept.name,
                            collegeId: college.id,
                            departmentId: dept.id
                        }
                    }
                }
            })
        }

        // Create 9 Faculty members
        for (let i = 1; i <= 9; i++) {
            const facultyEmail = `faculty${i}.${dept.code.toLowerCase()}@ssmiet.edu`
            let faculty = await prisma.user.findUnique({ where: { email: facultyEmail } })

            if (!faculty) {
                await prisma.user.create({
                    data: {
                        email: facultyEmail,
                        passwordHash,
                        role: 'faculty',
                        approvalStatus: 'approved',
                        profile: {
                            create: {
                                firstName: 'Faculty',
                                lastName: `${i} (${dept.name})`,
                                collegeId: college.id,
                                departmentId: dept.id
                            }
                        }
                    }
                })
            }
        }
    }

    console.log('Data seeding completed successfully!')
}

main()
    .catch(e => {
        console.error(e)
        process.exit(1)
    })
    .finally(async () => {
        await prisma.$disconnect()
    })
