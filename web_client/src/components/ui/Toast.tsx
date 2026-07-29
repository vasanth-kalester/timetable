"use client"

import { useEffect, useState } from "react"
import { CheckCircle2, XCircle, X } from "lucide-react"

export type ToastType = "success" | "error"

export interface ToastMessage {
    id: number
    type: ToastType
    message: string
}

let toastId = 0

type Listener = (toasts: ToastMessage[]) => void
const listeners: Listener[] = []
let toasts: ToastMessage[] = []

function emit() {
    listeners.forEach(l => l([...toasts]))
}

export function toast(message: string, type: ToastType = "success") {
    const id = ++toastId
    toasts = [...toasts, { id, type, message }]
    emit()
    setTimeout(() => {
        toasts = toasts.filter(t => t.id !== id)
        emit()
    }, 3500)
}

export function ToastContainer() {
    const [list, setList] = useState<ToastMessage[]>([])

    useEffect(() => {
        listeners.push(setList)
        return () => {
            const idx = listeners.indexOf(setList)
            if (idx > -1) listeners.splice(idx, 1)
        }
    }, [])

    if (list.length === 0) return null

    return (
        <div className="fixed bottom-6 right-6 z-[9999] flex flex-col gap-2 pointer-events-none">
            {list.map(t => (
                <div
                    key={t.id}
                    className={`
                        flex items-center gap-3 px-4 py-3 rounded-xl shadow-xl border
                        text-sm font-medium pointer-events-auto
                        animate-in slide-in-from-bottom-4 fade-in duration-300
                        ${t.type === "success"
                            ? "bg-emerald-50 border-emerald-200 text-emerald-800"
                            : "bg-red-50 border-red-200 text-red-800"
                        }
                    `}
                >
                    {t.type === "success"
                        ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />
                        : <XCircle className="w-4 h-4 text-red-500 shrink-0" />
                    }
                    {t.message}
                </div>
            ))}
        </div>
    )
}
