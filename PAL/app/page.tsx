'use client'
import Header from '../components/Header'
import SearchCapsule from '../components/SearchCapsule'
import Link from 'next/link'
import { useBooking } from '../lib/bookingStore'

export default function Page() {
  return (
    <div>
      <Header />
      <SearchCapsule />
      <div style={{ height: 80 }} />
      <div className="container">
        <div>
          <div style={{ fontSize: 22, fontWeight: 700, color: '#000' }}>Popüler Rotalar</div>
          <div style={{ color: '#777', fontSize: 14 }}>Sizin için seçtiğimiz en iyi fiyatlı uçuşlar</div>
        </div>
        <div style={{ height: 20 }} />
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(220px,1fr))', gap: 20 }}>
          {[
            { code: 'London (LHR)', name: 'Londra', price: '₺4,500', image: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400' },
            { code: 'Paris (CDG)', name: 'Paris', price: '₺3,800', image: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400' },
            { code: 'New York (JFK)', name: 'New York', price: '₺15,000', image: 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400' },
            { code: 'Berlin (BER)', name: 'Berlin', price: '₺2,900', image: 'https://images.unsplash.com/photo-1560969184-10fe8719e047?w=400' }
          ].map(item => (
            <RouteCard key={item.code} {...item} />
          ))}
        </div>
      </div>
      <div style={{ height: 80 }} />
      <div style={{ width: '100%', background: '#fff', padding: '50px 20px' }}>
        <div className="container" style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 24, fontWeight: 800 }}>Neden SkyRes?</div>
          <div style={{ height: 40 }} />
          <div style={{ display: 'flex', gap: 40, justifyContent: 'center', flexWrap: 'wrap' }}>
            <FeatureItem icon="verified_user" title="Güvenli Ödeme" subtitle="3D Secure ile koruma" />
            <FeatureItem icon="price_check" title="En İyi Fiyat" subtitle="Fiyat garantili biletler" />
            <FeatureItem icon="support_agent" title="7/24 Destek" subtitle="Her an yanınızdayız" />
          </div>
        </div>
      </div>
    </div>
  )
}

function FeatureItem({ icon, title, subtitle }: { icon: string; title: string; subtitle: string }) {
  return (
    <div>
      <div style={{ fontSize: 30, color: '#777' }}>★</div>
      <div style={{ height: 10 }} />
      <div style={{ fontWeight: 700 }}>{title}</div>
      <div style={{ fontSize: 12, color: '#777' }}>{subtitle}</div>
    </div>
  )
}

function RouteCard({ code, name, price, image }: { code: string; name: string; price: string; image: string }) {
  const { setQuickTrip, isLoggedIn } = useBooking()
  const onClick = () => {
    setQuickTrip(code)
    if (!isLoggedIn) {
      window.location.href = '/auth'
    } else {
      window.location.href = '/flights'
    }
  }
  return (
    <button onClick={onClick} className="card" style={{ overflow: 'hidden', borderRadius: 20, cursor: 'pointer', border: 'none' }}>
      <div style={{ position: 'relative', height: 160 }}>
        <img src={image} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
        <div style={{ position: 'absolute', top: 10, right: 10, background: 'rgba(255,255,255,0.9)', borderRadius: 8, padding: '4px 8px', color: 'var(--primary)', fontWeight: 700 }}>
          {price}
        </div>
      </div>
      <div style={{ padding: 12, textAlign: 'left' }}>
        <div style={{ fontWeight: 700, fontSize: 16 }}>{name}</div>
        <div style={{ fontSize: 11, color: '#777' }}>Istanbul → {name}</div>
      </div>
    </button>
  )
}
