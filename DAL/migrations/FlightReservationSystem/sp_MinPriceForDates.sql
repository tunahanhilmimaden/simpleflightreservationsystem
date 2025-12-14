CREATE OR ALTER PROCEDURE [FlightReservationSystem].[sp_MinPriceForDates]
  @Origin NVARCHAR(10),
  @Dest NVARCHAR(10),
  @StartDate DATE,
  @Days INT
AS
BEGIN
  SET NOCOUNT ON;
  ;WITH d AS (
    SELECT 0 AS offset
    UNION ALL
    SELECT offset + 1 FROM d WHERE offset + 1 < @Days
  )
  SELECT
    DATEADD(DAY, d.offset, @StartDate) AS theDate,
    FlightReservationSystem.fn_MinPriceOnDate(@Origin, @Dest, DATEADD(DAY, d.offset, @StartDate)) AS minPrice
  FROM d
  OPTION (MAXRECURSION 1000);
END
