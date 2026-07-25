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

            <Card className="w-full max-w-md relative z-10 border-slate-800 bg-slate-900/80 backdrop-blur-xl">
                <CardHeader className="space-y-4 text-center pb-8">
                    <div className="mx-auto bg-indigo-600 w-16 h-16 rounded-2xl flex items-center justify-center shadow-lg shadow-indigo-600/20">
                        <Network className="w-8 h-8 text-white" />
                    </div>
                    <div className="space-y-2">
                        <CardTitle className="text-2xl font-bold tracking-tight text-slate-50">Sign In to EduFlow</CardTitle>
                        <CardDescription className="text-slate-400">
                            Enter your email and password to access your campus.
                        </CardDescription>
                    </div>
                </CardHeader>

                <CardContent className="space-y-6">
                    {error && (
                        <div className="p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm flex items-center gap-2">
                            <ShieldAlert className="w-4 h-4" />
                            {error}
                        </div>
                    )}

                    <div className="space-y-4">
                        <div className="space-y-2">
                            <label className="text-sm font-medium text-slate-300">Email Address</label>
                            <div className="relative">
                                <Mail className="absolute left-3 top-2.5 h-5 w-5 text-slate-500" />
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
                            <label className="text-sm font-medium text-slate-300">Password</label>
                            <div className="relative">
                                <Lock className="absolute left-3 top-2.5 h-5 w-5 text-slate-500" />
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
                        <label className="flex items-center gap-2 cursor-pointer text-slate-300">
                            <input type="checkbox" className="rounded border-slate-700 bg-slate-800 text-indigo-600 focus:ring-indigo-600 focus:ring-offset-slate-900" defaultChecked />
                            Remember Me
                        </label>
                        <a href="#" className="text-indigo-400 hover:text-indigo-300 transition-colors">
                            Forgot Password?
                        </a>
                    </div>

                    <Button
                        className="w-full h-12 text-base font-semibold shadow-lg shadow-indigo-600/20"
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

                <CardFooter className="flex flex-col border-t border-slate-800 pt-6 gap-4">
                    <div className="w-full text-center">
                        <p className="text-sm text-slate-400">
                            New to EduFlow? <a href="/register" className="text-indigo-400 hover:text-indigo-300 font-medium">Sign up</a>
                        </p>
                    </div>
                </CardFooter>
            </Card>
        </div>
    )
}
