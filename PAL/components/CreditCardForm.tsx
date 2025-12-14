'use client'
import { useState } from 'react'

export default function CreditCardForm({ onValidChange }: { onValidChange: (v: boolean) => void }) {
  const [card, setCard] = useState('')
  const [expiry, setExpiry] = useState('')
  const [cvv, setCvv] = useState('')
  const isValid = card.replace(/\s/g, '').length >= 16 && /^\d{2}\/\d{2}$/.test(expiry) && /^\d{3}$/.test(cvv)
  onValidChange(isValid)
  return (
    <div>
      <div style={{ height: 200, borderRadius: 20, backgroundImage: 'linear-gradient(135deg,#1B263B,#415A77)', color: '#fff', boxShadow: '0 10px 15px rgba(0,0,0,0.2)', padding: 25 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          <div>⌁</div>
          <div style={{ fontWeight: 800 }}>BANK</div>
        </div>
        <div style={{ fontSize: 22, letterSpacing: 2, marginTop: 30 }}>{card ? card : '**** **** **** ****'}</div>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 20 }}>
          <div>
            <div style={{ fontSize: 10, opacity: 0.7 }}>Kart Sahibi</div>
            <div style={{ fontSize: 14 }}>SKYRES KULLANICI</div>
          </div>
          <div>
            <div style={{ fontSize: 10, opacity: 0.7 }}>SKT</div>
            <div style={{ fontSize: 14 }}>{expiry || 'MM/YY'}</div>
          </div>
        </div>
      </div>
      <div style={{ height: 25 }} />
      <Input label="Kart Numarası" value={card} onChange={v => setCard(formatCard(v))} maxLength={19} />
      <div style={{ height: 15 }} />
      <div style={{ display: 'flex', gap: 20 }}>
        <Input label="SKT (Ay/Yıl)" value={expiry} onChange={v => setExpiry(formatExpiry(v))} maxLength={5} />
        <Input label="CVV" value={cvv} onChange={v => setCvv(v.replace(/\D/g, '').slice(0, 3))} maxLength={3} />
      </div>
    </div>
  )
}

function Input({ label, value, onChange, maxLength }: { label: string; value: string; onChange: (v: string) => void; maxLength?: number }) {
  return (
    <label style={{ display: 'block', flex: 1 }}>
      <div style={{ fontSize: 12, color: '#777', marginBottom: 6 }}>{label}</div>
      <input value={value} onChange={e => onChange(e.target.value)} maxLength={maxLength} style={{ width: '100%', padding: '12px 14px', borderRadius: 12, border: '1px solid #eee', background: '#F7F9FC' }} />
    </label>
  )
}

function formatCard(v: string) {
  const t = v.replace(/\D/g, '').slice(0, 16)
  return t.replace(/(.{4})/g, '$1 ').trim()
}
function formatExpiry(v: string) {
  const t = v.replace(/\D/g, '').slice(0, 4)
  if (t.length <= 2) return t
  return t.slice(0, 2) + '/' + t.slice(2)
}
