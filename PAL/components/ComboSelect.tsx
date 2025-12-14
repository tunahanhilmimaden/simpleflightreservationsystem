'use client'
import { useEffect, useMemo, useState } from 'react'

type Props = {
  label: string
  name: string
  value: string
  onChange: (v: string) => void
  options: string[]
  placeholder?: string
}

export default function ComboSelect({ label, name, value, onChange, options, placeholder }: Props) {
  const [query, setQuery] = useState(value || '')
  const [open, setOpen] = useState(false)
  useEffect(() => {
    setQuery(value || '')
  }, [value])
  const filtered = useMemo(() => {
    const s = (query || '').toLowerCase().trim()
    const list = options.filter(o => o.toLowerCase().includes(s))
    return (s ? list : options).slice(0, 10)
  }, [options, query])
  return (
    <div className="fieldControl">
      <div className="fieldLabel">{label}</div>
      <input
        name={name}
        className="fieldInput"
        value={query}
        onFocus={() => setOpen(true)}
        onBlur={() => setTimeout(() => setOpen(false), 120)}
        onChange={e => {
          setQuery(e.target.value)
          setOpen(true)
        }}
        placeholder={placeholder || 'Yazın'}
      />
      {open && (
        <div className="autoList">
          {filtered.map(opt => (
            <div
              key={opt}
              className="autoItem"
              onMouseDown={e => e.preventDefault()}
              onClick={() => {
                onChange(opt)
                setQuery(opt)
                setOpen(false)
              }}
            >
              {opt}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
