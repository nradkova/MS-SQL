-------Section 1. DDL 
CREATE DATABASE Airport
USE Airport

CREATE TABLE Planes(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(30) NOT NULL,
    Seats INT NOT NULL,
    Range INT NOT NULL)

CREATE TABLE Flights(
    Id INT IDENTITY PRIMARY KEY,
    DepartureTime DATETIME2 NULL,
    ArrivalTime DATETIME2 NULL,
    Origin NVARCHAR(50) NOT NULL,
    Destination NVARCHAR(50) NOT NULL,
    PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL)

CREATE TABLE Passengers(
    Id INT IDENTITY PRIMARY KEY,
    FirstName NVARCHAR(30) NOT NULL,
    LastName NVARCHAR(30) NOT NULL,
    Age INT  NOT NULL,
    Address NVARCHAR(30) NOT NULL,
    PassportId CHAR(11) NOT NULL)
    --CHECK(LEN(PassportId)=11))

CREATE TABLE LuggageTypes(
    Id INT IDENTITY PRIMARY KEY,
    Type NVARCHAR(30) NOT NULL)

CREATE TABLE Luggages(
    Id INT IDENTITY PRIMARY KEY,
    LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
    PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL)

CREATE TABLE Tickets(
    Id INT IDENTITY PRIMARY KEY,
    PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
    FlightId INT FOREIGN KEY REFERENCES Flights(Id) NOT NULL,
    LuggageId INT FOREIGN KEY REFERENCES Luggages(Id) NOT NULL,
    Price DECIMAL(15,2) NOT NULL)




------Section 2. DML 

---Insert
INSERT INTO Planes(Name,Seats,Range) VALUES
    ('Airbus 336',112,5132),
    ('Airbus 330',432,5325),
    ('Boeing 369',231,2355),
    ('Stelt 297',254,2143),
    ('Boeing 338',165,5111),
    ('Airbus 558',387,1342),
    ('Boeing 128',345,5541)

INSERT INTO LuggageTypes(Type) VALUES
    ('Crossbody Bag'),
    ('School Backpack'),
    ('Shoulder Bag')
 

---Update
UPDATE Tickets
SET Price*=1.13
WHERE FlightId IN (SELECT Id FROM Flights WHERE Destination='Carlsbad')


---Delete
DELETE FROM Tickets WHERE FlightId IN(SELECT Id FROM Flights WHERE Destination='Ayn Halagim')
DELETE FROM Flights WHERE Destination='Ayn Halagim'




------Section 3. Querying 

---	The "Tr" Planes
SELECT *
FROM Planes
WHERE NAME LIKE '%tr%'
ORDER BY Id,Name,Seats,Range


---Flight Profits
SELECT FlightId=f.Id
      ,Price=SUM(t.Price)
FROM Flights AS f
JOIN Tickets AS t ON f.Id=t.FlightId
GROUP BY f.Id
ORDER BY Price DESC, FlightId


---Passenger Trips
SELECT [Full Name]=CONCAT(p.FirstName,' ',p.LastName)
      ,Origin=f.Origin
      ,Destination =f.Destination
FROM Tickets AS t
JOIN Passengers AS p ON t.PassengerId=p.Id
JOIN Flights AS f ON t.FlightId=f.Id
ORDER BY [Full Name],Origin,Destination


---Non Adventures People
SELECT FirstName
      ,LastName,Age
FROM Passengers
WHERE Id NOT IN (SELECT PassengerId FROM Tickets)
ORDER BY Age DESC, FirstName,LastName


---Full Info
SELECT [Full Name]=CONCAT(p.FirstName,' ',p.LastName)
      ,[Plane Name]=pl.Name
      ,Trip=CONCAT(f.Origin,' - ',f.Destination)
      ,[Luggage Type]=lt.Type
FROM Passengers AS p
JOIN Tickets AS t ON p.Id=t.PassengerId
JOIN Flights AS f ON t.FlightId=f.Id
JOIN Planes AS pl ON pl.Id=f.PlaneId
JOIN Luggages AS l ON t.LuggageId=l.Id
JOIN LuggageTypes AS lt ON l.LuggageTypeId=lt.Id
ORDER BY [Full Name], [Plane Name],f.Origin,f.Destination,[Luggage Type]


---PSP
SELECT Name=MIN(p.Name)
      ,Seats=AVG(p.Seats)
      ,[Passengers Count]=ISNULL(COUNT(t.PassengerId),0)
FROM Planes AS p
LEFT JOIN Flights AS f ON p.Id=f.PlaneId
LEFT JOIN Tickets AS t ON t.FlightId=f.Id
GROUP BY p.Id
ORDER BY [Passengers Count] DESC,Name,Seats

SELECT Name=p.Name
      ,Seats=p.Seats
      ,[Passengers Count]=ISNULL(COUNT(t.PassengerId),0)
FROM Planes AS p
LEFT JOIN Flights AS f ON p.Id=f.PlaneId
LEFT JOIN Tickets AS t ON t.FlightId=f.Id
GROUP BY p.Id,p.Name,p.Seats
ORDER BY [Passengers Count] DESC,Name,Seats




------Section 4. Programmability 

---	Vacation
GO

CREATE OR ALTER FUNCTION  udf_CalculateTickets(@origin NVARCHAR(50), @destination NVARCHAR(50), @peopleCount INT)
RETURNS NVARCHAR(50)
AS
BEGIN
     IF @peopleCount<=0 
        RETURN 'Invalid people count!'

   --IF NOT EXISTS (SELECT 1 FROM Flights WHERE Origin=@origin AND Destination=@destination)
     -- RETURN 'Invalid flight!'
     IF @origin NOT IN (SELECT Origin FROM Flights) OR @destination NOT IN (SELECT Destination FROM Flights)
        RETURN 'Invalid flight!'
     
RETURN CONCAT('Total price ',@peopleCount*(SELECT TOP 1 t.Price
                                           FROM Flights AS f
                                           JOIN Tickets AS t ON f.Id=t.FlightId
                                           WHERE Origin=@origin AND Destination=@destination)) 
END

GO

--SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 33)

--SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', -1)

--SELECT dbo.udf_CalculateTickets('Invalid','Rancabolang', 33)


---Wrong Data
GO

CREATE OR ALTER PROCEDURE usp_CancelFlights
AS
UPDATE Flights
SET ArrivalTime=NULL,DepartureTime=NULL 
WHERE ArrivalTime>DepartureTime

GO

--EXEC usp_CancelFlights
