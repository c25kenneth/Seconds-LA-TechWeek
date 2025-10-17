"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Users, ShoppingCart } from "lucide-react"
import { auth, db } from "@/lib/firebase"
import { GoogleAuthProvider, signInWithPopup } from "firebase/auth"
import { doc, setDoc, getDoc, serverTimestamp } from "firebase/firestore"
import { useAuth } from "@/lib/auth-context"

export const provider = new GoogleAuthProvider()

export const saveUserToFirestore = async (user, role) => {
  await setDoc(doc(db, "users", user.uid), {
    organizationName: user.displayName,
    role: role,
    updatedAt: serverTimestamp(),
    createdAt: serverTimestamp(),
  })
}

export const signInWithGoogle = async (router, role) => {
  try {
    const result = await signInWithPopup(auth, provider)
    const user = result.user
    const userRef = doc(db, "users", user.uid)
    const userSnap = await getDoc(userRef)

    if (userSnap.exists()) {
      console.log("✅ User already exists in Firestore.")
    } else {
      console.log("🆕 New user — creating Firestore document.")
      await saveUserToFirestore(user, role)
    }
    console.log("User signed in:", user)
    router.push(`/${role}`)
    return user
  } catch (error) {
    console.error("Google Sign-In Error:", error)
  }
}

export default function SignInPage() {
  const roleParam = typeof window !== "undefined" ? window.location.href.split("?role=")[1] : undefined
  const router = useRouter()
  const [role, setRole] = useState<"supplier" | "consumer">("supplier")
  const { user, userRole, loading } = useAuth()

  useEffect(() => {
    if (!loading && user && userRole) {
      router.push(`/${userRole}`)
    }
  }, [user, userRole, loading, router])

  const handleSignIn = (e: React.FormEvent) => {
    e.preventDefault()
  }

  if (loading) {
    return <div className="min-h-screen flex items-center justify-center">Loading...</div>
  }

  if (user) {
    return null
  }

  const roleOptions = [
    {
      value: "supplier",
      label: "Supplier",
      description: "For farms and grocery stores - List and manage surplus produce",
      icon: Users,
      color: "text-green-600",
      bgColor: "bg-green-100",
    },
    {
      value: "consumer",
      label: "Consumer",
      description: "For restaurants and food banks - Browse and claim quality produce",
      icon: ShoppingCart,
      color: "text-orange-600",
      bgColor: "bg-orange-100",
    },
  ]

  return (
    <div className="min-h-screen bg-gradient-to-b from-green-50 to-white flex items-center justify-center p-4">
      <Card className="w-full max-w-2xl">
        <CardHeader className="text-center">
          <div className="flex justify-center mb-4">
            <img
              src="/images/design-mode/AJfQ9KSlpUmEmU2R3cqhKN-KY1PPgjJudSOI_CWFtBtehHWuVkD9cpdEzrb2wYYmN0PKK26s_BnRAhOmCr0BsM2eQ-6I0No5qkZhUel5AU1YIub3DDFj5TH3KApDixzgV7tKnfB1SGtF4RKyhl0VVXiGwF5gY-5mMxhiA8O71Hf1hRkVJa3zkA%3Ds1024-rj.jpeg"
              alt="Seconds Logo"
              className="h-16 w-auto"
            />
          </div>
          <CardTitle className="text-2xl">Sign In to Seconds</CardTitle>
          <CardDescription>Choose your role and sign in to get started</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSignIn} className="space-y-6">
            <div className="space-y-3">
              <label className="text-base font-semibold">I am a...</label>
              <RadioGroup
                value={role}
                onValueChange={(value: any) => setRole(value)}
                className="grid grid-cols-1 md:grid-cols-2 gap-4"
                defaultValue={roleParam}
              >
                {roleOptions.map((option) => {
                  const Icon = option.icon
                  return (
                    <label
                      key={option.value}
                      className={`flex items-start gap-3 p-4 border-2 rounded-lg cursor-pointer transition-all ${
                        role === option.value ? "border-primary bg-primary/5" : "border-gray-200 hover:border-gray-300"
                      }`}
                    >
                      <RadioGroupItem value={option.value} id={option.value} className="mt-1" />
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <div className={`w-8 h-8 ${option.bgColor} rounded-lg flex items-center justify-center`}>
                            <Icon className={`h-4 w-4 ${option.color}`} />
                          </div>
                          <span className="font-semibold">{option.label}</span>
                        </div>
                        <p className="text-sm text-muted-foreground">{option.description}</p>
                      </div>
                    </label>
                  )
                })}
              </RadioGroup>
            </div>

            <div style={{ display: "flex", justifyContent: "center", marginTop: "20px" }}>
              <button
                onClick={() => signInWithGoogle(router, role)}
                style={{
                  backgroundColor: "#4285F4",
                  color: "#fff",
                  border: "none",
                  borderRadius: "6px",
                  padding: "10px 20px",
                  fontSize: "16px",
                  fontWeight: "500",
                  cursor: "pointer",
                  display: "flex",
                  alignItems: "center",
                  gap: "10px",
                  boxShadow: "0 2px 6px rgba(0,0,0,0.2)",
                  transition: "background-color 0.3s, transform 0.2s",
                }}
                onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = "#357ae8")}
                onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = "#4285F4")}
              >
                Sign in with Google
              </button>
            </div>

            <div className="text-center space-y-2">
              <Link href="/" className="text-sm text-muted-foreground hover:text-foreground block">
                Back to home
              </Link>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  )
}
