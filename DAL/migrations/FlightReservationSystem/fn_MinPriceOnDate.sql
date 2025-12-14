CREATE OR ALTER FUNCTION [FlightReservationSystem].[fn_MinPriceOnDate]
(
  @Origin NVARCHAR(10),
  @Dest NVARCHAR(10),
  @Date DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN
  DECLARE @min DECIMAL(18,2);
  SELECT @min = MIN(fp.Price)
  FROM FlightReservationSystem.Flights f
  JOIN FlightReservationSystem.FlightPricing fp ON fp.FlightID = f.FlightID
  JOIN FlightReservationSystem.Airports ao ON ao.AirportID = f.DepartureAirportID
  JOIN FlightReservationSystem.Airports ad ON ad.AirportID = f.ArrivalAirportID
  WHERE ao.IATA_Code = @Origin
    AND ad.IATA_Code = @Dest
    AND CAST(f.DepartureTime AS DATE) = @Date;
  RETURN ISNULL(@min, 0);
END
