'use client'
import { useBooking } from '../../lib/bookingStore'
import { useEffect, useMemo, useState } from 'react'
import { useSearchParams, useRouter } from 'next/navigation'

export default function FlightsPage() {
  const { selectedOrigin, selectedDestination, selectedDate, setDate } = useBooking()
  const searchParams = useSearchParams()
  const [sort, setSort] = useState<'Varsayılan' | 'En Ucuz' | 'En Hızlı'>('Varsayılan')
  const [rawFlights, setRawFlights] = useState<any[]>([])
  const [requiredSeats, setRequiredSeats] = useState<number>(1)
  const [paxLabel, setPaxLabel] = useState<string>('1 Yetişkin')
  const [departDateLabel, setDepartDateLabel] = useState<string>('')
  const [seatAvail, setSeatAvail] = useState<Record<number, number>>({})
  const originParam = searchParams.get('origin') || ''
  const destParam = searchParams.get('dest') || ''
  const dateParam = searchParams.get('date') || ''
  const originCode = originParam || (selectedOrigin || '').match(/\((.*?)\)/)?.[1] || ''
  const destCode = destParam || (selectedDestination || '').match(/\((.*?)\)/)?.[1] || ''
  const originLabel = (selectedOrigin || '').replace(/\s*\(.*\)\s*/, '') || originCode
  const destLabel = (selectedDestination || '').replace(/\s*\(.*\)\s*/, '') || destCode
  useEffect(() => {
    const chosenDate = dateParam || new Date(selectedDate).toISOString().slice(0, 10)
    if (!originCode || !destCode || !chosenDate) {
      setRawFlights([])
      return
    }
    const q = new URLSearchParams({ origin: originCode, dest: destCode, date: chosenDate }).toString()
    fetch(`http://localhost:4000/api/flights/search?${q}`)
      .then(r => r.json())
      .then(list => {
        const l = Array.isArray(list) ? list : []
        setRawFlights(l)
      })
      .catch(() => setRawFlights([]))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [originCode, destCode, dateParam, selectedDate])
  const flights = useMemo(() => {
    let l = [...rawFlights]
    if (sort === 'En Ucuz') l = l.sort((a: any, b: any) => (a.MinPrice ?? 0) - (b.MinPrice ?? 0))
    else if (sort === 'En Hızlı')
      l = l.sort(
        (a: any, b: any) =>
          (new Date(a.ArrivalTime).getTime() - new Date(a.DepartureTime).getTime()) -
          (new Date(b.ArrivalTime).getTime() - new Date(b.DepartureTime).getTime())
      )
    else l = l.sort((a: any, b: any) => new Date(a.DepartureTime).getTime() - new Date(b.DepartureTime).getTime())
    return l
  }, [rawFlights, sort])
  useEffect(() => {
    const ids = rawFlights.map(f => f.FlightID)
    if (!ids.length) {
      setSeatAvail({})
      return
    }
    Promise.all(
      ids.map(async (id: number) => {
        try {
          const r = await fetch(`http://localhost:4000/api/seats/available?flightId=${id}`)
          const obj = await r.json()
          const n = typeof obj?.availableSeats === 'number' ? obj.availableSeats : 0
          return { id, count: n as number }
        } catch {
          return { id, count: 0 }
        }
      })
    ).then(list => {
      const map: Record<number, number> = {}
      for (const { id, count } of list) map[id] = count
      setSeatAvail(map)
    })
  }, [rawFlights])
  useEffect(() => {
    try {
      const ck = document.cookie.split(';').map(s => s.trim())
      const item = ck.find(s => s.startsWith('fs_query='))
      if (item) {
        const json = decodeURIComponent(item.split('=')[1] || '')
        const data = JSON.parse(json)
        const pax = data?.pax
        const total = Number((pax?.adults ?? 0) + (pax?.children ?? 0) + (pax?.infants ?? 0))
        setRequiredSeats(total > 0 ? total : 1)
        const parts: string[] = []
        if ((pax?.adults ?? 0) > 0) parts.push(`${pax.adults} Yetişkin`)
        if ((pax?.children ?? 0) > 0) parts.push(`${pax.children} Çocuk`)
        if ((pax?.infants ?? 0) > 0) parts.push(`${pax.infants} Bebek`)
        setPaxLabel(parts.length ? parts.join(', ') : '1 Yetişkin')
        const dStr = (data?.date ?? dateParam ?? new Date(selectedDate).toISOString().slice(0, 10)) as string
        const d = new Date(dStr)
        setDepartDateLabel(`${d.toLocaleDateString('tr-TR', { day: '2-digit', month: 'short', year: 'numeric', weekday: 'short' })}`)
      } else {
        setRequiredSeats(1)
        const d = dateParam ? new Date(dateParam) : selectedDate
        setDepartDateLabel(`${new Date(d).toLocaleDateString('tr-TR', { day: '2-digit', month: 'short', year: 'numeric', weekday: 'short' })}`)
      }
    } catch {
      setRequiredSeats(1)
      const d = dateParam ? new Date(dateParam) : selectedDate
      setDepartDateLabel(`${new Date(d).toLocaleDateString('tr-TR', { day: '2-digit', month: 'short', year: 'numeric', weekday: 'short' })}`)
    }
  }, [])

  const days = Array.from({ length: 5 }).map((_, i) => {
    const d = new Date()
    d.setDate(d.getDate() + i)
    const theDate = d.toISOString().slice(0, 10)
    return { d, theDate }
  })
  const [minPrices, setMinPrices] = useState<Record<string, number>>({})
  useEffect(() => {
    const startDate = (dateParam || new Date().toISOString().slice(0, 10))
    if (!originCode || !destCode) {
      setMinPrices({})
      return
    }
    fetch(
      `http://localhost:4000/api/flights/min-prices?origin=${encodeURIComponent(originCode)}&dest=${encodeURIComponent(
        destCode
      )}&startDate=${encodeURIComponent(startDate)}&days=5`
    )
      .then(r => r.json())
      .then(rows => {
        const map: Record<string, number> = {}
        for (const row of rows || []) {
          const k = new Date(row.theDate).toISOString().slice(0, 10)
          map[k] = row.minPrice
        }
        setMinPrices(map)
      })
      .catch(() => setMinPrices({}))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [originCode, destCode, dateParam])

  return (
    <div>
      <div style={{ paddingBottom: 25, borderBottomLeftRadius: 30, borderBottomRightRadius: 30, backgroundImage: 'linear-gradient(135deg,#023E8A,#0096C7)' }}>
        <div style={{ padding: '10px 10px', display: 'flex', alignItems: 'center' }}>
          <button
            onClick={() => history.back()}
            className="btn"
            style={{ background: '#fff', color: '#023E8A', borderRadius: 12, height: 32, padding: '4px 12px', fontWeight: 700 }}
          >
            {'<'} Geri
          </button>
          <div style={{ flex: 1 }} />
          <div style={{ color: '#fff', opacity: 0.8 }}>Uçuş Seçimi</div>
          <div style={{ flex: 1 }} />
          <div style={{ width: 40 }} />
        </div>
        <div style={{ padding: '10px 0' }}>
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 20, color: '#fff' }}>
            <div>
              <div style={{ fontSize: 24, fontWeight: 800 }}>{originLabel}</div>
              <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.7)' }}>Nereden</div>
            </div>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <div style={{ width: 6, height: 6, background: 'rgba(255,255,255,0.7)', borderRadius: 999 }} />
                <div style={{ width: 80, height: 1, background: 'rgba(255,255,255,0.7)' }} />
                <div style={{ transform: 'rotate(90deg)', color: '#fff' }}>✈️</div>
                <div style={{ width: 80, height: 1, background: 'rgba(255,255,255,0.7)' }} />
                <div style={{ width: 6, height: 6, background: 'rgba(255,255,255,0.7)', borderRadius: 999 }} />
              </div>
              <div style={{ fontSize: 10, color: '#fff', textAlign: 'center' }}>1s 45dk</div>
            </div>
            <div>
              <div style={{ fontSize: 24, fontWeight: 800 }}>{destLabel}</div>
              <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.7)' }}>Nereye</div>
            </div>
          </div>
        </div>
        <div style={{ height: 20 }} />
        <div style={{ height: 80, display: 'flex', gap: 12, overflowX: 'auto', padding: '0 20px' }}>
          {days.map(({ d, theDate }, idx) => {
            const price = minPrices[theDate]
            const hasFlight = typeof price === 'number' && price > 0
            const isSelected = d.toDateString() === selectedDate.toDateString()
            const bg = !hasFlight ? 'rgba(255,255,255,0.05)' : isSelected ? '#FF9F1C' : 'rgba(255,255,255,0.15)'
            const color = !hasFlight ? 'rgba(255,255,255,0.35)' : isSelected ? '#fff' : 'rgba(255,255,255,0.9)'
            return (
              <button
                key={idx}
                onClick={() => {
                  if (!hasFlight) {
                    alert('Seçilen tarihte uygun uçuş bulunmamaktadır.')
                    return
                  }
                  setDate(d)
                }}
                style={{
                  width: 75,
                  borderRadius: 16,
                  border: `1px solid ${isSelected ? '#fff' : 'rgba(255,255,255,0.2)'}`,
                  background: bg,
                  color,
                  padding: 10,
                  cursor: 'pointer'
                }}
              >
                <div style={{ fontSize: 11 }}>{d.toLocaleDateString('tr-TR', { weekday: 'short' })}</div>
                <div style={{ fontWeight: 700, fontSize: 14 }}>
                  {d.getDate()} {d.toLocaleDateString('tr-TR', { month: 'short' })}
                </div>
                <div style={{ fontSize: 10, fontWeight: 700 }}>{hasFlight ? `₺${price}` : 'Yok'}</div>
              </button>
            )
          })}
        </div>
      </div>
      <div style={{ padding: '15px 20px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <div style={{ fontSize: 20, fontWeight: 800, color: '#1B263B' }}>{originLabel}</div>
              <div style={{ color: '#F2C94C' }}>↔</div>
              <div style={{ fontSize: 20, fontWeight: 800, color: '#1B263B' }}>{destLabel}</div>
            </div>
            <div style={{ color: '#4A5568', fontSize: 12, marginTop: 4 }}>
              Gidiş {departDateLabel}
            </div>
          </div>
          <div style={{ color: '#4A5568', fontSize: 12, fontWeight: 700 }}>{paxLabel}</div>
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div style={{ fontWeight: 700, color: '#333' }}>{flights.length} Uçuş</div>
          <div style={{ display: 'flex', border: '1px solid #ddd', borderRadius: 20, overflow: 'hidden' }}>
            {(['En Ucuz', 'En Hızlı'] as const).map(label => {
              const active = sort === label
              return (
                <button
                  key={label}
                  onClick={() => setSort(label)}
                  style={{
                    padding: '8px 16px',
                    background: active ? '#fff' : '#fff',
                    color: active ? '#0077B6' : '#777',
                    border: 'none',
                    cursor: 'pointer'
                  }}
                >
                  {label}
                </button>
              )
            })}
          </div>
        </div>
        <div style={{ height: 10 }} />
        {flights.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#777' }}>
            <div style={{ fontSize: 80, color: '#ccc' }}>✈️</div>
            <div style={{ fontSize: 18 }}>Uçuş Bulunamadı</div>
            <div style={{ fontSize: 14 }}>Lütfen başka bir tarih seçin.</div>
          </div>
        ) : (
          flights.map(f => <DbFlightRow key={f.FlightID} f={f} requiredSeats={requiredSeats} seatAvail={seatAvail} />)
        )}
      </div>
    </div>
  )
}

function DbFlightRow({ f, requiredSeats, seatAvail }: { f: any; requiredSeats: number; seatAvail: Record<number, number> }) {
  const router = useRouter()
  const { selectFlight } = useBooking()
  const dep = new Date(f.DepartureTime)
  const arr = new Date(f.ArrivalTime)
  const durMin = Math.floor((arr.getTime() - dep.getTime()) / 60000)
  const durTxt = `${Math.floor(durMin / 60)}sa ${durMin % 60}dk`
  const availableSeats = seatAvail[f.FlightID] ?? undefined
  const insufficient = availableSeats !== undefined && availableSeats < requiredSeats
  return (
    <button
      className="card"
      onClick={() => {
        if (insufficient) return
        selectFlight({
          id: String(f.FlightID),
          airlineName: f.AirlineName,
          flightNumber: String(f.FlightID),
          originCode: f.OriginCode,
          originCity: f.OriginCode,
          destCode: f.DestCode,
          destCity: f.DestCode,
          departureTime: dep,
          arrivalTime: arr,
          basePrice: f.MinPrice ?? 0,
          gate: 'C1'
        })
        router.push(`/seats/${f.FlightID}`)
      }}
      disabled={insufficient}
      style={{ width: '100%', marginBottom: 20, padding: 20, borderRadius: 20, boxShadow: '0 10px 15px rgba(0,0,255,0.05)', border: 'none', textAlign: 'left', cursor: insufficient ? 'not-allowed' : 'pointer' }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <div style={{ padding: 8, borderRadius: 10, background: '#EEF5FF', color: '#0B64D2' }}>✈️</div>
          <div>
            <div style={{ fontWeight: 700, fontSize: 16 }}>{f.AirlineName}</div>
            <div style={{ color: '#777', fontSize: 12 }}>{f.FlightID}</div>
          </div>
        </div>
        <div style={{ color: '#0077B6', fontWeight: 800, fontSize: 20 }}>₺{f.MinPrice ?? 0}</div>
      </div>
      <div style={{ height: 20 }} />
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <div style={{ fontSize: 22, fontWeight: 800 }}>{dep.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}</div>
          <div style={{ color: '#777', fontWeight: 700 }}>{f.OriginCode}</div>
        </div>
        <div style={{ flex: 1, padding: '0 20px', textAlign: 'center' }}>
          <div style={{ fontSize: 11, color: '#777' }}>{durTxt}</div>
          <div style={{ height: 5 }} />
          <div style={{ height: 1, background: '#ddd' }} />
          <div style={{ height: 5 }} />
          <div style={{ fontSize: 11, color: 'green', fontWeight: 700 }}>Direkt</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: 22, fontWeight: 800 }}>{arr.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}</div>
          <div style={{ color: '#777', fontWeight: 700 }}>{f.DestCode}</div>
        </div>
      </div>
      <div style={{ color: '#4A5568', fontSize: 12, marginTop: 8 }}>
        Kalan Koltuk Sayısı: {availableSeats !== undefined ? availableSeats : '–'}
      </div>
      {insufficient && <div className="warnBlink">Yeteri kadar koltuk yok</div>}
    </button>
  )
}
