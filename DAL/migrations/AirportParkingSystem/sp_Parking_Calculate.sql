CREATE OR ALTER PROCEDURE [AirportParkingSystem].[sp_Parking_Calculate]
  @VehicleType NVARCHAR(50),
  @StartDate DATE,
  @EndDate DATE
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @days INT = DATEDIFF(DAY, @StartDate, @EndDate);
  IF (@days <= 0) SET @days = 1;
  DECLARE @baseRate DECIMAL(18,2) = 250.00;
  DECLARE @mult DECIMAL(18,2) =
    CASE UPPER(@VehicleType)
      WHEN 'MOTOSIKLET' THEN 0.8
      WHEN 'MOTORCYCLE' THEN 0.8
      WHEN 'OTOMOBIL' THEN 1.0
      WHEN 'AUTOMOBILE' THEN 1.0
      WHEN 'SUV' THEN 1.3
      WHEN 'KAMYONET' THEN 1.5
      ELSE 1.0
    END;
  SELECT
    @days AS parkingDays,
    CAST(@baseRate AS DECIMAL(18,2)) AS dailyRate,
    CAST(@baseRate * @mult * @days AS DECIMAL(18,2)) AS totalParkingPrice;
END
