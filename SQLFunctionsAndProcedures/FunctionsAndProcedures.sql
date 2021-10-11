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
GO

CREATE OR ALTER PROCEDURE usp_EmployeesBySalaryLevel @salaryLevel VARCHAR(7)
AS
	SELECT FirstName
          ,LastName
    FROM Employees
    WHERE dbo.ufn_GetSalaryLevel(Salary)=@salaryLevel

GO

EXEC usp_EmployeesBySalaryLevel 'High'


---Define Function
GO

CREATE OR ALTER FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(100), @word NVARCHAR(100)) 
RETURNS BIT
AS
BEGIN
DECLARE @index INT=1
WHILE @index<=LEN(@word)
       BEGIN
             IF CHARINDEX(SUBSTRING(@word,@index,1),@setOfLetters)=0
	         BEGIN
	         RETURN 0 
	         END
	   SET @index+=1
       END
RETURN 1
END
GO

SELECT dbo.ufn_IsWordComprised('oistmiahf','Sofia')
SELECT dbo.ufn_IsWordComprised('oistmiahf','halves')
SELECT dbo.ufn_IsWordComprised('bobr','Rob')
SELECT dbo.ufn_IsWordComprised('pppp','Guy')


---Delete Employees and Departments
GO

CREATE PROCEDURE usp_DeleteEmployeesFromDepartment @departmentId INT
AS
BEGIN
      DELETE FROM EmployeesProjects
      WHERE EmployeeID IN (
                            SELECT EmployeeID
                            FROM Employees
                            WHERE DepartmentID=@departmentId
                           )
      
      UPDATE Employees
      SET ManagerID =NULL
      WHERE ManagerID IN (
                            SELECT EmployeeID
                            FROM Employees
                            WHERE DepartmentID=@departmentId
                           )
      
      ALTER TABLE Departments
      ALTER COLUMN ManagerID INT NULL

	  UPDATE Departments
      SET ManagerID =NULL
      WHERE ManagerID IN (
                            SELECT EmployeeID
                            FROM Employees
                            WHERE DepartmentID=@departmentId
                           )
      
      DELETE FROM Employees
      WHERE DepartmentID=@departmentId
      
      DELETE FROM Departments
      WHERE DepartmentID=@departmentId
      
      SELECT COUNT(*)
      FROM Employees
      WHERE DepartmentID=@departmentId
END

GO





--Data Queries for Bank Database
USE Bank

---Find Full Name
GO

CREATE PROCEDURE usp_GetHoldersFullName 
AS
SELECT CONCAT( FirstName,' ',LastName) AS [Full Name]
FROM AccountHolders
WHERE Id IN 
            (SELECT AccountHolderId
             FROM Accounts)

GO

EXEC usp_GetHoldersFullName


---People with Balance Higher Than
GO

CREATE OR ALTER PROCEDURE usp_GetHoldersWithBalanceHigherThan  @number DECIMAL(15,4)
AS
SELECT [First Name]= MIN(ah.FirstName),[Last Name]=MIN(ah.LastName)
FROM Accounts AS a
LEFT JOIN AccountHolders AS ah
ON a.AccountHolderId=ah.Id
GROUP BY a.AccountHolderId
HAVING SUM(a.Balance)>@number
ORDER BY [First Name],[Last Name]
GO

EXEC usp_GetHoldersWithBalanceHigherThan 100000


---Future Value Function
GO

CREATE OR ALTER FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(15,4), @rate DECIMAL(5,2),@years INT)
RETURNS DECIMAL(15,4)
AS
BEGIN
      WHILE @years>0
	  BEGIN
      SET @sum+=@sum*@rate
	  SET @years-=1
	  END
RETURN @sum
END

GO

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)


---Calculating Interest
GO

CREATE OR ALTER PROCEDURE usp_CalculateFutureValueForAccount @accountId INT, @rate DECIMAL(5,2) 
AS
SELECT [Account Id]= a.Id
       ,ah.FirstName
       ,ah.LastName
       ,[Current Balance]= a.Balance
       ,[Balance in 5 years]=dbo.ufn_CalculateFutureValue(a.Balance,@rate,5)
FROM Accounts AS a
LEFT JOIN AccountHolders AS ah
ON a.AccountHolderId=ah.Id
WHERE a.Id=@accountId

GO

EXEC usp_CalculateFutureValueForAccount 1,0.1




----Data Queries for Diablo Database
USE Diablo

---Cash in User Games Odd Rows
GO

CREATE OR ALTER FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(50))
RETURNS @output TABLE (SumCash DECIMAL(15,4))
AS
BEGIN
	 
	  DECLARE @id INT
	  DECLARE @sum DECIMAL(15,4)
	  SET @id=(SELECT Id
               FROM Games
               WHERE Name=@gameName)

	  SET @sum=(SELECT SumCash=SUM(s.Cash) 
                FROM
                    (SELECT *,RowNumber=ROW_NUMBER() OVER (ORDER BY Cash DESC)
	                FROM UsersGames
	                WHERE GameId=@id) AS s
                WHERE s.RowNumber%2<>0
                GROUP BY s.GameId)
     INSERT INTO @output VALUES (@sum)
	-- SELECT * FROM @output
	RETURN
END

GO

SELECT * 
FROM dbo.ufn_CashInUsersGames('Love in a mist') AS s
