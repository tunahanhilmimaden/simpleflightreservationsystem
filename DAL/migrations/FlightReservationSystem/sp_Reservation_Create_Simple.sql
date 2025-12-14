CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Reservation_Create_Simple]
  @UserID INT = NULL,
  @FlightID INT,
  @Status NVARCHAR(50) = N'Bekleyen',
  @TotalAmount DECIMAL(18,2) = 0
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @ReservationDate DATETIME2;
  SELECT @ReservationDate = TRY_CONVERT(DATETIME2, DepartureTime)
  FROM FlightReservationSystem.Flights
  WHERE FlightID = @FlightID;
  IF @ReservationDate IS NULL SET @ReservationDate = SYSUTCDATETIME();

  IF EXISTS (
    SELECT 1 FROM FlightReservationSystem.Reservations
    WHERE FlightID = @FlightID
      AND ( ( @UserID IS NULL AND UserID IS NULL ) OR ( UserID = @UserID ) )
      AND Status IN (N'Bekleyen', N'Tamamlanmadı')
  )
  BEGIN
    UPDATE FlightReservationSystem.Reservations
      SET TotalAmount = @TotalAmount
    WHERE FlightID = @FlightID
      AND ( ( @UserID IS NULL AND UserID IS NULL ) OR ( UserID = @UserID ) )
      AND Status IN (N'Bekleyen', N'Tamamlanmadı');
    SELECT TOP 1 ReservationID, UserID, FlightID, ReservationDate, Status, TotalAmount
    FROM FlightReservationSystem.Reservations
    WHERE FlightID = @FlightID
      AND ( ( @UserID IS NULL AND UserID IS NULL ) OR ( UserID = @UserID ) )
      AND Status IN (N'Bekleyen', N'Tamamlanmadı')
    ORDER BY ReservationID DESC;
    RETURN;
  END

  INSERT INTO FlightReservationSystem.Reservations (UserID, FlightID, ReservationDate, Status, TotalAmount)
  VALUES (@UserID, @FlightID, @ReservationDate, @Status, @TotalAmount);

  SELECT TOP 1 ReservationID, UserID, FlightID, ReservationDate, Status, TotalAmount
  FROM FlightReservationSystem.Reservations
  WHERE FlightID = @FlightID
  ORDER BY ReservationID DESC;
END
