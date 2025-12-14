'use client'
export default function QRBox({ data, size = 120, modules = 21 }: { data: string; size?: number; modules?: number }) {
  const gridSize = modules
  const cell = Math.floor(size / gridSize)
  const hash = Array.from(data).reduce((h, ch) => ((h << 5) - h + ch.charCodeAt(0)) | 0, 5381) >>> 0
  const rnd = (i: number, j: number) => {
    let x = (hash ^ (i * 374761393 + j * 668265263)) >>> 0
    x = (x ^ (x >> 13)) >>> 0
    x = (x * 1274126177) >>> 0
    return x & 1
  }
  const quiet = 2
  const pattern: boolean[][] = []
  for (let i = 0; i < gridSize; i++) {
    pattern[i] = []
    for (let j = 0; j < gridSize; j++) {
      const finder =
        (i < 7 && j < 7) ||
        (i < 7 && j >= gridSize - 7) ||
        (i >= gridSize - 7 && j < 7)
      const ring =
        (finder && (i === 0 || j === 0 || i === 6 || j === 6 || i === gridSize - 1 || j === gridSize - 1))
      const center = finder && i >= 2 && i <= 4 && j >= 2 && j <= 4
      pattern[i][j] = finder ? ring || center : i >= quiet && j >= quiet && i < gridSize - quiet && j < gridSize - quiet ? rnd(i, j) === 1 : false
    }
  }
  return (
    <svg width={size} height={size} viewBox={`0 0 ${gridSize * cell} ${gridSize * cell}`}>
      <rect x="0" y="0" width={gridSize * cell} height={gridSize * cell} fill="#fff" />
      {pattern.map((row, i) =>
        row.map((on, j) =>
          on ? <rect key={`${i}-${j}`} x={j * cell} y={i * cell} width={cell} height={cell} fill="#000" /> : null
        )
      )}
    </svg>
  )
}
