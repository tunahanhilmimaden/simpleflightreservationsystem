'use client'
import TicketCard from '../../components/TicketCard'
import { useRouter } from 'next/navigation'
import { useBooking } from '../../lib/bookingStore'
import BoardingTicket from '../../components/BoardingTicket'
import { useEffect, useState } from 'react'
import { useRef } from 'react'
import { logActivity } from '../../lib/activity'

export default function BoardingPage() {
  const router = useRouter()
  const { selectedFlight, passengers, selectedSeatNumbers, selectFlight, setSeatSelections } = useBooking() as any
  const [serverTickets, setServerTickets] = useState<any[]>([])
  const [flightMeta, setFlightMeta] = useState<any>(null)
  const issueGuard = useRef(false)
  useEffect(() => {
    try {
      const ck = document.cookie.split(';').map(s => s.trim())
      const item = ck.find(s => s.startsWith('fs_boarding='))
      if (item) {
        const json = decodeURIComponent(item.split('=')[1] || '')
        const data = JSON.parse(json)
        const reservationId = data?.reservationId
        if (reservationId) {
          fetch(`http://localhost:4000/api/booking/tickets?reservationId=${encodeURIComponent(reservationId)}`)
            .then(r => r.json())
            .then(arr => {
              if (Array.isArray(arr) && arr.length > 0) {
                setServerTickets(arr)
                const f = arr[0]
                setFlightMeta({
                  airlineName: f.AirlineName,
                  flightNumber: String(f.FlightNumber),
                  originCode: f.OriginCode,
                  destCode: f.DestCode,
                  departureTime: new Date(f.DepartureTime),
                  arrivalTime: new Date(f.ArrivalTime)
                })
                try { logActivity('boarding_loaded', 'tickets fetched', { reservationId, count: arr.length }) } catch {}
              }
            })
            .catch(() => {})
        }
      }
    } catch {}
  }, [])
  useEffect(() => {
    if (issueGuard.current) return
    if (!selectedFlight || !passengers || !selectedSeatNumbers || selectedSeatNumbers.length === 0) return
    if (serverTickets && serverTickets.length > 0) return
    issueGuard.current = true
    try {
      let uid = 0
      const raw = sessionStorage.getItem('user')
      if (raw) {
        const u = JSON.parse(raw)
        uid = u?.id ? Number(u.id) : (u?.UserID ? Number(u.UserID) : 0)
      }
      const reservePayload = {
        flightId: Number(selectedFlight.id),
        userId: uid > 0 ? uid : undefined,
        totalAmount: 0
      }
      fetch('http://localhost:4000/api/booking/reservation_create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(reservePayload)
      })
        .then(r => r.json())
        .then(obj => {
          const rid = obj?.ReservationID
          if (!rid) { issueGuard.current = false; return }
          const psg = (passengers || []).map((p: any) => {
            const age = (() => {
              try {
                const d = new Date(p.dob)
                const ref = new Date(selectedFlight.departureTime)
                let a = ref.getFullYear() - d.getFullYear()
                const m = ref.getMonth() - d.getMonth()
                if (m < 0 || (m === 0 && ref.getDate() < d.getDate())) a--
                return a
              } catch { return null }
            })()
            return {
              first: p.first || '',
              last: p.last || '',
              passportNo: p.passportNo || null,
              age,
              gender: p.gender || null,
              nationality: p.nationality || 'Türkiye'
            }
          })
          fetch('http://localhost:4000/api/booking/passengers_simple', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ reservationId: Number(rid), passengers: psg })
          })
            .catch(() => {})
            .finally(() => {
              const tickets = (passengers || []).map((p: any, i: number) => ({
                first: p.first,
                last: p.last,
                seatNumber: selectedSeatNumbers[i] || '',
                boardingGate: (selectedFlight as any).gate || 'C1',
                ticketStatus: 'Issued',
                passportNo: p.passportNo || null
              }))
              fetch('http://localhost:4000/api/booking/issue', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                  reservationId: Number(rid),
                  flightId: Number(selectedFlight.id),
                  tickets
                })
              })
                .then(() => {
                  try {
                    const payload = encodeURIComponent(JSON.stringify({ reservationId: Number(rid), flightId: Number(selectedFlight.id) }))
                    document.cookie = `fs_boarding=${payload};path=/`
                  } catch {}
                  try { logActivity('issue_client_boarding', 'issue on boarding page', { reservationId: Number(rid) }) } catch {}
                  fetch(`http://localhost:4000/api/booking/tickets?reservationId=${encodeURIComponent(rid)}`)
                    .then(r => r.json())
                    .then(arr => {
                      if (Array.isArray(arr)) setServerTickets(arr)
                      issueGuard.current = false
                    })
                    .catch(() => { issueGuard.current = false })
                })
                .catch(() => { issueGuard.current = false })
            })
        })
        .catch(() => { issueGuard.current = false })
    } catch { issueGuard.current = false }
  }, [selectedFlight, passengers, selectedSeatNumbers, serverTickets])
  useEffect(() => {
    try {
      if (selectedSeatNumbers && selectedSeatNumbers.length > 0 && selectedFlight) return
      const ck = document.cookie.split(';').map(s => s.trim())
      const item = ck.find(s => s.startsWith('fs_booking='))
      if (!item) return
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
    } catch {}
  }, [selectedFlight, selectedSeatNumbers])
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
        ) : serverTickets.length > 0 && flightMeta ? (
          <div style={{ display: 'grid', gap: 20 }}>
            {serverTickets.map((t: any, i: number) => (
              <BoardingTicket
                key={i}
                airlineName={flightMeta.airlineName}
                flightNumber={flightMeta.flightNumber}
                originCode={flightMeta.originCode}
                destCode={flightMeta.destCode}
                departureTime={flightMeta.departureTime}
                arrivalTime={flightMeta.arrivalTime}
                passenger={{ first: t.FirstName, last: t.LastName }}
                seatNumber={t.SeatNumber || ''}
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
