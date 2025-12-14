'use client'
import { useBooking } from '../lib/bookingStore'
import { useState } from 'react'

export default function ParkingPanel() {
  const { addParking, toggleParking, vehicleType, setVehicleType, parkingStartDate, parkingEndDate, setParkingDates, parkingDays, payAtLocation, setPayAtLocation, totalParkingPrice } =
    useBooking()
  const [openRange, setOpenRange] = useState(false)
  return (
    <div style={{ padding: 20, background: '#E3F2FD', borderRadius: 20, border: '1px solid rgba(33,150,243,0.3)' }}>
      <div style={{ display: 'flex', alignItems: 'center' }}>
        <div style={{ padding: 10, borderRadius: 10, background: '#fff', color: '#1565C0' }}>🅿️</div>
        <div style={{ marginLeft: 15, flex: 1 }}>
          <div style={{ fontWeight: 700, fontSize: 16, color: '#1565C0' }}>Otopark Ekle</div>
          <div style={{ color: '#1565C0', opacity: 0.8, fontSize: 12 }}>Güvenli ve ekonomik park yeri</div>
        </div>
        <input type="checkbox" checked={addParking} onChange={e => toggleParking(e.target.checked)} />
      </div>
      {addParking && (
        <>
          <div style={{ height: 20 }} />
          <div style={{ height: 1, background: '#fff' }} />
          <div style={{ height: 10 }} />
          <label style={{ display: 'block' }}>
            <div style={{ fontSize: 12, marginBottom: 6 }}>Araç Tipi</div>
            <select value={vehicleType} onChange={e => setVehicleType(e.target.value)} style={{ width: '100%', padding: '10px 12px', borderRadius: 10 }}>
              <option value="Motosiklet">Motosiklet (0.8x)</option>
              <option value="Otomobil">Otomobil (1.0x)</option>
              <option value="SUV">SUV / Jeep (1.3x)</option>
              <option value="Kamyonet">Kamyonet (1.5x)</option>
            </select>
          </label>
          <div style={{ height: 15 }} />
          <div
            onClick={() => setOpenRange(true)}
            style={{ padding: 12, borderRadius: 10, background: '#fff', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer' }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <div style={{ color: '#1976D2' }}>📅</div>
              <div style={{ fontWeight: 700 }}>
                {parkingStartDate.toLocaleDateString('tr-TR', { day: '2-digit', month: 'short' })} -{' '}
                {parkingEndDate.toLocaleDateString('tr-TR', { day: '2-digit', month: 'short' })}
              </div>
            </div>
            <div style={{ color: '#1976D2', fontWeight: 700 }}>{parkingDays} Gün</div>
          </div>
          {openRange && (
            <div style={{ marginTop: 10, display: 'flex', gap: 10 }}>
              <input
                type="date"
                value={parkingStartDate.toISOString().slice(0, 10)}
                min={new Date().toISOString().slice(0, 10)}
                onChange={e => setParkingDates(new Date(e.target.value), parkingEndDate)}
              />
              <input
                type="date"
                value={parkingEndDate.toISOString().slice(0, 10)}
                min={parkingStartDate.toISOString().slice(0, 10)}
                onChange={e => setParkingDates(parkingStartDate, new Date(e.target.value))}
              />
              <button className="btn" onClick={() => setOpenRange(false)}>
                Tamam
              </button>
            </div>
          )}
          <div style={{ height: 15 }} />
          <label
            style={{
              padding: '8px 10px',
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              borderRadius: 10,
              border: `1.5px solid ${payAtLocation ? '#1565C0' : 'transparent'}`,
              background: '#fff'
            }}
          >
            <input type="checkbox" checked={payAtLocation} onChange={e => setPayAtLocation(e.target.checked)} />
            <div style={{ fontWeight: 600, fontSize: 13 }}>Otoparkta Öde (Kapıda Ödeme)</div>
          </label>
          <div style={{ height: 15 }} />
          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            <div style={{ color: '#1565C0', fontWeight: 700 }}>Toplam Otopark:</div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ color: '#1565C0', fontWeight: 700, fontSize: 16 }}>₺{totalParkingPrice.toFixed(2)}</div>
              {payAtLocation && <div style={{ fontSize: 10, color: '#777', fontWeight: 700 }}>(Kapıda)</div>}
            </div>
          </div>
        </>
      )}
    </div>
  )
}
