import './globals.css'
import type { ReactNode } from 'react'
import { BookingProviderRoot } from '../lib/bookingStore'
import UserBar from '../components/UserBar'

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="tr">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet" />
      </head>
      <body>
        <BookingProviderRoot>
          <UserBar />
          {children}
        </BookingProviderRoot>
      </body>
    </html>
  )
}
