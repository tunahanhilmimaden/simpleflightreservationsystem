CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Passengers_InsertBulk]
  @ReservationId INT,
  @FlightId INT,
  @PassengersJson NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @cols TABLE (Name SYSNAME);
  INSERT INTO @cols(Name)
  SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'FlightReservationSystem' AND TABLE_NAME = 'Passengers';

  DECLARE @t TABLE (
    first NVARCHAR(100),
    last NVARCHAR(100),
    gender NVARCHAR(50),
    dob DATE,
    seatNumber NVARCHAR(10),
    type NVARCHAR(50)
  );
  INSERT INTO @t(first, last, gender, dob, seatNumber, type)
  SELECT first, last, gender, TRY_CONVERT(DATE, dob), seatNumber, type
  FROM OPENJSON(@PassengersJson)
  WITH (
    first NVARCHAR(100) '$.first',
    last NVARCHAR(100) '$.last',
    gender NVARCHAR(50) '$.gender',
    dob NVARCHAR(30) '$.dob',
    seatNumber NVARCHAR(10) '$.seatNumber',
    type NVARCHAR(50) '$.type'
  );

  DECLARE @first NVARCHAR(100), @last NVARCHAR(100), @gender NVARCHAR(50), @dob DATE, @seat NVARCHAR(10), @type NVARCHAR(50);
  DECLARE cur CURSOR FOR SELECT first, last, gender, dob, seatNumber, type FROM @t;
  OPEN cur;
  FETCH NEXT FROM cur INTO @first, @last, @gender, @dob, @seat, @type;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    DECLARE @c NVARCHAR(MAX) = N'';
    DECLARE @v NVARCHAR(MAX) = N'';
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='ReservationID') BEGIN SET @c += N'[ReservationID],'; SET @v += N'@ReservationId,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='FlightID') BEGIN SET @c += N'[FlightID],'; SET @v += N'@FlightId,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='FirstName') BEGIN SET @c += N'[FirstName],'; SET @v += N'@first,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='LastName') BEGIN SET @c += N'[LastName],'; SET @v += N'@last,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='PassengerName') BEGIN SET @c += N'[PassengerName],'; SET @v += N'@passengerName,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='Gender') BEGIN SET @c += N'[Gender],'; SET @v += N'@gender,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='DOB') BEGIN SET @c += N'[DOB],'; SET @v += N'@dob,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='BirthDate') BEGIN SET @c += N'[BirthDate],'; SET @v += N'@dob,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='SeatNumber') BEGIN SET @c += N'[SeatNumber],'; SET @v += N'@seat,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='PassengerType') BEGIN SET @c += N'[PassengerType],'; SET @v += N'@type,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='Type') BEGIN SET @c += N'[Type],'; SET @v += N'@type,' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='CreatedAt') BEGIN SET @c += N'[CreatedAt],'; SET @v += N'SYSUTCDATETIME(),' END
    IF RIGHT(@c,1)=',' SET @c=LEFT(@c,LEN(@c)-1)
    IF RIGHT(@v,1)=',' SET @v=LEFT(@v,LEN(@v)-1)
    DECLARE @sql NVARCHAR(MAX) = N'INSERT INTO FlightReservationSystem.Passengers ('+@c+') VALUES ('+@v+');';
    DECLARE @passengerName NVARCHAR(200) = CONCAT(COALESCE(@first,N''), N' ', COALESCE(@last,N''));
    EXEC sp_executesql @sql,
      N'@ReservationId INT, @FlightId INT, @first NVARCHAR(100), @last NVARCHAR(100), @passengerName NVARCHAR(200), @gender NVARCHAR(50), @dob DATE, @seat NVARCHAR(10), @type NVARCHAR(50)',
      @ReservationId=@ReservationId, @FlightId=@FlightId, @first=@first, @last=@last, @passengerName=@passengerName, @gender=@gender, @dob=@dob, @seat=@seat, @type=@type;
    FETCH NEXT FROM cur INTO @first, @last, @gender, @dob, @seat, @type;
  END
  CLOSE cur; DEALLOCATE cur;
END
