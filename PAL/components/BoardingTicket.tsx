'use client'
import { QRCodeCanvas } from 'qrcode.react'

export default function BoardingTicket({
  airlineName,
  flightNumber,
  originCode,
  destCode,
  departureTime,
  arrivalTime,
  passenger,
  seatNumber
}: {
  airlineName: string
  flightNumber: string
  originCode: string
  destCode: string
  departureTime: Date
  arrivalTime: Date
  passenger: { first: string; last: string }
  seatNumber: string
}) {
  const payload = JSON.stringify({ first: passenger.first, last: passenger.last, flightNumber, seatNumber })
  const depTime = new Date(departureTime)
  const arrTime = new Date(arrivalTime)
  const dateStr = depTime.toLocaleDateString('tr-TR', { day: '2-digit', month: 'long', year: 'numeric' })
  const timeStr = depTime.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })
  return (
    <div className="card" style={{ padding: 0, borderRadius: 24, width: '60%', margin: '0 auto', overflow: 'hidden' }}>
      <div style={{ background: '#D32F2F', color: '#fff', display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'center', padding: '14px 20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ fontWeight: 800 }}>SkyRes</div>
          <div style={{ opacity: 0.85, fontWeight: 700 }}>BOARDING PASS</div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontWeight: 800 }}>
          <div>{originCode}</div>
          <div>✈️</div>
          <div>{destCode}</div>
        </div>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 2.5fr 1.2fr', gap: 0 }}>
        <div style={{ padding: 20, borderRight: '1px dashed #ddd', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <QRCodeCanvas value={payload} size={120} />
        </div>
        <div style={{ padding: 20, borderRight: '1px dashed #ddd' }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', rowGap: 12, columnGap: 20 }}>
            <Field label="PASSENGER" value={`${passenger.first} ${passenger.last}`.toUpperCase()} />
            <Field label="FLIGHT" value={flightNumber} />
            <Field label="DATE" value={dateStr} />
            <Field label="FROM" value={originCode} large />
            <div style={{ display: 'grid', placeItems: 'center' }}>
              <div style={{ color: '#0077B6', fontSize: 22 }}>✈️</div>
            </div>
            <Field label="TO" value={destCode} large />
            <Field label="BOARDING TIME" value={timeStr} />
            <Field label="GATE" value="05" />
            <Field label="TERMINAL" value="2A" />
            <Field label="SEAT" value={seatNumber} />
          </div>
          <div style={{ marginTop: 14, color: '#777', fontSize: 11, textAlign: 'center' }}>KAPI UÇUŞTAN 20 DK ÖNCE KAPANIR</div>
        </div>
        <div style={{ padding: 20 }}>
          <div style={{ fontSize: 12, color: '#777' }}>NAME OF PASSENGER</div>
          <div style={{ fontWeight: 800, marginBottom: 8 }}>{`${passenger.first} ${passenger.last}`}</div>
          <StubRow label="FLIGHT" value={flightNumber} />
          <StubRow label="SEAT" value={seatNumber} />
          <StubRow label="DATE" value={dateStr} />
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
            <StubRow label="GATE" value="05" />
            <StubRow label="TERMINAL" value="2A" />
          </div>
          <div style={{ display: 'grid', placeItems: 'center', marginTop: 12 }}>
            <QRCodeCanvas value={payload} size={90} />
          </div>
        </div>
      </div>
    </div>
  )
}

function Field({ label, value, large }: { label: string; value: string; large?: boolean }) {
  return (
    <div>
      <div style={{ fontSize: 11, color: '#777' }}>{label}</div>
      <div style={{ fontWeight: 800, fontSize: large ? 22 : 14 }}>{value}</div>
    </div>
  )
}
function StubRow({ label, value }: { label: string; value: string }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
      <div style={{ fontSize: 11, color: '#777' }}>{label}</div>
      <div style={{ fontWeight: 800 }}>{value}</div>
    </div>
  )
}
