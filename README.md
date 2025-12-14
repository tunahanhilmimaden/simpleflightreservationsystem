# SkyRes Flight Reservation System

Monorepo for a simple flight reservation platform:
- `PAL/` — Next.js (Passenger App Layer): UI, seat selection, booking, boarding pass
- `BAL/` — NestJS (Business App Layer): REST microservices, Swagger, MSSQL integration
- `DAL/` — SQL Server migrations (schema, seeds, stored procedures)
- `flight_reservation_system/` — optional Flutter demo app

## Requirements
- Node.js 20+
- SQL Server (local or remote)
- Git

## Environment
Set DB connection for BAL via environment variables (examples for local):
```
DB_SERVER=localhost
DB_PORT=1433
DB_DATABASE=AirportServicesDB
DB_USER=sa
DB_PASSWORD=Str0ngPassw0rd!2025
DB_ENCRYPT=true
DB_TRUST_SERVER_CERTIFICATE=true
PORT=4000
```

## Database Migrations
Run the SQL migrations (PowerShell):
```
cd DAL
.\apply.ps1 -Server "localhost,1433" -Database "AirportServicesDB" -User "sa" -Password "Str0ngPassw0rd!2025"
```
Notes:
- Some seed scripts expect extra columns (e.g., `Airlines.Contact`, `Airports.Country`) — adjust seeds if your schema differs.
- `apply.ps1` supports blank password (set `-Password ""`) if `sqlcmd` is configured for integrated auth.

## Running Locally
Start BAL (NestJS):
```
cd BAL
npm ci
npm run dev
```
Swagger UI: `http://localhost:4000/docs`

Start PAL (Next.js):
```
cd PAL
npm ci
npm run dev
```
Passenger app: `http://localhost:3000/`

## Key Endpoints
- Flights
  - `GET /api/flights/search?origin=IST&dest=LHR&date=YYYY-MM-DD`
  - `GET /api/flights/min-prices?origin=IST&dest=LHR&startDate=YYYY-MM-DD&days=5`
  - `GET /api/flights/detail?flightId=1001`
- Seats
  - `GET /api/seats/by-flight?flightId=1001`
  - `GET /api/seats/available?flightId=1001`
  - `GET /api/seats/map?flightId=1001`
  - `GET /api/seats/price?flightId=1001&seatId=12C` (supports numeric SeatID or SeatNumber)
- Booking
  - `GET /api/booking/quote?flightId=1001&seatNumbers=1A,1B`
  - `POST /api/booking/create` — bulk create bookings (JSON body `{ flightId, passengers: [{ first, last, seatNumber }] }`)
  - `GET /api/booking/by-seat?flightId=1001&seatNumber=12C`
  - `GET /api/booking/by-name?name=John`

## Features
- Auth: register/login via SPs with MD5 in SQL Server (demo)
- Airports/flights/min-prices from SPs
- Seat map (3+3), class-based pricing, passenger forms with validation
- Booking summary with per-seat pricing and grand total
- Boarding pass per passenger with real QR (via `qrcode.react`)
- Branding in tickets: SkyRes

## Security
- Do not commit real secrets — `.gitignore` excludes `.env*`
- Demo SPs use MD5 for simplicity; use stronger hashing in production

## CI
GitHub Actions workflow builds PAL and BAL:
- PAL: `npm ci` + `next build`
- BAL: `npm ci` + `tsc`

## License
MIT (or your preferred license)

