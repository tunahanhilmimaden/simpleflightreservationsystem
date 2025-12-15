CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Passengers_InsertBulk_Simple]
  @ReservationId INT,
  @PassengersJson NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @cols TABLE (Name SYSNAME);
  INSERT INTO @cols(Name)
  SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'FlightReservationSystem' AND TABLE_NAME = 'Passengers';

  DECLARE @FlightID INT = NULL;
  SELECT @FlightID = FlightID FROM FlightReservationSystem.Reservations WHERE ReservationID = @ReservationId;

  DECLARE @t TABLE (
    first NVARCHAR(100),
    last NVARCHAR(100),
    dob NVARCHAR(30),
    passportNo NVARCHAR(50),
    age INT,
    gender NVARCHAR(50),
    nationality NVARCHAR(100)
  );
  INSERT INTO @t(first, last, dob, passportNo, age, gender, nationality)
  SELECT
    j.[first],
    j.[last],
    j.[dob],
    j.[passportNo],
    TRY_CONVERT(INT, j.[age]),
    j.[gender],
    j.[nationality]
  FROM OPENJSON(@PassengersJson)
  WITH (
    [first] NVARCHAR(100) '$.first',
    [last] NVARCHAR(100) '$.last',
    [dob] NVARCHAR(30) '$.dob',
    [passportNo] NVARCHAR(50) '$.passportNo',
    [age] NVARCHAR(10) '$.age',
    [gender] NVARCHAR(50) '$.gender',
    [nationality] NVARCHAR(100) '$.nationality'
  ) j;

  DECLARE @first NVARCHAR(100), @last NVARCHAR(100), @dob NVARCHAR(30), @passportNo NVARCHAR(50), @age INT, @gender NVARCHAR(50), @nationality NVARCHAR(100);
  DECLARE cur CURSOR FOR SELECT first, last, dob, passportNo, age, gender, nationality FROM @t;
  OPEN cur;
  FETCH NEXT FROM cur INTO @first, @last, @dob, @passportNo, @age, @gender, @nationality;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    DECLARE @ref DATETIME2 = COALESCE(
      (SELECT TRY_CONVERT(DATETIME2, ReservationDate) FROM FlightReservationSystem.Reservations WHERE ReservationID = @ReservationId),
      SYSUTCDATETIME()
    );
    DECLARE @computedAge INT = NULL;
    IF TRY_CONVERT(DATE, @dob) IS NOT NULL
      SET @computedAge = DATEDIFF(YEAR, TRY_CONVERT(DATE, @dob), @ref) - CASE WHEN (DATEADD(YEAR, DATEDIFF(YEAR, TRY_CONVERT(DATE, @dob), @ref), TRY_CONVERT(DATE, @dob)) > @ref) THEN 1 ELSE 0 END;
    DECLARE @finalAge INT = COALESCE(@age, @computedAge);
    DECLARE @c NVARCHAR(MAX) = N'[ReservationID]';
    DECLARE @v NVARCHAR(MAX) = N'@ReservationId';
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='FlightID') BEGIN SET @c += N', [FlightID]'; SET @v += N', @FlightID' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='FirstName') BEGIN SET @c += N', [FirstName]'; SET @v += N', @first' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='LastName') BEGIN SET @c += N', [LastName]'; SET @v += N', @last' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='PassportNo') BEGIN SET @c += N', [PassportNo]'; SET @v += N', @passportNo' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='Age') BEGIN SET @c += N', [Age]'; SET @v += N', @finalAge' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='Gender') BEGIN SET @c += N', [Gender]'; SET @v += N', @gender' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='Nationality') BEGIN SET @c += N', [Nationality]'; SET @v += N', @nationality' END
    IF EXISTS (SELECT 1 FROM @cols WHERE Name='CreatedAt') BEGIN SET @c += N', [CreatedAt]'; SET @v += N', SYSUTCDATETIME()' END
    DECLARE @sql NVARCHAR(MAX) = N'INSERT INTO FlightReservationSystem.Passengers ('+@c+') VALUES ('+@v+');';
    EXEC sp_executesql @sql,
      N'@ReservationId INT, @FlightID INT, @first NVARCHAR(100), @last NVARCHAR(100), @passportNo NVARCHAR(50), @finalAge INT, @gender NVARCHAR(50), @nationality NVARCHAR(100)',
      @ReservationId=@ReservationId, @FlightID=@FlightID, @first=@first, @last=@last, @passportNo=@passportNo, @finalAge=@finalAge, @gender=@gender, @nationality=@nationality;
    FETCH NEXT FROM cur INTO @first, @last, @dob, @passportNo, @age, @gender, @nationality;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT COUNT(*) AS InsertedCount FROM @t;
END
