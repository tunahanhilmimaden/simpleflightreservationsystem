CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Seat_ListWithPricing]
  @FlightId INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    s.SeatID,
    s.SeatNumber,
    sc.ClassID,
    sc.ClassName,
    sc.PriceMultiplier,
    ISNULL(fp.Price, 0) AS BasePrice,
    ISNULL(fp.Price, 0) * sc.PriceMultiplier AS SeatPrice,
    FlightReservationSystem.fn_SeatSurcharge(ISNULL(fp.Price, 0), sc.PriceMultiplier) AS Surcharge
  FROM FlightReservationSystem.Flights f
  INNER JOIN FlightReservationSystem.Seats s ON s.AircraftID = f.AircraftID
  INNER JOIN FlightReservationSystem.SeatClasses sc ON sc.ClassID = s.ClassID
  LEFT JOIN FlightReservationSystem.FlightPricing fp ON fp.FlightID = f.FlightID
  WHERE f.FlightID = @FlightId
  ORDER BY s.SeatNumber ASC;
END
