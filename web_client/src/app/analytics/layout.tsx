import { ShellLayout } from "@/components/layout/ShellLayout"

export default function AnalyticsLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return <ShellLayout>{children}</ShellLayout>
}
