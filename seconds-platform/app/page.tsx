import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Leaf, Clock, Users, Store, Heart, TrendingDown, ShoppingCart } from "lucide-react"

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-green-50 to-white">
      {/* Header */}
      <header className="border-b bg-white/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <img
              src="/images/design-mode/AJfQ9KSlpUmEmU2R3cqhKN-KY1PPgjJudSOI_CWFtBtehHWuVkD9cpdEzrb2wYYmN0PKK26s_BnRAhOmCr0BsM2eQ-6I0No5qkZhUel5AU1YIub3DDFj5TH3KApDixzgV7tKnfB1SGtF4RKyhl0VVXiGwF5gY-5mMxhiA8O71Hf1hRkVJa3zkA%3Ds1024-rj.jpeg"
              alt="Seconds Logo"
              className="h-12 w-auto"
            />
          </div>
          <nav className="hidden md:flex items-center gap-6">
            <Link
              href="#how-it-works"
              className="text-sm font-medium text-foreground/80 hover:text-foreground transition-colors"
            >
              How It Works
            </Link>
            <Link
              href="#impact"
              className="text-sm font-medium text-foreground/80 hover:text-foreground transition-colors"
            >
              Our Impact
            </Link>
            <Link
              href="/impact"
              className="text-sm font-medium text-foreground/80 hover:text-foreground transition-colors"
            >
              Impact Dashboard
            </Link>
            <Link
              href="#get-started"
              className="text-sm font-medium text-foreground/80 hover:text-foreground transition-colors"
            >
              Get Started
            </Link>
          </nav>
        </div>
      </header>

      {/* Hero Section */}
      <section className="container mx-auto px-4 py-16 md:py-24">
        <div className="max-w-4xl mx-auto text-center space-y-6">
          <div className="inline-flex items-center gap-2 bg-green-100 text-green-800 px-4 py-2 rounded-full text-sm font-medium">
            <Leaf className="h-4 w-4" />
            Rescuing Perfectly Good Produce
          </div>
          <h1 className="text-4xl md:text-6xl font-bold text-balance">
            Every Second Counts in the Fight Against Food Waste
          </h1>
          <p className="text-xl text-muted-foreground text-balance max-w-2xl mx-auto">
            Connect farms and grocery stores with surplus produce to restaurants and food banks. AI-powered grading ensures quality while
            tracking environmental impact.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center pt-4">
            <Button size="lg" className="bg-green-600 hover:bg-green-700 text-white" asChild>
              <Link href="#get-started">Get Started</Link>
            </Button>
            <Button size="lg" variant="outline" asChild>
              <Link href="#how-it-works">Learn More</Link>
            </Button>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-4xl mx-auto mt-16">
          <Card>
            <CardContent className="pt-6 text-center">
              <div className="text-3xl font-bold text-green-600">40%</div>
              <div className="text-sm text-muted-foreground mt-1">Food Waste Reduction</div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6 text-center">
              <div className="text-3xl font-bold text-orange-600">2.5M</div>
              <div className="text-sm text-muted-foreground mt-1">Pounds Rescued</div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6 text-center">
              <div className="text-3xl font-bold text-green-600">500+</div>
              <div className="text-sm text-muted-foreground mt-1">Active Partners</div>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* How It Works */}
      <section id="how-it-works" className="bg-white py-16 md:py-24">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl md:text-4xl font-bold text-center mb-4">How Seconds Works</h2>
            <p className="text-center text-muted-foreground mb-12 text-balance">
              A simple three-step process to rescue produce and reduce waste
            </p>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="text-center space-y-4">
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto">
                  <Users className="h-8 w-8 text-green-600" />
                </div>
                <h3 className="text-xl font-semibold">Suppliers Upload</h3>
                <p className="text-muted-foreground text-sm">
                  Suppliers such as farmers and grocery stores photograph and list surplus produce that's edible but visually imperfect
                </p>
              </div>

              <div className="text-center space-y-4">
                <div className="w-16 h-16 bg-orange-100 rounded-full flex items-center justify-center mx-auto">
                  <Clock className="h-8 w-8 text-orange-600" />
                </div>
                <h3 className="text-xl font-semibold">AI Grades Quality</h3>
                <p className="text-muted-foreground text-sm">
                  Our AI analyzes each item for edibility, freshness, and quality in seconds
                </p>
              </div>

              <div className="text-center space-y-4">
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto">
                  <Store className="h-8 w-8 text-green-600" />
                </div>
                <h3 className="text-xl font-semibold">Buyers Claim</h3>
                <p className="text-muted-foreground text-sm">
                  Restaurants and food banks browse and claim produce at reduced prices
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Impact Section */}
      <section id="impact" className="py-16 md:py-24 bg-gradient-to-b from-green-50 to-white">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl md:text-4xl font-bold text-center mb-4">Environmental Impact</h2>
            <p className="text-center text-muted-foreground mb-12 text-balance">
              Every rescued item makes a difference for our planet
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                      <TrendingDown className="h-6 w-6 text-green-600" />
                    </div>
                    <div>
                      <CardTitle>Reduced Emissions</CardTitle>
                      <CardDescription>CO2 saved from landfills</CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="text-3xl font-bold text-green-600">1,200 tons</div>
                  <p className="text-sm text-muted-foreground mt-2">
                    Equivalent to taking 260 cars off the road for a year
                  </p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                      <Heart className="h-6 w-6 text-orange-600" />
                    </div>
                    <div>
                      <CardTitle>Communities Fed</CardTitle>
                      <CardDescription>Meals provided to those in need</CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="text-3xl font-bold text-orange-600">500K+</div>
                  <p className="text-sm text-muted-foreground mt-2">
                    Nutritious meals delivered through food bank partnerships
                  </p>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </section>

      {/* Get Started Section */}
      <section id="get-started" className="py-16 md:py-24 bg-white">
        <div className="container mx-auto px-4">
          <div className="max-w-5xl mx-auto">
            <h2 className="text-3xl md:text-4xl font-bold text-center mb-4">Choose Your Role</h2>
            <p className="text-center text-muted-foreground mb-12 text-balance">
              Select how you'd like to participate in reducing food waste
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-3xl mx-auto">
              <Card className="hover:shadow-lg transition-shadow cursor-pointer border-2 hover:border-green-600">
                <CardHeader>
                  <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mb-4">
                    <Users className="h-6 w-6 text-green-600" />
                  </div>
                  <CardTitle>I'm a Supplier</CardTitle>
                  <CardDescription>
                    For farms and grocery stores - List surplus produce and maximize revenue from imperfect items
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <Button className="w-full bg-green-600 hover:bg-green-700" asChild>
                    <Link href="/signin?role=supplier">Get Started</Link>
                  </Button>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer border-2 hover:border-orange-600">
                <CardHeader>
                  <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center mb-4">
                    <ShoppingCart className="h-6 w-6 text-orange-600" />
                  </div>
                  <CardTitle>I'm a Consumer</CardTitle>
                  <CardDescription>
                    For restaurants and food banks - Source quality produce at reduced prices or access fresh produce
                    for your community
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <Button className="w-full bg-orange-600 hover:bg-orange-700" asChild>
                    <Link href="/signin?role=consumer">Get Started</Link>
                  </Button>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto text-center space-y-4">
            <img
              src="/images/design-mode/AJfQ9KSlpUmEmU2R3cqhKN-KY1PPgjJudSOI_CWFtBtehHWuVkD9cpdEzrb2wYYmN0PKK26s_BnRAhOmCr0BsM2eQ-6I0No5qkZhUel5AU1YIub3DDFj5TH3KApDixzgV7tKnfB1SGtF4RKyhl0VVXiGwF5gY-5mMxhiA8O71Hf1hRkVJa3zkA%3Ds1024-rj.jpeg"
              alt="Seconds Logo"
              className="h-12 w-auto mx-auto"
            />
            <p className="text-gray-400">Rescuing produce, one second at a time.</p>
            <div className="flex justify-center gap-6 text-sm text-gray-400">
              <Link href="#" className="hover:text-white transition-colors">
                About
              </Link>
              <Link href="#" className="hover:text-white transition-colors">
                Contact
              </Link>
              <Link href="#" className="hover:text-white transition-colors">
                Privacy
              </Link>
              <Link href="#" className="hover:text-white transition-colors">
                Terms
              </Link>
            </div>
            <p className="text-sm text-gray-500">© 2025 Seconds. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}
