import { Controller, Get } from '@nestjs/common'
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger'
import { getPool } from '../db'

@ApiTags('health')
@Controller('health')
export class HealthController {
  @Get()
  @ApiOperation({ summary: 'DB ping' })
  @ApiResponse({ status: 200, description: 'OK' })
  async ok() {
    const pool = await getPool()
    const res = await pool.request().query('SELECT 1 AS ok')
    return { ok: res.recordset[0].ok === 1 }
  }
}
