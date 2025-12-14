import { Body, Controller, Post } from '@nestjs/common'
import { ApiBody, ApiOperation, ApiResponse, ApiTags, ApiProperty } from '@nestjs/swagger'
import { getPool } from '../db'

class ParkingDto {
  @ApiProperty({ example: 'Otomobil' })
  vehicleType!: string
  @ApiProperty({ example: '2025-12-15' })
  startDate!: string
  @ApiProperty({ example: '2025-12-18' })
  endDate!: string
}

@ApiTags('parking')
@Controller('parking')
export class ParkingController {
  @Post('calculate')
  @ApiOperation({ summary: 'Otopark ücret hesaplama' })
  @ApiBody({ type: ParkingDto })
  @ApiResponse({ status: 200 })
  async calculate(@Body() dto: ParkingDto) {
    const pool = await getPool()
    const res = await pool
      .request()
      .input('VehicleType', dto.vehicleType)
      .input('StartDate', dto.startDate)
      .input('EndDate', dto.endDate)
      .execute('AirportParkingSystem.sp_Parking_Calculate')
    return res.recordset[0]
  }
}
