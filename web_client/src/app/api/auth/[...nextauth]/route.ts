import NextAuth, { NextAuthOptions } from "next-auth"
import CredentialsProvider from "next-auth/providers/credentials"
import bcrypt from "bcryptjs"
import prisma from "@/lib/prisma"

export const authOptions: NextAuthOptions = {
    providers: [
        CredentialsProvider({
            name: "Credentials",
            credentials: {
                email: { label: "Email", type: "email" },
                password: { label: "Password", type: "password" }
            },
            async authorize(credentials) {
                console.log("Login attempt for:", credentials?.email)
                if (!credentials?.email || !credentials?.password) {
                    console.log("Missing email or password")
                    throw new Error("Invalid credentials")
                }

                const user = await prisma.user.findUnique({
                    where: { email: credentials.email }
                })

                if (!user) {
                    console.log("User not found")
                    throw new Error("No user found")
                }

                if (!user.passwordHash) {
                    console.log("User has no password hash")
                    throw new Error("Invalid credentials")
                }

                const isCorrectPassword = await bcrypt.compare(
                    credentials.password,
                    user.passwordHash
                )

                if (!isCorrectPassword) {
                    console.log("Incorrect password")
                    throw new Error("Invalid credentials")
                }

                console.log("Login successful for:", user.email)
                return {
                    id: user.id,
                    email: user.email,
                    role: user.role,
                }
            }
        })
    ],
    callbacks: {
        async jwt({ token, user }) {
            if (user) {
                token.role = user.role
                token.id = user.id
            }
            return token
        },
        async session({ session, token }) {
            if (session.user) {
                (session.user as any).role = token.role;
                (session.user as any).id = token.id;
            }
            return session
        }
    },
    pages: {
        signIn: '/login',
    },
    session: {
        strategy: "jwt",
    },
    secret: process.env.NEXTAUTH_SECRET || "fallback_secret_for_local_dev",
}

const handler = NextAuth(authOptions)

export { handler as GET, handler as POST }
