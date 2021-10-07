--Queries for SoftUni Database

USE SoftUniFunc

---Find Names of All Employees by First Name
SELECT FirstName
      ,LastName 
FROM Employees
WHERE LEFT(FirstName,2)='Sa'


---Find Names of All employees by Last Name 
SELECT FirstName
      ,LastName
FROM Employees
WHERE LastName LIKE '%ei%'


---Find First Names of All Employees
SELECT FirstName
FROM Employees
WHERE DepartmentID IN (3,10) AND DATEPART(YEAR,HireDate) BETWEEN 1995 AND 2005


---Find All Employees Except Engineers
SELECT FirstName
      ,LastName
FROM Employees
WHERE CHARINDEX('engineer',LOWER( JobTitle))=0


---Find Towns with Name Length
SELECT Name
FROM Towns
WHERE LEN(Name)=5 OR LEN(NAME)=6
ORDER BY Name


---Find Towns Starting With
SELECT TownID
      ,Name
FROM Towns
WHERE SUBSTRING(Name,1,1) IN ('M','K','B','E')
ORDER BY Name


--- Find Towns Not Starting With
SELECT TownID
      ,Name
FROM Towns
WHERE SUBSTRING(Name,1,1) NOT IN ('R','B','D')
ORDER BY Name


---Create View Employees Hired After 2000 Year
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName
      ,LastName
FROM Employees
WHERE DATEPART(YEAR,HireDate)>2000


---Length of Last Name
SELECT FirstName
      ,LastName
FROM Employees
WHERE LEN(LastName)=5


---Rank Employees by Salary
SELECT EmployeeID
      ,FirstName
      ,LastName
      ,Salary
      ,DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC


---Find All Employees with Rank 2 
SELECT *
FROM  
    (SELECT EmployeeID
       ,FirstName
       ,LastName
       ,Salary
       ,DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS [Rank]
     FROM Employees
     WHERE Salary BETWEEN 10000 AND 50000) AS [RankTable]
WHERE [Rank]=2
ORDER BY Salary DESC




--Queries for Geography Database 
USE Geography

---Countries Holding ‘A’ 3 or More Times
SELECT CountryName  AS [Country Name]
      ,IsoCode AS [ISO Code]
FROM Countries
WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode


--Mix of Peak and River Names
SELECT p.PeakName 
      ,r.RiverName
      ,LOWER(CONCAT(LEFT(p.PeakName,LEN(p.PeakName)-1),r.RiverName)) AS MIX
FROM Peaks AS p
    ,Rivers AS r
WHERE LOWER(RIGHT(p.PeakName,1))=LOWER(LEFT(r.RiverName,1))
ORDER BY MIX




--Queries for Diablo Database
USE Diablo

---Games from 2011 and 2012 year
SELECT TOP 50 Name
      ,FORMAT(Start,'yyyy-MM-dd') AS Start
FROM Games
WHERE DATEPART(YEAR,Start) BETWEEN 2011 AND 2012
ORDER BY Start
      ,Name


---User Email Providers
SELECT Username
      ,SUBSTRING(Email,(CHARINDEX('@',Email)+1),LEN(Email)-(CHARINDEX('@',1)+1)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider]
      ,Username


---Get Users with IPAdress Like Pattern
SELECT Username
      ,IpAddress AS [IP Address]
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username
		 

---Show All Games with Duration and Part of the Day
SELECT Name AS Game
      ,CASE
           WHEN DATEPART(HOUR,Start) BETWEEN 0 AND 11 THEN 'Morning'
           WHEN DATEPART(HOUR,Start) BETWEEN 12 AND 17 THEN 'Afternoon'
           ELSE 'Evening'
       END AS [Part of the Day]
      ,CASE
           WHEN Duration BETWEEN 0 AND 3 THEN 'Extra Short'
           WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
           WHEN Duration>6 THEN 'Long'
           ELSE 'Extra Long'
       END AS Duration
FROM Games
ORDER BY Name
      ,Duration



--Date Functions Queries
CREATE TABLE Orders(
    Id INT IDENTITY PRIMARY KEY,
    ProductName CHAR(30) NOT NULL,
    OrderDate DATETIME2 
)

INSERT INTO Orders (ProductName,OrderDate) VALUES
    ('Butter','09-19-2016')

SELECT ProductName
      ,OrderDate
      ,DATEADD(DAY,3,OrderDate) AS [Pay Due]
      ,DATEADD(MONTH,1,OrderDate) AS [Deliver Due]
FROM Orders
