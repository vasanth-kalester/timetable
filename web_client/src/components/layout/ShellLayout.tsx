import { Sidebar } from "./Sidebar"
import { Topbar } from "./Topbar"

export function ShellLayout({ children }: { children: React.ReactNode }) {
    return (
        <div className="flex h-screen overflow-hidden bg-background">
            <Sidebar />
            <div className="flex flex-1 flex-col overflow-hidden relative">
                <div className="absolute top-[-20%] right-[-10%] w-[50%] h-[50%] rounded-full bg-indigo-600/5 blur-[120px] pointer-events-none" />
                <Topbar />
                <main className="flex-1 overflow-y-auto p-8 relative z-10">
                    {children}
                </main>
            </div>
        </div>
    )
}
