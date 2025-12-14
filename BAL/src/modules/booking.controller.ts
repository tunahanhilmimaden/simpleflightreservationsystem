import { Body, Controller, Get, Post, Query } from '@nestjs/common'
import { ApiBody, ApiOperation, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger'
import { getPool } from '../db'

@ApiTags('booking')
@Controller('booking')
export class BookingController {
  @Get('summary')
  @ApiOperation({ summary: 'Rezervasyon özeti' })
  @ApiQuery({ name: 'bookingId', required: true, type: Number, example: 5001 })
  @ApiResponse({ status: 200 })
  async summary(@Query('bookingId') bookingId: string) {
    const pool = await getPool()
    const res = await pool.request().input('BookingId', parseInt(bookingId, 10)).execute('FlightReservationSystem.sp_Booking_GetSummary')
    return res.recordset[0] ?? null
  }

  @Get('quote')
  @ApiOperation({ summary: 'Uçuş + koltuklara göre fiyat teklifi' })
  @ApiQuery({ name: 'flightId', required: true, type: Number, example: 1001 })
  @ApiQuery({ name: 'seatNumbers', required: true, description: 'Virgülle ayrılmış koltuk numaraları (örn: 1A,1B,2C)' })
  @ApiResponse({ status: 200 })
  async quote(@Query('flightId') flightId: string, @Query('seatNumbers') seatNumbers: string) {
    const pool = await getPool()
    const res = await pool
      .request()
      .input('FlightId', parseInt(flightId, 10))
      .input('SeatNumbers', seatNumbers)
      .execute('FlightReservationSystem.sp_Booking_Quote')
    return res.recordset
  }

  @Post('create')
  @ApiOperation({ summary: 'Çoklu yolcu için rezervasyon kayıtları oluştur' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        flightId: { type: 'number', example: 1001 },
        passengers: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              first: { type: 'string', example: 'John' },
              last: { type: 'string', example: 'Doe' },
              seatNumber: { type: 'string', example: '12C' }
            },
            required: ['first', 'last', 'seatNumber']
          }
        }
      },
      required: ['flightId', 'passengers']
    }
  })
  @ApiResponse({ status: 200 })
  async create(@Body() body: { flightId: number; passengers: Array<{ first: string; last: string; seatNumber: string }> }) {
    const pool = await getPool()
    const res = await pool
      .request()
      .input('FlightId', Number(body.flightId))
      .input('PassengerJson', JSON.stringify(body.passengers || []))
      .execute('FlightReservationSystem.sp_Booking_CreateBulk')
    return res.recordset
  }

  @Get('by-seat')
  @ApiOperation({ summary: 'Uçuş ve koltuk numarasına göre rezervasyonlar' })
  @ApiQuery({ name: 'flightId', required: true, type: Number, example: 1001 })
  @ApiQuery({ name: 'seatNumber', required: true, example: '12C' })
  @ApiResponse({ status: 200 })
  async bySeat(@Query('flightId') flightId: string, @Query('seatNumber') seatNumber: string) {
    const pool = await getPool()
    const res = await pool
      .request()
      .input('FlightId', parseInt(flightId, 10))
      .input('SeatNumber', seatNumber)
      .execute('FlightReservationSystem.sp_Booking_GetBySeat')
    return res.recordset
  }

  @Get('by-name')
  @ApiOperation({ summary: 'Ada göre rezervasyon arama' })
  @ApiQuery({ name: 'name', required: true, example: 'John' })
  @ApiResponse({ status: 200 })
  async byName(@Query('name') name: string) {
    const pool = await getPool()
    const res = await pool.request().input('Name', name).execute('FlightReservationSystem.sp_Booking_SearchByName')
    return res.recordset
  }
}
