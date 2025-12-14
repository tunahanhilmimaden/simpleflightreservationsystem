import 'reflect-metadata'
import * as sql from 'mssql'

let poolPromise: Promise<sql.ConnectionPool> | null = null

function bool(v: string | undefined, d = true) {
  if (v === undefined) return d
  const s = v.toLowerCase()
  return s === 'true' || s === '1'
}

function int(v: string | undefined, d: number) {
  if (!v) return d
  const n = parseInt(v, 10)
  return Number.isNaN(n) ? d : n
}

export async function getPool() {
  if (!poolPromise) {
    const connStr = process.env.DB_CONN_STR
    if (connStr) {
      poolPromise = sql.connect(connStr)
    } else {
      poolPromise = sql.connect({
        server: process.env.DB_SERVER!,
        port: int(process.env.DB_PORT, 1433),
        database: process.env.DB_DATABASE!,
        user: process.env.DB_USER!,
        password: process.env.DB_PASSWORD!,
        options: {
          encrypt: bool(process.env.DB_ENCRYPT, true),
          trustServerCertificate: bool(process.env.DB_TRUST_SERVER_CERTIFICATE, true)
        }
      })
    }
  }
  return poolPromise
}
