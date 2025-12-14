-- Seed dummy Airlines
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airlines WHERE Name = N'Turkish Airlines')
INSERT INTO FlightReservationSystem.Airlines(Name, Country) VALUES (N'Turkish Airlines', N'Turkey');
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airlines WHERE Name = N'Pegasus')
INSERT INTO FlightReservationSystem.Airlines(Name, Country) VALUES (N'Pegasus', N'Turkey');
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airlines WHERE Name = N'British Airways')
INSERT INTO FlightReservationSystem.Airlines(Name, Country) VALUES (N'British Airways', N'United Kingdom');
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airlines WHERE Name = N'Lufthansa')
INSERT INTO FlightReservationSystem.Airlines(Name, Country) VALUES (N'Lufthansa', N'Germany');

-- Seed dummy Airports
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airports WHERE IATA_Code = N'IST')
INSERT INTO FlightReservationSystem.Airports(IATA_Code, City, Name) VALUES (N'IST', N'Istanbul', N'Istanbul Airport');
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airports WHERE IATA_Code = N'SAW')
INSERT INTO FlightReservationSystem.Airports(IATA_Code, City, Name) VALUES (N'SAW', N'Istanbul (Sabiha)', N'Sabiha Gokcen Airport');
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airports WHERE IATA_Code = N'LHR')
INSERT INTO FlightReservationSystem.Airports(IATA_Code, City, Name) VALUES (N'LHR', N'London', N'Heathrow Airport');
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airports WHERE IATA_Code = N'CDG')
INSERT INTO FlightReservationSystem.Airports(IATA_Code, City, Name) VALUES (N'CDG', N'Paris', N'Charles de Gaulle Airport');
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airports WHERE IATA_Code = N'JFK')
INSERT INTO FlightReservationSystem.Airports(IATA_Code, City, Name) VALUES (N'JFK', N'New York', N'John F. Kennedy International Airport');
IF NOT EXISTS (SELECT 1 FROM FlightReservationSystem.Airports WHERE IATA_Code = N'BER')
INSERT INTO FlightReservationSystem.Airports(IATA_Code, City, Name) VALUES (N'BER', N'Berlin', N'Berlin Brandenburg Airport');
