CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Flight_Search]
  @Origin NVARCHAR(10),
  @Dest NVARCHAR(10),
  @Date DATE
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP 200
    f.FlightID,
    al.Name AS AirlineName,
    ao.IATA_Code AS OriginCode,
    ad.IATA_Code AS DestCode,
    f.DepartureTime,
    f.ArrivalTime,
    MIN(fp.Price) AS MinPrice
  FROM FlightReservationSystem.Flights f
  JOIN FlightReservationSystem.Airlines al ON al.AirlineID = f.AirlineID
  JOIN FlightReservationSystem.Airports ao ON ao.AirportID = f.DepartureAirportID
  JOIN FlightReservationSystem.Airports ad ON ad.AirportID = f.ArrivalAirportID
  LEFT JOIN FlightReservationSystem.FlightPricing fp ON fp.FlightID = f.FlightID
  WHERE ao.IATA_Code = @Origin
    AND ad.IATA_Code = @Dest
    AND CAST(f.DepartureTime AS DATE) = @Date
  GROUP BY f.FlightID, al.Name, ao.IATA_Code, ad.IATA_Code, f.DepartureTime, f.ArrivalTime
  ORDER BY f.DepartureTime ASC;
END
