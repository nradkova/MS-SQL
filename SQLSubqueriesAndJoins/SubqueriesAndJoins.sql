--Data queries for SoftUni database
USE SoftUniFunc

---Employee Address
SELECT TOP 5 e.EmployeeID
            ,e.JobTitle
			,e.AddressID
			,a.AddressText
FROM Employees AS e
LEFT JOIN Addresses AS a
ON e.AddressID=a.AddressID
ORDER BY e.AddressID


---Addresses with Towns
SELECT TOP 50 e.FirstName
             ,e.LastName
			 ,t.Name AS Town
			 ,a.AddressText
FROM Employees AS e
LEFT JOIN Addresses AS a
ON e.AddressID=a.AddressID
LEFT JOIN Towns AS t
ON a.TownID=t.TownID
ORDER BY e.FirstName
        ,e.LastName


---Sales Employee
SELECT e.EmployeeID
      ,e.FirstName
	  ,e.LastName
	  ,d.Name AS DepartmentName
FROM Employees AS e
LEFT JOIN Departments AS d
ON e.DepartmentID=d.DepartmentID
WHERE d.Name='Sales'
ORDER BY e.EmployeeID


---Employee Departments
SELECT TOP 5 e.EmployeeID
      ,e.FirstName
	  ,e.Salary
	  ,d.Name AS DepartmentName
FROM Employees AS e
LEFT JOIN Departments AS d
ON e.DepartmentID=d.DepartmentID
WHERE e.Salary>15000
ORDER BY e.DepartmentID


---Employees Without Projects
SELECT TOP 3 e.EmployeeID
      ,e.FirstName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep
ON e.EmployeeID=ep.EmployeeID
LEFT JOIN Projects AS p
ON ep.ProjectID=p.ProjectID
WHERE P.ProjectID IS NULL
ORDER BY e.EmployeeID


---Employees Hired After
SELECT e.FirstName
      ,e.LastName
	  ,e.HireDate
	  ,d.Name AS DeptName
FROM Employees AS e
LEFT JOIN Departments AS d
ON e.DepartmentID=d.DepartmentID
WHERE e.HireDate>'1999-01-01' AND d.Name IN ('Sales','Finance')
ORDER BY e.HireDate


---Employees with Project
SELECT TOP 5 e.EmployeeID
      ,e.FirstName
	  ,p.Name AS ProjectName
FROM Employees AS e
INNER JOIN EmployeesProjects AS ep
ON e.EmployeeID=ep.EmployeeID
INNER JOIN Projects AS p
ON ep.ProjectID=p.ProjectID
WHERE p.StartDate>'2002-08-13' AND p.EndDate IS NULL
ORDER BY e.EmployeeID


---Employee 24
SELECT e.EmployeeID
      ,e.FirstName
	  ,ProjectName=
	  CASE
	      WHEN DATEPART(YEAR,p.StartDate)>=2005  THEN NULL
		  ELSE p.Name
	   END 
FROM Employees AS e
INNER JOIN EmployeesProjects AS ep
ON e.EmployeeID=ep.EmployeeID
INNER JOIN Projects AS p
ON ep.ProjectID=p.ProjectID
WHERE e.EmployeeID=24 


---Employee Manager
SELECT e.EmployeeID
      ,e.FirstName
	  ,e.ManagerID
	  ,m.FirstName AS ManagerName
FROM Employees AS e
INNER JOIN Employees AS m
ON e.ManagerID=m.EmployeeID
WHERE e.ManagerID IN (3,7)
ORDER BY e.EmployeeID


---Employee Summary
SELECT TOP 50 e.EmployeeID
      ,CONCAT(e.FirstName,' ',e.LastName) AS EmployeeName
	  ,CONCAT(m.FirstName,' ',m.LastName) AS ManagerName
	  ,d.Name AS DepartmentName
FROM Employees AS e
INNER JOIN Employees AS m
ON e.ManagerID=m.EmployeeID
INNER JOIN Departments AS d
ON e.DepartmentID=d.DepartmentID
ORDER BY e.EmployeeID


---Min Average Salary
SELECT MIN(a.AvrSalary) AS MinAverageSalary
FROM
     (SELECT e.DepartmentID
            ,AVG(e.Salary) AS AvrSalary
     FROM Employees AS e 
     GROUP BY e.DepartmentID) AS a




--Data queries for Geography database
USE Geography

---Highest Peaks in Bulgaria
SELECT c.CountryCode
      ,m.MountainRange
	  ,p.PeakName
	  ,p.Elevation
FROM Countries AS c
INNER JOIN MountainsCountries AS mc
ON c.CountryCode=mc.CountryCode
INNER JOIN Mountains AS m
ON mc.MountainId=m.Id
INNER JOIN Peaks AS p
ON m.Id=p.MountainId
WHERE c.CountryCode='BG' AND p.Elevation>2835
ORDER BY p.Elevation DESC


--Count Mountain Ranges
SELECT c.CountryCode
	  ,COUNT(mc.MountainId) AS MountainRanges
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
ON c.CountryCode=mc.CountryCode
WHERE c.CountryCode IN ('BG','US','RU')
GROUP BY c.CountryCode


--Countries with Rivers
SELECT TOP 5 c.CountryName
      ,r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr
ON c.CountryCode=cr.CountryCode
LEFT JOIN Rivers AS r
ON cr.RiverId=R.Id
WHERE C.ContinentCode='AF'
ORDER BY c.CountryName


---Continents and Currencies
SELECT ContinentCode
      ,CurrencyCode
	  ,CurrencyUsage
FROM
      (SELECT *
             ,CurrencyRank=DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY CurrencyUsage DESC )
       FROM
              (SELECT ContinentCode
                     ,CurrencyCode
                     ,CurrencyUsage=COUNT(CurrencyCode)
               FROM Countries
               GROUP BY ContinentCode,CurrencyCode) AS CurrencyGroupingSubquery
       WHERE CurrencyUsage>1) AS CurrencyCountSubquery
WHERE CurrencyRank=1
GROUP BY ContinentCode,CurrencyCode,CurrencyUsage


---Countries Without Any Mountains
SELECT COUNT(CountryCode) AS Count
FROM
       (SELECT c.CountryCode,mc.MountainId
       FROM Countries AS c
       LEFT JOIN MountainsCountries AS mc
       ON c.CountryCode=mc.CountryCode
       WHERE MountainId IS NULL) AS MountainsCountSubquery
GROUP BY MountainId


---Highest Peak and Longest River by Country
SELECT TOP 5 c.CountryName
      ,MAX(p.Elevation) AS HighestPeakElevation
      ,MAX(r.Length) AS LongestRiverLength
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
ON c.CountryCode=mc.CountryCode
LEFT JOIN Mountains AS m
ON mc.MountainId=m.Id
LEFT JOIN Peaks AS p
ON m.Id=p.MountainId
LEFT JOIN CountriesRivers AS cr
ON c.CountryCode=cr.CountryCode
LEFT JOIN Rivers AS r
ON cr.RiverId=r.Id
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC
        ,LongestRiverLength DESC
		,c.CountryName


---Highest Peak Name and Elevation by Country
SELECT TOP 5 CountryName AS Country
      ,[Highest Peak Name]=ISNULL(PeakName,'(no highest peak)')
	  ,[Highest Peak Elevation]=ISNULL(Elevation,0)
	  ,Mountain=ISNULL(MountainRange,'(no mountain)')
FROM
      (SELECT c.CountryName
              ,p.PeakName
			  ,p.Elevation
      	      ,m.MountainRange
			  ,DENSE_RANK() OVER (PARTITION BY c.CountryCode ORDER BY p.Elevation DESC) AS [Rank]
      FROM Countries AS c
      LEFT JOIN MountainsCountries AS mc
      ON c.CountryCode=mc.CountryCode
      LEFT JOIN Mountains AS m
      ON mc.MountainId=m.Id
      LEFT JOIN Peaks AS p
      ON m.Id=p.MountainId) AS PeaksElevationSubquery
WHERE [Rank]=1
ORDER BY Country,[Highest Peak Name]