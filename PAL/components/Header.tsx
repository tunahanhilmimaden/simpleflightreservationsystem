'use client'
import Link from 'next/link'
import { useBooking } from '../lib/bookingStore'
import { useRouter } from 'next/navigation'
import { useEffect } from 'react'
import { logActivity, logActivityList } from '../lib/activity'

export default function Header() {
  const { isLoggedIn, logout, userId } = useBooking() as any
  const router = useRouter()
  useEffect(() => {
    try {
      logActivity('page_view', typeof window !== 'undefined' ? window.location.href : '', null, userId)
    } catch {}
    try {
      logActivityList(50, userId)
    } catch {}
  }, [])
  return (
    <div style={{ height: 300, position: 'relative', borderBottomLeftRadius: 40, borderBottomRightRadius: 40, overflow: 'hidden' }}>
      <div style={{ position: 'absolute', inset: 0, backgroundImage: 'linear-gradient(135deg,#023E8A,#0077B6)' }} />
      <div style={{ position: 'absolute', top: 40, right: 20, zIndex: 2 }}>
        <button
          className="btn"
          style={{ background: 'rgba(255,255,255,0.2)', border: '1px solid rgba(255,255,255,0.3)' }}
          onClick={() => {
            if (isLoggedIn) {
              try {
                sessionStorage.removeItem('user')
              } catch {}
              try {
                document.cookie = 'fs_booking=;path=/;max-age=0'
                document.cookie = 'fs_query=;path=/;max-age=0'
              } catch {}
              try { logActivity('logout', 'user logout', null, userId) } catch {}
              logout()
              router.push('/')
            } else {
              try { logActivity('navigate_auth', '/auth', null, userId) } catch {}
              router.push('/auth')
            }
          }}
        >
          {isLoggedIn ? 'Çıkış Yap' : 'Giriş Yap / Kayıt Ol'}
        </button>
      </div>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column', pointerEvents: 'none', zIndex: 1 }}>
        <div style={{ background: 'rgba(255,255,255,0.2)', borderRadius: 20, padding: '5px 15px', color: '#fff', fontWeight: 700 }}>✈️ Dünyayı Keşfet</div>
        <div style={{ color: '#fff', fontSize: 42, fontWeight: 800, letterSpacing: 1.5 }}>SkyRes</div>
        <div style={{ color: 'rgba(255,255,255,0.7)', fontSize: 16 }}>Sınırsız Rota, Tek Adres</div>
      </div>
    </div>
  )
}
