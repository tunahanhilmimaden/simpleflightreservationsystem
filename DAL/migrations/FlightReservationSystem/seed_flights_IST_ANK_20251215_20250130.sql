/* Seed: IST ↔ ANK flights between 2025-12-15 and 2025-01-30 with 2000 base price and 72 seats (2 rows First, 2 rows Business, rest Economy) */
SET NOCOUNT ON;

DECLARE @hasAirlines BIT = CASE WHEN EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[FlightReservationSystem].[Airlines]') AND type = 'U') THEN 1 ELSE 0 END;
DECLARE @hasAirports BIT = CASE WHEN EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[FlightReservationSystem].[Airports]') AND type = 'U') THEN 1 ELSE 0 END;
DECLARE @hasAircrafts BIT = CASE WHEN EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[FlightReservationSystem].[Aircrafts]') AND type = 'U') THEN 1 ELSE 0 END;
DECLARE @hasSeats BIT = CASE WHEN EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[FlightReservationSystem].[Seats]') AND type = 'U') THEN 1 ELSE 0 END;
DECLARE @hasFlights BIT = CASE WHEN EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[FlightReservationSystem].[Flights]') AND type = 'U') THEN 1 ELSE 0 END;
DECLARE @hasSeatClasses BIT = CASE WHEN EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[FlightReservationSystem].[SeatClasses]') AND type = 'U') THEN 1 ELSE 0 END;
DECLARE @hasFlightPricing BIT = CASE WHEN EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[FlightReservationSystem].[FlightPricing]') AND type = 'U') THEN 1 ELSE 0 END;

IF @hasSeatClasses = 1
BEGIN
  IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.SeatClasses WHERE ClassID = 1) INSERT INTO FlightReservationSystem.SeatClasses(ClassID, ClassName, PriceMultiplier) VALUES(1, N'First Class', 3.00);
  IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.SeatClasses WHERE ClassID = 2) INSERT INTO FlightReservationSystem.SeatClasses(ClassID, ClassName, PriceMultiplier) VALUES(2, N'Business', 1.00);
  IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.SeatClasses WHERE ClassID = 3) INSERT INTO FlightReservationSystem.SeatClasses(ClassID, ClassName, PriceMultiplier) VALUES(3, N'Economy', 1.00);
END

DECLARE @AirlineId INT = NULL;
IF @hasAirlines = 1
BEGIN
  IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airlines WHERE Name = N'SkyRes Air')
  BEGIN
    DECLARE @colsA TABLE(Name SYSNAME);
    INSERT INTO @colsA SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='FlightReservationSystem' AND TABLE_NAME='Airlines';
    DECLARE @cA NVARCHAR(MAX) = N'[Name]';
    DECLARE @vA NVARCHAR(MAX) = N'@Name';
    IF EXISTS(SELECT 1 FROM @colsA WHERE Name='Contact') BEGIN SET @cA += N',[Contact]'; SET @vA += N',N''info@skyres.local''' END
    DECLARE @sqlA NVARCHAR(MAX) = N'INSERT INTO FlightReservationSystem.Airlines('+@cA+') VALUES('+@vA+');';
    EXEC sp_executesql @sqlA, N'@Name NVARCHAR(200)', @Name=N'SkyRes Air';
  END
  SELECT TOP 1 @AirlineId = AirlineID FROM FlightReservationSystem.Airlines WHERE Name = N'SkyRes Air';
END

DECLARE @DepAirportId INT = NULL, @ArrAirportId INT = NULL;
IF @hasAirports = 1
BEGIN
  IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airports WHERE IATA_Code = N'IST')
  BEGIN
    DECLARE @colsAp TABLE(Name SYSNAME);
    INSERT INTO @colsAp SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='FlightReservationSystem' AND TABLE_NAME='Airports';
    DECLARE @cAp NVARCHAR(MAX) = N'[IATA_Code]';
    DECLARE @vAp NVARCHAR(MAX) = N'@Code';
    IF EXISTS(SELECT 1 FROM @colsAp WHERE Name='City') BEGIN SET @cAp += N',[City]'; SET @vAp += N',N''İstanbul''' END
    IF EXISTS(SELECT 1 FROM @colsAp WHERE Name='Country') BEGIN SET @cAp += N',[Country]'; SET @vAp += N',N''TR''' END
    DECLARE @sqlAp NVARCHAR(MAX) = N'INSERT INTO FlightReservationSystem.Airports('+@cAp+') VALUES ('+@vAp+');';
    EXEC sp_executesql @sqlAp, N'@Code NVARCHAR(10)', @Code=N'IST';
  END
  IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airports WHERE IATA_Code = N'ANK')
  BEGIN
    DECLARE @colsAp2 TABLE(Name SYSNAME);
    INSERT INTO @colsAp2 SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='FlightReservationSystem' AND TABLE_NAME='Airports';
    DECLARE @cAp2 NVARCHAR(MAX) = N'[IATA_Code]';
    DECLARE @vAp2 NVARCHAR(MAX) = N'@Code';
    IF EXISTS(SELECT 1 FROM @colsAp2 WHERE Name='City') BEGIN SET @cAp2 += N',[City]'; SET @vAp2 += N',N''Ankara''' END
    IF EXISTS(SELECT 1 FROM @colsAp2 WHERE Name='Country') BEGIN SET @cAp2 += N',[Country]'; SET @vAp2 += N',N''TR''' END
    DECLARE @sqlAp2 NVARCHAR(MAX) = N'INSERT INTO FlightReservationSystem.Airports('+@cAp2+') VALUES ('+@vAp2+');';
    EXEC sp_executesql @sqlAp2, N'@Code NVARCHAR(10)', @Code=N'ANK';
  END
  SELECT TOP 1 @DepAirportId = AirportID FROM FlightReservationSystem.Airports WHERE IATA_Code = N'IST';
  SELECT TOP 1 @ArrAirportId = AirportID FROM FlightReservationSystem.Airports WHERE IATA_Code = N'ANK';
END

DECLARE @AircraftId INT = NULL;
IF @hasAircrafts = 1
BEGIN
  IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Aircrafts WHERE Model = N'SKY-A320-IST-ANK')
  BEGIN
    DECLARE @colsAc TABLE(Name SYSNAME);
    INSERT INTO @colsAc SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='FlightReservationSystem' AND TABLE_NAME='Aircrafts';
    DECLARE @cAc NVARCHAR(MAX) = N'[Model]';
    DECLARE @vAc NVARCHAR(MAX) = N'@Model';
    IF EXISTS(SELECT 1 FROM @colsAc WHERE Name='Capacity') BEGIN SET @cAc += N',[Capacity]'; SET @vAc += N',72' END
    DECLARE @sqlAc NVARCHAR(MAX) = N'INSERT INTO FlightReservationSystem.Aircrafts('+@cAc+') VALUES ('+@vAc+');';
    EXEC sp_executesql @sqlAc, N'@Model NVARCHAR(100)', @Model=N'SKY-A320-IST-ANK';
  END
  SELECT TOP 1 @AircraftId = AircraftID FROM FlightReservationSystem.Aircrafts WHERE Model = N'SKY-A320-IST-ANK';
END

IF @hasSeats = 1 AND @AircraftId IS NOT NULL
BEGIN
  DECLARE @existing INT = (SELECT COUNT(*) FROM FlightReservationSystem.Seats WHERE AircraftID = @AircraftId);
  IF @existing < 72
  BEGIN
    DECLARE @row INT = 1;
    WHILE @row <= 12
    BEGIN
      DECLARE @classId INT = CASE WHEN @row <= 2 THEN 1 WHEN @row <= 4 THEN 2 ELSE 3 END;
      DECLARE @letters TABLE(L NVARCHAR(1));
      DELETE FROM @letters;
      INSERT INTO @letters(L) VALUES(N'A'),(N'B'),(N'C'),(N'D'),(N'E'),(N'F');
      DECLARE @L NVARCHAR(1);
      DECLARE curL CURSOR FOR SELECT L FROM @letters;
      OPEN curL; FETCH NEXT FROM curL INTO @L;
      WHILE @@FETCH_STATUS = 0
      BEGIN
        DECLARE @seat NVARCHAR(10) = CONCAT(@row, @L);
        IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Seats WHERE AircraftID=@AircraftId AND SeatNumber=@seat)
          INSERT INTO FlightReservationSystem.Seats (AircraftID, SeatNumber, ClassID) VALUES (@AircraftId, @seat, @classId);
        FETCH NEXT FROM curL INTO @L;
      END
      CLOSE curL; DEALLOCATE curL;
      SET @row += 1;
    END
  END
END

IF @hasFlights = 1
BEGIN
  DECLARE @d DATE;
  SET @d = '2025-12-15';
  WHILE @d <= '2025-12-31'
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Flights WHERE DepartureAirportID=@DepAirportId AND ArrivalAirportID=@ArrAirportId AND CAST(DepartureTime AS DATE)=@d)
      INSERT INTO FlightReservationSystem.Flights (AirlineID, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, AircraftID)
      VALUES (@AirlineId, @DepAirportId, @ArrAirportId, DATEADD(HOUR, 9, CAST(@d AS DATETIME2)), DATEADD(HOUR, 10, CAST(@d AS DATETIME2)), @AircraftId);
    SET @d = DATEADD(DAY, 1, @d);
  END
  SET @d = '2025-01-01';
  WHILE @d <= '2025-01-30'
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Flights WHERE DepartureAirportID=@DepAirportId AND ArrivalAirportID=@ArrAirportId AND CAST(DepartureTime AS DATE)=@d)
      INSERT INTO FlightReservationSystem.Flights (AirlineID, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, AircraftID)
      VALUES (@AirlineId, @DepAirportId, @ArrAirportId, DATEADD(HOUR, 9, CAST(@d AS DATETIME2)), DATEADD(HOUR, 10, CAST(@d AS DATETIME2)), @AircraftId);
    SET @d = DATEADD(DAY, 1, @d);
  END
END

IF @hasFlightPricing = 1
BEGIN
  INSERT INTO FlightReservationSystem.FlightPricing (FlightID, Price)
  SELECT f.FlightID, 2000.0
  FROM FlightReservationSystem.Flights f
  WHERE f.DepartureAirportID=@DepAirportId AND f.ArrivalAirportID=@ArrAirportId
    AND CAST(f.DepartureTime AS DATE) BETWEEN '2025-01-01' AND '2025-01-30'
  AND NOT EXISTS (SELECT 1 FROM FlightReservationSystem.FlightPricing fp WHERE fp.FlightID = f.FlightID);
  INSERT INTO FlightReservationSystem.FlightPricing (FlightID, Price)
  SELECT f.FlightID, 2000.0
  FROM FlightReservationSystem.Flights f
  WHERE f.DepartureAirportID=@DepAirportId AND f.ArrivalAirportID=@ArrAirportId
    AND CAST(f.DepartureTime AS DATE) BETWEEN '2025-12-15' AND '2025-12-31'
  AND NOT EXISTS (SELECT 1 FROM FlightReservationSystem.FlightPricing fp WHERE fp.FlightID = f.FlightID);
END

PRINT 'Seed IST-ANK flights and seats prepared (no data applied unless executed).';
