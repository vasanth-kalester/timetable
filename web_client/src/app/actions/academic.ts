"use server"

import prisma from "@/lib/prisma"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"

export async function getSubjects() {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        const subjects = await prisma.subject.findMany({
            orderBy: { createdAt: 'desc' }
        })

        // Fetch faculty names for the subjects
        const facultyIds = subjects.map(s => s.staffId).filter(Boolean) as string[]
        const faculty = await prisma.faculty.findMany({
            where: { id: { in: facultyIds } }
        })
        const facultyMap = new Map(faculty.map(f => [f.id, f.name]))

        // Fetch classes for the subjects
        const classIds = subjects.map(s => s.classId).filter(Boolean) as string[]
        const classes = await prisma.class.findMany({
            where: { id: { in: classIds } }
        })
        const classMap = new Map(classes.map(c => [c.id, c]))

        // Fetch departments for the classes
        const departmentIds = classes.map(c => c.departmentId).filter(Boolean) as string[]
        const departments = await prisma.department.findMany({
            where: { id: { in: departmentIds } }
        })
        const departmentMap = new Map(departments.map(d => [d.id, d.name]))

        const mappedSubjects = subjects.map(s => {
            const cls = classMap.get(s.classId)
            return {
                id: s.id,
                code: s.code,
                name: s.name,
                credits: (s as any).hoursPerWeek || 3, // Using hoursPerWeek as credits for display
                hoursPerWeek: (s as any).hoursPerWeek || 3,
                faculty: s.staffId ? facultyMap.get(s.staffId) || "Unknown" : "Unassigned",
                className: cls?.name || "Unassigned",
                departmentName: cls?.departmentId ? departmentMap.get(cls.departmentId) || "Unassigned" : "Unassigned",
                students: 0 // Default since we don't have direct mapping in legacy schema
            }
        })

        return { subjects: mappedSubjects }
    } catch (e: any) {
        return { error: e.message || "Failed to fetch subjects" }
    }
}

export async function addSubject(data: { code: string, name: string, hoursPerWeek: number }) {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        // Create a dummy class if needed since classId is required in legacy Subject model
        let defaultClass = await prisma.class.findFirst()
        if (!defaultClass) {
            let dept = await prisma.department.findFirst()
            if (!dept) {
                // Create a fallback department if none exists
                dept = await prisma.department.create({
                    data: {
                        name: "General Department",
                        code: "GEN"
                    }
                })
            }

            defaultClass = await prisma.class.create({
                data: {
                    name: "General Class",
                    departmentId: dept.id
                }
            })
        }

        const subject = await prisma.subject.create({
            data: {
                code: data.code,
                name: data.name,
                hoursPerWeek: data.hoursPerWeek,
                classId: defaultClass.id
            } as any
        })

        return { success: true, subject }
    } catch (e: any) {
        return { error: e.message || "Failed to add subject" }
    }
}

export async function editSubject(id: string, data: { code: string, name: string, hoursPerWeek: number }) {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        const subject = await prisma.subject.update({
            where: { id },
            data: {
                code: data.code,
                name: data.name,
                hoursPerWeek: data.hoursPerWeek,
            } as any
        })

        return { success: true, subject }
    } catch (e: any) {
        return { error: e.message || "Failed to edit subject" }
    }
}

export async function deleteSubject(id: string) {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        await prisma.subject.delete({
            where: { id }
        })

        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to delete subject" }
    }
}

export async function deleteAllSubjects() {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        await prisma.subject.deleteMany({})

        return { success: true }
    } catch (e: any) {
        return { error: e.message || "Failed to delete all subjects" }
    }
}

export async function bulkImportSubjects(data: any[]) {
    try {
        const session = await getServerSession(authOptions)
        if (!session) return { error: "Unauthorized" }

        const results = {
            successCount: 0,
            errors: [] as string[]
        }

        // Process sequentially to handle relations safely
        for (let i = 0; i < data.length; i++) {
            const row = data[i]
            const rowIndex = i + 1

            try {
                // 1. Find or Create Department
                let dept = await prisma.department.findUnique({
                    where: { code: row["Department Code"] }
                })

                if (!dept) {
                    // Try to get collegeId from the user's profile
                    const user = await prisma.user.findUnique({
                        where: { id: (session.user as any).id },
                        include: { profile: true }
                    })

                    let collegeId = user?.profile?.collegeId

                    // Fallback to first college if not linked
                    if (!collegeId) {
                        const firstCollege = await prisma.college.findFirst()
                        if (firstCollege) {
                            collegeId = firstCollege.id
                        }
                    }

                    if (!collegeId) {
                        results.errors.push(`Row ${rowIndex}: Department with code '${row["Department Code"]}' not found, and could not auto-create because no college was found.`)
                        continue
                    }

                    dept = await prisma.department.create({
                        data: {
                            name: row["Department Code"], // Using code as name since we don't have it in CSV
                            code: row["Department Code"],
                            collegeId: collegeId
                        }
                    })
                }

                // 2. Find or Create Class
                let cls = await prisma.class.findFirst({
                    where: {
                        name: row["Class Name"],
                        departmentId: dept.id
                    }
                })

                if (!cls) {
                    cls = await prisma.class.create({
                        data: {
                            name: row["Class Name"],
                            departmentId: dept.id
                        }
                    })
                }

                // 3. Check if Subject Code already exists in this class
                const existingSubject = await prisma.subject.findFirst({
                    where: {
                        code: row["Subject Code"],
                        classId: cls.id
                    }
                })

                if (existingSubject) {
                    results.errors.push(`Row ${rowIndex}: Subject code '${row["Subject Code"]}' already exists in class '${cls.name}'.`)
                    continue
                }

                // 4. Create Subject
                await prisma.subject.create({
                    data: {
                        name: row["Subject Name"],
                        code: row["Subject Code"],
                        hoursPerWeek: parseInt(row["Hours Per Week"]) || 3,
                        classId: cls.id
                    } as any
                })

                results.successCount++
            } catch (err: any) {
                results.errors.push(`Row ${rowIndex}: Unexpected error - ${err.message}`)
            }
        }

        if (results.errors.length > 0) {
            return {
                error: `Imported ${results.successCount} subjects, but encountered ${results.errors.length} errors:\n${results.errors.slice(0, 5).join('\n')}${results.errors.length > 5 ? '\n...and more' : ''}`,
                success: results.successCount > 0
            }
        }

        return { success: true, message: `Successfully imported ${results.successCount} subjects.` }
    } catch (e: any) {
        return { error: e.message || "Failed to process bulk import" }
    }
}
