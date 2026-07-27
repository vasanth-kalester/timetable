const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient({ datasources: { db: { url: 'postgresql://postgres:Kalester%40timetable@db.lzkoegmtltmzisfmggun.supabase.co:5432/postgres' } } });
async function check() {
    try {
        const users = await prisma.user.findMany();
        console.log('Emails:', users.map(u => u.email));
    } catch (e) {
        console.error('Error:', e.message);
    } finally {
        await prisma.$disconnect();
    }
}
check();
