// Mock data generator for analytics
export interface TimeSeriesData {
  date: string
  value: number
  projected?: boolean
}

export interface CategoryBreakdown {
  category: string
  value: number
  percentage: number
  color: string
}

export function generateTimeSeriesData(
  baseValue: number,
  days = 30,
  projectionDays = 14,
  growthRate = 0.05,
): TimeSeriesData[] {
  const data: TimeSeriesData[] = []
  const today = new Date()

  // Historical data
  for (let i = days; i >= 0; i--) {
    const date = new Date(today)
    date.setDate(date.getDate() - i)
    const randomVariation = (Math.random() - 0.5) * 0.2
    const value = baseValue * (1 - (i / days) * 0.3) * (1 + randomVariation)
    data.push({
      date: date.toLocaleDateString("en-US", { month: "short", day: "numeric" }),
      value: Math.max(0, value),
      projected: false,
    })
  }

  // Projected data
  const lastValue = data[data.length - 1].value
  for (let i = 1; i <= projectionDays; i++) {
    const date = new Date(today)
    date.setDate(date.getDate() + i)
    const projectedValue = lastValue * Math.pow(1 + growthRate, i)
    data.push({
      date: date.toLocaleDateString("en-US", { month: "short", day: "numeric" }),
      value: projectedValue,
      projected: true,
    })
  }

  return data
}

export function generateCategoryBreakdown(type: "supplier" | "buyer"): CategoryBreakdown[] {
  if (type === "supplier") {
    return [
      { category: "Vegetables", value: 450, percentage: 45, color: "#10b981" }, // Green
      { category: "Fruits", value: 300, percentage: 30, color: "#f97316" }, // Orange
      { category: "Herbs", value: 150, percentage: 15, color: "#06b6d4" }, // Cyan
      { category: "Grains", value: 100, percentage: 10, color: "#eab308" }, // Yellow
    ]
  } else {
    return [
      { category: "Vegetables", value: 380, percentage: 38, color: "#10b981" }, // Green
      { category: "Fruits", value: 320, percentage: 32, color: "#f97316" }, // Orange
      { category: "Herbs", value: 200, percentage: 20, color: "#06b6d4" }, // Cyan
      { category: "Dairy", value: 100, percentage: 10, color: "#3b82f6" }, // Blue
    ]
  }
}

export function generateMonthlyComparison() {
  return [
    { month: "Jan", current: 120, previous: 100 },
    { month: "Feb", current: 150, previous: 110 },
    { month: "Mar", current: 180, previous: 130 },
    { month: "Apr", current: 220, previous: 160 },
    { month: "May", current: 280, previous: 200 },
    { month: "Jun", current: 350, previous: 240 },
  ]
}
