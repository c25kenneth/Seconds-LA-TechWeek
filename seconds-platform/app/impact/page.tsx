"use client"

import { useState } from "react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ArrowLeft, Leaf, Droplets, Trash2, Car, TreePine, Flower as Shower, Users, Award } from "lucide-react"

export default function ImpactDashboard() {
  // Mock aggregated data from the platform
  const [timeRange, setTimeRange] = useState<"week" | "month" | "year" | "all">("month")

  const impactData = {
    week: {
      co2Saved: 156.3,
      waterSaved: 18750,
      landSaved: 625,
      wasteReduced: 625,
      itemsRescued: 42,
      farmersHelped: 8,
      mealsProvided: 2500,
      carsMiles: 386.9,
      treesPlanted: 7.4,
      showerDays: 1090,
    },
    month: {
      co2Saved: 687.5,
      waterSaved: 82500,
      landSaved: 2750,
      wasteReduced: 2750,
      itemsRescued: 183,
      farmersHelped: 24,
      mealsProvided: 11000,
      carsMiles: 1701.7,
      treesPlanted: 32.7,
      showerDays: 4796,
    },
    year: {
      co2Saved: 8250,
      waterSaved: 990000,
      landSaved: 33000,
      wasteReduced: 33000,
      itemsRescued: 2196,
      farmersHelped: 156,
      mealsProvided: 132000,
      carsMiles: 20420.3,
      treesPlanted: 392.9,
      showerDays: 57558,
    },
    all: {
      co2Saved: 12375,
      waterSaved: 1485000,
      landSaved: 49500,
      wasteReduced: 49500,
      itemsRescued: 3294,
      farmersHelped: 234,
      mealsProvided: 198000,
      carsMiles: 30630.4,
      treesPlanted: 589.3,
      showerDays: 86337,
    },
  }

  const data = impactData[timeRange]

  // Calculate progress towards annual goals
  const annualGoals = {
    co2: 10000,
    water: 1200000,
    waste: 40000,
    meals: 150000,
  }

  const progress = {
    co2: (data.co2Saved / annualGoals.co2) * 100,
    water: (data.waterSaved / annualGoals.water) * 100,
    waste: (data.wasteReduced / annualGoals.waste) * 100,
    meals: (data.mealsProvided / annualGoals.meals) * 100,
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-green-50 to-white">
      {/* Header */}
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
                <h1 className="text-xl font-bold">Environmental Impact Dashboard</h1>
                <p className="text-sm text-muted-foreground">Track the positive change we're making together</p>
              </div>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Time Range Selector */}
        <div className="flex justify-center mb-8">
          <div className="inline-flex rounded-lg border bg-white p-1">
            <Button
              variant={timeRange === "week" ? "default" : "ghost"}
              size="sm"
              onClick={() => setTimeRange("week")}
              className={timeRange === "week" ? "bg-green-600" : ""}
            >
              This Week
            </Button>
            <Button
              variant={timeRange === "month" ? "default" : "ghost"}
              size="sm"
              onClick={() => setTimeRange("month")}
              className={timeRange === "month" ? "bg-green-600" : ""}
            >
              This Month
            </Button>
            <Button
              variant={timeRange === "year" ? "default" : "ghost"}
              size="sm"
              onClick={() => setTimeRange("year")}
              className={timeRange === "year" ? "bg-green-600" : ""}
            >
              This Year
            </Button>
            <Button
              variant={timeRange === "all" ? "default" : "ghost"}
              size="sm"
              onClick={() => setTimeRange("all")}
              className={timeRange === "all" ? "bg-green-600" : ""}
            >
              All Time
            </Button>
          </div>
        </div>

        {/* Hero Stats */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <Card className="bg-gradient-to-br from-green-500 to-green-600 text-white">
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <CardDescription className="text-green-50">CO2 Emissions Saved</CardDescription>
                <Leaf className="h-8 w-8 text-green-100" />
              </div>
              <CardTitle className="text-4xl">{data.co2Saved.toLocaleString()}</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-green-50">kg of greenhouse gases</p>
            </CardContent>
          </Card>

          <Card className="bg-gradient-to-br from-blue-500 to-blue-600 text-white">
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <CardDescription className="text-blue-50">Water Conserved</CardDescription>
                <Droplets className="h-8 w-8 text-blue-100" />
              </div>
              <CardTitle className="text-4xl">{data.waterSaved.toLocaleString()}</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-blue-50">gallons of fresh water</p>
            </CardContent>
          </Card>

          <Card className="bg-gradient-to-br from-orange-500 to-orange-600 text-white">
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <CardDescription className="text-orange-50">Food Waste Reduced</CardDescription>
                <Trash2 className="h-8 w-8 text-orange-100" />
              </div>
              <CardTitle className="text-4xl">{data.wasteReduced.toLocaleString()}</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-orange-50">pounds of produce rescued</p>
            </CardContent>
          </Card>

          <Card className="bg-gradient-to-br from-purple-500 to-purple-600 text-white">
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <CardDescription className="text-purple-50">Meals Provided</CardDescription>
                <Users className="h-8 w-8 text-purple-100" />
              </div>
              <CardTitle className="text-4xl">{data.mealsProvided.toLocaleString()}</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-purple-50">to communities in need</p>
            </CardContent>
          </Card>
        </div>

        {/* Main Content Tabs */}
        <Tabs defaultValue="equivalents" className="space-y-6">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="equivalents">Real-World Impact</TabsTrigger>
            <TabsTrigger value="goals">Annual Goals</TabsTrigger>
            <TabsTrigger value="breakdown">Detailed Breakdown</TabsTrigger>
          </TabsList>

          {/* Equivalents Tab */}
          <TabsContent value="equivalents" className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <Card>
                <CardHeader>
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                      <Car className="h-6 w-6 text-green-600" />
                    </div>
                    <div>
                      <CardTitle>Driving Emissions</CardTitle>
                      <CardDescription>Equivalent to not driving</CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="text-3xl font-bold text-green-600">{data.carsMiles.toLocaleString()}</div>
                  <p className="text-sm text-muted-foreground mt-2">miles in an average car</p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                      <TreePine className="h-6 w-6 text-green-600" />
                    </div>
                    <div>
                      <CardTitle>Carbon Sequestration</CardTitle>
                      <CardDescription>Equivalent to planting</CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="text-3xl font-bold text-green-600">{data.treesPlanted.toLocaleString()}</div>
                  <p className="text-sm text-muted-foreground mt-2">trees for one year</p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                      <Shower className="h-6 w-6 text-blue-600" />
                    </div>
                    <div>
                      <CardTitle>Water Conservation</CardTitle>
                      <CardDescription>Equivalent to</CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="text-3xl font-bold text-blue-600">{data.showerDays.toLocaleString()}</div>
                  <p className="text-sm text-muted-foreground mt-2">days of showers</p>
                </CardContent>
              </Card>
            </div>

            {/* Impact Story */}
            <Card className="bg-gradient-to-r from-green-50 to-blue-50">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Award className="h-5 w-5 text-green-600" />
                  Your Collective Impact
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <p className="text-muted-foreground">
                  Together, the Seconds community has rescued{" "}
                  <span className="font-bold text-foreground">{data.itemsRescued} produce items</span> from{" "}
                  <span className="font-bold text-foreground">{data.farmersHelped} local farms</span>, preventing them
                  from going to waste.
                </p>
                <p className="text-muted-foreground">
                  This has provided{" "}
                  <span className="font-bold text-foreground">
                    {data.mealsProvided.toLocaleString()} nutritious meals
                  </span>{" "}
                  to communities in need while saving the equivalent environmental impact of driving{" "}
                  <span className="font-bold text-foreground">{data.carsMiles.toLocaleString()} miles</span> in a car.
                </p>
                <p className="text-muted-foreground">
                  Every second counts, and every item rescued makes a real difference for our planet and our
                  communities.
                </p>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Goals Tab */}
          <TabsContent value="goals" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Progress Towards Annual Goals</CardTitle>
                <CardDescription>Track our journey to making a bigger impact</CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Leaf className="h-5 w-5 text-green-600" />
                      <span className="font-medium">CO2 Emissions Saved</span>
                    </div>
                    <span className="text-sm text-muted-foreground">
                      {data.co2Saved.toLocaleString()} / {annualGoals.co2.toLocaleString()} kg
                    </span>
                  </div>
                  <Progress value={progress.co2} className="h-3" />
                  <p className="text-sm text-muted-foreground">{Math.round(progress.co2)}% of annual goal</p>
                </div>

                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Droplets className="h-5 w-5 text-blue-600" />
                      <span className="font-medium">Water Conserved</span>
                    </div>
                    <span className="text-sm text-muted-foreground">
                      {data.waterSaved.toLocaleString()} / {annualGoals.water.toLocaleString()} gal
                    </span>
                  </div>
                  <Progress value={progress.water} className="h-3" />
                  <p className="text-sm text-muted-foreground">{Math.round(progress.water)}% of annual goal</p>
                </div>

                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Trash2 className="h-5 w-5 text-orange-600" />
                      <span className="font-medium">Food Waste Reduced</span>
                    </div>
                    <span className="text-sm text-muted-foreground">
                      {data.wasteReduced.toLocaleString()} / {annualGoals.waste.toLocaleString()} lbs
                    </span>
                  </div>
                  <Progress value={progress.waste} className="h-3" />
                  <p className="text-sm text-muted-foreground">{Math.round(progress.waste)}% of annual goal</p>
                </div>

                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Users className="h-5 w-5 text-purple-600" />
                      <span className="font-medium">Meals Provided</span>
                    </div>
                    <span className="text-sm text-muted-foreground">
                      {data.mealsProvided.toLocaleString()} / {annualGoals.meals.toLocaleString()}
                    </span>
                  </div>
                  <Progress value={progress.meals} className="h-3" />
                  <p className="text-sm text-muted-foreground">{Math.round(progress.meals)}% of annual goal</p>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Breakdown Tab */}
          <TabsContent value="breakdown" className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle>Environmental Metrics</CardTitle>
                  <CardDescription>Detailed environmental impact data</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-center justify-between py-2 border-b">
                    <span className="text-sm font-medium">CO2 Emissions Saved</span>
                    <span className="text-sm text-green-600 font-bold">{data.co2Saved.toLocaleString()} kg</span>
                  </div>
                  <div className="flex items-center justify-between py-2 border-b">
                    <span className="text-sm font-medium">Water Conserved</span>
                    <span className="text-sm text-blue-600 font-bold">{data.waterSaved.toLocaleString()} gal</span>
                  </div>
                  <div className="flex items-center justify-between py-2 border-b">
                    <span className="text-sm font-medium">Land Saved</span>
                    <span className="text-sm text-green-600 font-bold">{data.landSaved.toLocaleString()} sq ft</span>
                  </div>
                  <div className="flex items-center justify-between py-2">
                    <span className="text-sm font-medium">Waste Reduced</span>
                    <span className="text-sm text-orange-600 font-bold">{data.wasteReduced.toLocaleString()} lbs</span>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Community Impact</CardTitle>
                  <CardDescription>Social and economic benefits</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-center justify-between py-2 border-b">
                    <span className="text-sm font-medium">Items Rescued</span>
                    <span className="text-sm font-bold">{data.itemsRescued.toLocaleString()}</span>
                  </div>
                  <div className="flex items-center justify-between py-2 border-b">
                    <span className="text-sm font-medium">Farmers Supported</span>
                    <span className="text-sm font-bold">{data.farmersHelped.toLocaleString()}</span>
                  </div>
                  <div className="flex items-center justify-between py-2 border-b">
                    <span className="text-sm font-medium">Meals Provided</span>
                    <span className="text-sm text-purple-600 font-bold">{data.mealsProvided.toLocaleString()}</span>
                  </div>
                  <div className="flex items-center justify-between py-2">
                    <span className="text-sm font-medium">People Served</span>
                    <span className="text-sm font-bold">{Math.floor(data.mealsProvided / 3).toLocaleString()}</span>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
