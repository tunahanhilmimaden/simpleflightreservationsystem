'use client'
import { createContext, useContext, useEffect, useMemo, useState } from 'react'
import { Flight, Seat, User } from './types'
import { MockData, defaultUsers } from './data'

export type BookingState = {
  registeredUsers: User[]
  isLoggedIn: boolean
  currentUser?: User
  selectedOrigin?: string
  selectedDestination?: string
  selectedDate: Date
  selectedFlight?: Flight
  selectedSeat?: Seat
  selectedSeatNumbers?: string[]
  passengers?: Array<{ gender: string; dob: string; first: string; last: string; seatNumber?: string }>
  addParking: boolean
  payAtLocation: boolean
  parkingSpot?: string
  baseParkingDailyRate: number
  vehicleType: string
  parkingStartDate: Date
  parkingEndDate: Date
}

type BookingContextType = BookingState & {
  name: string
  passport: string
  email: string
  phone: string
  parkingDays: number
  totalParkingPrice: number
  totalPrice: number
  register: (name: string, email: string, password: string, phone: string) => string
  login: (email: string, password: string) => string
  logout: () => void
  setRemoteUser: (u: User) => void
  setOrigin: (v?: string) => void
  setDestination: (v?: string) => void
  setDate: (d: Date) => void
  setQuickTrip: (destCode: string) => void
  toggleParking: (v: boolean) => void
  setPayAtLocation: (v: boolean) => void
  setVehicleType: (v: string) => void
  setParkingDates: (s: Date, e: Date) => void
  selectFlight: (f: Flight) => void
  selectSeat: (s: Seat) => void
  setSeatSelections: (seatNumbers: string[], passengers: Array<{ gender: string; dob: string; first: string; last: string; seatNumber?: string }>) => void
  getFilteredFlights: () => Flight[]
  getMinPriceForDate: (d: Date) => string
}

const BookingContext = createContext<BookingContextType | null>(null)

export function BookingProviderRoot({ children }: { children: React.ReactNode }) {
  const [registeredUsers, setRegisteredUsers] = useState<User[]>(defaultUsers)
  const [isLoggedIn, setIsLoggedIn] = useState(false)
  const [currentUser, setCurrentUser] = useState<User | undefined>(undefined)
  const [selectedOrigin, setSelectedOrigin] = useState<string | undefined>(undefined)
  const [selectedDestination, setSelectedDestination] = useState<string | undefined>(undefined)
  const [selectedDate, setSelectedDate] = useState<Date>(new Date())
  const [selectedFlight, setSelectedFlight] = useState<Flight | undefined>(undefined)
  const [selectedSeat, setSelectedSeat] = useState<Seat | undefined>(undefined)
  const [selectedSeatNumbers, setSelectedSeatNumbers] = useState<string[]>([])
  const [passengers, setPassengers] = useState<Array<{ gender: string; dob: string; first: string; last: string; seatNumber?: string }>>([])
  const [addParking, setAddParking] = useState(false)
  const [payAtLocation, setPayAtLocation] = useState(false)
  const [parkingSpot, setParkingSpot] = useState<string | undefined>(undefined)
  const [baseParkingDailyRate] = useState(250)
  const [vehicleType, setVehicleType] = useState('Otomobil')
  const [parkingStartDate, setParkingStartDate] = useState<Date>(new Date())
  const [parkingEndDate, setParkingEndDate] = useState<Date>(new Date(new Date().getTime() + 3 * 24 * 60 * 60 * 1000))
  const [name, setName] = useState('')
  const [passport, setPassport] = useState('')
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')

  const vehicleMultipliers: Record<string, number> = { Motosiklet: 0.8, Otomobil: 1.0, SUV: 1.3, Kamyonet: 1.5 }

  const parkingDays = useMemo(() => {
    const diff = Math.floor((parkingEndDate.getTime() - parkingStartDate.getTime()) / (24 * 60 * 60 * 1000))
    return diff <= 0 ? 1 : diff
  }, [parkingStartDate, parkingEndDate])

  const totalParkingPrice = useMemo(() => {
    if (!addParking) return 0
    const mult = vehicleMultipliers[vehicleType] ?? 1.0
    return baseParkingDailyRate * mult * parkingDays
  }, [addParking, vehicleType, baseParkingDailyRate, parkingDays])

  const totalPrice = useMemo(() => {
    let total = 0
    if (selectedFlight) total += selectedFlight.basePrice
    if (selectedSeat && selectedFlight) total += selectedFlight.basePrice * (selectedSeat.priceMultiplier - 1)
    if (addParking && !payAtLocation) total += totalParkingPrice
    return total
  }, [selectedFlight, selectedSeat, addParking, payAtLocation, totalParkingPrice])

  function register(n: string, e: string, p: string, ph: string) {
    const exists = registeredUsers.some(u => u.email === e)
    if (exists) return 'Bu e-posta adresi zaten kayıtlı!'
    const user = { name: n, email: e, password: p, phone: ph }
    setRegisteredUsers(prev => [...prev, user])
    return 'success'
  }

  function login(e: string, p: string) {
    const user = registeredUsers.find(u => u.email === e && u.password === p)
    if (!user) return 'E-posta veya şifre hatalı!'
    setCurrentUser(user)
    setIsLoggedIn(true)
    setName(user.name)
    setEmail(user.email)
    setPhone(user.phone ?? '')
    setPassport('')
    return 'success'
  }

  function logout() {
    setIsLoggedIn(false)
    setCurrentUser(undefined)
    setName('')
    setEmail('')
    setPhone('')
    setPassport('')
  }
  function setRemoteUser(u: User) {
    setCurrentUser(u)
    setIsLoggedIn(true)
    setName(u.name)
    setEmail(u.email)
    setPhone(u.phone ?? '')
    setPassport('')
  }

  function setOrigin(v?: string) {
    setSelectedOrigin(v)
  }

  function setDestination(v?: string) {
    setSelectedDestination(v)
  }

  function setDate(d: Date) {
    setSelectedDate(d)
    setParkingStartDate(d)
    setParkingEndDate(new Date(d.getTime() + 3 * 24 * 60 * 60 * 1000))
  }

  function setQuickTrip(destCode: string) {
    setSelectedOrigin('Istanbul (IST)')
    setSelectedDestination(destCode)
    const d = new Date()
    setSelectedDate(new Date(d.getFullYear(), d.getMonth(), d.getDate() + 1))
  }

  function generateParkingSpot() {
    const blocks = ['A', 'B', 'C']
    const block = blocks[Math.floor(Math.random() * blocks.length)]
    const number = Math.floor(Math.random() * 100) + 1
    setParkingSpot(`${block}-${number}`)
  }

  function toggleParking(v: boolean) {
    setAddParking(v)
    if (v) {
      generateParkingSpot()
    } else {
      setPayAtLocation(false)
      setParkingSpot(undefined)
    }
  }

  function setParkingDates(s: Date, e: Date) {
    setParkingStartDate(s)
    setParkingEndDate(e)
  }

  function selectFlight(f: Flight) {
    setSelectedFlight(f)
    setSelectedSeat(undefined)
    setAddParking(false)
  }

  function selectSeat(s: Seat) {
    setSelectedSeat(s)
  }
  function setSeatSelections(seatNumbers: string[], psg: Array<{ gender: string; dob: string; first: string; last: string; seatNumber?: string }>) {
    setSelectedSeatNumbers(seatNumbers)
    setPassengers(psg)
  }

  function getFilteredFlights() {
    const all = MockData.getFlights()
    return all.filter(f => {
      const dateMatch =
        f.departureTime.getFullYear() === selectedDate.getFullYear() &&
        f.departureTime.getMonth() === selectedDate.getMonth() &&
        f.departureTime.getDate() === selectedDate.getDate()
      const originMatch = selectedOrigin ? f.originCity.toLowerCase().includes('istanbul') : true
      const destMatch = selectedDestination ? f.destCode === selectedDestination.split(' ')[1].replace('(', '').replace(')', '') : true
      return dateMatch && originMatch && destMatch
    })
  }

  function getMinPriceForDate(d: Date) {
    const all = MockData.getFlights()
    const list = all.filter(f => f.departureTime.getFullYear() === d.getFullYear() && f.departureTime.getMonth() === d.getMonth() && f.departureTime.getDate() === d.getDate())
    if (list.length === 0) return '-'
    const min = list.map(e => e.basePrice).reduce((a, b) => (a < b ? a : b))
    return `₺${min.toFixed(0)}`
  }

  const value: BookingContextType = {
    registeredUsers,
    isLoggedIn,
    currentUser,
    selectedOrigin,
    selectedDestination,
    selectedDate,
    selectedFlight,
    selectedSeat,
    selectedSeatNumbers,
    passengers,
    addParking,
    payAtLocation,
    parkingSpot,
    baseParkingDailyRate,
    vehicleType,
    parkingStartDate,
    parkingEndDate,
    name,
    passport,
    email,
    phone,
    parkingDays,
    totalParkingPrice,
    totalPrice,
    register,
    login,
    logout,
    setRemoteUser,
    setOrigin,
    setDestination,
    setDate,
    setQuickTrip,
    toggleParking,
    setPayAtLocation,
    setVehicleType,
    setParkingDates,
    selectFlight,
    selectSeat,
    setSeatSelections,
    getFilteredFlights,
    getMinPriceForDate
  }

  useEffect(() => {
    try {
      const raw = sessionStorage.getItem('user')
      if (raw) {
        const u = JSON.parse(raw)
        if (u?.email) setRemoteUser(u)
      }
    } catch {}
  }, [])

  return <BookingContext.Provider value={value}>{children}</BookingContext.Provider>
}

export function useBooking() {
  const ctx = useContext(BookingContext)
  if (!ctx) throw new Error('BookingContext not available')
  return ctx
}
