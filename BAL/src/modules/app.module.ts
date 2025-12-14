import { Module } from '@nestjs/common'
import { HealthController } from './health.controller'
import { AuthController } from './auth.controller'
import { FlightsController } from './flights.controller'
import { ParkingController } from './parking.controller'
import { SeatsController } from './seats.controller'
import { BookingController } from './booking.controller'
import { ActivityController } from './activity.controller'

@Module({
  controllers: [
    HealthController,
    AuthController,
    FlightsController,
    ParkingController,
    SeatsController,
    BookingController,
    ActivityController
  ]
})
export class AppModule {}
