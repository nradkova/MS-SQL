------Section 1. DDL 
CREATE DATABASE School
USE School

CREATE TABLE Subjects(
    Id INT PRIMARY KEY IDENTITY NOT NULL,
    Name NVARCHAR(20) NOT NULL,
    Lessons INT NOT NULL)

CREATE TABLE Exams(
    Id INT PRIMARY KEY IDENTITY NOT NULL,
    Date DATE,
    SubjectId INT FOREIGN KEY REFERENCES Subjects(Id))

CREATE TABLE Students(
    Id INT PRIMARY KEY IDENTITY NOT NULL,
    FirstName NVARCHAR(20) NOT NULL,
    MiddleName NVARCHAR(20),
    LastName NVARCHAR(20) NOT NULL,
    Age INT NOT NULL CHECK (Age > 0),
    Address NVARCHAR(30),
    Phone NVARCHAR(10))

CREATE TABLE Teachers(
    Id INT PRIMARY KEY IDENTITY NOT NULL,
    FirstName NVARCHAR(20) NOT NULL,
    LastName NVARCHAR(20) NOT NULL,
    Address NVARCHAR(20) NOT NULL,
    Phone NVARCHAR(10),
    SubjectId INT FOREIGN KEY REFERENCES Subjects(Id))

CREATE TABLE StudentsExams(
    StudentId INT NOT NULL,
    ExamId INT NOT NULL,
    Grade DECIMAL(15,2) NOT NULL CHECK (Grade >= 2 AND Grade <= 6),
    PRIMARY KEY (StudentId, ExamId),
    FOREIGN KEY (StudentId) REFERENCES Students (Id),
    FOREIGN KEY (ExamId) REFERENCES Exams (Id))

CREATE TABLE StudentsTeachers(
    StudentId INT NOT NULL,
    TeacherId INT NOT NULL,
    PRIMARY KEY (StudentId, TeacherId),
    FOREIGN KEY (StudentId) REFERENCES Students (Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers (Id))

CREATE TABLE StudentsSubjects(
    Id INT PRIMARY KEY IDENTITY,
    StudentId INT NOT NULL,
    SubjectId INT NOT NULL,
    Grade DECIMAL(15,2) NOT NULL  CHECK (Grade >= 2 AND Grade <= 6),
    FOREIGN KEY (StudentId) REFERENCES Students (Id),
    FOREIGN KEY (SubjectId) REFERENCES Subjects (Id))





------Section 2. DML 
---Insert


---Update
UPDATE StudentsSubjects
SET Grade=6
WHERE SubjectId IN (1,2) AND Grade>=5.50

---Delete
DELETE FROM StudentsTeachers
WHERE TeacherId IN (SELECT Id FROM Teachers WHERE Phone LIKE '%72%')
DELETE FROM Teachers
WHERE Phone LIKE '%72%'




------Section 3. Querying 

---Teen Students
SELECT FirstName
      ,LastName
      ,Age
FROM Students
WHERE AGE>=12
ORDER BY FirstName,LastName


---Students Teachers
SELECT s.FirstName
      ,s.LastName
      ,TeachersCount=COUNT(st.TeacherId)
FROM Students AS s
LEFT JOIN StudentsTeachers AS st ON s.Id=st.StudentId
GROUP BY s.Id,s.FirstName,s.LastName
ORDER BY s.LastName


---Students to Go
SELECT [Full Name]= CONCAT(s.FirstName, ' ',s.LastName)
FROM Students AS s
LEFT JOIN StudentsExams AS se ON s.Id=se.StudentId
WHERE se.ExamId IS NULL
ORDER BY [Full Name]


--- Top Students
SELECT TOP 10 s.FirstName
      ,s.LastName
      ,Grade=CAST(ROUND(AVG(se.Grade),2) AS DECIMAL (5,2))
FROM Students AS s
JOIN StudentsExams AS se ON s.Id=se.StudentId
GROUP BY s.Id,s.FirstName,s.LastName
ORDER BY Grade DESC,s.FirstName,s.LastName


---Not So In The Studying
SELECT [Full Name]=CONCAT(st.FirstName,' ',st.MiddleName+' ',st.LastName)
FROM Students AS st
LEFT JOIN StudentsSubjects AS sb ON st.Id=sb.StudentId
WHERE sb.SubjectId IS NULL
ORDER BY [Full Name]


--Average Grade per Subject
SELECT NAME=s.Name
      ,AverageGrade=AVG(ss.Grade)
FROM StudentsSubjects AS ss
JOIN Subjects AS s ON ss.SubjectId=s.Id
GROUP BY ss.SubjectId,s.Name
ORDER BY ss.SubjectId


