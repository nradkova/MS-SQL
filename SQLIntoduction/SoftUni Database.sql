CREATE DATABASE SoftUni

USE SoftUni

CREATE TABLE Towns(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] NVARCHAR(30) NOT NULL
)

INSERT INTO Towns (Name) VALUES
	('Sofia'),
	('Plovdiv'),
	('Varna'),
	('Burgas')

CREATE TABLE Addresses(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	AddressText NVARCHAR(100) NULL,
	TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL,
)

CREATE TABLE Departments(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] NVARCHAR(50) NOT NULL,
)

INSERT INTO Departments ([Name]) VALUES
	('Engineering'),
	('Sales'),
	('Marketing'),
	('Software Development'),
	('Quality Assurance')

CREATE TABLE Employees(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	FirstName NVARCHAR(30) NOT NULL, 
	MiddleName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	JobTitle NVARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments (Id) NOT NULL,
	HireDate DATETIME2 NOT NULL,
	Salary DECIMAL(9,2) NOT NULL,
	AddressId INT FOREIGN KEY REFERENCES Addresses (Id) NULL
)

INSERT INTO Employees (FirstName,MiddleName,LastName,JobTitle,DepartmentId,HireDate,Salary,AddressId) VALUES
	('Ivan','Ivanov','Ivanov','.NET Developer', 4, '2013-01-02', 3500, NULL),
	('Petar','Petrov','Petrov','Senior Engineer',1, '2004-03-02', 4000, NULL),
	('Maria','Petrova','Ivanova','Intern',5, '2016-08-28', 525.25, NULL),
	('Georgi','Terziev','Ivanov','CEO', 2, '2007-12-09', 3000, NULL),
	('Petar','Pan','Pan','Intern', 3, '2016-08-28', 599.88, NULL)

--Backup Database
BACKUP DATABASE SoftUni
TO DISK = 'D:\SQL\softuni-backup.bak' --WITH DIFFERENTIAL (for later backups)


--Select All Fields

SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees

--Select All Fields and Order Them

SELECT * FROM Towns ORDER BY [NAME]
SELECT * FROM Departments ORDER BY [Name]
SELECT * FROM Employees ORDER BY Salary DESC

--Select Some Fields

SELECT [Name] FROM Towns
	ORDER BY [NAME]
SELECT [Name] FROM Departments
	 ORDER BY [Name]
SELECT FirstName,LastName,JobTitle,Salary FROM Employees
	ORDER BY Salary DESC

--Increase Employees Salary

UPDATE Employees
SET Salary = Salary*1.1

SELECT Salary FROM Employees
