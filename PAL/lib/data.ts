import { Flight, Seat, User } from './types'

export const MockData = {
  getCities(): string[] {
    return ['Istanbul (IST)', 'London (LHR)', 'Paris (CDG)', 'New York (JFK)', 'Berlin (BER)']
  },
  getFlights(): Flight[] {
    const today = new Date()
    const tomorrow = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1)
    return [
      {
        id: '1',
        airlineName: 'Pegasus',
        flightNumber: 'PC 101',
        originCode: 'SAW',
        originCity: 'Istanbul',
        destCode: 'LHR',
        destCity: 'London',
        departureTime: new Date(today.getFullYear(), today.getMonth(), today.getDate(), 6, 0),
        arrivalTime: new Date(today.getFullYear(), today.getMonth(), today.getDate(), 11, 30),
        basePrice: 2500,
        gate: '304'
      },
      {
        id: '2',
        airlineName: 'Turkish Airlines',
        flightNumber: 'TK 1985',
        originCode: 'IST',
        originCity: 'Istanbul',
        destCode: 'LHR',
        destCity: 'London',
        departureTime: new Date(today.getFullYear(), today.getMonth(), today.getDate(), 9, 0),
        arrivalTime: new Date(today.getFullYear(), today.getMonth(), today.getDate(), 11, 0),
        basePrice: 6000,
        gate: '212'
      },
      {
        id: '3',
        airlineName: 'British Airways',
        flightNumber: 'BA 670',
        originCode: 'IST',
        originCity: 'Istanbul',
        destCode: 'LHR',
        destCity: 'London',
        departureTime: new Date(today.getFullYear(), today.getMonth(), today.getDate(), 14, 0),
        arrivalTime: new Date(today.getFullYear(), today.getMonth(), today.getDate(), 17, 30),
        basePrice: 4500,
        gate: '101'
      },
      {
        id: '4',
        airlineName: 'Lufthansa',
        flightNumber: 'LH 990',
        originCode: 'IST',
        originCity: 'Istanbul',
        destCode: 'LHR',
        destCity: 'London',
        departureTime: new Date(tomorrow.getFullYear(), tomorrow.getMonth(), tomorrow.getDate(), 13, 15),
        arrivalTime: new Date(tomorrow.getFullYear(), tomorrow.getMonth(), tomorrow.getDate(), 16, 20),
        basePrice: 3800,
        gate: 'C4'
      }
    ]
  },
  getSeatsForFlight(flightId: string): Seat[] {
    return Array.from({ length: 24 }).map((_, index) => {
      const row = Math.floor(index / 4) + 1
      const letter = ['A', 'B', 'C', 'D'][index % 4]
      let type = 'Economy'
      let mult = 1.0
      if (row === 1) {
        type = 'First Class'
        mult = 4.0
      } else if (row <= 3) {
        type = 'Business'
        mult = 2.0
      }
      return {
        seatID: `${flightId}-${row}${letter}`,
        seatNumber: `${row}${letter}`,
        isBooked: [2, 5, 8, 12, 19].includes(index),
        classType: type,
        priceMultiplier: mult
      }
    })
  }
}

export const defaultUsers: User[] = [{ name: 'Test Kullanıcı', email: 'test@gmail.com', password: '123456', phone: '05000000000' }]
