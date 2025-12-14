import { Controller, Get, Query } from '@nestjs/common'
import { ApiOperation, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger'
import { getPool } from '../db'

@ApiTags('flights')
@Controller('flights')
export class FlightsController {
  @Get('airports')
  @ApiOperation({ summary: 'Havalimanı listesi' })
  @ApiResponse({ status: 200 })
  async airports() {
    const pool = await getPool()
    const res = await pool.request().execute('FlightReservationSystem.sp_Airport_List')
    return res.recordset
  }

  @Get('airportlist')
  @ApiOperation({ summary: 'Havalimanı listesi (alternatif uç nokta)' })
  @ApiResponse({ status: 200 })
  async airportlist() {
    const pool = await getPool()
    const res = await pool.request().execute('FlightReservationSystem.sp_Airport_List')
    return res.recordset
  }

  @Get('search')
  @ApiOperation({ summary: 'Uçuş arama' })
  @ApiQuery({ name: 'origin', required: true, example: 'IST' })
  @ApiQuery({ name: 'dest', required: true, example: 'LHR' })
  @ApiQuery({ name: 'date', required: true, description: 'YYYY-MM-DD', example: '2025-12-15' })
  @ApiResponse({ status: 200 })
  async search(@Query('origin') origin: string, @Query('dest') dest: string, @Query('date') date: string) {
    const pool = await getPool()
    const res = await pool
      .request()
      .input('Origin', origin)
      .input('Dest', dest)
      .input('Date', date)
      .execute('FlightReservationSystem.sp_Flight_Search')
    return res.recordset
  }

  @Get('min-prices')
  @ApiOperation({ summary: 'Günlere göre minimum fiyatlar' })
  @ApiQuery({ name: 'origin', required: true, example: 'IST' })
  @ApiQuery({ name: 'dest', required: true, example: 'LHR' })
  @ApiQuery({ name: 'startDate', required: true, example: '2025-12-15' })
  @ApiQuery({ name: 'days', required: true, type: Number, example: 5 })
  @ApiResponse({ status: 200 })
  async minPrices(
    @Query('origin') origin: string,
    @Query('dest') dest: string,
    @Query('startDate') startDate: string,
    @Query('days') days: string
  ) {
    const pool = await getPool()
    const res = await pool
      .request()
      .input('Origin', origin)
      .input('Dest', dest)
      .input('StartDate', startDate)
      .input('Days', parseInt(days, 10))
      .execute('FlightReservationSystem.sp_MinPriceForDates')
    return res.recordset
  }

  @Get('detail')
  @ApiOperation({ summary: 'Uçuş detayları' })
  @ApiQuery({ name: 'flightId', required: true, type: Number, example: 1001 })
  @ApiResponse({ status: 200 })
  async detail(@Query('flightId') flightId: string) {
    const pool = await getPool()
    const res = await pool.request().input('FlightId', parseInt(flightId, 10)).execute('FlightReservationSystem.sp_Flight_GetDetail')
    return res.recordset?.[0] ?? null
  }
}
