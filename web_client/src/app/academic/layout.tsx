import { ShellLayout } from "@/components/layout/ShellLayout"

export default function AcademicLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return <ShellLayout>{children}</ShellLayout>
}
