"use client"

import { useSession } from "next-auth/react"
import { useEffect, useState } from "react"
import { PrincipalDashboard } from "@/components/dashboard/PrincipalDashboard"
import { HodDashboard } from "@/components/dashboard/HodDashboard"
import { FacultyDashboard } from "@/components/dashboard/FacultyDashboard"
import { StudentDashboard } from "@/components/dashboard/StudentDashboard"
import { Loader2 } from "lucide-react"

export default function DashboardPage() {
    const { data: session, status } = useSession()
    const [firstName, setFirstName] = useState("User")
    const [userRole, setUserRole] = useState<string | null>(null)

    useEffect(() => {
        if (session?.user) {
            setFirstName((session.user as any).name?.split(' ')[0] || "User")
            setUserRole((session.user as any).role || "student")
        }
    }, [session])

    if (status === "loading") {
        return <div className="flex justify-center py-12 h-full items-center"><Loader2 className="w-8 h-8 animate-spin text-indigo-500" /></div>
    }

    if (userRole === 'principal') {
        return <PrincipalDashboard firstName={firstName} />
    }

    if (userRole === 'hod') {
        return <HodDashboard firstName={firstName} />
    }

    if (userRole === 'faculty') {
        return <FacultyDashboard firstName={firstName} />
    }

    return <StudentDashboard firstName={firstName} />
}
