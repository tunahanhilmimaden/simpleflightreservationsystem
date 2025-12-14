CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Flight_AvailableSeats]
  @FlightId INT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @total INT = 0;
  DECLARE @booked INT = 0;
  SELECT @total = COUNT(*)
  FROM FlightReservationSystem.Seats s
  INNER JOIN FlightReservationSystem.Flights f ON f.AircraftID = s.AircraftID
  WHERE f.FlightID = @FlightId;

  SELECT @booked = COUNT(*)
  FROM FlightReservationSystem.Bookings b
  WHERE b.FlightID = @FlightId;

  SELECT CAST(ISNULL(@total - @booked, 0) AS INT) AS availableSeats;
END

