CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Tickets_GetByReservation]
  @ReservationId INT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @colsT TABLE (Name SYSNAME);
  INSERT INTO @colsT(Name)
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'FlightReservationSystem' AND TABLE_NAME = 'Tickets';
  DECLARE @colsP TABLE (Name SYSNAME);
  INSERT INTO @colsP(Name)
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'FlightReservationSystem' AND TABLE_NAME = 'Passengers';
  DECLARE @colsS TABLE (Name SYSNAME);
  INSERT INTO @colsS(Name)
  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'FlightReservationSystem' AND TABLE_NAME = 'Seats';

  DECLARE @hasT_PassengerID BIT = CASE WHEN EXISTS (SELECT 1 FROM @colsT WHERE Name='PassengerID') THEN 1 ELSE 0 END;
  DECLARE @hasT_SeatID BIT = CASE WHEN EXISTS (SELECT 1 FROM @colsT WHERE Name='SeatID') THEN 1 ELSE 0 END;
  DECLARE @hasT_BoardingGate BIT = CASE WHEN EXISTS (SELECT 1 FROM @colsT WHERE Name='BoardingGate') THEN 1 ELSE 0 END;
  DECLARE @hasT_TicketStatus BIT = CASE WHEN EXISTS (SELECT 1 FROM @colsT WHERE Name='TicketStatus') THEN 1 ELSE 0 END;
  DECLARE @hasS_SeatID BIT = CASE WHEN EXISTS (SELECT 1 FROM @colsS WHERE Name='SeatID') THEN 1 ELSE 0 END;
  DECLARE @hasS_SeatNumber BIT = CASE WHEN EXISTS (SELECT 1 FROM @colsS WHERE Name='SeatNumber') THEN 1 ELSE 0 END;
  DECLARE @hasP_FirstName BIT = CASE WHEN EXISTS (SELECT 1 FROM @colsP WHERE Name='FirstName') THEN 1 ELSE 0 END;
  DECLARE @hasP_LastName BIT = CASE WHEN EXISTS (SELECT 1 FROM @colsP WHERE Name='LastName') THEN 1 ELSE 0 END;
  DECLARE @hasP_Name BIT = CASE WHEN EXISTS (SELECT 1 FROM @colsP WHERE Name='Name') THEN 1 ELSE 0 END;

  DECLARE @sel NVARCHAR(MAX) = N'SELECT ';
  DECLARE @from NVARCHAR(MAX) = N' FROM FlightReservationSystem.Reservations r ';
  SET @from += N' JOIN FlightReservationSystem.Flights f ON f.FlightID = r.FlightID ';
  SET @from += N' JOIN FlightReservationSystem.Passengers p ON p.ReservationID = r.ReservationID ';
  IF @hasT_PassengerID = 1
    SET @from += N' LEFT JOIN FlightReservationSystem.Tickets t ON t.PassengerID = p.PassengerID ';
  IF @hasT_SeatID = 1 AND @hasS_SeatID = 1
    SET @from += N' LEFT JOIN FlightReservationSystem.Seats s ON s.SeatID = t.SeatID ';

  SET @sel += N' r.ReservationID, r.FlightID, ';
  SET @sel += N' f.AirlineName, f.FlightID AS FlightNumber, f.OriginCode, f.DestCode, f.DepartureTime, f.ArrivalTime, ';
  IF @hasP_FirstName = 1
    SET @sel += N' p.FirstName, ';
  ELSE IF @hasP_Name = 1
    SET @sel += N' p.Name AS FirstName, ';
  ELSE
    SET @sel += N' CAST(NULL AS NVARCHAR(100)) AS FirstName, ';
  IF @hasP_LastName = 1
    SET @sel += N' p.LastName, ';
  ELSE
    SET @sel += N' CAST(NULL AS NVARCHAR(100)) AS LastName, ';
  IF @hasS_SeatNumber = 1
    SET @sel += N' s.SeatNumber, ';
  ELSE
    SET @sel += N' CAST(NULL AS NVARCHAR(10)) AS SeatNumber, ';
  IF @hasT_BoardingGate = 1
    SET @sel += N' t.BoardingGate, ';
  ELSE
    SET @sel += N' CAST(NULL AS NVARCHAR(10)) AS BoardingGate, ';
  IF @hasT_TicketStatus = 1
    SET @sel += N' t.TicketStatus ';
  ELSE
    SET @sel += N' CAST(NULL AS NVARCHAR(50)) AS TicketStatus ';

  DECLARE @sql NVARCHAR(MAX) = @sel + @from + N' WHERE r.ReservationID = @ReservationId;';
  EXEC sp_executesql @sql, N'@ReservationId INT', @ReservationId=@ReservationId;
END
