import { NextResponse } from 'next/server'
import { ping } from '../../../lib/db'

export async function GET() {
  try {
    const ok = await ping()
    return NextResponse.json({ ok }, { status: 200 })
  } catch (e) {
    return NextResponse.json({ ok: false, error: 'db_connect_error' }, { status: 500 })
  }
}
