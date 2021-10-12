-------Section 1. DDL 

CREATE DATABASE WMS
USE WMS

CREATE TABLE Clients(
   ClientId INT IDENTITY PRIMARY KEY,
   FirstName VARCHAR(50) NOT NULL,
   LastName VARCHAR(50) NOT NULL,
   Phone CHAR(12) NOT NULL CHECK(LEN(Phone)=12)
)

CREATE TABLE Mechanics(
   MechanicId INT IDENTITY PRIMARY KEY,
   FirstName VARCHAR(50) NOT NULL,
   LastName VARCHAR(50) NOT NULL,
   Address VARCHAR(255) NOT NULL
)

CREATE TABLE Models(
   ModelId INT IDENTITY PRIMARY KEY,
   Name VARCHAR(50) UNIQUE NOT NULL,
)

CREATE TABLE Vendors(
   VendorId INT IDENTITY PRIMARY KEY,
   Name VARCHAR(50) UNIQUE NOT NULL,
)

CREATE TABLE Parts(
   PartId INT IDENTITY PRIMARY KEY,
   SerialNumber VARCHAR(50) UNIQUE NOT NULL,
   Description VARCHAR(255)  NULL,
   Price DECIMAL(6,2) CHECK (Price>0) NOT NULL,
   VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
   StockQty INT CHECK (StockQty>=0) DEFAULT 0 NOT NULL,
)

CREATE TABLE Jobs(
   JobId INT IDENTITY PRIMARY KEY,
   ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
   Status VARCHAR(11) CHECK (Status IN('Pending', 'In Progress', 'Finished')) DEFAULT ('Pending') NOT NULL,
   ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
   MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId) NULL,
   IssueDate DATE NOT NULL,
   FinishDate DATE NULL,
)

CREATE TABLE Orders(
   OrderId INT IDENTITY PRIMARY KEY,
   JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
   IssueDate DATE NULL,
   Delivered BIT DEFAULT 0 NOT NULL,
)

CREATE TABLE OrderParts(
   OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
   PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
   PRIMARY KEY (OrderId,PartId),
   Quantity INT CHECK(Quantity>0) DEFAULT 1 NOT NULL,
)

CREATE TABLE PartsNeeded(
   JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
   PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
   PRIMARY KEY (JobId,PartId),
   Quantity INT CHECK(Quantity>0) DEFAULT 1 NOT NULL,
)




------Section 2. DML

---Insert
INSERT INTO Clients(FirstName,LastName,Phone) VALUES
    ('Teri','Ennaco','570-889-5187'),
    ('Merlyn','Lawler','201-588-7810'),
    ('Georgene','Montezuma','925-615-5185'),
    ('Jettie','Mconnell','908-802-3564'),
    ('Lemuel','Latzke','631-748-6479'),
    ('Melodie','Knipp','805-690-1682'),
    ('Candida','Corbley','908-275-8357')

INSERT INTO Parts(SerialNumber,Description,Price,VendorId) VALUES
    ('WP8182119','Door Boot Seal',117.86 ,2),
    ('W10780048','Suspension Rod',42.81 ,1),
    ('W10841140','Silicone Adhesive',6.77 ,4),
    ('WPY055980','High Temperature Adhesive',13.94 ,3)

---Update
UPDATE Jobs
SET MechanicId=3,Status='In Progress'
WHERE Status='Pending'

---Delete
DELETE FROM OrderParts
WHERE OrderId=19

DELETE FROM Orders
WHERE OrderId=19



------Section 3. Querying 

---Mechanic Assignments
SELECT [Full Name]=CONCAT(m.FirstName,' ',m.LastName)
      ,j.Status
      ,j.IssueDate
FROM Mechanics AS m
INNER JOIN Jobs AS j ON m.MechanicId=j.MechanicId
ORDER BY m.MechanicId,j.IssueDate,j.JobId


---Current Clients
SELECT Client=CONCAT(c.FirstName,' ',c.LastName)
      ,[Days going]=DATEDIFF(DAY,j.IssueDate, '2017-04-24')
      ,j.Status
FROM Clients AS c
JOIN Jobs AS j ON c.ClientId=j.ClientId
WHERE j.Status<>'Finished'
ORDER BY [Days going] DESC,c.ClientId


---Mechanic Performance
SELECT [Mechanic]=CONCAT(MIN(m.FirstName),' ',MIN(m.LastName))
      ,[Average Days]=AVG(DATEDIFF(DAY,j.IssueDate, j.FinishDate))
FROM Mechanics AS m
JOIN Jobs AS j ON m.MechanicId=j.MechanicId
WHERE j.Status='Finished'
GROUP BY m.MechanicId
ORDER BY m.MechanicId


---Available Mechanics
SELECT Available = CONCAT(MIN(m.FirstName),' ',MIN(m.LastName))
FROM Mechanics AS m LEFT JOIN Jobs AS j
ON m.MechanicId=j.MechanicId
WHERE J.MechanicId NOT IN
                        (SELECT MechanicId
                         FROM Jobs 
                         WHERE Status='In Progress')
GROUP BY m.MechanicId
ORDER BY m.MechanicId


---Past Expenses
SELECT j.JobId
      ,Total=SUM(p.Price)
FROM Jobs AS j
JOIN PartsNeeded AS pn ON j.JobId=pn.JobId
JOIN Parts AS p ON pn.PartId=p.PartId
GROUP BY j.JobId
ORDER BY Total DESC,j.JobId


---Missing Parts
SELECT *
FROM
    (SELECT p.PartId
           ,p.Description
           ,Required=pn.Quantity
           ,[In Stock]=p.StockQty
           ,Ordered=ISNULL(op.Quantity,0)
    FROM Jobs AS j
    LEFT JOIN PartsNeeded AS pn ON j.JobId=pn.JobId
    LEFT JOIN Parts AS p ON p.PartId=pn.PartId
    LEFT JOIN Orders AS o ON J.JobId=o.JobId
    LEFT JOIN OrderParts AS op ON  o.OrderId=op.OrderId
    WHERE j.Status<>'Finished'AND (o.Delivered=0 OR o.Delivered IS NULL)) AS s
WHERE s.Required>s.[In Stock]+s.Ordered

SELECT PartId
      ,Description
      ,Required
      ,[In Stock]
      ,Ordered
FROM
    (SELECT p.Description
           ,p.PartId
           ,Required=pn.Quantity
           ,[In Stock]=p.StockQty
           ,IsDelivered=ISNULL(o.Delivered,0)
           ,Ordered=ISNULL(op.Quantity,0)
    FROM Jobs AS j
    LEFT JOIN PartsNeeded AS pn ON pn.JobId=j.JobId
    LEFT JOIN Parts AS p ON p.PartId=pn.PartId
    LEFT JOIN Orders AS o ON o.JobId=j.JobId
    LEFT JOIN OrderParts AS op ON o.OrderId=op.OrderId
    WHERE j.Status<>'Finished') AS sq
WHERE IsDelivered=0 AND Required>[In Stock]+Ordered
ORDER BY PartId



-------Section 4. Programmability
---	Place Order


---Cost Of Order
GO

CREATE OR ALTER FUNCTION udf_GetCost (@jobId INT)
RETURNS DECIMAL (15,2)
AS
BEGIN
RETURN (SELECT ISNULL(SUM(p.Price),0) 
        FROM Jobs AS j
        LEFT JOIN Orders AS o ON j.JobId=o.JobId
        JOIN OrderParts AS op ON o.OrderId=op.OrderId
        JOIN Parts AS p ON op.PartId=p.PartId
        WHERE j.JobId=@jobId)
END

GO

--SELECT dbo.udf_GetCost(1000)