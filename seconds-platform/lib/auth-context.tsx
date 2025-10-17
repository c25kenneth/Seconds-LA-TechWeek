"use client"

import type React from "react"

import { createContext, useContext, useEffect, useState } from "react"
import { onAuthStateChanged, signOut, type User } from "firebase/auth"
import { doc, getDoc } from "firebase/firestore"
import { useRouter } from "next/navigation"
import { auth, db } from "./firebase"

interface AuthContextType {
  user: User | null
  userRole: "supplier" | "consumer" | null
  loading: boolean
  signOutUser: () => Promise<void>
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  userRole: null,
  loading: true,
  signOutUser: async () => {},
})

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [userRole, setUserRole] = useState<"supplier" | "consumer" | null>(null)
  const [loading, setLoading] = useState(true)
  const router = useRouter()

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      setUser(currentUser)

      if (currentUser) {
        // Fetch user role from Firestore
        try {
          const userDoc = await getDoc(doc(db, "users", currentUser.uid))
          if (userDoc.exists()) {
            const role = userDoc.data().role as "supplier" | "consumer"
            setUserRole(role)
          }
        } catch (error) {
          console.error("Error fetching user role:", error)
        }
      } else {
        setUserRole(null)
      }

      setLoading(false)
    })

    return () => unsubscribe()
  }, [])

  const signOutUser = async () => {
    await signOut(auth)
    setUser(null)
    setUserRole(null)
    router.push("/signin")
  }

  return <AuthContext.Provider value={{ user, userRole, loading, signOutUser }}>{children}</AuthContext.Provider>
}

export function useAuth() {
  return useContext(AuthContext)
}
