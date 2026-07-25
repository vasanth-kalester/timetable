import { ShellLayout } from "@/components/layout/ShellLayout"

export default function DepartmentsLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return <ShellLayout>{children}</ShellLayout>
}
