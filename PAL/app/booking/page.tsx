'use client'
import { useEffect, useMemo, useState } from 'react'
import { useBooking } from '../../lib/bookingStore'
import ParkingPanel from '../../components/ParkingPanel'
import CreditCardForm from '../../components/CreditCardForm'
import { useRouter } from 'next/navigation'

export default function BookingPage() {
  const { selectedFlight, selectedSeatNumbers, passengers, currentUser, vehicleType, addParking, payAtLocation, totalParkingPrice, selectFlight, setSeatSelections } = useBooking() as any
  const [valid, setValid] = useState(false)
  const [rows, setRows] = useState<any[]>([])
  const [kvkkOk, setKvkkOk] = useState(false)
  const router = useRouter()
  useEffect(() => {
    try {
      const ck = document.cookie.split(';').map(s => s.trim())
      const item = ck.find(s => s.startsWith('fs_booking='))
      if (item) {
        const json = decodeURIComponent(item.split('=')[1] || '')
        const data = JSON.parse(json)
        const flightId = data?.flightId
        const seatNumbers = Array.isArray(data?.seatNumbers) ? data.seatNumbers : []
        const psg = Array.isArray(data?.passengers) ? data.passengers : []
        if (seatNumbers.length && (!selectedSeatNumbers || selectedSeatNumbers.length === 0)) {
          setSeatSelections(seatNumbers, psg)
        }
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
  }, [])
  useEffect(() => {
    if (!selectedFlight || !selectedSeatNumbers || selectedSeatNumbers.length === 0) return
    const seatNumbers = selectedSeatNumbers.join(',')
    fetch(`http://localhost:4000/api/booking/quote?flightId=${encodeURIComponent(selectedFlight.id)}&seatNumbers=${encodeURIComponent(seatNumbers)}`)
      .then(r => r.json())
      .then(arr => setRows(Array.isArray(arr) ? arr : []))
      .catch(() => setRows([]))
  }, [selectedFlight, selectedSeatNumbers])
  if (!selectedFlight || !selectedSeatNumbers || selectedSeatNumbers.length === 0) {
    return (
      <div className="container" style={{ paddingTop: 40 }}>
        <div className="card" style={{ padding: 20 }}>Önce uçuş ve koltuk seçiniz.</div>
      </div>
    )
  }
  const taxes = 450
  const seatTotal = useMemo(() => rows.reduce((sum, r) => sum + (typeof r.SeatPrice === 'number' ? r.SeatPrice : 0), 0), [rows])
  const grandTotal = useMemo(() => seatTotal + taxes + (addParking && !payAtLocation ? totalParkingPrice : 0), [seatTotal, taxes, addParking, payAtLocation, totalParkingPrice])
  return (
    <div className="container" style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: 30, paddingTop: 30 }}>
      <div>
        <div className="card" style={{ padding: 25 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            <div>
              <div style={{ color: '#777', fontSize: 12 }}>Gidiş Uçuşu</div>
              <div style={{ fontWeight: 700, fontSize: 16 }}>{selectedFlight.airlineName}</div>
            </div>
            <div style={{ background: '#EEF5FF', color: '#0B64D2', fontWeight: 700, padding: '5px 10px', borderRadius: 5 }}>{selectedFlight.flightNumber}</div>
          </div>
          <div style={{ height: 20 }} />
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontSize: 10, color: '#777' }}>Kalkış</div>
              <FlightTime code={selectedFlight.originCode} time={selectedFlight.departureTime} />
            </div>
            <div style={{ color: '#777' }}>→</div>
            <div>
              <div style={{ fontSize: 10, color: '#777' }}>Varış</div>
              <FlightTime code={selectedFlight.destCode} time={selectedFlight.arrivalTime} />
            </div>
          </div>
        </div>
        <div style={{ height: 20 }} />
        <div className="card" style={{ padding: 25 }}>
          <div style={{ fontSize: 16, fontWeight: 800, marginBottom: 10 }}>Yolcu Bilgileri</div>
          <div style={{ border: '1px solid #eee', borderRadius: 10, overflow: 'hidden' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr 1fr 1fr', padding: '8px 12px', background: '#F7FAFC', fontWeight: 700 }}>
              <div>Ad Soyad</div>
              <div>Cinsiyet</div>
              <div>Doğum Tarihi</div>
              <div>Koltuk</div>
            </div>
            {(passengers || []).map((p: any, i: number) => (
              <div key={i} style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr 1fr 1fr', padding: '8px 12px', borderTop: '1px solid #eee' }}>
                <div>{p.first} {p.last}</div>
                <div>{p.gender}</div>
                <div>{p.dob}</div>
                <div>{p.seatNumber}</div>
              </div>
            ))}
          </div>
          <div style={{ height: 20 }} />
          <div style={{ fontSize: 16, fontWeight: 800, marginBottom: 10 }}>İletişim Bilgisi</div>
          <div style={{ border: '1px solid #eee', borderRadius: 10, padding: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}><div>Ad</div><div style={{ fontWeight: 700 }}>{currentUser?.name || '-'}</div></div>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}><div>E-posta</div><div style={{ fontWeight: 700 }}>{currentUser?.email || '-'}</div></div>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}><div>Telefon</div><div style={{ fontWeight: 700 }}>{currentUser?.phone || '-'}</div></div>
          </div>
          <div style={{ height: 20 }} />
          <div style={{ fontSize: 16, fontWeight: 800, marginBottom: 10 }}>Koltuk Bazlı Ücretler</div>
          <div style={{ border: '1px solid #eee', borderRadius: 10, overflow: 'hidden' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', padding: '8px 12px', background: '#F7FAFC', fontWeight: 700 }}>
              <div>Koltuk</div>
              <div>Sınıf</div>
              <div>Baz Fiyat</div>
              <div>Tutar</div>
            </div>
            {rows.map((r, i) => (
              <div key={i} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', padding: '8px 12px', borderTop: '1px solid #eee' }}>
                <div>{r.SeatNumber}</div>
                <div>{r.ClassName}</div>
                <div>₺{Number(r.BasePrice || 0).toFixed(0)}</div>
                <div>₺{Number(r.SeatPrice || 0).toFixed(0)}</div>
              </div>
            ))}
            <div style={{ display: 'grid', gridTemplateColumns: '3fr 1fr', padding: '8px 12px', borderTop: '2px solid #eee', fontWeight: 800 }}>
              <div>TOPLAM (Koltuklar)</div>
              <div>₺{seatTotal.toFixed(0)}</div>
            </div>
          </div>
          <div style={{ height: 20 }} />
          <CreditCardForm onValidChange={setValid} />
        </div>
      </div>
      <div>
        <ParkingPanel />
        <div style={{ height: 20 }} />
        <div className="card" style={{ padding: 25 }}>
          <PriceRow label="Vergiler & Harçlar" value={`₺${taxes.toFixed(0)}`} />
          {addParking && <PriceRow label={`Otopark (${vehicleType})`} value={payAtLocation ? 'Kapıda Ödenecek' : `+₺${totalParkingPrice.toFixed(0)}`} />}
          <div style={{ height: 20 }} />
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ fontSize: 18, fontWeight: 800 }}>GENEL TOPLAM</div>
            <div style={{ fontSize: 24, fontWeight: 800, color: '#2E7D32' }}>₺{grandTotal.toFixed(0)}</div>
          </div>
          <div style={{ height: 25 }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 12 }}>
            <input type="radio" name="kvkk" checked={kvkkOk} onChange={() => setKvkkOk(true)} />
            <div style={{ fontSize: 12, color: '#555' }}>KVKK kurallarını ve aydınlatma metnini okudum, onaylıyorum.</div>
          </div>
          <button
            className="btn"
            style={{ width: '100%', height: 55, borderRadius: 15, background: valid && kvkkOk ? '#FF9F1C' : '#bbb', color: valid && kvkkOk ? '#000' : '#666' }}
            onClick={() => {
              if (valid && kvkkOk) {
                const payload = {
                  flightId: Number(selectedFlight.id),
                  passengers: (passengers || []).map((p: any, i: number) => ({
                    first: p.first,
                    last: p.last,
                    seatNumber: selectedSeatNumbers[i] || ''
                  }))
                }
                fetch('http://localhost:4000/api/booking/create', {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify(payload)
                })
                  .then(() => router.push('/boarding'))
                  .catch(() => router.push('/boarding'))
              }
              else alert('Lütfen hatalı alanları düzeltin.')
            }}
          >
            ÖDEMEYİ TAMAMLA
          </button>
        </div>
      </div>
    </div>
  )
}

function FlightTime({ code, time }: { code: string; time: Date }) {
  return (
    <div>
      <div style={{ fontSize: 20, fontWeight: 800 }}>{new Date(time).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}</div>
      <div style={{ color: '#777', fontWeight: 700 }}>{code}</div>
    </div>
  )
}

function PriceRow({ label, value }: { label: string; value: string }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', padding: '5px 0' }}>
      <div style={{ color: '#777' }}>{label}</div>
      <div style={{ fontWeight: 700 }}>{value}</div>
    </div>
  )
}
