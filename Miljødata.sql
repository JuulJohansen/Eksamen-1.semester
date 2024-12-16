CREATE TABLE `HCandersen` (
starttid datetime primary key, -- Starttid på scrapen,
CO int, -- CO Data
NO2 int, -- NO2 Data
NOX int, -- NOX Data
SO2 int, -- SO2 Data
O3 int, -- O3 Data
PM10 int, -- PM10 Data
`PM2.5` int, -- PM2.5 Data
Scrapetime datetime
);
SELECT * FROM Risoe;

CREATE TABLE `Risoe` (
starttid datetime, -- Starttid på scrapen,
CO int, -- CO Data
NO2 int, -- NO2 Data
NOX int, -- NOX Data
O3 int, -- O3 Data
PM10 int, -- PM10 Data
Scrapetime datetime,
FOREIGN KEY (starttid) REFERENCES `HCandersen` (starttid)
);

CREATE TABLE `Banegaard` (
starttid datetime, -- Starttid på scrapen,
CO int, -- CO Data
NO2 int, -- NO2 Data
NOX int, -- NOX Data
Scrapetime datetime,
FOREIGN KEY (starttid) REFERENCES `HCandersen` (starttid)
);

CREATE TABLE `Anholt` (
starttid datetime, -- Starttid på scrapen,
NO2 int, -- NO2 Data
NOX int, -- NOX Data
Scrapetime datetime,
FOREIGN KEY (starttid) REFERENCES `HCandersen` (starttid)
);