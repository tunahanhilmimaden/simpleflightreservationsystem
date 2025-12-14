CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Booking_CreateBulk]
  @FlightId INT,
  @PassengerJson NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @t TABLE (first NVARCHAR(100), last NVARCHAR(100), seatNumber NVARCHAR(10));
  INSERT INTO @t(first, last, seatNumber)
  SELECT first, last, seatNumber
  FROM OPENJSON(@PassengerJson)
  WITH (
    first NVARCHAR(100) '$.first',
    last NVARCHAR(100) '$.last',
    seatNumber NVARCHAR(10) '$.seatNumber'
  );

  INSERT INTO FlightReservationSystem.Bookings (FlightID, PassengerName, SeatNumber, CreatedAt)
  SELECT @FlightId, CONCAT(first, N' ', last), seatNumber, SYSUTCDATETIME()
  FROM @t;

  SELECT b.BookingID, b.FlightID, b.PassengerName, b.SeatNumber, b.CreatedAt
  FROM FlightReservationSystem.Bookings b
  WHERE b.FlightID = @FlightId AND b.SeatNumber IN (SELECT seatNumber FROM @t);
END
