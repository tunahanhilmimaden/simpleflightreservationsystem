'use client'
import { useBooking } from '../lib/bookingStore'
import { useRouter } from 'next/navigation'

export default function UserBar() {
  const { isLoggedIn, name, logout } = useBooking()
  const router = useRouter()
  if (!isLoggedIn) return null
  return (
    <div
      style={{
        height: 25,
        background: '#EDF2F7',
        borderBottom: '1px solid #E2E8F0',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '0 12px',
        fontSize: 12
      }}
    >
      <div style={{ color: '#2D3748' }}>{name}</div>
      <button
        onClick={() => {
          try {
            sessionStorage.removeItem('user')
          } catch {}
          logout()
          router.push('/')
        }}
        style={{
          background: 'transparent',
          border: 'none',
          color: '#E53E3E',
          cursor: 'pointer',
          fontWeight: 600
        }}
      >
        Çıkış
      </button>
    </div>
  )
}
