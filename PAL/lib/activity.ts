export async function logActivity(action: string, description: string, payload?: any, userId?: number) {
  try {
    const body = { action, description, payload, userId }
    await fetch('http://localhost:4000/api/activity/log', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    })
  } catch {}
}

export async function logActivityList(limit?: number, userId?: number) {
  try {
    const body: any = {}
    if (typeof limit === 'number') body.limit = limit
    if (typeof userId === 'number') body.userId = userId
    const res = await fetch('http://localhost:4000/api/activity/list', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    })
    const data = await res.json()
    console.log('ActivityLog list', data)
  } catch {}
}
