CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Booking_GetSummary]
  @BookingId INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    b.BookingID AS bookingId,
    b.PassengerName,
    b.SeatNumber,
    f.FlightID AS flightId,
    al.Name AS airlineName,
    ao.IATA_Code AS originCode,
    ad.IATA_Code AS destCode,
    f.DepartureTime AS departureTime,
    f.ArrivalTime AS arrivalTime,
    ISNULL(MIN(fp.Price), 0) AS basePrice,
    CAST(450.00 AS DECIMAL(18,2)) AS taxes,
    CAST(0 AS DECIMAL(18,2)) AS seatSurcharge
  FROM FlightReservationSystem.Bookings b
  INNER JOIN FlightReservationSystem.Flights f ON f.FlightID = b.FlightID
  LEFT JOIN FlightReservationSystem.FlightPricing fp ON fp.FlightID = f.FlightID
  LEFT JOIN FlightReservationSystem.Airlines al ON al.AirlineID = f.AirlineID
  LEFT JOIN FlightReservationSystem.Airports ao ON ao.AirportID = f.DepartureAirportID
  LEFT JOIN FlightReservationSystem.Airports ad ON ad.AirportID = f.ArrivalAirportID
  WHERE b.BookingID = @BookingId
  GROUP BY b.BookingID, b.PassengerName, b.SeatNumber, f.FlightID, al.Name, ao.IATA_Code, ad.IATA_Code, f.DepartureTime, f.ArrivalTime;
END
