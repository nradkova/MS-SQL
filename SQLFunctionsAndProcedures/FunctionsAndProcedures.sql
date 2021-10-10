-- Data Queries for SoftUni Database
USE SoftUniFunc

---Employees with Salary Above 35000
GO

CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000 
AS 
   SELECT FirstName,LastName FROM Employees WHERE Salary>35000

GO

EXEC usp_GetEmployeesSalaryAbove35000


---Employees with Salary Above Number
GO

CREATE OR ALTER PROCEDURE usp_GetEmployeesSalaryAboveNumber @salaryLevel DECIMAL(18,4)
AS 
   SELECT FirstName,LastName FROM Employees WHERE Salary>=@salaryLevel

GO

EXEC usp_GetEmployeesSalaryAboveNumber 48100


---Town Names Starting With
GO

CREATE OR ALTER PROCEDURE usp_GetTownsStartingWith @search NVARCHAR(50)
AS 
   SELECT Name FROM Towns WHERE LOWER(Name) LIKE LOWER(CONCAT(@search,'%'))

GO

EXEC usp_GetTownsStartingWith 'b'


---Employees from Town
GO

CREATE OR ALTER PROCEDURE usp_GetEmployeesFromTown  @search NVARCHAR(50)
AS 
   SELECT FirstName,LastName 
   FROM Employees AS e
   INNER JOIN Addresses AS a
   ON e.AddressID=a.AddressID
   INNER JOIN Towns AS t
   ON a.TownID=t.TownID
   WHERE LOWER(t.Name)=LOWER(@search)

GO

EXEC usp_GetEmployeesFromTown 'Sofia'


---Salary Level Function
GO

CREATE OR ALTER FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(7)
AS
BEGIN
   DECLARE @result VARCHAR(7)
   IF @salary<30000
   SET @result= 'Low'
   ELSE IF @salary<50000
   SET @result=  'Average'
   ELSE
   SET @result= 'High'
   RETURN  @result    
END

GO

DECLARE @currSalary DECIMAL(18,4)=100000
SELECT dbo.ufn_GetSalaryLevel(@currSalary)


---Employees by Salary Level
			

SELECT FirstName,
       SL= dbo.ufn_GetSalaryLevel(Salary)
FROM Employees


SELECT FirstName
	   ,LastName
	   ,DepartmentID
	   ,SL= dbo.ufn_GetSalaryLevel(Salary)
FROM Employees