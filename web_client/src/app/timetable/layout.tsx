import { ShellLayout } from "@/components/layout/ShellLayout"

export default function TimetableLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return <ShellLayout>{children}</ShellLayout>
}
