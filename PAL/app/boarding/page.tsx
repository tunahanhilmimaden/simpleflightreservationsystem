'use client'
import TicketCard from '../../components/TicketCard'
import { useRouter } from 'next/navigation'
import { useBooking } from '../../lib/bookingStore'
import BoardingTicket from '../../components/BoardingTicket'

export default function BoardingPage() {
  const router = useRouter()
  const { selectedFlight, passengers, selectedSeatNumbers, selectFlight, setSeatSelections } = useBooking() as any
  if (!selectedFlight || !passengers || !selectedSeatNumbers || selectedSeatNumbers.length === 0) {
    try {
      const ck = document.cookie.split(';').map(s => s.trim())
      const item = ck.find(s => s.startsWith('fs_booking='))
      if (item) {
        const json = decodeURIComponent(item.split('=')[1] || '')
        const data = JSON.parse(json)
        const flightId = data?.flightId
        const seatNumbers = Array.isArray(data?.seatNumbers) ? data.seatNumbers : []
        const psg = Array.isArray(data?.passengers) ? data.passengers : []
        if (seatNumbers.length) setSeatSelections(seatNumbers, psg)
        if (flightId && !selectedFlight) {
          fetch(`http://localhost:4000/api/flights/detail?flightId=${encodeURIComponent(flightId)}`)
            .then(r => r.json())
            .then(obj => {
              if (obj?.FlightID) {
                selectFlight({
                  id: String(obj.FlightID),
                  airlineName: obj.AirlineName,
                  flightNumber: String(obj.FlightID),
                  originCode: obj.OriginCode,
                  originCity: obj.OriginCode,
                  destCode: obj.DestCode,
                  destCity: obj.DestCode,
                  departureTime: new Date(obj.DepartureTime),
                  arrivalTime: new Date(obj.ArrivalTime),
                  basePrice: 0,
                  gate: 'C1'
                })
              }
            })
            .catch(() => {})
        }
      }
    } catch {}
  }
  return (
    <div style={{ minHeight: '100vh', position: 'relative' }}>
      <div style={{ position: 'absolute', inset: 0, backgroundImage: 'linear-gradient(135deg,#023E8A,#0096C7)' }} />
      <div style={{ position: 'relative' }}>
        <div style={{ height: 40 }} />
        <div style={{ textAlign: 'center', color: '#fff' }}>
          <div style={{ fontSize: 80 }}>✔️</div>
          <div style={{ fontSize: 24, fontWeight: 800 }}>İyi Uçuşlar!</div>
          <div style={{ fontSize: 14, opacity: 0.8 }}>Rezervasyonunuz başarıyla oluşturuldu.</div>
        </div>
        <div style={{ height: 30 }} />
        {selectedFlight && passengers && selectedSeatNumbers && selectedSeatNumbers.length > 0 ? (
          <div style={{ display: 'grid', gap: 20 }}>
            {passengers.map((p: any, i: number) => (
              <BoardingTicket
                key={i}
                airlineName={selectedFlight.airlineName}
                flightNumber={selectedFlight.flightNumber}
                originCode={selectedFlight.originCode}
                destCode={selectedFlight.destCode}
                departureTime={selectedFlight.departureTime}
                arrivalTime={selectedFlight.arrivalTime}
                passenger={{ first: p.first, last: p.last }}
                seatNumber={selectedSeatNumbers[i] || ''}
              />
            ))}
          </div>
        ) : (
          <TicketCard />
        )}
        <div style={{ height: 30 }} />
        <div style={{ display: 'grid', placeItems: 'center' }}>
          <button className="btn" style={{ width: 200, height: 50, borderRadius: 30, background: '#FF9F1C' }} onClick={() => router.push('/')}>
            ANA SAYFA
          </button>
        </div>
        <div style={{ height: 20 }} />
      </div>
    </div>
  )
}
