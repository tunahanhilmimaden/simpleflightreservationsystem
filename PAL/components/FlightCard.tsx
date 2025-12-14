'use client'
import { Flight } from '../lib/types'
import { useBooking } from '../lib/bookingStore'
import { useRouter } from 'next/navigation'

export default function FlightCard({ flight }: { flight: Flight }) {
  const router = useRouter()
  const { selectFlight } = useBooking()
  const durationMinutes = Math.floor((flight.arrivalTime.getTime() - flight.departureTime.getTime()) / 60000)
  const duration = `${Math.floor(durationMinutes / 60)}sa ${durationMinutes % 60}dk`
  return (
    <button
      className="card"
      onClick={() => {
        selectFlight(flight)
        router.push(`/seats/${flight.id}`)
      }}
      style={{ width: '100%', textAlign: 'left', border: 'none', padding: 20, marginBottom: 20 }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <div style={{ padding: 8, borderRadius: 10, background: '#EEF5FF', color: '#0B64D2' }}>✈️</div>
          <div>
            <div style={{ fontWeight: 700, fontSize: 16 }}>{flight.airlineName}</div>
            <div style={{ color: '#777', fontSize: 12 }}>{flight.flightNumber}</div>
          </div>
        </div>
        <div style={{ color: 'var(--primary)', fontWeight: 800, fontSize: 20 }}>₺{flight.basePrice}</div>
      </div>
      <div style={{ height: 20 }} />
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <div style={{ fontSize: 22, fontWeight: 800 }}>
            {new Date(flight.departureTime).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}
          </div>
          <div style={{ color: '#777', fontWeight: 700 }}>{flight.originCode}</div>
        </div>
        <div style={{ flex: 1, padding: '0 20px', textAlign: 'center' }}>
          <div style={{ fontSize: 11, color: '#777' }}>{duration}</div>
          <div style={{ height: 5 }} />
          <div style={{ height: 1, background: '#ddd' }} />
          <div style={{ height: 5 }} />
          <div style={{ fontSize: 11, color: 'green', fontWeight: 700 }}>Direkt</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: 22, fontWeight: 800 }}>
            {new Date(flight.arrivalTime).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}
          </div>
          <div style={{ color: '#777', fontWeight: 700 }}>{flight.destCode}</div>
        </div>
      </div>
      <div style={{ height: 20 }} />
      <div style={{ height: 1, background: '#eee' }} />
      <div style={{ height: 10 }} />
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ color: '#777', fontSize: 12 }}>Ekonomi • 1 Yolcu</div>
        <div style={{ color: '#C95C00', fontWeight: 700, display: 'flex', alignItems: 'center', gap: 6 }}>
          <div>Seç</div>
          <div>→</div>
        </div>
      </div>
    </button>
  )
}
