CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Tickets_IssueForReservation]
  @ReservationId INT,
  @FlightId INT,
  @TicketsJson NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @cols TABLE (Name SYSNAME);
  INSERT INTO @cols(Name)
  SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'FlightReservationSystem' AND TABLE_NAME = 'Tickets';

  DECLARE @pcols TABLE (Name SYSNAME);
  INSERT INTO @pcols(Name)
  SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'FlightReservationSystem' AND TABLE_NAME = 'Passengers';
  DECLARE @hasFirstName BIT = CASE WHEN EXISTS (SELECT 1 FROM @pcols WHERE Name='FirstName') THEN 1 ELSE 0 END;
  DECLARE @hasLastName BIT = CASE WHEN EXISTS (SELECT 1 FROM @pcols WHERE Name='LastName') THEN 1 ELSE 0 END;
  DECLARE @hasName BIT = CASE WHEN EXISTS (SELECT 1 FROM @pcols WHERE Name='Name') THEN 1 ELSE 0 END;
  DECLARE @hasPassportNo BIT = CASE WHEN EXISTS (SELECT 1 FROM @pcols WHERE Name='PassportNo') THEN 1 ELSE 0 END;

  DECLARE @t TABLE (
    first NVARCHAR(100),
    last NVARCHAR(100),
    seatNumber NVARCHAR(10),
    boardingGate NVARCHAR(10),
    ticketStatus NVARCHAR(50),
    passportNo NVARCHAR(50)
  );
  INSERT INTO @t(first, last, seatNumber, boardingGate, ticketStatus, passportNo)
  SELECT
    j.[first],
    j.[last],
    j.[seatNumber],
    COALESCE(j.[boardingGate], N'C1'),
    COALESCE(j.[ticketStatus], N'Issued'),
    j.[passportNo]
  FROM OPENJSON(@TicketsJson)
  WITH (
    [first] NVARCHAR(100) '$.first',
    [last] NVARCHAR(100) '$.last',
    [seatNumber] NVARCHAR(10) '$.seatNumber',
    [boardingGate] NVARCHAR(10) '$.boardingGate',
    [ticketStatus] NVARCHAR(50) '$.ticketStatus',
    [passportNo] NVARCHAR(50) '$.passportNo'
  ) j;

  DECLARE @first NVARCHAR(100), @last NVARCHAR(100), @seatNumber NVARCHAR(10), @boardingGate NVARCHAR(10), @ticketStatus NVARCHAR(50), @passportNo NVARCHAR(50);
  DECLARE cur CURSOR FOR SELECT first, last, seatNumber, boardingGate, ticketStatus, passportNo FROM @t;
  OPEN cur;
  FETCH NEXT FROM cur INTO @first, @last, @seatNumber, @boardingGate, @ticketStatus, @passportNo;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    DECLARE @PassengerID INT = NULL;
    DECLARE @pSql NVARCHAR(MAX) = N'';
    IF @hasPassportNo = 1 AND @passportNo IS NOT NULL
      SET @pSql = N'SELECT TOP 1 @pidOut = PassengerID FROM FlightReservationSystem.Passengers WHERE ReservationID = @ReservationId AND PassportNo = @passportNo';
    ELSE IF @hasFirstName = 1 AND @hasLastName = 1
      SET @pSql = N'SELECT TOP 1 @pidOut = PassengerID FROM FlightReservationSystem.Passengers WHERE ReservationID = @ReservationId AND FirstName = @first AND LastName = @last';
    ELSE IF @hasName = 1
      SET @pSql = N'SELECT TOP 1 @pidOut = PassengerID FROM FlightReservationSystem.Passengers WHERE ReservationID = @ReservationId AND Name = CONCAT(@first, N'' '', @last)';
    IF LEN(@pSql) > 0
      EXEC sp_executesql @pSql, N'@ReservationId INT, @passportNo NVARCHAR(50), @first NVARCHAR(100), @last NVARCHAR(100), @pidOut INT OUTPUT', @ReservationId=@ReservationId, @passportNo=@passportNo, @first=@first, @last=@last, @pidOut=@PassengerID OUTPUT;
    DECLARE @SeatID INT = (
      SELECT TOP 1 s.SeatID
      FROM FlightReservationSystem.Seats s
      JOIN FlightReservationSystem.Flights f ON f.AircraftID = s.AircraftID
      WHERE f.FlightID = @FlightId AND s.SeatNumber = @seatNumber
    );

    IF @PassengerID IS NOT NULL AND @SeatID IS NOT NULL
    BEGIN
      DECLARE @c NVARCHAR(MAX) = N'';
      DECLARE @v NVARCHAR(MAX) = N'';
      IF EXISTS (SELECT 1 FROM @cols WHERE Name='PassengerID') BEGIN SET @c += N'[PassengerID],'; SET @v += N'@PassengerID,' END
      IF EXISTS (SELECT 1 FROM @cols WHERE Name='SeatID') BEGIN SET @c += N'[SeatID],'; SET @v += N'@SeatID,' END
      IF EXISTS (SELECT 1 FROM @cols WHERE Name='BoardingGate') BEGIN SET @c += N'[BoardingGate],'; SET @v += N'@BoardingGate,' END
      IF EXISTS (SELECT 1 FROM @cols WHERE Name='TicketStatus') BEGIN SET @c += N'[TicketStatus],'; SET @v += N'@TicketStatus,' END
      IF EXISTS (SELECT 1 FROM @cols WHERE Name='CreatedAt') BEGIN SET @c += N'[CreatedAt],'; SET @v += N'SYSUTCDATETIME(),' END
      IF RIGHT(@c,1)=',' SET @c=LEFT(@c,LEN(@c)-1);
      IF RIGHT(@v,1)=',' SET @v=LEFT(@v,LEN(@v)-1);
      DECLARE @sql NVARCHAR(MAX) = N'INSERT INTO FlightReservationSystem.Tickets ('+@c+') VALUES ('+@v+');';
      EXEC sp_executesql @sql,
        N'@PassengerID INT, @SeatID INT, @BoardingGate NVARCHAR(10), @TicketStatus NVARCHAR(50)',
        @PassengerID=@PassengerID, @SeatID=@SeatID, @BoardingGate=@boardingGate, @TicketStatus=@ticketStatus;
    END
    FETCH NEXT FROM cur INTO @first, @last, @seatNumber, @boardingGate, @ticketStatus, @passportNo;
  END
  CLOSE cur; DEALLOCATE cur;

  UPDATE FlightReservationSystem.Reservations
    SET Status = N'Tamamlanan'
  WHERE ReservationID = @ReservationId;

  SELECT COUNT(*) AS IssuedCount FROM @t;
END
