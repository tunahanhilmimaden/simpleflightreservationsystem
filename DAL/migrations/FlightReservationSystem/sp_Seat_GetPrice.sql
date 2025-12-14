CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Seat_GetPrice]
  @FlightId INT,
  @SeatId INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    s.SeatID,
    s.SeatNumber,
    sc.ClassName,
    ISNULL(fp.Price, 0) AS BasePrice,
    sc.PriceMultiplier,
    ISNULL(fp.Price, 0) * sc.PriceMultiplier AS SeatPrice,
    FlightReservationSystem.fn_SeatSurcharge(ISNULL(fp.Price, 0), sc.PriceMultiplier) AS Surcharge
  FROM FlightReservationSystem.Flights f
  JOIN FlightReservationSystem.Seats s ON s.AircraftID = f.AircraftID
  JOIN FlightReservationSystem.SeatClasses sc ON sc.ClassID = s.ClassID
  LEFT JOIN FlightReservationSystem.FlightPricing fp ON fp.FlightID = f.FlightID
  WHERE f.FlightID = @FlightId
    AND s.SeatID = @SeatId;
END
