"use client"

import type React from "react"
import { useState, useEffect, useRef } from "react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Badge } from "@/components/ui/badge"
import { ArrowLeft, Upload, Package, DollarSign, TrendingUp, Leaf, Camera } from "lucide-react"
import { useToast } from "@/hooks/use-toast"
import { Toaster } from "@/components/ui/toaster"
import { db, storage } from "@/lib/firebase"
import { collection, getDocs, addDoc, serverTimestamp, query, where } from "firebase/firestore"
import { ref, uploadString, getDownloadURL } from "firebase/storage"
import { useAuth } from "@/lib/auth-context"
import { SignOutButton } from "@/components/sign-out-button"
import { useRouter } from "next/navigation"

export default function SupplierDashboard() {
  const { toast } = useToast()
  const router = useRouter()
  const { user, userRole, loading: authLoading } = useAuth()
  const [showUploadForm, setShowUploadForm] = useState(false)
  const [isUploading, setIsUploading] = useState(false)
  const [imagePreview, setImagePreview] = useState<string>("")
  const [imageFile, setImageFile] = useState<File | null>(null)
  const [produceItems, setProduceItems] = useState([])
  const [loading, setLoading] = useState(true)
  const [showCamera, setShowCamera] = useState(false)
  const videoRef = useRef<HTMLVideoElement>(null)
  const streamRef = useRef<MediaStream | null>(null)

  const [formData, setFormData] = useState({
    name: "",
    quantity: "",
    unit: "lbs",
    retailPrice: "",
    description: "",
    expiresIn: "",
    pickupLocation: "",
  })

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/signin")
    } else if (!authLoading && userRole && userRole !== "supplier") {
      router.push("/consumer")
    }
  }, [user, userRole, authLoading, router])

  useEffect(() => {
    if (!user) return

    const fetchIngredients = async () => {
      try {
        const q = query(collection(db, "listings"), where("supplierUID", "==", user.uid))
        const querySnapshot = await getDocs(q)
        const listings = querySnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }))
        setProduceItems(listings)
      } catch (error) {
        console.error("Error fetching ingredients:", error)
      } finally {
        setLoading(false)
      }
    }
    fetchIngredients()
  }, [user])

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setImageFile(file)
      const reader = new FileReader()
      reader.onloadend = () => {
        setImagePreview(reader.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const startCamera = async () => {
    try {
      console.log("[v0] Requesting camera access...")
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: "environment",
          width: { ideal: 1280 },
          height: { ideal: 720 },
        },
      })
      console.log("[v0] Camera stream obtained:", stream)

      if (videoRef.current) {
        videoRef.current.srcObject = stream
        streamRef.current = stream

        // Explicitly play the video
        try {
          await videoRef.current.play()
          console.log("[v0] Video playing successfully")
        } catch (playError) {
          console.error("[v0] Error playing video:", playError)
        }
      }
      setShowCamera(true)
    } catch (error) {
      console.error("[v0] Error accessing camera:", error)
      toast({
        title: "Camera Error",
        description: "Unable to access camera. Please check permissions.",
        variant: "destructive",
      })
    }
  }

  const capturePhoto = () => {
    if (videoRef.current) {
      const canvas = document.createElement("canvas")
      canvas.width = videoRef.current.videoWidth
      canvas.height = videoRef.current.videoHeight
      const ctx = canvas.getContext("2d")
      if (ctx) {
        ctx.drawImage(videoRef.current, 0, 0)
        const dataUrl = canvas.toDataURL("image/jpeg")
        setImagePreview(dataUrl)

        fetch(dataUrl)
          .then((res) => res.blob())
          .then((blob) => {
            const file = new File([blob], `camera-${Date.now()}.jpg`, { type: "image/jpeg" })
            setImageFile(file)
          })

        stopCamera()
      }
    }
  }

  const stopCamera = () => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop())
      streamRef.current = null
    }
    if (videoRef.current) {
      videoRef.current.srcObject = null
    }
    setShowCamera(false)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsUploading(true)

    try {
      let qualityScore = "5/10"
      let aiGradeNumber = 5
      let imageUrl = imagePreview

      if (imageFile && imagePreview) {
        try {
          const storageRef = ref(storage, `produce-images/${Date.now()}_${imageFile.name}`)
          await uploadString(storageRef, imagePreview, "data_url")
          imageUrl = await getDownloadURL(storageRef)
        } catch (error) {
          console.error("Error uploading image:", error)
        }
      }

      if (imageFile) {
        try {
          const formDataAPI = new FormData()
          formDataAPI.append("file", imageFile)

          const response = await fetch("https://streakiest-exigent-dustin.ngrok-free.dev/predict", {
            method: "POST",
            body: formDataAPI,
          })

          if (response.ok) {
            const result = await response.json()

            const classification = result.prediction || result.class || result.classification || ""
            const isHealthy = classification.toLowerCase().includes("healthy")
            const isRotten = classification.toLowerCase().includes("rotten")

            if (isHealthy) {
              aiGradeNumber = Math.floor(Math.random() * 4) + 6
              qualityScore = `${aiGradeNumber}/10`
            } else if (isRotten) {
              aiGradeNumber = Math.floor(Math.random() * 2) + 1
              qualityScore = `${aiGradeNumber}/10`
            }
          } else {
            console.error("API request failed:", response.statusText)
          }
        } catch (error) {
          console.error("Error calling classification API:", error)
        }
      }

      const retailPrice = Number.parseFloat(formData.retailPrice)
      const finalPrice = (retailPrice / 2) * (aiGradeNumber / 10)

      const listingData = {
        additionalNotes: formData.description,
        co2Saved: 0.2,
        currentStatus: "Available",
        expirationDate: formData.expiresIn,
        imageUrl: imageUrl,
        listingAdded: serverTimestamp(),
        pickupLocation: formData.pickupLocation,
        price: finalPrice,
        qualityScore: qualityScore,
        quantity: `${formData.quantity} ${formData.unit}`,
        supplierUID: user?.uid || "unknown",
        title: formData.name,
      }

      await addDoc(collection(db, "listings"), listingData)

      const q = query(collection(db, "listings"), where("supplierUID", "==", user.uid))
      const querySnapshot = await getDocs(q)
      const listings = querySnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }))
      setProduceItems(listings)

      setIsUploading(false)
      setShowUploadForm(false)
      setImagePreview("")
      setImageFile(null)
      setFormData({
        name: "",
        quantity: "",
        unit: "lbs",
        retailPrice: "",
        description: "",
        expiresIn: "",
        pickupLocation: "",
      })

      toast({
        title: "Produce Listed Successfully!",
        description: `AI Grade: ${qualityScore} - Your ${formData.name} is now available for claiming.`,
      })
    } catch (error) {
      console.error("Error submitting form:", error)
      setIsUploading(false)
      toast({
        title: "Error",
        description: "Failed to list produce. Please try again.",
        variant: "destructive",
      })
    }
  }

  const stats = {
    totalListed: produceItems.length,
    totalRevenue: produceItems
      .filter((item) => item.currentStatus !== "Available")
      .reduce((sum, item) => sum + (item.price || 0), 0),
    co2Saved: produceItems.reduce((sum, item) => sum + item.co2Saved, 0),
    activeListings: produceItems.filter((item) => item.currentStatus === "Available").length,
  }

  if (authLoading || loading) return <div className="min-h-screen flex items-center justify-center">Loading...</div>

  if (!user || userRole !== "supplier") return null

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
                <h1 className="text-xl font-bold">Supplier Dashboard</h1>
                <p className="text-sm text-muted-foreground">
                  For farms and grocery stores - Manage your surplus produce
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Button onClick={() => setShowUploadForm(true)} className="bg-green-600 hover:bg-green-700">
                <Upload className="h-4 w-4 mr-2" />
                Upload Produce
              </Button>
              <SignOutButton />
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <Card className="cursor-pointer hover:shadow-lg transition-shadow">
            <CardHeader className="pb-3">
              <CardDescription>Total Listed</CardDescription>
              <CardTitle className="text-3xl">{stats.totalListed}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <Package className="h-4 w-4" />
                <span>Items</span>
              </div>
            </CardContent>
          </Card>

          <Card className="cursor-pointer hover:shadow-lg transition-shadow">
            <CardHeader className="pb-3">
              <CardDescription>Revenue Generated</CardDescription>
              <CardTitle className="text-3xl">${stats.totalRevenue.toFixed(2)}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2 text-sm text-green-600">
                <DollarSign className="h-4 w-4" />
                <span>From rescued produce</span>
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
              <CardDescription>Active Listings</CardDescription>
              <CardTitle className="text-3xl">{stats.activeListings}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <TrendingUp className="h-4 w-4" />
                <span>Available now</span>
              </div>
            </CardContent>
          </Card>
        </div>

        {showUploadForm && (
          <Card className="mb-8">
            <CardHeader>
              <CardTitle>Upload New Produce</CardTitle>
              <CardDescription>Add details about your surplus produce for AI grading</CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <Label htmlFor="name">Produce Name *</Label>
                    <Input
                      id="name"
                      placeholder="e.g., Heirloom Tomatoes"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="quantity">Quantity *</Label>
                    <Input
                      id="quantity"
                      type="number"
                      placeholder="100"
                      value={formData.quantity}
                      onChange={(e) => setFormData({ ...formData, quantity: e.target.value })}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="unit">Unit *</Label>
                    <Select value={formData.unit} onValueChange={(value) => setFormData({ ...formData, unit: value })}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="lbs">Pounds (lbs)</SelectItem>
                        <SelectItem value="kg">Kilograms (kg)</SelectItem>
                        <SelectItem value="units">Units</SelectItem>
                        <SelectItem value="boxes">Boxes</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="retailPrice">Retail Price per Unit ($) *</Label>
                    <Input
                      id="retailPrice"
                      type="number"
                      step="0.01"
                      placeholder="1.50"
                      value={formData.retailPrice}
                      onChange={(e) => setFormData({ ...formData, retailPrice: e.target.value })}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="expiresIn">Expires In *</Label>
                    <Input
                      id="expiresIn"
                      placeholder="e.g., 3 days, 1 week"
                      value={formData.expiresIn}
                      onChange={(e) => setFormData({ ...formData, expiresIn: e.target.value })}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="pickupLocation">Pickup Location *</Label>
                    <Input
                      id="pickupLocation"
                      placeholder="e.g., 123 Farm Road, City, State"
                      value={formData.pickupLocation}
                      onChange={(e) => setFormData({ ...formData, pickupLocation: e.target.value })}
                      required
                    />
                  </div>

                  <div className="space-y-2 md:col-span-2">
                    <Label htmlFor="image">Upload Image</Label>
                    <div className="flex items-center gap-4">
                      <Input id="image" type="file" accept="image/*" onChange={handleImageUpload} className="flex-1" />
                      <Button type="button" variant="outline" onClick={startCamera}>
                        <Camera className="h-4 w-4 mr-2" />
                        Camera
                      </Button>
                      {imagePreview && (
                        <div className="w-16 h-16 rounded-lg overflow-hidden border">
                          <img
                            src={imagePreview || "/placeholder.svg"}
                            alt="Preview"
                            className="w-full h-full object-cover"
                          />
                        </div>
                      )}
                    </div>

                    {showCamera && (
                      <div className="mt-4 space-y-2">
                        <video
                          ref={videoRef}
                          autoPlay
                          playsInline
                          muted
                          className="w-full rounded-lg border bg-black"
                          style={{ minHeight: "300px", maxHeight: "500px" }}
                        />
                        <div className="flex gap-2">
                          <Button type="button" onClick={capturePhoto} className="flex-1">
                            Capture Photo
                          </Button>
                          <Button type="button" variant="outline" onClick={stopCamera}>
                            Cancel
                          </Button>
                        </div>
                      </div>
                    )}
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="description">Description *</Label>
                  <Textarea
                    id="description"
                    placeholder="Describe the condition, any imperfections, and best uses..."
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    rows={3}
                    required
                  />
                </div>

                <div className="flex gap-3">
                  <Button type="submit" disabled={isUploading} className="bg-green-600 hover:bg-green-700">
                    {isUploading ? (
                      <>
                        <span className="animate-spin mr-2">⏳</span>
                        AI Grading in Progress...
                      </>
                    ) : (
                      <>
                        <Upload className="h-4 w-4 mr-2" />
                        Upload & Grade
                      </>
                    )}
                  </Button>
                  <Button type="button" variant="outline" onClick={() => setShowUploadForm(false)}>
                    Cancel
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        )}

        <div>
          <h2 className="text-2xl font-bold mb-4">Your Produce Listings</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {produceItems.map((item) => (
              <Card key={item.id} className="overflow-hidden">
                <div className="aspect-video relative bg-gray-100">
                  <img
                    src={item.imageUrl || "/placeholder.svg"}
                    alt={item.title}
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute top-3 right-3 flex gap-2">
                    <Badge className="bg-white text-foreground border">AI Grade: {item.qualityScore}</Badge>
                    <Badge
                      variant={item.currentStatus === "Available" ? "default" : "secondary"}
                      className={item.currentStatus === "Available" ? "bg-green-600" : "bg-orange-600"}
                    >
                      {item.currentStatus === "Available" ? "Available" : "Sold"}
                    </Badge>
                  </div>
                </div>
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div>
                      <CardTitle className="text-lg">{item.title}</CardTitle>
                    </div>
                    <div className="text-right">
                      <div className="text-lg font-bold text-green-600">${item.price.toFixed(2)}</div>
                      <div className="text-xs text-muted-foreground">per unit</div>
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <p className="text-sm text-muted-foreground mb-4">{item.additionalNotes || item.description}</p>
                  <div className="flex items-center justify-between text-sm">
                    <div>
                      <span className="font-medium">{item.quantity}</span>
                    </div>
                    <div className="flex items-center gap-1 text-green-600">
                      <Leaf className="h-3 w-3" />
                      <span className="text-xs">{item.co2Saved}kg CO2</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
