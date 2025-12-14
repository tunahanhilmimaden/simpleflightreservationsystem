CREATE OR ALTER FUNCTION [FlightReservationSystem].[fn_SeatSurcharge]
(
  @BasePrice DECIMAL(18,2),
  @PriceMultiplier DECIMAL(18,2)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
  RETURN (@BasePrice * (@PriceMultiplier - 1));
END
