'use client'
import { useState } from 'react'
import { useBooking } from '../../lib/bookingStore'
import { useRouter } from 'next/navigation'

export default function AuthPage() {
  const [isLogin, setIsLogin] = useState(true)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [name, setName] = useState('')
  const [phone, setPhone] = useState('')
  const { register, login, setRemoteUser } = useBooking()
  const router = useRouter()
  const submit = () => {
    if (!isLogin) {
      const digits = phone.replace(/\D/g, '')
      if (digits.length < 10) {
        alert('Telefon numarası eksik veya geçersiz')
        return
      }
    }
    if (isLogin) {
      fetch('http://localhost:4000/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.trim(), password: password.trim() })
      })
        .then(async r => {
          const data = await r.json()
          if (data && !data.error) {
            const u = { name: data.Name ?? name.trim(), email: data.Email ?? email.trim(), password: '', phone: data.Phone ?? '' }
            setRemoteUser(u)
            try {
              sessionStorage.setItem('user', JSON.stringify(u))
            } catch {}
            router.push('/')
          } else {
            alert('E-posta veya şifre hatalı!')
          }
        })
        .catch(() => alert('Sunucuya bağlanılamadı'))
      return
    }
    fetch('http://localhost:4000/api/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: name.trim(), email: email.trim(), password: password.trim(), phone: phone.trim() })
    })
      .then(async r => {
        const data = await r.json()
        if (data && !data.error) {
          setIsLogin(true)
          setPassword('')
          alert('Kayıt başarılı. Lütfen giriş yapın.')
        } else {
          alert(data.error === 'email_exists' ? 'Bu e-posta adresi zaten kayıtlı!' : 'Kayıt sırasında hata oluştu')
        }
      })
      .catch(() => alert('Sunucuya bağlanılamadı'))
  }
  return (
    <div style={{ minHeight: '100vh', display: 'grid', placeItems: 'center', backgroundImage: 'linear-gradient(135deg,#023E8A,#0096C7)' }}>
      <div className="card" style={{ width: '100%', maxWidth: 420, padding: 30 }}>
        <div style={{ fontSize: 24, fontWeight: 800, color: '#023E8A' }}>{isLogin ? 'Giriş Yap' : 'Kayıt Ol'}</div>
        <div style={{ height: 10 }} />
        <div style={{ color: '#777', fontSize: 14 }}>{isLogin ? 'Devam etmek için giriş yapın' : 'Hızlıca yeni hesap oluşturun'}</div>
        <div style={{ height: 30 }} />
        {!isLogin && (
          <>
            <Input label="Ad Soyad" value={name} onChange={setName} type="text" />
            <div style={{ height: 20 }} />
            <Input label="Telefon" value={phone} onChange={setPhone} type="tel" />
            <div style={{ height: 20 }} />
          </>
        )}
        <Input label="E-posta" value={email} onChange={setEmail} type="email" />
        <div style={{ height: 20 }} />
        <Input label="Şifre" value={password} onChange={setPassword} type="password" />
        <div style={{ height: 30 }} />
        <button className="btn" style={{ width: '100%', height: 50, borderRadius: 12 }} onClick={submit}>
          {isLogin ? 'GİRİŞ YAP' : 'KAYIT OL'}
        </button>
        <div style={{ height: 20 }} />
        <button
          onClick={() => {
            setIsLogin(!isLogin)
            setEmail('')
            setPassword('')
            setName('')
            setPhone('')
          }}
          style={{ background: 'transparent', border: 'none', color: '#777', cursor: 'pointer' }}
        >
          {isLogin ? 'Hesabın yok mu? Kayıt Ol' : 'Zaten hesabın var mı? Giriş Yap'}
        </button>
      </div>
    </div>
  )
}

function Input({ label, value, onChange, type }: { label: string; value: string; onChange: (v: string) => void; type: string }) {
  return (
    <label style={{ display: 'block' }}>
      <div style={{ fontSize: 12, color: '#777', marginBottom: 6 }}>{label}</div>
      <input
        value={value}
        onChange={e => onChange(e.target.value)}
        type={type}
        style={{ width: '100%', padding: '12px 14px', borderRadius: 12, border: '1px solid #eee', background: '#F7F9FC' }}
      />
    </label>
  )
}
