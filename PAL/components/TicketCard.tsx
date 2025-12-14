'use client'
import { useBooking } from '../lib/bookingStore'

export default function TicketCard() {
  const { selectedFlight, selectedSeat, name, selectedDate, addParking, payAtLocation, parkingSpot } = useBooking()
  if (!selectedFlight) return null
  const durationMinutes = Math.floor((selectedFlight.arrivalTime.getTime() - selectedFlight.departureTime.getTime()) / 60000)
  const duration = `${Math.floor(durationMinutes / 60)}sa ${durationMinutes % 60}dk`
  const statusText = payAtLocation ? 'Otopark: Kapıda Ödenecek' : 'Otopark: Ödendi'
  const spotText = `Park Yeri: ${parkingSpot}`
  return (
    <div className="card" style={{ padding: '25px 25px', borderRadius: 24, width: '60%', margin: '0 auto' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between' }}>
        <div style={{ background: '#E3F2FD', color: '#0D47A1', borderRadius: 8, padding: '5px 10px', fontWeight: 700 }}>SKYRES</div>
        <div style={{ color: '#777', fontSize: 10, fontWeight: 700 }}>ECONOMY CLASS</div>
      </div>
      <div style={{ height: 25 }} />
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <BigCity code={selectedFlight.originCode} label="Kalkış" />
        <div style={{ flex: 1, padding: '0 15px', textAlign: 'center' }}>
          <div style={{ color: '#0077B6', fontSize: 24 }}>✈️</div>
          <div style={{ height: 5 }} />
          <div style={{ height: 2, background: '#ddd' }} />
          <div style={{ height: 5 }} />
          <div style={{ fontSize: 11, color: '#777', fontWeight: 700 }}>{duration}</div>
        </div>
        <BigCity code={selectedFlight.destCode} label="Varış" />
      </div>
      <div style={{ height: 25 }} />
      <div style={{ height: 1, background: '#eee' }} />
      <div style={{ height: 15 }} />
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 20 }}>
        <Info label="YOLCU" value={name.toUpperCase()} />
        <Info label="TARİH" value={new Date(selectedDate).toLocaleDateString('tr-TR', { day: '2-digit', month: 'short', year: 'numeric' })} />
        <Info label="UÇUŞ NO" value={selectedFlight.flightNumber} />
        <Info label="KAPI" value={selectedFlight.gate} />
        <Info label="BİNİŞ" value="08:10" />
        <Info label="KOLTUK" value={selectedSeat?.seatNumber ?? 'XX'} highlight />
      </div>
      {addParking && (
        <>
          <div style={{ height: 20 }} />
          <div
            style={{
              width: '100%',
              padding: '12px 15px',
              borderRadius: 12,
              border: `1px solid ${(payAtLocation ? '#1565C0' : 'green') + '33'}`,
              background: payAtLocation ? '#E3F2FD' : 'rgba(0,128,0,0.1)',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center'
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, color: payAtLocation ? '#1565C0' : 'green', fontWeight: 700 }}>
              <div>{payAtLocation ? 'ℹ️' : '✔️'}</div>
              <div style={{ fontSize: 12 }}>{statusText}</div>
            </div>
            <div style={{ padding: '4px 8px', borderRadius: 6, background: 'rgba(255,255,255,0.5)', color: payAtLocation ? '#1565C0' : 'green', fontWeight: 700, fontSize: 12 }}>
              {spotText}
            </div>
          </div>
        </>
      )}
    </div>
  )
}

function BigCity({ code, label }: { code: string; label: string }) {
  return (
    <div style={{ textAlign: 'center' }}>
      <div style={{ fontSize: 36, fontWeight: 800, color: '#1B263B' }}>{code}</div>
      <div style={{ color: '#777', fontSize: 12 }}>{label}</div>
    </div>
  )
}
function Info({ label, value, highlight }: { label: string; value: string; highlight?: boolean }) {
  return (
    <div style={{ width: 75 }}>
      <div style={{ color: '#777', fontSize: 10, fontWeight: 600 }}>{label}</div>
      <div style={{ fontWeight: 800, fontSize: 14, color: highlight ? '#FF9F1C' : '#111' }}>{value}</div>
    </div>
  )
}
