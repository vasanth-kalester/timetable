const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient({ datasources: { db: { url: 'postgresql://postgres:Kalester%40timetable@db.lzkoegmtltmzisfmggun.supabase.co:5432/postgres' } } });

async function seedFaculty() {
    try {
        // Ensure a department exists
        let dept = await prisma.department.findFirst();
        if (!dept) {
            dept = await prisma.department.create({
                data: { name: 'Computer Science', code: 'CSE' }
            });
        }

        const users = await prisma.user.findMany();

        for (const user of users) {
            const existingFaculty = await prisma.faculty.findUnique({
                where: { email: user.email }
            });

            if (!existingFaculty) {
                await prisma.faculty.create({
                    data: {
                        employeeId: `EMP-${Math.floor(Math.random() * 10000)}`,
                        name: user.name || user.email.split('@')[0],
                        email: user.email,
                        departmentId: dept.id,
                        designation: user.role === 'HOD' ? 'Head of Department' : 'Assistant Professor',
                    }
                });
                console.log(`Created faculty profile for ${user.email}`);
            } else {
                console.log(`Faculty profile already exists for ${user.email}`);
            }
        }
    } catch (e) {
        console.error('Error:', e.message);
    } finally {
        await prisma.$disconnect();
    }
}

seedFaculty();
