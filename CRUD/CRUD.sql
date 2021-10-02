--SoftUni Database
USE SoftUni

--Find All Information About Departments
SELECT * FROM Departments


--Find all Department Names
SELECT Name FROM Departments


--Find Salary of Each Employee
SELECT FirstName, LastName, Salary FROM Employees


--Find Full Name of Each Employee
SELECT FirstName,MiddleName,LastName FROM Employees


--Find Email Address of Each Employee
SELECT CONCAT(FirstName,'.',LastName,'@softuni.bg')
	AS [Full Email Address]
  FROM Employees


--Find All Different Employee’s Salaries
SELECT DISTINCT Salary
  FROM Employees


--Find all Information About Employees
SELECT * FROM Employees
WHERE JobTitle='Sales Representative'


--Find Names of All Employees by Salary in Range
SELECT FirstName, LastName, JobTitle FROM Employees
WHERE Salary>=20000 AND Salary<=30000


--Find Names of All Employees 
SELECT CONCAT(FirstName,' ',MiddleName,' ',LastName)
	AS [Full Name]
  FROM Employees
WHERE Salary IN (25000,14000,12500,23600)

--Find All Employees Without Manager
SELECT FirstName,LastName FROM Employees
WHERE ManagerID IS NULL


--Find 5 Best Paid Employees
SELECT  TOP(5) FirstName,LastName FROM Employees 
ORDER BY Salary DESC


--Find All Employees with Salary More Than 50000
SELECT FirstName, LastName, Salary FROM Employees
WHERE Salary>50000
ORDER BY Salary DESC


--Find All Employees Except Marketing
SELECT FirstName, LastName FROM Employees
WHERE DepartmentID!=4


--Sort Employees Table
SELECT * FROM Employees
ORDER BY Salary DESC
		 ,FirstName 
		 ,LastName DESC
		 ,MiddleName
		 

--Create View Employees with Salaries
CREATE VIEW V_EmployeesSalaries AS(
	SELECT FirstName, LastName,Salary
	FROM Employees
)


--Create View Employees with Job Titles
CREATE VIEW V_EmployeeNameJobTitle AS(
	SELECT CONCAT(FirstName,' ',MiddleName, ' ',LastName) 
		AS [Full Name]
		  ,JobTitle AS [Job Title]
	  FROM Employees
)


--Distinct Job Titles
SELECT DISTINCT JobTitle FROM Employees


--Find First 10 Started Projects
  SELECT TOP(10) * FROM Projects
ORDER BY StartDate
		 ,Name


--Last 7 Hired Employees
  SELECT TOP(7) FirstName,LastName,HireDate FROM Employees
ORDER BY HireDate DESC


--Increase Salaries
SELECT * FROM Departments

UPDATE Employees
SET Salary=Salary*1.12
WHERE DepartmentID IN(1,2,4,11)

SELECT Salary FROM Employees



--Queries for Geography Database

USE Geography


--All Mountain Peaks
  SELECT PeakName FROM Peaks
ORDER BY PeakName


--Biggest Countries by Population
  SELECT TOP(30) CountryName, Population FROM Countries
   WHERE ContinentCode='EU'
ORDER BY Population DESC
		,CountryName


--Countries and Currency (Euro / Not Euro)
  SELECT CountryName,CountryCode,
         CASE
           WHEN CurrencyCode='EUR' THEN 'Euro'
	       ELSE 'Not Euro'
         END AS Currency
    FROM Countries
ORDER BY CountryName



--Queries for Diablo Database

USE Diablo

--All Diablo Characters
  SELECT Name FROM Characters
ORDER BY Name
