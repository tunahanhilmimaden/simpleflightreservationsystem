CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Flight_GetDetail]
  @FlightId INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    f.FlightID,
    al.Name AS AirlineName,
    ao.IATA_Code AS OriginCode,
    ad.IATA_Code AS DestCode,
    f.DepartureTime,
    f.ArrivalTime
  FROM FlightReservationSystem.Flights f
  JOIN FlightReservationSystem.Airlines al ON al.AirlineID = f.AirlineID
  JOIN FlightReservationSystem.Airports ao ON ao.AirportID = f.DepartureAirportID
  JOIN FlightReservationSystem.Airports ad ON ad.AirportID = f.ArrivalAirportID
  WHERE f.FlightID = @FlightId;
END
