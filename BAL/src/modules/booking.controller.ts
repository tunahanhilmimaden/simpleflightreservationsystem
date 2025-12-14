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

  @Post('reserve')
  @ApiOperation({ summary: 'Rezervasyon kaydı oluştur (Tamamlanmadı)' })
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
              last: { type: 'string', example: 'Doe' }
            },
            required: ['first', 'last']
          }
        }
      },
      required: ['flightId']
    }
  })
  @ApiResponse({ status: 200 })
  async reserve(
    @Body() body: { flightId: number; passengers?: Array<{ first: string; last: string }> }
  ) {
    const pool = await getPool()
    const resReservation = await pool
      .request()
      .input('FlightId', Number(body.flightId))
      .execute('FlightReservationSystem.sp_Reservation_Create_Simple')
    const reservation = resReservation.recordset?.[0] ?? null
    const reservationId = reservation?.ReservationID
    try {
      if (reservationId) {
        const minimal = Array.isArray(body.passengers)
          ? body.passengers.map(p => ({ first: String(p.first || ''), last: String(p.last || '') }))
          : []
        await pool
          .request()
          .input('ReservationId', Number(reservationId))
          .input('PassengersJson', JSON.stringify(minimal))
          .execute('FlightReservationSystem.sp_Passengers_InsertBulk_Simple')
      }
    } catch {}
    return reservation
  }

  @Post('reservation_create')
  @ApiOperation({ summary: 'Basit rezervasyon oluştur' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        flightId: { type: 'number', example: 1001 },
        userId: { type: 'number', example: 42 },
        totalAmount: { type: 'number', example: 1650.0 }
      },
      required: ['flightId']
    }
  })
  @ApiResponse({ status: 200 })
  async reservationCreate(@Body() body: { flightId: number; userId?: number; totalAmount?: number }) {
    try {
      const pool = await getPool()
      const userIdParam = body.userId && body.userId > 0 ? Number(body.userId) : null
      const res = await pool
        .request()
        .input('UserID', userIdParam as any)
        .input('FlightID', Number(body.flightId))
        .input('Status', 'Bekleyen')
        .input('TotalAmount', Number(body.totalAmount ?? 0))
        .execute('FlightReservationSystem.sp_Reservation_Create_Simple')
      const out = res.recordset?.[0] ?? null
      try {
        await pool
          .request()
          .input('Action', 'reservation_create')
          .input('Description', `flight=${body.flightId}`)
          .input('Payload', JSON.stringify({ in: body, out }))
          .input('UserID', userIdParam as any)
          .execute('GeneralCommon.sp_Activity_Log')
      } catch {}
      return out
    } catch (e: any) {
      return { error: String(e?.message || e) }
    }
  }

  @Post('passengers_simple')
  @ApiOperation({ summary: 'Basit yolcu kayıtları ekle' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        reservationId: { type: 'number', example: 123 },
        passengers: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              first: { type: 'string', example: 'John' },
              last: { type: 'string', example: 'Doe' },
              passportNo: { type: 'string', example: 'U1234567' },
              age: { type: 'number', example: 29 },
              gender: { type: 'string', example: 'Erkek' },
              nationality: { type: 'string', example: 'TR' }
            }
          }
        }
      },
      required: ['reservationId', 'passengers']
    }
  })
  @ApiResponse({ status: 200 })
  async passengersSimple(@Body() body: { reservationId: number; passengers: Array<{ first: string; last: string; passportNo?: string; age?: number; gender?: string; nationality?: string }> }) {
    try {
      const reservationId = Number(body.reservationId)
      const passengers = Array.isArray(body.passengers) ? body.passengers : []
      if (!reservationId || reservationId <= 0 || passengers.length === 0) {
        return { ok: false, error: 'Geçersiz giriş' }
      }
      const pool = await getPool()
      await pool
        .request()
        .input('ReservationId', reservationId)
        .input('PassengersJson', JSON.stringify(passengers))
        .execute('FlightReservationSystem.sp_Passengers_InsertBulk_Simple')
      try {
        await pool
          .request()
          .input('Action', 'passengers_simple')
          .input('Description', `reservation=${reservationId}`)
          .input('Payload', JSON.stringify({ in: body }))
          .input('UserID', null)
          .execute('GeneralCommon.sp_Activity_Log')
      } catch {}
      return { ok: true }
    } catch (e: any) {
      return { ok: false, error: String(e?.message || e) }
    }
  }

  @Post('issue')
  @ApiOperation({ summary: 'Rezervasyon için biletleri üret ve rezervasyonu tamamla' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        reservationId: { type: 'number', example: 123 },
        flightId: { type: 'number', example: 1001 },
        tickets: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              first: { type: 'string', example: 'John' },
              last: { type: 'string', example: 'Doe' },
              seatNumber: { type: 'string', example: '12C' },
              boardingGate: { type: 'string', example: 'C1' },
              ticketStatus: { type: 'string', example: 'Issued' }
            }
          }
        }
      },
      required: ['reservationId', 'flightId', 'tickets']
    }
  })
  @ApiResponse({ status: 200 })
  async issue(@Body() body: { reservationId: number; flightId: number; tickets: Array<{ first: string; last: string; seatNumber: string; boardingGate?: string; ticketStatus?: string }> }) {
    const pool = await getPool()
    await pool
      .request()
      .input('ReservationId', Number(body.reservationId))
      .input('FlightId', Number(body.flightId))
      .input('TicketsJson', JSON.stringify(body.tickets || []))
      .execute('FlightReservationSystem.sp_Tickets_IssueForReservation')
    try {
      await pool
        .request()
        .input('Action', 'issue_tickets')
        .input('Description', `reservation=${body.reservationId}, flight=${body.flightId}`)
        .input('Payload', JSON.stringify({ in: body }))
        .input('UserID', null)
        .execute('GeneralCommon.sp_Activity_Log')
    } catch {}
    return { ok: true }
  }

  @Get('tickets')
  @ApiOperation({ summary: 'Rezervasyon ID ile biletleri listele' })
  @ApiQuery({ name: 'reservationId', required: true, type: Number, example: 123 })
  @ApiResponse({ status: 200 })
  async tickets(@Query('reservationId') reservationId: string) {
    try {
      const pool = await getPool()
      const res = await pool
        .request()
        .input('ReservationId', parseInt(reservationId, 10))
        .execute('FlightReservationSystem.sp_Tickets_GetByReservation')
      return res.recordset
    } catch (e: any) {
      return { ok: false, error: String(e?.message || e) }
    }
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
