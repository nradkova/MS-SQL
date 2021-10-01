---Random queries
CREATE DATABASE [Minions]

CREATE TABLE [Minions](
	[Id] INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	[Age] INT NULL
)

CREATE TABLE [Towns](
	[Id] INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
)

ALTER TABLE [Minions]
	ADD [TownsId] INT FOREIGN KEY REFERENCES [Towns]([Id])
	
INSERT INTO dbo.[Towns] ([Id] , [Name]) VALUES
	(1,'Sofia'),
	(2,'Plovdiv'),
	(3,'Varna')


INSERT INTO dbo.[Minions] ([Id],[Name], [Age], [TownId]) VALUES
	(1,'Kevin',22,1 ),
	(2,'Bob',15,3),
	(3,'Steward',NULL,2)

DROP TABLE dbo.[Minions];

EXEC sp_rename [Minions.TownsId], [TownId], 'COLUMN';

CREATE TABLE [People](
	[Id] BIGINT IDENTITY(1,1) PRIMARY KEY,
	[Name] NVARCHAR(200) NOT NULL,
	[Picture] VARBINARY(MAX) NULL  
		CHECK (DATALENGTH ([Picture]) <= 2000000),
	[Height] FLOAT(24) NULL,
	[Weight] FLOAT NULL,
	[Gender] CHAR NOT NULL
		CHECK ([Gender]='m'OR [Gender]='f'),
	[Birthdate] DATETIME2 NOT NULL,
	[Biography] NVARCHAR(MAX) NULL
)

INSERT INTO dbo.People([Name], [Picture], [Height], [Weight], [Gender], [Birthdate], [Biography]) VALUES
	('Kevin',NULL,2.00,100,'m','2000-12-31',NULL ),
	('Bob',NULL,1.80,100,'m','2000-07-31',NULL ),
	('Bobby',NULL,1.80,88.500,'m','2000-07-15','aaaaaaaaaaaaaaaaaa' ),
	('Dona',NULL,1.80,68,'f','1999-07-15','aaaaaaaaaaaaaaaaaa' ),
	('Mona',NULL,1.69,58.2,'f','1999-07-15','aaaaaaaaaaaaaaaaaa' )


CREATE TABLE [Users](
	[Id] BIGINT IDENTITY(1,1) PRIMARY KEY,
	[Username] NVARCHAR(30) UNIQUE NOT NULL,
	[Password] NVARCHAR(26) NOT NULL,
	[ProfilePicture] VARBINARY(MAX) NULL
		CHECK (DATALENGTH([ProfilePicture])<=900000),
	[LastLoginTime] DATETIME2 NULL,
	[IsDeleted] BIT NOT NULL,
)

INSERT INTO dbo.[Users]([Username],[Password],[ProfilePicture],[LastLoginTime],[IsDeleted]) VALUES
	('Kevin','ABC7',NULL,'2000-12-31',0 ),
	('Bob','ABC789',NULL,'2000-12-31',0 ),
	('Bobby','@ABC',NULL,'2000-01-12',1 ),
	('Dona','ABC_7',NULL,'2000-05-16',1 ),
	('Mona','ABC@123',NULL,'2000-12-31',0 )

ALTER TABLE [Users]
	DROP CONSTRAINT [PK__Users__3214EC07AF350FFF]

ALTER TABLE [Users]
	ADD CONSTRAINT [PK_UsersCompositeIdUsername] PRIMARY KEY ([Id],[Username])

ALTER TABLE [Users]
	ADD CONSTRAINT df_LastLoginTime DEFAULT GETDATE() FOR [LastLoginTime];


----Movies Database

CREATE DATABASE Movies

CREATE TABLE Directors(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200) NULL
)

INSERT INTO Directors(DirectorName,Notes) VALUES
	('AAAAAAAAAA','aaaaaaaaaaa'),
	('BBBBBBBBB', 'bbbbbbbbb'),
	('CCCCCCCCC',NULL),
	('DDDDDDDDDDD DD',NULL),
	('E EEEEE',NULL)

CREATE TABLE Genres(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200) NULL
)

INSERT INTO Genres(GenreName,Notes) VALUES
	('Action','aaaaaaaaaaaaa'),
	('Animation','aaa aaa'),
	('Comedy',NULL),
	('Crime',NULL),
	('Fantasy',NULL)

CREATE TABLE Categories(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200) NULL
)

INSERT INTO Categories(CategoryName,Notes) VALUES
	('QQQQQQQQQQQ','aaaaaaaaaaaaa'),
	('WWWWWWWWW','aaa aaa'),
	('RRRRRRRR',NULL),
	('TTTTTTTTTT',NULL),
	('YYYYYYY',NULL)

CREATE TABLE Movies(
	Id BIGINT IDENTITY(1,1) PRIMARY KEY,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors (Id) NOT NULL,
	CopyrightYear SMALLINT NOT NULL,
	[Length] SMALLINT NOT NULL,
	GenreId INT FOREIGN KEY REFERENCES Genres (Id) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories (Id) NOT NULL,
	Rating DECIMAL(5,2) NOT NULL,
	Notes NVARCHAR(200) NULL
)

INSERT INTO Movies(Title,DirectorId,CopyrightYear,[Length],GenreId,CategoryId,Rating,Notes) VALUES
	('No name',1,1990,120,2,1,5.5,'no name notes'),
	('First name',2,2000,220,2,5,6.6,'first name notes'),
	('Second name',5,2011,160,4,2,9,NULL),
	('Third name',5,2011,160,4,2,9,NULL),
	('Fourth name',5,2011,160,4,2,9,NULL)


