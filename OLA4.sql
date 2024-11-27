
CREATE TABLE Biler.Forhandler (
    ForhandlerID VARCHAR(100) PRIMARY KEY, -- Unikt ID for forhandleren
    #Forhandlernavn VARCHAR(50) NOT NULL, -- Navn på forhandleren
    Location VARCHAR(100) -- Adresse på forhandleren
);

-- Opret tabel "Biler"
CREATE TABLE Biler.Biler (
    CarId INT PRIMARY KEY, -- Unikt ID for bilen
    Model VARCHAR(100) NOT NULL, -- Bilens model
    Fra_land VARCHAR(2), -- Beskrivelse af bilen
    Link VARCHAR(100), -- Link til bilens side
    ForhandlerID VARCHAR(100), -- Fremmednøgle der linker til CVRnummer i "Forhandler"
    FOREIGN KEY (ForhandlerID) REFERENCES Forhandler(ForhandlerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Opret tabel "Bilpriser"
CREATE TABLE Biler.Bilpriser (
    CarId INT, -- Fremmednøgle der linker til CarId i "Biler"
    Dato DATE NOT NULL, -- Alder på bilen
    Price INT NOT NULL, -- Pris på bilen
    Kilometer INT NOT NULL, -- Kilometer kørt
    Scrapedate datetime Not NUll, -- WebScrape tiden
    FOREIGN KEY (CarId) REFERENCES Biler(CarId)
        ON DELETE CASCADE ON UPDATE CASCADE
);

DESCRIBE Biler;
Select * From Biler;