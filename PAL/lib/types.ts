export type Flight = {
  id: string
  airlineName: string
  flightNumber: string
  originCode: string
  originCity: string
  destCode: string
  destCity: string
  departureTime: Date
  arrivalTime: Date
  basePrice: number
  gate: string
}

export type Seat = {
  seatID: string
  seatNumber: string
  isBooked: boolean
  classType: string
  priceMultiplier: number
}

export type User = {
  id?: number
  name: string
  email: string
  password: string
  phone?: string
}
