'use client'
import { useBooking } from '../lib/bookingStore'
import { useRouter } from 'next/navigation'
import { useEffect, useMemo, useState } from 'react'
import ComboSelect from './ComboSelect'

export default function SearchCapsule() {
  const { selectedOrigin, selectedDestination, selectedDate, setOrigin, setDestination, setDate, isLoggedIn } = useBooking()
  const router = useRouter()
  const [airports, setAirports] = useState<{ code: string; city: string }[]>([])
  const [originQuery, setOriginQuery] = useState('')
  const [destQuery, setDestQuery] = useState('')
  const [showOrigin, setShowOrigin] = useState(false)
  const [showDest, setShowDest] = useState(false)
  const [dateStr, setDateStr] = useState('')
  const [showPax, setShowPax] = useState(false)
  const [adults, setAdults] = useState(1)
  const [children, setChildren] = useState(0)
  const [infants, setInfants] = useState(0)
  useEffect(() => {
    fetch('http://localhost:4000/api/flights/airportlist')
      .then(r => r.json())
      .then(d => setAirports(Array.isArray(d) ? d : []))
      .catch(() => setAirports([]))
  }, [])
  useEffect(() => {
    if (selectedOrigin) setOriginQuery(selectedOrigin)
    if (selectedDestination) setDestQuery(selectedDestination)
  }, [selectedOrigin, selectedDestination])
  const filterAirports = useMemo(
    () => (q: string) => {
      const s = (q || '').toLowerCase().trim()
      const list = airports.filter(a => a.city.toLowerCase().includes(s) || a.code.toLowerCase().includes(s))
      return list.slice(0, 10)
    },
    [airports]
  )
  const onSearch = async () => {
    const canSearch = !!(selectedOrigin && selectedDestination && dateStr)
    if (!canSearch) return
    try {
      const data = {
        origin: selectedOrigin,
        destination: selectedDestination,
        date: dateStr,
        pax: { adults, children, infants }
      }
      document.cookie = `fs_query=${encodeURIComponent(JSON.stringify(data))};path=/;max-age=604800`
    } catch {}
    if (!isLoggedIn) {
      router.push('/auth')
    } else {
      const oCode = (selectedOrigin || '').match(/\((.*?)\)/)?.[1] || ''
      const dCode = (selectedDestination || '').match(/\((.*?)\)/)?.[1] || ''
      const qs = new URLSearchParams({ origin: oCode, dest: dCode, date: dateStr }).toString()
      router.push(`/flights?${qs}`)
    }
  }
  return (
    <div style={{ position: 'relative' }}>
      <div
        className="card"
        style={{
          position: 'absolute',
          left: '50%',
          transform: 'translateX(-50%)',
          top: -26,
          width: '94%',
          maxWidth: 980,
          padding: '16px 20px',
          borderRadius: 24,
          zIndex: 10000
        }}
      >
        <div className="searchBar" style={{ gridTemplateColumns: 'repeat(5, 1fr)' }}>
          <div style={{ gridColumn: 'span 1' }}>
            <ComboSelect
              label="Nereden"
              name="location"
              value={originQuery}
              onChange={v => {
                setOrigin(v)
                setOriginQuery(v)
              }}
              options={airports.map(a => `${a.city} (${a.code})`)}
              placeholder="Şehir veya kod yazın"
            />
          </div>
          <div style={{ gridColumn: 'span 1' }}>
            <ComboSelect
              label="Nereye"
              name="destination"
              value={destQuery}
              onChange={v => {
                setDestination(v)
                setDestQuery(v)
              }}
              options={airports.map(a => `${a.city} (${a.code})`)}
              placeholder="Şehir veya kod yazın"
            />
          </div>
          <div className="fieldControl" style={{ gridColumn: 'span 1' }}>
            <div className="fieldLabel">Tarih</div>
            <input
              name="date"
              type="date"
              className="fieldInput"
              value={dateStr}
              min={new Date().toISOString().slice(0, 10)}
              placeholder="Tarih seçin"
              onChange={e => {
                const v = e.target.value
                setDateStr(v)
                if (v) setDate(new Date(v))
              }}
            />
          </div>
          <div className="fieldControl" style={{ position: 'relative', gridColumn: 'span 1' }}>
            <div className="fieldLabel">Yolcu</div>
            <div className="paxButton" onClick={() => setShowPax(v => !v)}>
              <div>{adults + children + infants} {adults + children + infants === 1 ? 'Yolcu' : 'Yolcu'}</div>
              <div>▼</div>
            </div>
            {showPax && (
              <div className="paxPanel">
                <div className="paxRow">
                  <div className="paxLabel">Yetişkin (12+)</div>
                  <div className="paxControls">
                    <button className="paxCounterBtn" onClick={() => setAdults(a => Math.max(1, a - 1))}>−</button>
                    <div>{adults}</div>
                    <button
                      className="paxCounterBtn"
                      onClick={() => setAdults(a => (a + children + infants >= 5 ? a : a + 1))}
                    >
                      +
                    </button>
                  </div>
                </div>
                <div className="paxRow">
                  <div className="paxLabel">Çocuk (2-12)</div>
                  <div className="paxControls">
                    <button className="paxCounterBtn" onClick={() => setChildren(c => Math.max(0, c - 1))}>−</button>
                    <div>{children}</div>
                    <button
                      className="paxCounterBtn"
                      onClick={() => setChildren(c => (adults + c + infants >= 5 ? c : c + 1))}
                    >
                      +
                    </button>
                  </div>
                </div>
                <div className="paxRow">
                  <div className="paxLabel">Bebek (0-2)</div>
                  <div className="paxControls">
                    <button className="paxCounterBtn" onClick={() => setInfants(i => Math.max(0, i - 1))}>−</button>
                    <div>{infants}</div>
                    <button
                      className="paxCounterBtn"
                      onClick={() =>
                        setInfants(i => {
                          const total = adults + children + i
                          if (total >= 5) return i
                          const next = i + 1
                          return Math.min(adults, next)
                        })
                      }
                    >
                      +
                    </button>
                  </div>
                </div>
                <button
                  className="paxFooterBtn"
                  onClick={() => {
                    try {
                      const data = {
                        origin: selectedOrigin,
                        destination: selectedDestination,
                        date: dateStr,
                        pax: { adults, children, infants }
                      }
                      document.cookie = `fs_query=${encodeURIComponent(JSON.stringify(data))};path=/;max-age=604800`
                    } catch {}
                    setShowPax(false)
                  }}
                >
                  TAMAM
                </button>
              </div>
            )}
          </div>
          <button className="btn searchButton" style={{ gridColumn: 'span 1', width: '100%' }} onClick={onSearch} disabled={!(selectedOrigin && selectedDestination && dateStr)}>
            UÇUŞ ARA
          </button>
        </div>
      </div>
    </div>
  )
}
