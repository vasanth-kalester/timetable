"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Building2, Mail, Lock, User, ShieldAlert, ArrowRight, Loader2, CheckCircle2, Search, GraduationCap } from "lucide-react"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/Card"
import { registerPrincipal, findCollege, registerStaff } from "@/app/actions/auth"

interface Department {
    id: string;
    name: string;
}

export default function RegistrationPage() {
    const router = useRouter()

    const [registrationType, setRegistrationType] = useState<'principal' | 'staff'>('principal')
    const [step, setStep] = useState(1)
    const [isLoading, setIsLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)
    const [successMessage, setSuccessMessage] = useState<string | null>(null)

    // Principal Form State
    const [collegeName, setCollegeName] = useState("")
    const [collegeAddress, setCollegeAddress] = useState("")
    const [generatedCode, setGeneratedCode] = useState("")

    // Staff Form State
    const [collegeCode, setCollegeCode] = useState("")
    const [foundCollege, setFoundCollege] = useState<{ id: string, name: string } | null>(null)
    const [staffRole, setStaffRole] = useState<'hod' | 'faculty'>('faculty')
    const [departments, setDepartments] = useState<Department[]>([])
    const [selectedDepartment, setSelectedDepartment] = useState("")

    // Common Form State
    const [firstName, setFirstName] = useState("")
    const [lastName, setLastName] = useState("")
    const [email, setEmail] = useState("")
    const [password, setPassword] = useState("")

    const handleNextStep = async () => {
        if (registrationType === 'principal' && step === 1) {
            if (!collegeName || !collegeAddress) {
                setError("Please fill in all college details.")
                return
            }
            setError(null)
            setStep(2)
        } else if (registrationType === 'staff' && step === 1) {
            if (!collegeCode || collegeCode.length !== 4) {
                setError("Please enter a valid 4-digit college code.")
                return
            }
            setIsLoading(true)
            setError(null)

            const result = await findCollege(collegeCode)

            setIsLoading(false)

            if (result.error || !result.college) {
                setError(result.error || "College not found. Please check the code.")
                return
            }

            setFoundCollege(result.college)
            if (result.departments) setDepartments(result.departments)

            setStep(2)
        } else if (registrationType === 'staff' && step === 2) {
            if (!selectedDepartment) {
                setError("Please select a department.")
                return
            }
            setError(null)
            setStep(3)
        }
    }

    const handleRegister = async () => {
        if (!firstName || !lastName || !email || !password) {
            setError("Please fill in all personal details.")
            return
        }

        setIsLoading(true)
        setError(null)

        try {
            if (registrationType === 'principal') {
                const result = await registerPrincipal({
                    firstName, lastName, email, password, collegeName, collegeAddress
                })

                if (result.error) throw new Error(result.error)

                setGeneratedCode(result.code!)
                setStep(3) // Show success screen with code
            } else {
                const result = await registerStaff({
                    firstName, lastName, email, password, role: staffRole, collegeId: foundCollege?.id, departmentId: selectedDepartment
                })

                if (result.error) throw new Error(result.error)

                setSuccessMessage("Registration successful! Your account is pending approval from your HOD or Principal.")
                setStep(4) // Show success screen
            }

        } catch (err) {
            console.error("Full Error:", err)
            setError(err instanceof Error ? err.message : "An error occurred during registration.")
        } finally {
            setIsLoading(false)
        }
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-background p-4 relative overflow-hidden">
            <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-indigo-600/10 blur-[120px] pointer-events-none" />
            <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-blue-600/10 blur-[120px] pointer-events-none" />

            <Card className="w-full max-w-md relative z-10 border-slate-800 bg-slate-900/80 backdrop-blur-xl">
                <CardHeader className="space-y-4 text-center pb-6">
                    <div className="mx-auto bg-indigo-600 w-16 h-16 rounded-2xl flex items-center justify-center shadow-lg shadow-indigo-600/20">
                        {registrationType === 'principal' ? <Building2 className="w-8 h-8 text-white" /> : <GraduationCap className="w-8 h-8 text-white" />}
                    </div>
                    <div className="space-y-2">
                        <CardTitle className="text-2xl font-bold tracking-tight text-slate-50">
                            {registrationType === 'principal' ? "Register Your College" : "Join Your College"}
                        </CardTitle>
                        <CardDescription className="text-slate-400">
                            {registrationType === 'principal'
                                ? (step === 1 ? "Step 1: College Information" : step === 2 ? "Step 2: Principal Account" : "Success!")
                                : (step === 1 ? "Step 1: Find College" : step === 2 ? "Step 2: Role & Department" : step === 3 ? "Step 3: Personal Details" : "Success!")
                            }
                        </CardDescription>
                    </div>
                </CardHeader>

                <CardContent className="space-y-6">
                    {step === 1 && (
                        <div className="flex p-1 bg-slate-800/50 rounded-lg mb-6">
                            <button
                                className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors ${registrationType === 'principal' ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'}`}
                                onClick={() => { setRegistrationType('principal'); setError(null); }}
                            >
                                Register College
                            </button>
                            <button
                                className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors ${registrationType === 'staff' ? 'bg-indigo-600 text-white shadow' : 'text-slate-400 hover:text-slate-200'}`}
                                onClick={() => { setRegistrationType('staff'); setError(null); }}
                            >
                                Join as Staff
                            </button>
                        </div>
                    )}

                    {error && (
                        <div className="p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm flex items-center gap-2">
                            <ShieldAlert className="w-4 h-4" />
                            {error}
                        </div>
                    )}

                    {/* PRINCIPAL FLOW */}
                    {registrationType === 'principal' && step === 1 && (
                        <div className="space-y-4 animate-in fade-in slide-in-from-right-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">College Name</label>
                                <div className="relative">
                                    <Building2 className="absolute left-3 top-2.5 h-5 w-5 text-slate-500" />
                                    <Input placeholder="e.g. EduFlow Institute of Technology" className="pl-10" value={collegeName} onChange={(e) => setCollegeName(e.target.value)} />
                                </div>
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">College Address</label>
                                <div className="relative">
                                    <Input placeholder="e.g. 123 Campus Drive, City, State" value={collegeAddress} onChange={(e) => setCollegeAddress(e.target.value)} />
                                </div>
                            </div>
                            <Button className="w-full h-12 text-base font-semibold shadow-lg shadow-indigo-600/20 mt-6" onClick={handleNextStep}>
                                Continue <ArrowRight className="w-4 h-4 ml-2" />
                            </Button>
                        </div>
                    )}

                    {/* STAFF FLOW - STEP 1 */}
                    {registrationType === 'staff' && step === 1 && (
                        <div className="space-y-4 animate-in fade-in slide-in-from-right-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">4-Digit College Code</label>
                                <div className="relative">
                                    <Search className="absolute left-3 top-2.5 h-5 w-5 text-slate-500" />
                                    <Input placeholder="e.g. 4829" className="pl-10 text-center tracking-widest text-lg" maxLength={4} value={collegeCode} onChange={(e) => setCollegeCode(e.target.value.replace(/\D/g, ''))} />
                                </div>
                                <p className="text-xs text-slate-500 text-center mt-2">Ask your Principal or Admin for this code.</p>
                            </div>
                            <Button className="w-full h-12 text-base font-semibold shadow-lg shadow-indigo-600/20 mt-6" onClick={handleNextStep} disabled={isLoading}>
                                {isLoading ? <Loader2 className="w-5 h-5 animate-spin" /> : <>Find College <ArrowRight className="w-4 h-4 ml-2" /></>}
                            </Button>
                        </div>
                    )}

                    {/* STAFF FLOW - STEP 2 */}
                    {registrationType === 'staff' && step === 2 && (
                        <div className="space-y-4 animate-in fade-in slide-in-from-right-4">
                            <div className="p-4 rounded-lg bg-emerald-500/10 border border-emerald-500/20 flex items-center gap-3">
                                <CheckCircle2 className="w-5 h-5 text-emerald-400" />
                                <div>
                                    <p className="text-xs text-emerald-400/70 font-medium uppercase tracking-wider">College Found</p>
                                    <p className="text-sm font-medium text-emerald-400">{foundCollege?.name}</p>
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Your Role</label>
                                <select
                                    className="flex h-10 w-full rounded-md border border-slate-800 bg-slate-950 px-3 py-2 text-sm text-slate-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-indigo-500"
                                    value={staffRole}
                                    onChange={e => setStaffRole(e.target.value as 'hod' | 'faculty')}
                                >
                                    <option value="faculty">Faculty / Teacher</option>
                                    <option value="hod">Head of Department (HOD)</option>
                                </select>
                            </div>

                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Department</label>
                                <select
                                    className="flex h-10 w-full rounded-md border border-slate-800 bg-slate-950 px-3 py-2 text-sm text-slate-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-indigo-500"
                                    value={selectedDepartment}
                                    onChange={e => setSelectedDepartment(e.target.value)}
                                >
                                    <option value="">Select a department...</option>
                                    {departments.map(d => (
                                        <option key={d.id} value={d.id}>{d.name}</option>
                                    ))}
                                </select>
                                {departments.length === 0 && <p className="text-xs text-amber-400 mt-1">No departments found. Contact your admin.</p>}
                            </div>

                            <div className="flex gap-3 mt-6">
                                <Button variant="outline" className="w-1/3 h-12" onClick={() => setStep(1)}>Back</Button>
                                <Button className="w-2/3 h-12 text-base font-semibold shadow-lg shadow-indigo-600/20" onClick={handleNextStep}>
                                    Continue <ArrowRight className="w-4 h-4 ml-2" />
                                </Button>
                            </div>
                        </div>
                    )}

                    {/* COMMON PERSONAL DETAILS STEP */}
                    {((registrationType === 'principal' && step === 2) || (registrationType === 'staff' && step === 3)) && (
                        <div className="space-y-4 animate-in fade-in slide-in-from-right-4">
                            <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-slate-300">First Name</label>
                                    <div className="relative">
                                        <User className="absolute left-3 top-2.5 h-5 w-5 text-slate-500" />
                                        <Input placeholder="John" className="pl-10" value={firstName} onChange={(e) => setFirstName(e.target.value)} />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-slate-300">Last Name</label>
                                    <Input placeholder="Doe" value={lastName} onChange={(e) => setLastName(e.target.value)} />
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Email Address</label>
                                <div className="relative">
                                    <Mail className="absolute left-3 top-2.5 h-5 w-5 text-slate-500" />
                                    <Input type="email" placeholder="name@college.edu" className="pl-10" value={email} onChange={(e) => setEmail(e.target.value)} />
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-300">Password</label>
                                <div className="relative">
                                    <Lock className="absolute left-3 top-2.5 h-5 w-5 text-slate-500" />
                                    <Input type="password" placeholder="••••••••" className="pl-10" value={password} onChange={(e) => setPassword(e.target.value)} />
                                </div>
                            </div>

                            <div className="flex gap-3 mt-6">
                                <Button variant="outline" className="w-1/3 h-12" onClick={() => setStep(registrationType === 'principal' ? 1 : 2)} disabled={isLoading}>
                                    Back
                                </Button>
                                <Button className="w-2/3 h-12 text-base font-semibold shadow-lg shadow-indigo-600/20" onClick={handleRegister} disabled={isLoading}>
                                    {isLoading ? <Loader2 className="w-5 h-5 animate-spin" /> : "Complete Registration"}
                                </Button>
                            </div>
                        </div>
                    )}

                    {/* PRINCIPAL SUCCESS SCREEN */}
                    {registrationType === 'principal' && step === 3 && (
                        <div className="space-y-6 text-center animate-in zoom-in-95 duration-500">
                            <div className="mx-auto w-16 h-16 bg-emerald-500/20 rounded-full flex items-center justify-center mb-4">
                                <CheckCircle2 className="w-8 h-8 text-emerald-400" />
                            </div>
                            <h3 className="text-xl font-bold text-slate-50">Registration Successful!</h3>
                            <p className="text-slate-400 text-sm">Your college has been registered. Share this 4-digit code with your staff so they can join.</p>

                            <div className="p-6 bg-slate-950 rounded-xl border border-slate-800">
                                <p className="text-xs text-slate-500 uppercase tracking-widest font-semibold mb-2">College Code</p>
                                <p className="text-5xl font-black text-indigo-400 tracking-widest">{generatedCode}</p>
                            </div>

                            <Button className="w-full h-12 text-base font-semibold shadow-lg shadow-indigo-600/20 mt-6" onClick={() => router.push("/dashboard")}>
                                Go to Dashboard <ArrowRight className="w-4 h-4 ml-2" />
                            </Button>
                        </div>
                    )}

                    {/* STAFF SUCCESS SCREEN */}
                    {registrationType === 'staff' && step === 4 && (
                        <div className="space-y-6 text-center animate-in zoom-in-95 duration-500">
                            <div className="mx-auto w-16 h-16 bg-amber-500/20 rounded-full flex items-center justify-center mb-4">
                                <CheckCircle2 className="w-8 h-8 text-amber-400" />
                            </div>
                            <h3 className="text-xl font-bold text-slate-50">Registration Submitted</h3>
                            <p className="text-slate-400 text-sm">{successMessage}</p>

                            <Button className="w-full h-12 text-base font-semibold shadow-lg shadow-indigo-600/20 mt-6" onClick={() => router.push("/login")}>
                                Back to Login
                            </Button>
                        </div>
                    )}
                </CardContent>

                {step < 3 && (
                    <CardFooter className="flex justify-center border-t border-slate-800 pt-6">
                        <p className="text-sm text-slate-400">
                            Already have an account? <a href="/login" className="text-indigo-400 hover:text-indigo-300">Sign in</a>
                        </p>
                    </CardFooter>
                )}
            </Card>
        </div>
    )
}
