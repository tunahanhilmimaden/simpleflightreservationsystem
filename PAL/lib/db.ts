import sql from 'mssql'

type DbConfig = {
  server?: string
  port?: number
  database?: string
  user?: string
  password?: string
  options?: {
    encrypt?: boolean
    trustServerCertificate?: boolean
  }
}

let poolPromise: Promise<sql.ConnectionPool> | null = null

function buildConfigFromEnv(): DbConfig {
  const encrypt =
    process.env.DB_ENCRYPT?.toLowerCase() === 'true' ||
    process.env.DB_ENCRYPT === '1'
  const trust =
    process.env.DB_TRUST_SERVER_CERTIFICATE?.toLowerCase() === 'true' ||
    process.env.DB_TRUST_SERVER_CERTIFICATE === '1'
  const port = process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 1433
  return {
    server: process.env.DB_SERVER,
    port,
    database: process.env.DB_DATABASE,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    options: {
      encrypt,
      trustServerCertificate: trust
    }
  }
}

export async function getPool() {
  if (!poolPromise) {
    const connStr = process.env.DB_CONN_STR
    if (connStr) {
      poolPromise = sql.connect(connStr)
    } else {
      const cfg = buildConfigFromEnv()
      poolPromise = sql.connect({
        server: cfg.server!,
        port: cfg.port!,
        database: cfg.database!,
        user: cfg.user!,
        password: cfg.password!,
        options: {
          encrypt: cfg.options?.encrypt ?? true,
          trustServerCertificate: cfg.options?.trustServerCertificate ?? true
        }
      })
    }
  }
  return poolPromise
}

export async function ping() {
  const pool = await getPool()
  const result = await pool.request().query('SELECT 1 AS ok')
  return result.recordset[0].ok === 1
}
