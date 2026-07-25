import { ShellLayout } from "@/components/layout/ShellLayout"

export default function StaffLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return <ShellLayout>{children}</ShellLayout>
}
