import { ShellLayout } from "@/components/layout/ShellLayout"

export default function CampusLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return <ShellLayout>{children}</ShellLayout>
}
