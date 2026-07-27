"use client"

import { useState, useRef } from "react"
import { X, Upload, FileSpreadsheet, AlertTriangle, CheckCircle2, Loader2, Download } from "lucide-react"
import { Button } from "@/components/ui/Button"
import Papa from "papaparse"

interface BulkImportModalProps {
    isOpen: boolean
    onClose: () => void
    onImport: (data: any[]) => Promise<{ error?: string; success?: boolean }>
}

export function BulkImportModal({ isOpen, onClose, onImport }: BulkImportModalProps) {
    const [file, setFile] = useState<File | null>(null)
    const [parsedData, setParsedData] = useState<any[]>([])
    const [errors, setErrors] = useState<string[]>([])
    const [isImporting, setIsImporting] = useState(false)
    const [importResult, setImportResult] = useState<{ success?: boolean; error?: string } | null>(null)
    const fileInputRef = useRef<HTMLInputElement>(null)

    if (!isOpen) return null

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const selectedFile = e.target.files?.[0]
        if (!selectedFile) return

        setFile(selectedFile)
        setErrors([])
        setImportResult(null)

        Papa.parse(selectedFile, {
            header: true,
            skipEmptyLines: true,
            complete: (results) => {
                const data = results.data as any[]
                const validationErrors: string[] = []

                // Validate required columns
                const requiredColumns = ["Subject Name", "Subject Code", "Hours Per Week", "Department Code", "Class Name"]
                const missingColumns = requiredColumns.filter(col => !results.meta.fields?.includes(col))

                if (missingColumns.length > 0) {
                    validationErrors.push(`Missing required columns: ${missingColumns.join(", ")}`)
                    setParsedData([])
                } else {
                    // Basic row validation
                    data.forEach((row, index) => {
                        if (!row["Subject Name"] || !row["Subject Code"] || !row["Department Code"] || !row["Class Name"]) {
                            validationErrors.push(`Row ${index + 1}: Missing required fields.`)
                        }
                    })
                    setParsedData(data)
                }

                setErrors(validationErrors)
            },
            error: (error) => {
                setErrors([`Error parsing CSV: ${error.message}`])
            }
        })
    }

    const handleImport = async () => {
        if (parsedData.length === 0 || errors.length > 0) return

        setIsImporting(true)
        setImportResult(null)

        try {
            const result = await onImport(parsedData)
            setImportResult(result)
            if (result.success) {
                setTimeout(() => {
                    onClose()
                    setFile(null)
                    setParsedData([])
                    setImportResult(null)
                }, 2000)
            }
        } catch (err: any) {
            setImportResult({ error: err.message || "An unexpected error occurred." })
        } finally {
            setIsImporting(false)
        }
    }

    const downloadTemplate = () => {
        const csvContent = "Subject Name,Subject Code,Hours Per Week,Department Code,Class Name\nData Structures,CS201,4,CSE,2nd Year A\nComputer Networks,CS301,3,CSE,3rd Year A"
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
        const link = document.createElement("a")
        const url = URL.createObjectURL(blob)
        link.setAttribute("href", url)
        link.setAttribute("download", "subject_import_template.csv")
        link.style.visibility = 'hidden'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
    }

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
            <div className="bg-slate-900 border border-slate-800 rounded-xl shadow-2xl w-full max-w-3xl max-h-[90vh] flex flex-col animate-in zoom-in-95 duration-200">
                <div className="flex items-center justify-between p-6 border-b border-slate-800">
                    <div>
                        <h2 className="text-xl font-bold text-slate-50">Bulk Import Subjects</h2>
                        <p className="text-sm text-slate-400 mt-1">Upload a CSV file to add multiple subjects at once.</p>
                    </div>
                    <button onClick={onClose} className="text-slate-400 hover:text-slate-200 transition-colors">
                        <X className="w-5 h-5" />
                    </button>
                </div>

                <div className="p-6 flex-1 overflow-y-auto space-y-6">
                    {/* File Upload Area */}
                    {!file && (
                        <div
                            className="border-2 border-dashed border-slate-700 rounded-xl p-12 flex flex-col items-center justify-center text-center hover:bg-slate-800/50 transition-colors cursor-pointer"
                            onClick={() => fileInputRef.current?.click()}
                        >
                            <div className="bg-indigo-500/10 p-4 rounded-full mb-4">
                                <Upload className="w-8 h-8 text-indigo-400" />
                            </div>
                            <h3 className="text-lg font-semibold text-slate-200 mb-2">Click to upload CSV</h3>
                            <p className="text-sm text-slate-400 max-w-md mx-auto mb-6">
                                Make sure your CSV matches the required format. You can download the template below to get started.
                            </p>
                            <Button variant="outline" className="border-slate-700 hover:bg-slate-800" onClick={(e) => { e.stopPropagation(); downloadTemplate(); }}>
                                <Download className="w-4 h-4 mr-2" /> Download Template
                            </Button>
                            <input
                                type="file"
                                accept=".csv"
                                className="hidden"
                                ref={fileInputRef}
                                onChange={handleFileChange}
                            />
                        </div>
                    )}

                    {/* File Selected State */}
                    {file && (
                        <div className="space-y-6">
                            <div className="flex items-center justify-between p-4 bg-slate-800/50 rounded-lg border border-slate-700">
                                <div className="flex items-center gap-3">
                                    <FileSpreadsheet className="w-8 h-8 text-emerald-400" />
                                    <div>
                                        <p className="font-medium text-slate-200">{file.name}</p>
                                        <p className="text-xs text-slate-400">{(file.size / 1024).toFixed(2)} KB • {parsedData.length} rows found</p>
                                    </div>
                                </div>
                                <Button variant="ghost" size="sm" className="text-slate-400 hover:text-red-400" onClick={() => { setFile(null); setParsedData([]); setErrors([]); setImportResult(null); }}>
                                    Remove
                                </Button>
                            </div>

                            {/* Errors */}
                            {errors.length > 0 && (
                                <div className="p-4 bg-red-500/10 border border-red-500/20 rounded-lg space-y-2">
                                    <div className="flex items-center gap-2 text-red-400 font-semibold mb-2">
                                        <AlertTriangle className="w-5 h-5" />
                                        <span>Validation Errors Found</span>
                                    </div>
                                    <ul className="list-disc list-inside text-sm text-red-400/80 space-y-1">
                                        {errors.map((err, i) => <li key={i}>{err}</li>)}
                                    </ul>
                                </div>
                            )}

                            {/* Import Result */}
                            {importResult && (
                                <div className={`p-4 rounded-lg border flex items-start gap-3 ${importResult.success ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-400' : 'bg-red-500/10 border-red-500/20 text-red-400'}`}>
                                    {importResult.success ? <CheckCircle2 className="w-5 h-5 mt-0.5" /> : <AlertTriangle className="w-5 h-5 mt-0.5" />}
                                    <div>
                                        <p className="font-semibold">{importResult.success ? 'Import Successful!' : 'Import Failed'}</p>
                                        {importResult.error && <p className="text-sm mt-1 opacity-90">{importResult.error}</p>}
                                    </div>
                                </div>
                            )}

                            {/* Data Preview */}
                            {parsedData.length > 0 && errors.length === 0 && (
                                <div className="space-y-3">
                                    <h3 className="text-sm font-semibold text-slate-300">Data Preview (First 5 rows)</h3>
                                    <div className="overflow-x-auto border border-slate-800 rounded-lg">
                                        <table className="w-full text-sm text-left">
                                            <thead className="text-xs text-slate-400 uppercase bg-slate-900/50 border-b border-slate-800">
                                                <tr>
                                                    <th className="px-4 py-3">Subject Name</th>
                                                    <th className="px-4 py-3">Code</th>
                                                    <th className="px-4 py-3">Hrs/Wk</th>
                                                    <th className="px-4 py-3">Dept</th>
                                                    <th className="px-4 py-3">Class</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-slate-800/50">
                                                {parsedData.slice(0, 5).map((row, i) => (
                                                    <tr key={i} className="bg-slate-900/20">
                                                        <td className="px-4 py-3 text-slate-200">{row["Subject Name"]}</td>
                                                        <td className="px-4 py-3 text-indigo-400">{row["Subject Code"]}</td>
                                                        <td className="px-4 py-3 text-slate-300">{row["Hours Per Week"]}</td>
                                                        <td className="px-4 py-3 text-slate-300">{row["Department Code"]}</td>
                                                        <td className="px-4 py-3 text-slate-300">{row["Class Name"]}</td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                    {parsedData.length > 5 && (
                                        <p className="text-xs text-slate-500 text-center">...and {parsedData.length - 5} more rows.</p>
                                    )}
                                </div>
                            )}
                        </div>
                    )}
                </div>

                <div className="p-6 border-t border-slate-800 flex justify-end gap-3 bg-slate-900/50">
                    <Button variant="ghost" onClick={onClose} disabled={isImporting}>
                        Cancel
                    </Button>
                    <Button
                        className="bg-indigo-600 hover:bg-indigo-700"
                        disabled={!file || errors.length > 0 || isImporting || importResult?.success}
                        onClick={handleImport}
                    >
                        {isImporting ? (
                            <><Loader2 className="w-4 h-4 mr-2 animate-spin" /> Importing...</>
                        ) : importResult?.success ? (
                            <><CheckCircle2 className="w-4 h-4 mr-2" /> Done</>
                        ) : (
                            <><Upload className="w-4 h-4 mr-2" /> Import {parsedData.length > 0 ? `${parsedData.length} Subjects` : ''}</>
                        )}
                    </Button>
                </div>
            </div>
        </div>
    )
}
