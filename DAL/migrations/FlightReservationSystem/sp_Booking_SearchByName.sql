CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Booking_SearchByName]
  @Name NVARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP 200 BookingID, FlightID, PassengerName, SeatNumber, CreatedAt
  FROM FlightReservationSystem.Bookings
  WHERE PassengerName LIKE '%' + @Name + '%'
  ORDER BY CreatedAt DESC;
END
