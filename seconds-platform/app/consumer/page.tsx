"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ArrowLeft, Search, ShoppingCart, Package, DollarSign, Leaf, Filter, CheckCircle2, Clock } from "lucide-react"
import { useToast } from "@/hooks/use-toast"
import { Toaster } from "@/components/ui/toaster"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { db } from "@/lib/firebase"
import { collection, getDocs, doc, updateDoc } from "firebase/firestore"
import { useAuth } from "@/lib/auth-context"
import { SignOutButton } from "@/components/sign-out-button"
import { useRouter } from "next/navigation"

interface ProduceItem {
  id: string
  name: string
  category: string
  quantity: number
  unit: string
  price: number
  description: string
  imageUrl: string
  aiGrade: string
  supplierName: string
  location: string
  co2Saved: number
  uploadedAt: Date
}

interface ClaimedItem extends ProduceItem {
  claimedAt: Date
  claimedQuantity: number
  status: "pending" | "confirmed" | "delivered"
}

export default function ConsumerDashboard() {
  const { toast } = useToast()
  const router = useRouter()
  const { user, userRole, loading: authLoading } = useAuth()
  const [searchQuery, setSearchQuery] = useState("")
  const [categoryFilter, setCategoryFilter] = useState("all")
  const [gradeFilter, setGradeFilter] = useState("all")
  const [availableProduce, setAvailableProduce] = useState([])
  const [claimedItems, setClaimedItems] = useState([])
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({})

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/signin")
    } else if (!authLoading && userRole && userRole !== "consumer") {
      router.push("/supplier")
    }
  }, [user, userRole, authLoading, router])

  useEffect(() => {
    if (!user) return

    const fetchIngredients = async () => {
      try {
        const querySnapshot = await getDocs(collection(db, "listings"))
        const supplierSnapshot = await getDocs(collection(db, "users"))
        const listings = querySnapshot.docs.map((doc) => {
          let supplierName = ""
          for (const i of supplierSnapshot.docs) {
            if (i.id == doc.data().supplierUID) {
              supplierName = i.data().organizationName
            }
          }
          return {
            id: doc.id,
            supplierName: supplierName,
            ...doc.data(),
          }
        })
        setAvailableProduce(listings.filter((val) => val.currentStatus.toLowerCase() == "available"))
        const tempStats = {
          totalClaimed: 0,
          totalSpent: 0,
          co2Saved: 0,
          pendingOrders: 0,
        }
        listings
          .filter((val) => val.currentStatus == user.uid)
          .forEach((val) => {
            tempStats.totalClaimed++
            tempStats.totalSpent += val.claimedQuantity * val.price
            tempStats.co2Saved += val.co2Saved
          })
        setStats(tempStats)
        setClaimedItems(listings.filter((val) => val.currentStatus == user.uid))
      } catch (error) {
        console.error("Error fetching ingredients:", error)
      } finally {
        setLoading(false)
      }
    }
    fetchIngredients()
  }, [user])

  const handleClaim = async (item, quantity) => {
    try {
      const listingRef = doc(db, "listings", item.id)
      await updateDoc(listingRef, {
        currentStatus: user.uid,
        claimedQuantity: quantity,
      })
    } catch (e) {
      console.log("Error claiming item:", e)
    }
    toast({
      title: "Produce Claimed Successfully!",
      description: `You've claimed ${quantity} ${item.unit} of ${item.title}. The supplier will be notified.`,
    })
  }

  const filteredProduce = availableProduce.filter((item) => {
    const matchesSearch = item.title.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesCategory = categoryFilter === "all" || item.category === categoryFilter
    const matchesGrade = gradeFilter === "all" || item.qualityScore === gradeFilter
    return matchesSearch && matchesCategory && matchesGrade
  })

  if (authLoading || loading) return <div className="min-h-screen flex items-center justify-center">Loading...</div>

  if (!user || userRole !== "consumer") return null

  return (
    <div className="min-h-screen bg-gray-50">
      <Toaster />
      <header className="bg-white border-b sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <Button variant="ghost" size="icon" asChild>
                <Link href="/">
                  <ArrowLeft className="h-5 w-5" />
                </Link>
              </Button>
              <div>
                <h1 className="text-xl font-bold">Consumer Dashboard</h1>
                <p className="text-sm text-muted-foreground">Browse and claim quality produce</p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Badge variant="outline" className="gap-1">
                <ShoppingCart className="h-3 w-3" />
                {stats.pendingOrders} Pending
              </Badge>
              <SignOutButton />
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <Card className="cursor-pointer hover:shadow-lg transition-shadow">
            <CardHeader className="pb-3">
              <CardDescription>Total Claimed</CardDescription>
              <CardTitle className="text-3xl">{stats.totalClaimed}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <Package className="h-4 w-4" />
                <span>Orders</span>
              </div>
            </CardContent>
          </Card>

          <Card className="cursor-pointer hover:shadow-lg transition-shadow">
            <CardHeader className="pb-3">
              <CardDescription>Total Spent</CardDescription>
              <CardTitle className="text-3xl">${stats.totalSpent.toFixed(2)}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2 text-sm text-orange-600">
                <DollarSign className="h-4 w-4" />
                <span>On rescued produce</span>
              </div>
            </CardContent>
          </Card>

          <Card className="cursor-pointer hover:shadow-lg transition-shadow">
            <CardHeader className="pb-3">
              <CardDescription>CO2 Saved</CardDescription>
              <CardTitle className="text-3xl">{stats.co2Saved.toFixed(2)}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <Leaf className="h-4 w-4 text-green-600" />
                <span>kg of emissions</span>
              </div>
            </CardContent>
          </Card>

          <Card className="cursor-pointer hover:shadow-lg transition-shadow">
            <CardHeader className="pb-3">
              <CardDescription>Pending Orders</CardDescription>
              <CardTitle className="text-3xl">{stats.pendingOrders}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <Clock className="h-4 w-4" />
                <span>Awaiting confirmation</span>
              </div>
            </CardContent>
          </Card>
        </div>

        <Tabs defaultValue="browse" className="space-y-6">
          <TabsList>
            <TabsTrigger value="browse">Browse Produce</TabsTrigger>
            <TabsTrigger value="claimed">My Orders ({claimedItems.length})</TabsTrigger>
          </TabsList>

          <TabsContent value="browse" className="space-y-6">
            <Card>
              <CardContent className="pt-6">
                <div className="flex flex-col md:flex-row gap-4">
                  <div className="flex-1 relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                    <Input
                      placeholder="Search produce..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="pl-10"
                    />
                  </div>
                  <div className="flex gap-2">
                    <Select value={categoryFilter} onValueChange={setCategoryFilter}>
                      <SelectTrigger className="w-[150px]">
                        <Filter className="h-4 w-4 mr-2" />
                        <SelectValue placeholder="Category" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Categories</SelectItem>
                        <SelectItem value="Fruits">Fruits</SelectItem>
                        <SelectItem value="Vegetables">Vegetables</SelectItem>
                        <SelectItem value="Herbs">Herbs</SelectItem>
                      </SelectContent>
                    </Select>
                    <Select value={gradeFilter} onValueChange={setGradeFilter}>
                      <SelectTrigger className="w-[130px]">
                        <SelectValue placeholder="Grade" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Grades</SelectItem>
                        <SelectItem value="A">Grade A</SelectItem>
                        <SelectItem value="A-">Grade A-</SelectItem>
                        <SelectItem value="B+">Grade B+</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </CardContent>
            </Card>

            <div>
              <h2 className="text-2xl font-bold mb-4">Available Produce ({filteredProduce.length})</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredProduce.map((item) => (
                  <ProduceCard key={item.id} item={item} onClaim={handleClaim} />
                ))}
              </div>
              {filteredProduce.length === 0 && (
                <Card className="p-12">
                  <div className="text-center text-muted-foreground">
                    <Package className="h-12 w-12 mx-auto mb-4 opacity-50" />
                    <p>No produce found matching your filters.</p>
                  </div>
                </Card>
              )}
            </div>
          </TabsContent>

          <TabsContent value="claimed" className="space-y-6">
            <div>
              <h2 className="text-2xl font-bold mb-4">My Orders</h2>
              <div className="space-y-4">
                {claimedItems.map((item) => (
                  <Card key={item.id}>
                    <CardContent className="pt-6">
                      <div className="flex flex-col md:flex-row gap-6">
                        <div className="w-full md:w-32 h-32 rounded-lg overflow-hidden bg-gray-100 flex-shrink-0">
                          <img
                            src={item.imageUrl || "/placeholder.svg"}
                            alt={item.title}
                            className="w-full h-full object-cover"
                          />
                        </div>
                        <div className="flex-1 space-y-3">
                          <div className="flex items-start justify-between">
                            <div>
                              <h3 className="text-lg font-semibold">{item.title}</h3>
                              <p className="text-sm text-muted-foreground">
                                From {item.supplierName} • {item.location}
                              </p>
                            </div>
                          </div>
                          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                            <div>
                              <p className="text-muted-foreground">Quantity</p>
                              <p className="font-medium">
                                {item.claimedQuantity} {item.unit}
                              </p>
                            </div>
                            <div>
                              <p className="text-muted-foreground">Total Cost</p>
                              <p className="font-medium text-orange-600">
                                ${(item.claimedQuantity * item.price).toFixed(2)}
                              </p>
                            </div>
                            <div>
                              <p className="text-muted-foreground">AI Grade</p>
                              <p className="font-medium">{item.aiGrade}</p>
                            </div>
                            <div>
                              <p className="text-muted-foreground">Claimed</p>
                              <p className="font-medium">Test Date</p>
                            </div>
                          </div>
                          <div className="flex items-center gap-2 text-sm text-green-600">
                            <Leaf className="h-4 w-4" />
                            <span>
                              {((item.co2Saved * item.claimedQuantity) / item.quantity).toFixed(2)}kg CO2 saved
                            </span>
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))}
                {claimedItems.length === 0 && (
                  <Card className="p-12">
                    <div className="text-center text-muted-foreground">
                      <ShoppingCart className="h-12 w-12 mx-auto mb-4 opacity-50" />
                      <p>You haven't claimed any produce yet.</p>
                      <p className="text-sm mt-2">Browse available produce to get started!</p>
                    </div>
                  </Card>
                )}
              </div>
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}

function ProduceCard({
  item,
  onClaim,
}: {
  item: ProduceItem
  onClaim: (item: ProduceItem, quantity: number) => void
}) {
  const [showClaimDialog, setShowClaimDialog] = useState(false)
  const [claimQuantity, setClaimQuantity] = useState(item.quantity)

  const handleClaim = () => {
    onClaim(item, claimQuantity)
    setShowClaimDialog(false)
    setClaimQuantity(item.quantity)
  }

  return (
    <Card className="overflow-hidden hover:shadow-lg transition-shadow">
      <div className="aspect-video relative bg-gray-100">
        <img src={item.imageUrl || "/placeholder.svg"} alt={item.title} className="w-full h-full object-cover" />
        <div className="absolute top-3 right-3">
          <Badge className="bg-white text-foreground border">AI Grade: {item.aiGrade}</Badge>
        </div>
      </div>
      <CardHeader>
        <div className="flex items-start justify-between">
          <div>
            <CardTitle className="text-lg">{item.name}</CardTitle>
            <CardDescription>{item.category}</CardDescription>
          </div>
          <div className="text-right">
            <div className="text-lg font-bold text-orange-600">${item.price.toFixed(2)}</div>
            <div className="text-xs text-muted-foreground">per {item.unit}</div>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        <p className="text-sm text-muted-foreground">{item.description}</p>
        <div className="space-y-2 text-sm">
          <div className="flex items-center justify-between">
            <span className="text-muted-foreground">Available:</span>
            <span className="font-medium">
              {item.quantity} {item.unit}
            </span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-muted-foreground">From:</span>
            <span className="font-medium">{item.supplierName}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-muted-foreground">Location:</span>
            <span className="font-medium">{item.location}</span>
          </div>
          <div className="flex items-center justify-between text-green-600">
            <span className="flex items-center gap-1">
              <Leaf className="h-3 w-3" />
              CO2 Saved:
            </span>
            <span className="font-medium">{item.co2Saved}kg</span>
          </div>
        </div>

        {!showClaimDialog ? (
          <Button onClick={() => setShowClaimDialog(true)} className="w-full bg-orange-600 hover:bg-orange-700">
            <ShoppingCart className="h-4 w-4 mr-2" />
            Claim Produce
          </Button>
        ) : (
          <div className="space-y-3 pt-2 border-t">
            <div className="space-y-2">
              <label className="text-sm font-medium">Quantity ({item.unit})</label>
              <Input
                type="number"
                min="1"
                max={item.quantity}
                value={claimQuantity}
                onChange={(e) => setClaimQuantity(Number(e.target.value))}
              />
              <p className="text-xs text-muted-foreground">Total: ${(claimQuantity * item.price).toFixed(2)}</p>
            </div>
            <div className="flex gap-2">
              <Button
                onClick={() => handleClaim(item, claimQuantity)}
                className="flex-1 bg-green-600 hover:bg-green-700"
              >
                <CheckCircle2 className="h-4 w-4 mr-2" />
                Confirm
              </Button>
              <Button variant="outline" onClick={() => setShowClaimDialog(false)} className="flex-1">
                Cancel
              </Button>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
