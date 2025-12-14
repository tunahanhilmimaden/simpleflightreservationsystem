'use client'

type Seat = {
  seatID: string
  seatNumber: string
  isBooked: boolean
  classType: 'First' | 'Business' | 'Economy'
}

export default function SeatMap({
  flightId,
  selectedSeatIds,
  onToggleSeat,
  capacity = 24,
  seatsData
}: {
  flightId: string
  selectedSeatIds: string[]
  onToggleSeat: (seatId: string) => void
  capacity?: number
  seatsData?: Array<{ SeatID: string; SeatNumber: string; ClassName: string }>
}) {
  const letters = ['A', 'B', 'C', 'D', 'E', 'F']
  let rows: Record<number, Seat[]> = {}
  if (seatsData && seatsData.length) {
    const normalize = (name: string) => {
      const n = (name || '').toLowerCase()
      if (n.includes('first')) return 'First'
      if (n.includes('business')) return 'Business'
      return 'Economy'
    }
    const toRowNum = (seatNumber: string) => parseInt(seatNumber.replace(/[^0-9]/g, ''), 10)
    const byClass: Record<'First' | 'Business' | 'Economy', Array<{ SeatID: string; SeatNumber: string; ClassName: string }>> = {
      First: [],
      Business: [],
      Economy: []
    }
    for (const s of seatsData) {
      const cls = normalize(s.ClassName) as 'First' | 'Business' | 'Economy'
      byClass[cls].push(s)
    }
    rows = {}
    const pushGroup = (group: Array<{ SeatID: string; SeatNumber: string; ClassName: string }>, classType: Seat['classType']) => {
      const map: Record<number, Seat[]> = {}
      for (const s of group) {
        const rn = toRowNum(s.SeatNumber)
        const L = s.SeatNumber.replace(/[0-9]/g, '')
        const seat: Seat = { seatID: s.SeatID, seatNumber: s.SeatNumber, isBooked: false, classType }
        map[rn] = map[rn] || []
        map[rn].push(seat)
      }
      const orderedRowNums = Object.keys(map)
        .map(Number)
        .sort((a, b) => a - b)
      for (const rn of orderedRowNums) {
        const arr = map[rn]
        const ordered = letters
          .map(L => arr.find(x => x.seatNumber.endsWith(L)))
          .filter(Boolean) as Seat[]
        rows[rn] = ordered
      }
    }
    pushGroup(byClass.First, 'First')
    pushGroup(byClass.Business, 'Business')
    pushGroup(byClass.Economy, 'Economy')
  } else {
    const totalRows = Math.max(1, Math.ceil(capacity / 6))
    rows = {}
    for (let r = 1; r <= totalRows; r++) {
      const classType: Seat['classType'] = r <= 2 ? 'First' : r <= 6 ? 'Business' : 'Economy'
      rows[r] = letters.map(L => ({
        seatID: `${flightId}-${r}${L}`,
        seatNumber: `${r}${L}`,
        isBooked: false,
        classType
      }))
    }
  }
  return (
    <div style={{ width: 320, background: '#fff', borderRadius: '160px 160px 40px 40px', boxShadow: '0 10px 30px rgba(0,0,0,0.1)', paddingBottom: 60 }}>
      <div style={{ height: 60 }} />
      <div style={{ textAlign: 'center', color: '#bbb', fontSize: 50 }}>✈️</div>
      <div style={{ height: 20 }} />
      <ClassBadge text="FIRST CLASS" color="#FFD700" />
      {[1, 2].filter(r => rows[r]).map(r => (
        <SeatRow key={r} rowNum={r} seats={rows[r]} classType="First" selectedSeatIds={selectedSeatIds} onToggleSeat={onToggleSeat} />
      ))}
      <div style={{ height: 20 }} />
      <ClassBadge text="BUSINESS CLASS" color="#0D47A1" />
      {[3, 4, 5, 6].filter(r => rows[r]).map(r => (
        <SeatRow key={r} rowNum={r} seats={rows[r]} classType="Business" selectedSeatIds={selectedSeatIds} onToggleSeat={onToggleSeat} />
      ))}
      <div style={{ height: 20 }} />
      <ClassBadge text="ECONOMY CLASS" color="#03A9F4" />
      {Object.keys(rows)
        .map(Number)
        .filter(r => r > 6)
        .map(r => (
          <SeatRow key={r} rowNum={r} seats={rows[r]} classType="Economy" selectedSeatIds={selectedSeatIds} onToggleSeat={onToggleSeat} />
        ))}
    </div>
  )
}

function ClassBadge({ text, color }: { text: string; color: string }) {
  return (
    <div style={{ margin: '10px 0', padding: '5px 15px', borderRadius: 20, border: `1px solid ${color}`, color, background: `${color}1A`, width: 'fit-content', marginLeft: 'auto', marginRight: 'auto' }}>
      {text}
    </div>
  )
}

function SeatRow({
  rowNum,
  seats,
  classType,
  selectedSeatIds,
  onToggleSeat
}: {
  rowNum: number
  seats: Seat[]
  classType: 'First' | 'Business' | 'Economy'
  selectedSeatIds: string[]
  onToggleSeat: (seatId: string) => void
}) {
  const isPremium = classType === 'First' || classType === 'Business'
  const renderSeat = (i: number) => {
    const seat = seats[i]
    if (!seat) return <div style={{ width: 30, height: 30 }} />
    return <SeatItem seat={seat} classType={classType} selected={selectedSeatIds.includes(String(seat.seatID))} onToggleSeat={onToggleSeat} />
  }
  return (
    <div style={{ marginBottom: isPremium ? 15 : 8, padding: '0 10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
      <Window left />
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: isPremium ? 10 : 4 }}>
        {renderSeat(0)}
        {renderSeat(1)}
        {renderSeat(2)}
        <div style={{ width: 40, textAlign: 'center', color: '#ccc', fontWeight: 700 }}>{rowNum}</div>
        {renderSeat(3)}
        {renderSeat(4)}
        {renderSeat(5)}
      </div>
      <Window />
    </div>
  )
}

function SeatItem({
  seat,
  classType,
  selected,
  onToggleSeat
}: {
  seat: Seat
  classType: 'First' | 'Business' | 'Economy'
  selected: boolean
  onToggleSeat: (seatId: string) => void
}) {
  let color = '#fff'
  let border = '#ddd'
  let textColor = '#777'
  if (seat.isBooked) {
    color = '#e0e0e0'
    border = 'transparent'
  } else if (selected) {
    color = '#FF9F1C'
    border = '#FF9F1C'
    textColor = '#000'
  } else if (classType === 'First') {
    color = '#FFF8E1'
    border = '#FFD700'
    textColor = '#000'
  } else if (classType === 'Business') {
    color = '#E8EAF6'
    border = '#3949AB'
    textColor = '#333'
  }
  const size = 30
  return (
    <button
      onClick={() => (seat.isBooked ? null : onToggleSeat(String(seat.seatID)))}
      style={{
        width: size,
        height: size,
        background: color,
        borderRadius: 10,
        border: `2px solid ${border}`,
        boxShadow: selected || classType === 'First' ? `0 0 8px ${border}66` : 'none',
        cursor: seat.isBooked ? 'not-allowed' : 'pointer'
      }}
    >
      {seat.isBooked ? '×' : seat.seatNumber.replace(/[0-9]/g, '')}
    </button>
  )
}

function Window({ left }: { left?: boolean }) {
  return <div style={{ width: 6, height: 20, background: '#B3E5FC', borderRadius: left ? '10px 0 0 10px' : '0 10px 10px 0' }} />
}
