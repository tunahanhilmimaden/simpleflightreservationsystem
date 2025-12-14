CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Reservation_Create]
  @UserID INT = NULL,
  @FlightID INT,
  @Status NVARCHAR(50) = N'Tamamlanmadı',
  @TotalAmount DECIMAL(18,2) = 0
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO FlightReservationSystem.Reservations (UserID, FlightID, ReservationDate, Status, TotalAmount)
  VALUES (@UserID, @FlightID, SYSUTCDATETIME(), @Status, @TotalAmount);

  SELECT TOP 1 ReservationID, UserID, FlightID, ReservationDate, Status, TotalAmount
  FROM FlightReservationSystem.Reservations
  WHERE FlightID = @FlightID
  ORDER BY ReservationID DESC;
END
