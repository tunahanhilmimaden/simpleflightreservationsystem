import { Body, Controller, Post } from '@nestjs/common'
import { ApiBody, ApiOperation, ApiResponse, ApiTags, ApiQuery } from '@nestjs/swagger'
import { getPool } from '../db'

@ApiTags('activity')
@Controller('activity')
export class ActivityController {
  @Post('log')
  @ApiOperation({ summary: 'Activity log kaydı' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        action: { type: 'string', example: 'page_view' },
        description: { type: 'string', example: 'http://localhost:3000/flights — viewed flights page' },
        payload: { type: 'object', example: { query: 'IST-LHR', date: '2025-12-14' } },
        userId: { type: 'number', example: 42 }
      },
      required: ['action', 'description']
    }
  })
  @ApiResponse({ status: 200 })
  async log(@Body() body: { action: string; description: string; payload?: any; userId?: number }) {
    try {
      const pool = await getPool()
      await pool
        .request()
        .input('Action', body.action)
        .input('Description', body.description)
        .input('Payload', body.payload ? JSON.stringify(body.payload) : null)
        .input('UserID', typeof body.userId === 'number' ? body.userId : null)
        .execute('GeneralCommon.sp_Activity_Log')
      return { ok: true }
    } catch (e: any) {
      try {
        const pool = await getPool()
        const colsRes = await pool.request().query(`
          SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_SCHEMA='GeneralCommon' AND TABLE_NAME='ActivityLog'
        `)
        const cols = new Set((colsRes.recordset || []).map((r: any) => String(r.COLUMN_NAME)))
        const hasUserId = cols.has('UserID')
        const hasLogDate = cols.has('LogDate')
        const fields = ['Action', 'Description']
        const values = ['@Action', '@Description']
        if (hasUserId) { fields.push('UserID'); values.push('@UserID') }
        if (hasLogDate) { fields.push('LogDate'); values.push('SYSUTCDATETIME()') }
        const sql = `INSERT INTO GeneralCommon.ActivityLog (${fields.map(f => `[${f}]`).join(', ')}) VALUES (${values.join(', ')})`
        await pool
          .request()
          .input('Action', body.action)
          .input('Description', body.description)
          .input('UserID', typeof body.userId === 'number' ? body.userId : null)
          .query(sql)
        return { ok: true, fallback: true }
      } catch (e2: any) {
        return { ok: false, error: String(e2?.message || e2) }
      }
    }
  }

  @ApiOperation({ summary: 'Activity log listesi' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 50 })
  @ApiQuery({ name: 'userId', required: false, type: Number, example: 42 })
  @ApiResponse({ status: 200 })
  @Post('list')
  async list(@Body() body: { limit?: number; userId?: number }) {
    const pool = await getPool()
    const limit = body?.limit && body.limit > 0 ? body.limit : 50
    const where = typeof body?.userId === 'number' ? 'WHERE UserID = @UserID' : ''
    const sql = `
      SELECT TOP (@Limit) *
      FROM GeneralCommon.ActivityLog
      ${where}
      ORDER BY CreatedAt DESC
    `
    const req = pool.request().input('Limit', Number(limit))
    if (typeof body?.userId === 'number') req.input('UserID', Number(body.userId))
    const res = await req.query(sql)
    return res.recordset
  }
}
