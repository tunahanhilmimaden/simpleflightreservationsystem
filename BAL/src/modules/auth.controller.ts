import { Body, Controller, Post } from '@nestjs/common'
import { ApiBody, ApiOperation, ApiResponse, ApiTags, ApiProperty } from '@nestjs/swagger'
import { getPool } from '../db'

class LoginDto {
  @ApiProperty({ example: 'user@example.com' })
  email!: string
  @ApiProperty({ example: 'P@ssw0rd123' })
  password!: string
}
class RegisterDto {
  @ApiProperty({ example: 'Jane Doe' })
  name!: string
  @ApiProperty({ example: 'user@example.com' })
  email!: string
  @ApiProperty({ example: 'P@ssw0rd123' })
  password!: string
  @ApiProperty({ example: '+90 555 123 45 67' })
  phone!: string
}

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  @Post('login')
  @ApiOperation({ summary: 'Kullanıcı girişi' })
  @ApiBody({ type: LoginDto })
  @ApiResponse({ status: 200 })
  async login(@Body() dto: LoginDto) {
    const pool = await getPool()
    try {
      const res = await pool
        .request()
        .input('Email', dto.email)
        .input('Password', dto.password)
        .execute('GeneralCommon.sp_User_Login')
      const row = res.recordset[0] || {}
      const UserID = row.UserID ?? row.userId ?? row.Id ?? row.ID ?? null
      const out = {
        UserID,
        Name: row.Name ?? null,
        Email: row.Email ?? dto.email,
        Phone: row.Phone ?? null
      }
      try {
        await pool
          .request()
          .input('Action', 'login')
          .input('Description', `email=${dto.email}`)
          .input('Payload', JSON.stringify({ in: { email: dto.email }, out }))
          .input('UserID', UserID ?? null)
          .execute('GeneralCommon.sp_Activity_Log')
      } catch {}
      return out
    } catch (e: any) {
      return { error: 'invalid_credentials' }
    }
  }

  @Post('register')
  @ApiOperation({ summary: 'Kullanıcı kaydı' })
  @ApiBody({ type: RegisterDto })
  @ApiResponse({ status: 200 })
  async register(@Body() dto: RegisterDto) {
    const pool = await getPool()
    try {
      const digits = dto.phone.replace(/\D/g, '')
      if (digits.length < 10) {
        return { error: 'invalid_phone' }
      }
      const res = await pool
        .request()
        .input('Name', dto.name)
        .input('Email', dto.email)
        .input('Password', dto.password)
        .input('Phone', dto.phone)
        .execute('GeneralCommon.sp_User_Register')
      const out = res.recordset[0]
      try {
        await pool
          .request()
          .input('Action', 'register')
          .input('Description', `email=${dto.email}`)
          .input('Payload', JSON.stringify({ in: { name: dto.name, email: dto.email, phone: dto.phone }, out }))
          .input('UserID', null)
          .execute('GeneralCommon.sp_Activity_Log')
      } catch {}
      return out
    } catch (e: any) {
      return { error: 'email_exists' }
    }
  }
}
