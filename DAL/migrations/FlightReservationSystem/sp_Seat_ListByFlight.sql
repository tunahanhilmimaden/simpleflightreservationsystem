CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Seat_ListByFlight]
  @FlightId INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    s.SeatID,
    s.SeatNumber,
    s.ClassID
  FROM FlightReservationSystem.Seats s
  INNER JOIN FlightReservationSystem.Flights f ON f.AircraftID = s.AircraftID
  WHERE f.FlightID = @FlightId
  ORDER BY s.SeatNumber ASC;
END
