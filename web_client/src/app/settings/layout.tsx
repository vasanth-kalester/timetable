import { ShellLayout } from "@/components/layout/ShellLayout"

export default function SettingsLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return <ShellLayout>{children}</ShellLayout>
}
