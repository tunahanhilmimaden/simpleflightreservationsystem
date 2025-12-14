CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Booking_GetBySeat]
  @FlightId INT,
  @SeatNumber NVARCHAR(10)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT BookingID, FlightID, PassengerName, SeatNumber, CreatedAt
  FROM FlightReservationSystem.Bookings
  WHERE FlightID = @FlightId AND SeatNumber = @SeatNumber
  ORDER BY CreatedAt DESC;
END
