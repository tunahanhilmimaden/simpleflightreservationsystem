import { Controller, Get, Query } from '@nestjs/common'
import { ApiOperation, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger'
import { getPool } from '../db'

@ApiTags('seats')
@Controller('seats')
export class SeatsController {
  @Get('by-flight')
  @ApiOperation({ summary: 'Uçuşa göre koltuk listesi' })
  @ApiQuery({ name: 'flightId', required: true, type: Number })
  @ApiResponse({ status: 200 })
  async byFlight(@Query('flightId') flightId: string) {
    const pool = await getPool()
    const res = await pool.request().input('FlightId', parseInt(flightId, 10)).execute('FlightReservationSystem.sp_Seat_ListByFlight')
    return res.recordset
  }

  @Get('available')
  @ApiOperation({ summary: 'Uçuşa göre müsait koltuk sayısı' })
  @ApiQuery({ name: 'flightId', required: true, type: Number, example: 1001 })
  @ApiResponse({ status: 200 })
  async available(@Query('flightId') flightId: string) {
    const pool = await getPool()
    const res = await pool.request().input('FlightId', parseInt(flightId, 10)).execute('FlightReservationSystem.sp_Flight_AvailableSeats')
    const row = res.recordset[0]
    return { availableSeats: row ? row.availableSeats : 0 }
  }

  @Get('map')
  @ApiOperation({ summary: 'Uçuşa göre koltuk sınıf ve fiyat haritası' })
  @ApiQuery({ name: 'flightId', required: true, type: Number, example: 1001 })
  @ApiResponse({ status: 200 })
  async map(@Query('flightId') flightId: string) {
    const pool = await getPool()
    const res = await pool.request().input('FlightId', parseInt(flightId, 10)).execute('FlightReservationSystem.sp_Seat_ListWithPricing')
    return res.recordset
  }

  @Get('price')
  @ApiOperation({ summary: 'Seçilen koltuk için fiyat bilgisi' })
  @ApiQuery({ name: 'flightId', required: true, type: Number, example: 1001 })
  @ApiQuery({ name: 'seatId', required: true, description: 'SeatID (numeric) veya SeatNumber (örn: 1A)', example: '20001' })
  @ApiResponse({ status: 200 })
  async price(@Query('flightId') flightId: string, @Query('seatId') seatId: string) {
    const pool = await getPool()
    const req = pool.request().input('FlightId', parseInt(flightId, 10))
    let res
    if (/^\d+$/.test(seatId)) {
      res = await req.input('SeatId', parseInt(seatId, 10)).execute('FlightReservationSystem.sp_Seat_GetPrice')
    } else {
      // Expect formats like "191-1A" or "1A" -> extract seat number part
      const parts = String(seatId).split('-')
      const seatNumber = parts.length > 1 ? parts[1] : parts[0]
      res = await req.input('SeatNumber', seatNumber).execute('FlightReservationSystem.sp_Seat_GetPriceByNumber')
    }
    const row = res.recordset?.[0]
    if (!row) return { seatPrice: 0 }
    return {
      seatId: row.SeatID,
      seatNumber: row.SeatNumber,
      className: row.ClassName,
      basePrice: row.BasePrice,
      priceMultiplier: row.PriceMultiplier,
      seatPrice: row.SeatPrice,
      surcharge: row.Surcharge
    }
  }
}
