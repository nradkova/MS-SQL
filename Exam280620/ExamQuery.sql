CREATE DATABASE ColonialJourney
USE ColonialJourney

--------Section 1. DDL 
CREATE TABLE Planets(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(30) NOT NULL)

CREATE TABLE Spaceports(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL,
	PlanetId INT FOREIGN KEY REFERENCES Planets(Id))

CREATE TABLE Spaceships(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT(0))

CREATE TABLE Colonists(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) UNIQUE NOT NULL,
	BirthDate DATE NOT NULL)

CREATE TABLE Journeys(
	Id INT PRIMARY KEY IDENTITY,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) CHECK (Purpose IN ('Medical','Technical','Educational','Military')),
	DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id),
	SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id))

CREATE TABLE TravelCards(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber VARCHAR(10) UNIQUE NOT NULL,
	JobDuringJourney VARCHAR(8) CHECK (JobDuringJourney IN ('Pilot','Engineer','Trooper','Cleaner','Cook')),
	ColonistId INT FOREIGN KEY REFERENCES Colonists(Id),
	JourneyId INT FOREIGN KEY REFERENCES Journeys(Id))




--------Section 2. DML

---Insert

---Update
UPDATE Spaceships
SET LightSpeedRate+=1
WHERE Id BETWEEN 8 AND 12


---Delete
DELETE FROM TravelCards
WHERE JourneyId BETWEEN 1 AND 3
DELETE FROM Journeys
WHERE Id BETWEEN 1 AND 3




--------Section 3. Querying 

---Select All Military Journeys
SELECT Id
      ,JourneyStart=FORMAT(JourneyStart,'dd/MM/yyyy')
      ,JourneyEnd=FORMAT(JourneyEnd,'dd/MM/yyyy')
FROM Journeys
WHERE Purpose='Military'
ORDER BY JourneyStart


---Select All Pilots
SELECT [id]= c.Id
      ,[full_name]=CONCAT(c.FirstName, ' ',c.LastName)
FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id=tc.ColonistId
WHERE tc.JobDuringJourney ='Pilot'
ORDER BY id 


---Count Colonists
SELECT COUNT(c.Id)
FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id=tc.ColonistId
JOIN Journeys AS j ON j.Id=tc.JourneyId
WHERE Purpose='Technical'


---Select Spaceships With Pilots
SELECT DISTINCT ss.Name
      ,ss.Manufacturer
FROM Spaceships AS ss
JOIN Journeys AS j ON j.SpaceshipId=ss.Id
JOIN TravelCards AS tc ON tc.JourneyId=j.Id
JOIN Colonists AS c ON c.Id=tc.ColonistId 
WHERE tc.JobDuringJourney='Pilot' AND DATEDIFF(YEAR,c.BirthDate,'01/01/2019')<30
ORDER BY ss.Name


---Planets And Journeys
SELECT PlanetName=p.Name
      ,JourneysCount=COUNT(j.Id)
FROM Planets AS p
JOIN Spaceports AS sp ON sp.PlanetId=p.Id
JOIN Journeys AS j ON j.DestinationSpaceportId=sp.Id
GROUP BY p.Name
ORDER BY JourneysCount DESC, PlanetName


---Select Special Colonists
SELECT s.JobDuringJourney
      ,FullName=CONCAT(s.FirstName,' ',s.LastName)
      ,s.JobRank
FROM
    (SELECT tc.JobDuringJourney
           ,c.FirstName
           ,c.LastName
           ,JobRank=DENSE_RANK() OVER(PARTITION BY tc.JobDuringJourney ORDER BY c.BirthDate)
    FROM Colonists AS c
    JOIN TravelCards AS tc ON c.Id=tc.ColonistId
    GROUP BY tc.JobDuringJourney,c.FirstName,c.LastName,c.BirthDate) AS s
WHERE s.JobRank= 2





--------Section 4. Programmability

---	Get Colonists Count
GO

CREATE OR ALTER FUNCTION dbo.udf_GetColonistsCount(@planetName VARCHAR (30)) 
RETURNS INT
AS
BEGIN
   RETURN (SELECT COUNT(tc.ColonistId)
           FROM Planets AS p
           JOIN Spaceports AS ss ON ss.PlanetId=p.Id
           JOIN Journeys AS j ON j.DestinationSpaceportId=ss.Id
           JOIN TravelCards AS tc ON tc.JourneyId=j.Id
           WHERE p.Name=@planetName)
END

GO

--SELECT dbo.udf_GetColonistsCount('Otroyphus')


---Change Journey Purpose
GO

CREATE OR ALTER PROCEDURE usp_ChangeJourneyPurpose(@journeyId INT, @newPurpose VARCHAR(11))
AS
        IF @journeyId NOT IN (SELECT Id FROM Journeys)
        THROW 50001,'The journey does not exist!',1

        IF @newPurpose=(SELECT Purpose FROM Journeys WHERE Id=@journeyId)
        THROW 50002,'You cannot change the purpose!',1

        UPDATE Journeys
        SET Purpose=@newPurpose
        WHERE Id=@journeyId
GO

--EXEC usp_ChangeJourneyPurpose 196, 'Technical'
--EXEC usp_ChangeJourneyPurpose 2, 'Educational'
