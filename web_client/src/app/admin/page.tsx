import { getServerSession } from "next-auth/next"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"
import { redirect } from "next/navigation"
import { SuperAdminDashboard } from "@/components/dashboard/SuperAdminDashboard"

export default async function AdminPage() {
    const session = await getServerSession(authOptions)

    if (!session || !session.user) {
        redirect("/login")
    }

    const userRole = (session.user as any).role

    if (userRole !== 'admin') {
        redirect("/dashboard")
    }

    const firstName = (session.user as any).name?.split(' ')[0] || "Admin"

    return (
        <div className="p-6 md:p-8 max-w-7xl mx-auto">
            <SuperAdminDashboard firstName={firstName} />
        </div>
    )
}
