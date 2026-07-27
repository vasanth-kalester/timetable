"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Network, Lock, Mail, ShieldAlert, Loader2 } from "lucide-react"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/Card"
import { signIn } from "next-auth/react"

export default function LoginPage() {
    const router = useRouter()

    const [email, setEmail] = useState("")
    const [password, setPassword] = useState("")
    const [isLoading, setIsLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)

    const handleLogin = async () => {
        if (!email || !password) {
            setError("Please enter your email and password.")
            return
        }

        setIsLoading(true)
        setError(null)

        try {
            const result = await signIn("credentials", {
                redirect: false,
                email: email.trim(),
                password,
            })

            if (result?.error) {
                throw new Error(result.error)
            }

            // Successfully signed in, route to dashboard
            router.push("/dashboard")

        } catch (err) {
            console.error(err)
            setError(err instanceof Error ? err.message : "Invalid credentials. Please try again.")
        } finally {
            setIsLoading(false)
        }
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-background p-4 relative overflow-hidden">
            <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-indigo-600/10 blur-[120px] pointer-events-none" />
            <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-blue-600/10 blur-[120px] pointer-events-none" />

            <Card className="w-full max-w-md relative z-10">
                <CardHeader className="space-y-4 text-center pb-8">
                    <div className="mx-auto bg-primary w-16 h-16 rounded-2xl flex items-center justify-center shadow-lg shadow-primary/20">
                        <Network className="w-8 h-8 text-on-primary" />
                    </div>
                    <div className="space-y-2">
                        <CardTitle className="text-2xl font-bold tracking-tight text-on-surface">Sign In to EduFlow</CardTitle>
                        <CardDescription className="text-on-surface-variant">
                            Enter your email and password to access your campus.
                        </CardDescription>
                    </div>
                </CardHeader>

                <CardContent className="space-y-6">
                    {error && (
                        <div className="p-3 rounded-lg bg-error-container border border-error/20 text-on-error-container text-sm flex items-center gap-2">
                            <ShieldAlert className="w-4 h-4" />
                            {error}
                        </div>
                    )}

                    <div className="space-y-4">
                        <div className="space-y-2">
                            <label className="text-sm font-medium text-on-surface-variant">Email Address</label>
                            <div className="relative">
                                <Mail className="absolute left-3 top-2.5 h-5 w-5 text-outline" />
                                <Input
                                    type="email"
                                    placeholder="e.g. principal@college.edu"
                                    className="pl-10"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className="text-sm font-medium text-on-surface-variant">Password</label>
                            <div className="relative">
                                <Lock className="absolute left-3 top-2.5 h-5 w-5 text-outline" />
                                <Input
                                    type="password"
                                    placeholder="••••••••"
                                    className="pl-10"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                />
                            </div>
                        </div>
                    </div>

                    <div className="flex items-center justify-between text-sm">
                        <label className="flex items-center gap-2 cursor-pointer text-on-surface-variant">
                            <input type="checkbox" className="rounded border-outline-variant bg-surface-container-low text-primary focus:ring-primary focus:ring-offset-background" defaultChecked />
                            Remember Me
                        </label>
                        <a href="#" className="text-primary hover:text-primary/80 transition-colors">
                            Forgot Password?
                        </a>
                    </div>

                    <Button
                        className="w-full h-12 text-base font-semibold shadow-lg shadow-primary/20"
                        onClick={handleLogin}
                        disabled={isLoading}
                    >
                        {isLoading ? (
                            <Loader2 className="w-5 h-5 animate-spin" />
                        ) : (
                            "Sign In"
                        )}
                    </Button>
                </CardContent>

                <CardFooter className="flex flex-col border-t border-outline-variant pt-6 gap-4">
                    <div className="w-full text-center">
                        <p className="text-sm text-on-surface-variant">
                            New to EduFlow? <a href="/register" className="text-primary hover:text-primary/80 font-medium">Sign up</a>
                        </p>
                    </div>
                </CardFooter>
            </Card>
        </div>
    )
}
