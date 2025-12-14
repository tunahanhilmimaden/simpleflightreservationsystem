 'use client'
import { useParams, useRouter } from 'next/navigation'
import { useBooking } from '../../../lib/bookingStore'
import SeatMap from '../../../components/SeatMap'
import { useEffect, useState } from 'react'

export default function SeatsPage() {
  const params = useParams()
  const flightId = params?.flightId as string
  const { selectedSeat, selectedFlight, totalPrice, setSeatSelections } = useBooking()
  const router = useRouter()
  const [capacity, setCapacity] = useState<number | null>(null)
  const [paxCount, setPaxCount] = useState<number>(1)
  const [selectedSeatIds, setSelectedSeatIds] = useState<string[]>([])
  const [seatsData, setSeatsData] = useState<any[]>([])
  const [activeIndex, setActiveIndex] = useState<number>(0)
  const [flightDetail, setFlightDetail] = useState<any | null>(null)
  const [priceMap, setPriceMap] = useState<Record<string, number>>({})
  const [forms, setForms] = useState<Array<{ gender?: string; dob?: string; first?: string; last?: string }>>([])
  useEffect(() => {
    try {
      const ck = document.cookie.split(';').map(s => s.trim())
      const item = ck.find(s => s.startsWith('fs_query='))
      if (item) {
        const json = decodeURIComponent(item.split('=')[1] || '')
        const data = JSON.parse(json)
        const pax = data?.pax
        const total = Number((pax?.adults ?? 0) + (pax?.children ?? 0) + (pax?.infants ?? 0))
        const capped = Math.min(5, total > 0 ? total : 1)
        setPaxCount(capped)
        setForms(Array.from({ length: capped }).map(() => ({})))
      } else {
        setPaxCount(1)
        setForms([{}])
      }
    } catch {
      setPaxCount(1)
      setForms([{}])
    }
  }, [])
  useEffect(() => {
    if (!flightId) return
    fetch(`http://localhost:4000/api/seats/by-flight?flightId=${flightId}`)
      .then(r => r.json())
      .then(arr => setCapacity(Array.isArray(arr) ? arr.length : 0))
      .catch(() => setCapacity(null))
    fetch(`http://localhost:4000/api/seats/map?flightId=${flightId}`)
      .then(r => r.json())
      .then(rows => {
        setSeatsData(Array.isArray(rows) ? rows : [])
      })
      .catch(() => setSeatsData([]))
    fetch(`http://localhost:4000/api/flights/detail?flightId=${flightId}`)
      .then(r => r.json())
      .then(obj => setFlightDetail(obj || null))
      .catch(() => setFlightDetail(null))
  }, [flightId])
  const idx = Math.min(activeIndex, selectedSeatIds.length - 1)
  const currentSeatId = idx >= 0 ? selectedSeatIds[idx] : undefined
  const currentSeatRow = seatsData.find(s => s.SeatID === currentSeatId)
  const basePrice = typeof currentSeatRow?.BasePrice === 'number' ? currentSeatRow.BasePrice : (selectedFlight?.basePrice ?? 0)
  const priceMultiplier = typeof currentSeatRow?.PriceMultiplier === 'number' ? currentSeatRow.PriceMultiplier : 1
  const surcharge = basePrice * (priceMultiplier - 1)
  const seatTotalPrice = basePrice * priceMultiplier
  useEffect(() => {
    if (!flightId) return
    const ids = selectedSeatIds.filter(Boolean)
    if (!ids.length) {
      setPriceMap({})
      return
    }
    Promise.all(
      ids.map(async (sid) => {
        try {
          const r = await fetch(`http://localhost:4000/api/seats/price?flightId=${flightId}&seatId=${encodeURIComponent(sid)}`)
          const obj = await r.json()
          return { sid, price: typeof obj?.seatPrice === 'number' ? obj.seatPrice : 0 }
        } catch {
          return { sid, price: 0 }
        }
      })
    ).then(list => {
      const map: Record<string, number> = {}
      for (const { sid, price } of list) map[sid] = price
      setPriceMap(map)
    })
  }, [flightId, selectedSeatIds])
  const selectedRows = seatsData.filter(s => selectedSeatIds.includes(String(s.SeatID)))
  const totalSeatSum = selectedSeatIds.reduce((sum, sid) => sum + (priceMap[sid] ?? 0), 0)
  const canConfirm =
    selectedSeatIds.length === paxCount &&
    forms.length === paxCount &&
    forms.every(f => f.gender && f.dob && f.first && f.last)
  const toggleSeat = (seatId: string) => {
    setSelectedSeatIds(prev => {
      if (prev.includes(seatId)) {
        const next = prev.filter(id => id !== seatId)
        return next
      } else {
        if (prev.length >= paxCount) return prev
        return [...prev, seatId]
      }
    })
  }
  const updateForm = (idx: number, patch: Partial<{ gender: string; dob: string; first: string; last: string }>) => {
    setForms(prev => {
      const next = prev.map((f, i) => (i === idx ? { ...f, ...patch } : f))
      return next
    })
  }
  const goNext = (idx: number) => {
    const f = forms[idx]
    const complete = f.gender && f.dob && f.first && f.last
    if (complete && idx < forms.length - 1) setActiveIndex(idx + 1)
  }
  return (
    <div style={{ background: '#ECEFF1', minHeight: '100vh' }}>
      <div className="container" style={{ display: 'grid', gridTemplateColumns: '1.2fr 1.2fr 1.6fr', gap: 20 }}>
        <div className="card" style={{ padding: 25 }}>
          <div style={{ fontSize: 18, fontWeight: 800, color: '#444' }}>Uçuş Detayları</div>
          <div style={{ height: 20 }} />
          <InfoRow
            label="Kalkış"
            v1={flightDetail ? `${flightDetail.OriginCode}` : '—'}
            v2={flightDetail ? new Date(flightDetail.DepartureTime).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' }) : '—'}
          />
          <div style={{ height: 20 }} />
          <InfoRow
            label="Varış"
            v1={flightDetail ? `${flightDetail.DestCode}` : '—'}
            v2={flightDetail ? new Date(flightDetail.ArrivalTime).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' }) : '—'}
          />
          <div style={{ height: 20 }} />
          <InfoRow label="Havayolu" v1={flightDetail ? `${flightDetail.AirlineName}` : '—'} v2="" />
          <div style={{ height: 20 }} />
          <InfoRow label="Kapasite" v1={capacity !== null ? `${capacity} Koltuk` : '—'} v2="Toplam kapasite" />
          <div style={{ height: 20 }} />
          <div style={{ fontSize: 14, fontWeight: 800 }}>Koltuk Ücret Bilgisi</div>
          <div style={{ height: 10 }} />
          <div style={{ border: '1px solid #eee', borderRadius: 12, padding: 12 }}>
            {selectedRows.length > 0 ? (
              <>
                {selectedRows.map((row, i) => {
                  const sp = typeof row.SeatPrice === 'number' ? row.SeatPrice : ((typeof row.BasePrice === 'number' ? row.BasePrice : 0) * (typeof row.PriceMultiplier === 'number' ? row.PriceMultiplier : 1))
                  return (
                    <SummaryItem key={row.SeatID} label={`Koltuk ${row.SeatNumber} • ${row.ClassName}`} value={`₺${sp.toFixed(0)}`} />
                  )
                })}
                <div style={{ height: 6 }} />
                <SummaryItem label="Toplam (Seçilen Koltuklar)" value={`₺${totalSeatSum.toFixed(0)}`} />
              </>
            ) : (
              <div style={{ fontSize: 12, color: '#777' }}>Koltuk seçiniz</div>
            )}
          </div>
          <div style={{ height: 20 }} />
          <div style={{ fontSize: 14, fontWeight: 800 }}>Koltuk Durumları</div>
          <div style={{ height: 10 }} />
          <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
            <LegendItem color="#fff" text="Boş" border />
            <LegendItem color="#e0e0e0" text="Dolu" />
            <LegendItem color="#FF9F1C" text="Seçili" />
            <LegendItem color="#FFD700" text="First Class" />
            <LegendItem color="#0D47A1" text="Business" />
          </div>
        </div>
        <div style={{ display: 'flex', justifyContent: 'center' }}>
          <SeatMap
            flightId={flightId}
            selectedSeatIds={selectedSeatIds}
            onToggleSeat={toggleSeat}
            capacity={capacity ?? 24}
            seatsData={seatsData}
          />
        </div>
        <div className="card" style={{ padding: 25 }}>
          <div style={{ fontSize: 18, fontWeight: 800, color: '#444' }}>Seçiminiz</div>
          <div style={{ height: 20 }} />
          <div style={{ fontSize: 12, color: '#777' }}>Toplam Yolcu: {paxCount} • Seçilen Koltuk: {selectedSeatIds.length}</div>
          <div style={{ height: 12 }} />
          {forms.map((f, i) => (
            <div key={i} style={{ border: '1px solid #eee', borderRadius: 12, padding: 0, marginBottom: 12, overflow: 'hidden' }}>
              <button
                onClick={() => setActiveIndex(i)}
                style={{ width: '100%', textAlign: 'left', padding: 12, background: '#F7FAFC', border: 'none', fontWeight: 700 }}
              >
                Yolcu {i + 1}
              </button>
              <div style={{ display: activeIndex === i ? 'block' : 'none', padding: 12 }}>
                <div style={{ display: 'grid', placeItems: 'center', marginBottom: 8 }}>
                  <div
                    style={{
                      height: 42,
                      width: 42,
                      borderRadius: 8,
                      border: `2px solid #1976D2`,
                      background: '#E3F2FD',
                      display: 'grid',
                      placeItems: 'center',
                      color: '#0D47A1',
                      fontSize: 14,
                      fontWeight: 800
                    }}
                  >
                    {(() => {
                      const sid = selectedSeatIds[i]
                      const row = seatsData.find(s => String(s.SeatID) === sid)
                      return row ? String(row.SeatNumber) : '--'
                    })()}
                  </div>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
                  <label>
                    <div style={{ fontSize: 11, color: '#777' }}>Cinsiyet</div>
                    <select value={f.gender || ''} onChange={e => updateForm(i, { gender: e.target.value })} style={{ width: '100%', height: 36, borderRadius: 8, border: '1px solid #eee' }}>
                      <option value="">Seçiniz</option>
                      <option value="Kadın">Kadın</option>
                      <option value="Erkek">Erkek</option>
                      <option value="Belirtmek istemiyorum">Belirtmek istemiyorum</option>
                    </select>
                  </label>
                  <label>
                    <div style={{ fontSize: 11, color: '#777' }}>Doğum Tarihi</div>
                    <input type="date" value={f.dob || ''} onChange={e => updateForm(i, { dob: e.target.value })} style={{ width: '100%', height: 36, borderRadius: 8, border: '1px solid #eee', padding: '0 8px' }} />
                  </label>
                  <label>
                    <div style={{ fontSize: 11, color: '#777' }}>Ad</div>
                    <input value={f.first || ''} onChange={e => updateForm(i, { first: e.target.value })} style={{ width: '100%', height: 36, borderRadius: 8, border: '1px solid #eee', padding: '0 8px' }} />
                  </label>
                  <label>
                    <div style={{ fontSize: 11, color: '#777' }}>Soyad</div>
                    <input value={f.last || ''} onChange={e => updateForm(i, { last: e.target.value })} style={{ width: '100%', height: 36, borderRadius: 8, border: '1px solid #eee', padding: '0 8px' }} />
                  </label>
                </div>
                <div style={{ height: 10 }} />
                <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
                  <button
                    onClick={() => goNext(i)}
                    disabled={!(f.gender && f.dob && f.first && f.last)}
                    className="btn"
                    style={{ height: 36, borderRadius: 10, background: '#1976D2', color: '#fff' }}
                  >
                    Devam
                  </button>
                </div>
              </div>
            </div>
          ))}
          <button
            disabled={!canConfirm}
            className="btn"
            style={{
              width: '100%',
              height: 55,
              borderRadius: 15,
              background: canConfirm ? '#FF9F1C' : '#bbb',
              color: canConfirm ? '#000' : '#666'
            }}
            onClick={() => {
              const seatNumbers = selectedSeatIds.map(sid => {
                const row = seatsData.find(x => String(x.SeatID) === sid)
                return row ? String(row.SeatNumber) : ''
              }).filter(Boolean)
              const passengersPayload = forms.map((f, i) => ({
                gender: f.gender || '',
                dob: f.dob || '',
                first: f.first || '',
                last: f.last || '',
                seatNumber: seatNumbers[i] || ''
              }))
              setSeatSelections(seatNumbers, passengersPayload)
              try {
                const payload = { flightId, seatNumbers, passengers: passengersPayload }
                document.cookie = `fs_booking=${encodeURIComponent(JSON.stringify(payload))};path=/;max-age=604800`
              } catch {}
              router.push('/booking')
            }}
          >
            SEÇİMİ ONAYLA
          </button>
        </div>
      </div>
    </div>
  )
}

function InfoRow({ label, v1, v2 }: { label: string; v1: string; v2: string }) {
  return (
    <div style={{ display: 'flex', gap: 15, alignItems: 'center' }}>
      <div style={{ padding: 10, borderRadius: 10, background: '#f5f5f5', color: '#0D47A1' }}>✈️</div>
      <div>
        <div style={{ fontSize: 10, color: '#777' }}>{label}</div>
        <div style={{ fontWeight: 700 }}>{v1}</div>
        <div style={{ fontSize: 12, color: '#777' }}>{v2}</div>
      </div>
    </div>
  )
}

function LegendItem({ color, text, border }: { color: string; text: string; border?: boolean }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
      <div style={{ width: 14, height: 14, background: color, borderRadius: 4, border: border ? '1px solid #ddd' : 'none' }} />
      <div style={{ fontSize: 11 }}>{text}</div>
    </div>
  )
}

function SummaryItem({ label, value }: { label: string; value: string }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', margin: '8px 0' }}>
      <div style={{ color: '#777' }}>{label}</div>
      <div style={{ fontWeight: 700 }}>{value}</div>
    </div>
  )
}
