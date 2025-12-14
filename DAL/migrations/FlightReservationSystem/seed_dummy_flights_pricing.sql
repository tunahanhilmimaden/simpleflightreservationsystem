-- Insert dummy flights across multiple days and routes
DECLARE @today DATE = CAST(GETDATE() AS DATE);

DECLARE @al_TK INT, @al_PG INT, @al_BA INT, @al_LH INT;
SELECT @al_TK = AirlineID FROM FlightReservationSystem.Airlines WHERE Name = N'Turkish Airlines';
SELECT @al_PG = AirlineID FROM FlightReservationSystem.Airlines WHERE Name = N'Pegasus';
SELECT @al_BA = AirlineID FROM FlightReservationSystem.Airlines WHERE Name = N'British Airways';
SELECT @al_LH = AirlineID FROM FlightReservationSystem.Airlines WHERE Name = N'Lufthansa';

DECLARE @ap_IST INT, @ap_SAW INT, @ap_LHR INT, @ap_CDG INT, @ap_JFK INT, @ap_BER INT;
SELECT @ap_IST = AirportID FROM FlightReservationSystem.Airports WHERE IATA_Code = N'IST';
SELECT @ap_SAW = AirportID FROM FlightReservationSystem.Airports WHERE IATA_Code = N'SAW';
SELECT @ap_LHR = AirportID FROM FlightReservationSystem.Airports WHERE IATA_Code = N'LHR';
SELECT @ap_CDG = AirportID FROM FlightReservationSystem.Airports WHERE IATA_Code = N'CDG';
SELECT @ap_JFK = AirportID FROM FlightReservationSystem.Airports WHERE IATA_Code = N'JFK';
SELECT @ap_BER = AirportID FROM FlightReservationSystem.Airports WHERE IATA_Code = N'BER';

-- Helper: insert flight if not exists (by airline, airports, departure time)
DECLARE @d INT = 0;
WHILE @d < 5
BEGIN
  DECLARE @depDate DATE = DATEADD(DAY, @d, @today);
  -- IST -> LHR
  IF NOT EXISTS (
    SELECT 1 FROM FlightReservationSystem.Flights 
    WHERE AirlineID = @al_TK AND DepartureAirportID = @ap_IST AND ArrivalAirportID = @ap_LHR 
      AND CAST(DepartureTime AS DATE) = @depDate AND DATEPART(HOUR, DepartureTime) = 9
  )
  INSERT INTO FlightReservationSystem.Flights (AirlineID, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status)
  VALUES (@al_TK, @ap_IST, @ap_LHR, DATEADD(HOUR, 9, CAST(@depDate AS DATETIME2)), DATEADD(HOUR, 11, CAST(@depDate AS DATETIME2)), N'Scheduled');

  IF NOT EXISTS (
    SELECT 1 FROM FlightReservationSystem.Flights 
    WHERE AirlineID = @al_BA AND DepartureAirportID = @ap_IST AND ArrivalAirportID = @ap_LHR 
      AND CAST(DepartureTime AS DATE) = @depDate AND DATEPART(HOUR, DepartureTime) = 14
  )
  INSERT INTO FlightReservationSystem.Flights (AirlineID, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status)
  VALUES (@al_BA, @ap_IST, @ap_LHR, DATEADD(HOUR, 14, CAST(@depDate AS DATETIME2)), DATEADD(HOUR, 17, CAST(@depDate AS DATETIME2)), N'Scheduled');

  -- SAW -> LHR
  IF NOT EXISTS (
    SELECT 1 FROM FlightReservationSystem.Flights 
    WHERE AirlineID = @al_PG AND DepartureAirportID = @ap_SAW AND ArrivalAirportID = @ap_LHR 
      AND CAST(DepartureTime AS DATE) = @depDate AND DATEPART(HOUR, DepartureTime) = 6
  )
  INSERT INTO FlightReservationSystem.Flights (AirlineID, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status)
  VALUES (@al_PG, @ap_SAW, @ap_LHR, DATEADD(HOUR, 6, CAST(@depDate AS DATETIME2)), DATEADD(HOUR, 11, CAST(@depDate AS DATETIME2)), N'Scheduled');

  -- IST -> CDG
  IF NOT EXISTS (
    SELECT 1 FROM FlightReservationSystem.Flights 
    WHERE AirlineID = @al_LH AND DepartureAirportID = @ap_IST AND ArrivalAirportID = @ap_CDG 
      AND CAST(DepartureTime AS DATE) = @depDate AND DATEPART(HOUR, DepartureTime) = 13
  )
  INSERT INTO FlightReservationSystem.Flights (AirlineID, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status)
  VALUES (@al_LH, @ap_IST, @ap_CDG, DATEADD(HOUR, 13, CAST(@depDate AS DATETIME2)), DATEADD(HOUR, 16, CAST(@depDate AS DATETIME2)), N'Scheduled');

  -- IST -> BER
  IF NOT EXISTS (
    SELECT 1 FROM FlightReservationSystem.Flights 
    WHERE AirlineID = @al_TK AND DepartureAirportID = @ap_IST AND ArrivalAirportID = @ap_BER 
      AND CAST(DepartureTime AS DATE) = @depDate AND DATEPART(HOUR, DepartureTime) = 10
  )
  INSERT INTO FlightReservationSystem.Flights (AirlineID, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status)
  VALUES (@al_TK, @ap_IST, @ap_BER, DATEADD(HOUR, 10, CAST(@depDate AS DATETIME2)), DATEADD(HOUR, 12, CAST(@depDate AS DATETIME2)), N'Scheduled');

  -- LHR -> JFK (daha uzun, min fiyat testi için)
  IF NOT EXISTS (
    SELECT 1 FROM FlightReservationSystem.Flights 
    WHERE AirlineID = @al_BA AND DepartureAirportID = @ap_LHR AND ArrivalAirportID = @ap_JFK 
      AND CAST(DepartureTime AS DATE) = @depDate AND DATEPART(HOUR, DepartureTime) = 8
  )
  INSERT INTO FlightReservationSystem.Flights (AirlineID, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status)
  VALUES (@al_BA, @ap_LHR, @ap_JFK, DATEADD(HOUR, 8, CAST(@depDate AS DATETIME2)), DATEADD(HOUR, 16, CAST(@depDate AS DATETIME2)), N'Scheduled');

  SET @d = @d + 1;
END

-- Insert pricing for all flights on the seeded dates if missing
INSERT INTO FlightReservationSystem.FlightPricing (FlightID, Price)
SELECT f.FlightID,
       CASE 
         WHEN ad.IATA_Code = N'LHR' THEN 4500
         WHEN ad.IATA_Code = N'CDG' THEN 3800
         WHEN ad.IATA_Code = N'BER' THEN 2900
         WHEN ad.IATA_Code = N'JFK' THEN 15000
         ELSE 2500
       END
FROM FlightReservationSystem.Flights f
JOIN FlightReservationSystem.Airports ao ON ao.AirportID = f.DepartureAirportID
JOIN FlightReservationSystem.Airports ad ON ad.AirportID = f.ArrivalAirportID
LEFT JOIN FlightReservationSystem.FlightPricing fp ON fp.FlightID = f.FlightID
WHERE fp.FlightID IS NULL;
