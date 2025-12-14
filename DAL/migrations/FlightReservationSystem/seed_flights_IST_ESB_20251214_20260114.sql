-- Ensure Airline and Airports exist with required fields
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airlines WHERE Name = N'Turkish Airlines')
INSERT INTO FlightReservationSystem.Airlines (Name, Country, Contact) VALUES (N'Turkish Airlines', N'Turkey', N'info@tk.com');
ELSE
UPDATE FlightReservationSystem.Airlines SET Country = ISNULL(Country, N'Turkey'), Contact = ISNULL(Contact, N'info@tk.com')
WHERE Name = N'Turkish Airlines';

IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airports WHERE IATA_Code = N'IST')
INSERT INTO FlightReservationSystem.Airports (IATA_Code, City, Name, Country) VALUES (N'IST', N'Istanbul', N'Istanbul Airport', N'Turkey');
ELSE
UPDATE FlightReservationSystem.Airports SET Country = ISNULL(Country, N'Turkey'), Name = ISNULL(Name, N'Istanbul Airport')
WHERE IATA_Code = N'IST';

IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airports WHERE IATA_Code = N'ESB')
INSERT INTO FlightReservationSystem.Airports (IATA_Code, City, Name, Country) VALUES (N'ESB', N'Ankara', N'Esenboga Airport', N'Turkey');
ELSE
UPDATE FlightReservationSystem.Airports SET Country = ISNULL(Country, N'Turkey'), Name = ISNULL(Name, N'Esenboga Airport')
WHERE IATA_Code = N'ESB';

DECLARE @al_TK INT = (SELECT AirlineID FROM FlightReservationSystem.Airlines WHERE Name = N'Turkish Airlines');
DECLARE @ap_IST INT = (SELECT AirportID FROM FlightReservationSystem.Airports WHERE IATA_Code = N'IST');
DECLARE @ap_ESB INT = (SELECT AirportID FROM FlightReservationSystem.Airports WHERE IATA_Code = N'ESB');

DECLARE @startDate DATE = N'2025-12-14';
DECLARE @endDate DATE = N'2026-01-14';
DECLARE @curr DATE = @startDate;

WHILE @curr <= @endDate
BEGIN
  -- Depart at 13:00, arrive 14:30 (approx.)
  DECLARE @dep DATETIME2 = DATEADD(HOUR, 13, CAST(@curr AS DATETIME2));
  DECLARE @arr DATETIME2 = DATEADD(MINUTE, 90, @dep);

  IF NOT EXISTS (
    SELECT 1 FROM FlightReservationSystem.Flights 
    WHERE AirlineID = @al_TK AND DepartureAirportID = @ap_IST AND ArrivalAirportID = @ap_ESB
      AND CAST(DepartureTime AS DATE) = @curr AND DATEPART(HOUR, DepartureTime) = 13
  )
  INSERT INTO FlightReservationSystem.Flights (AirlineID, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status)
  VALUES (@al_TK, @ap_IST, @ap_ESB, @dep, @arr, N'Scheduled');

  SET @curr = DATEADD(DAY, 1, @curr);
END

-- Add pricing if missing for IST->ESB
INSERT INTO FlightReservationSystem.FlightPricing (FlightID, Price)
SELECT f.FlightID, 1200
FROM FlightReservationSystem.Flights f
JOIN FlightReservationSystem.Airports ao ON ao.AirportID = f.DepartureAirportID
JOIN FlightReservationSystem.Airports ad ON ad.AirportID = f.ArrivalAirportID
LEFT JOIN FlightReservationSystem.FlightPricing fp ON fp.FlightID = f.FlightID
WHERE ao.IATA_Code = N'IST' AND ad.IATA_Code = N'ESB' AND fp.FlightID IS NULL;

