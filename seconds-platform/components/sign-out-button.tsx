"use client"

import { Button } from "@/components/ui/button"
import { LogOut } from "lucide-react"
import { useAuth } from "@/lib/auth-context"

export function SignOutButton() {
  const { signOutUser } = useAuth()

  return (
    <Button variant="outline" size="sm" onClick={signOutUser}>
      <LogOut className="h-4 w-4 mr-2" />
      Sign Out
    </Button>
  )
}
