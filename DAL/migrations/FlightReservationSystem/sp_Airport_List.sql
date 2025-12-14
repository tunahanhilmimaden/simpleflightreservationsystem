CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_Airport_List]
AS
BEGIN
  SET NOCOUNT ON;
  SELECT IATA_Code AS code, City AS city
  FROM FlightReservationSystem.Airports
  ORDER BY City ASC;
END
