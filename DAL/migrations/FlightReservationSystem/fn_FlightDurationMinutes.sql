CREATE OR ALTER FUNCTION [FlightReservationSystem].[fn_FlightDurationMinutes]
(
  @Departure DATETIME2,
  @Arrival DATETIME2
)
RETURNS INT
AS
BEGIN
  RETURN DATEDIFF(MINUTE, @Departure, @Arrival);
END
