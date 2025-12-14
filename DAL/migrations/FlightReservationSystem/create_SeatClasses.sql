IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[FlightReservationSystem].[SeatClasses]') AND type in (N'U'))
BEGIN
  CREATE TABLE [FlightReservationSystem].[SeatClasses] (
    [ClassID] INT NOT NULL PRIMARY KEY,
    [ClassName] NVARCHAR(50) NOT NULL UNIQUE,
    [PriceMultiplier] DECIMAL(5,2) NOT NULL DEFAULT(1.00)
  );
END
GO
IF NOT EXISTS (SELECT 1 FROM [FlightReservationSystem].[SeatClasses] WHERE [ClassID] = 1)
BEGIN
  INSERT INTO [FlightReservationSystem].[SeatClasses] (ClassID, ClassName, PriceMultiplier) VALUES (1, N'First Class', 3.00);
END
IF NOT EXISTS (SELECT 1 FROM [FlightReservationSystem].[SeatClasses] WHERE [ClassID] = 2)
BEGIN
  INSERT INTO [FlightReservationSystem].[SeatClasses] (ClassID, ClassName, PriceMultiplier) VALUES (2, N'Business', 1.00);
END
IF NOT EXISTS (SELECT 1 FROM [FlightReservationSystem].[SeatClasses] WHERE [ClassID] = 3)
BEGIN
  INSERT INTO [FlightReservationSystem].[SeatClasses] (ClassID, ClassName, PriceMultiplier) VALUES (3, N'Economy', 1.00);
END
