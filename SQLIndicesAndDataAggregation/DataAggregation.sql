--Data Queries for Gringotts Database
USE Gringotts

---Records’ Count
SELECT COUNT(*) AS [Count]
FROM WizzardDeposits


---Longest Magic Wand
SELECT TOP 1 LongestMagicWand=MagicWandSize
FROM WizzardDeposits
ORDER BY MagicWandSize DESC


---Longest Magic Wand Per Deposit Groups
SELECT DepositGroup
      ,LongestMagicWand=MAX(MagicWandSize)
FROM WizzardDeposits
GROUP BY DepositGroup


---Smallest Deposit Group per Magic Wand Size
SELECT TOP 2 DepositGroup
FROM
      (SELECT DepositGroup
             ,AvgMagicWandSize= AVG(MagicWandSize) 
      FROM WizzardDeposits
      GROUP BY DepositGroup) AS AvgMagicWandSizeSubquery
ORDER BY AvgMagicWandSize


---Deposits Sum
SELECT DepositGroup
      ,TotalSum=SUM(DepositAmount)
FROM WizzardDeposits
GROUP BY DepositGroup


---Deposits Sum for Ollivander Family
SELECT DepositGroup
      ,TotalSum=SUM(DepositAmount)
FROM WizzardDeposits
WHERE MagicWandCreator='Ollivander family'
GROUP BY DepositGroup


--- Deposits Filter
SELECT DepositGroup
      ,TotalSum=SUM(DepositAmount)
FROM WizzardDeposits
WHERE MagicWandCreator='Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount)<150000
ORDER BY TotalSum DESC


---Deposit Charge
SELECT DepositGroup
      ,MagicWandCreator
      ,MinDepositCharge=MIN(DepositCharge)
FROM WizzardDeposits
GROUP BY DepositGroup,MagicWandCreator
ORDER BY MagicWandCreator,DepositGroup


---Age Groups
SELECT AgeGroup
      ,WizardCount=COUNT(AgeGroup)
FROM
      (SELECT AgeGroup=
                 CASE
                     WHEN Age<=10 THEN '[0-10]'
                     WHEN Age>10 AND Age<=20 THEN '[11-20]'
                     WHEN Age>20 AND Age<=30 THEN '[21-30]'
                     WHEN Age>30 AND Age<=40 THEN '[31-40]'
                     WHEN Age>40 AND Age<=50 THEN '[41-50]'
                     WHEN Age>50 AND Age<=60 THEN '[51-60]'
                     ELSE '[61+]'
                 END
      FROM WizzardDeposits) AS AgeGroupSubquery
GROUP BY AgeGroup 


---First Letter
SELECT DISTINCT FirstLetter=LEFT(FirstName,1)
FROM WizzardDeposits
WHERE DepositGroup='Troll Chest'
ORDER BY FirstLetter


---Average Interest
SELECT DepositGroup
      ,IsDepositExpired
      ,AverageInterest=AVG(DepositInterest)
FROM WizzardDeposits
WHERE DepositStartDate>'01/01/1985'
GROUP BY DepositGroup,IsDepositExpired
ORDER BY DepositGroup DESC,IsDepositExpired


---Rich Wizard, Poor Wizard
SELECT SumDifference=SUM([Difference])
FROM
       (SELECT [Host Wizard]=f.FirstName
              ,[Host Wizard Deposit]=f.DepositAmount
              ,[Guest Wizard]=s.FirstName
              ,[Guest Wizard Deposit]=s.DepositAmount
              ,[Difference]=f.DepositAmount-s.DepositAmount
        FROM WizzardDeposits AS f
        LEFT JOIN WizzardDeposits AS s
        ON f.Id+1=s.Id) AS MatchingSubquery


---Rich Wizard, Poor Wizard(other decision)
SELECT SumDifference=SUM([Difference])
FROM
       (SELECT [Host Wizard]=FirstName
              ,[Host Wizard Deposit]=DepositAmount
              ,[Guest Wizard]=LEAD(FirstName) OVER (ORDER BY Id)
              ,[Guest Wizard Deposit]=LEAD(DepositAmount) OVER (ORDER BY Id)
              ,[Difference]=DepositAmount-LEAD(DepositAmount) OVER (ORDER BY Id)
        FROM WizzardDeposits) AS MatchingSubquery




--Data Queries for SoftUni  Database
USE SoftUniFunc

---Departments Total Salaries
SELECT DepartmentID
      ,TotalSalary=SUM(Salary)
FROM Employees 
GROUP BY DepartmentID
ORDER BY DepartmentID


---Employees Minimum Salaries
SELECT DepartmentID
      ,MinimumSalary=MIN(Salary)
FROM Employees 
WHERE DepartmentID IN (2,5,7) AND HireDate>'2000-01-01'
GROUP BY DepartmentID
ORDER BY DepartmentID


---Employees Average Salaries
SELECT DepartmentID
      ,AverageSalary=AVG(ReCalcSalary)
FROM
      (SELECT DepartmentID
             ,ReCalcSalary=
                   CASE
                       WHEN DepartmentID=1 THEN Salary+5000
                       ELSE Salary
                   END
      FROM 
	       (SELECT *
		    FROM Employees
			WHERE Salary>30000 AND ManagerID != 42 OR ManagerID IS NULL) AS FilteringSubquery
      ) AS ReCalculationSalarySubquery
GROUP BY DepartmentID


---Employees Average Salaries(other decision)
SELECT DepartmentID, Salary, ManagerID
INTO SalariesOver30000
FROM Employees
WHERE SALARY > 30000

DELETE FROM SalariesOver30000
WHERE ManagerID = 42

UPDATE  SalariesOver30000
SET SALARY += 5000
WHERE DepartmentID = 1

SELECT DepartmentID,AverageSalary= AVG(Salary)
FROM SalariesOver30000
GROUP BY DepartmentID


---Employees Maximum Salaries
SELECT DepartmentID
      ,MaxSalary=MAX(Salary)
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary)<30000 OR MAX(Salary)>70000


---Employees Count Salaries
SELECT [Count]=COUNT(Salary)
FROM Employees
WHERE ManagerID IS NULL


---3rd Highest Salary
SELECT DepartmentID
      ,ThirdHighestSalary=MAX(Salary)
FROM
     (SELECT *
           ,[Rank]=DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC)
     FROM Employees) AS SalaryRankingSubquery
WHERE [Rank]=3
GROUP BY DepartmentID


---Salary Challenge
SELECT TOP 10 FirstName
      ,LastName
	  ,e.DepartmentID
FROM Employees AS e
INNER JOIN 
          (SELECT DepartmentID, AvgSalary=AVG(Salary)
           FROM Employees
           GROUP BY DepartmentID) AS s
ON e.DepartmentID=s.DepartmentID
WHERE Salary>AvgSalary
ORDER BY e.DepartmentID


---Salary Challenge(other decision)
SELECT TOP 10 FirstName
      ,LastName
	  ,e.DepartmentID
FROM Employees AS e
WHERE e.Salary>
              (SELECT AvgSalary=AVG(Salary)
               FROM Employees  AS s
		       WHERE e.DepartmentID=s.DepartmentID
		       GROUP BY s.DepartmentID)
ORDER BY e.DepartmentID
