USE MajuUniversityDB

--#1
CREATE TABLE Student(
	StudentID VARCHAR(255) NOT NULL PRIMARY KEY,
	StudentName VARCHAR(255) NOT NULL,
	PlaceOfBirth VARCHAR(255) NOT NULL,
	DateofBirth VARCHAR(255) NOT NULL,
	ProgramID INT NOT NULL,
	Address VARCHAR(255) NOT NULL,
);
SELECT *FROM Student

CREATE TABLE Program(
	ProgramID INT NOT NULL PRIMARY KEY,
	ProgramName VARCHAR(255) NOT NULL
)

CREATE TABLE ScoreComponent(
	Component CHAR(4) NOT NULL PRIMARY KEY,
	Description VARCHAR(255) NOT NULL,
	Weight DECIMAL(10,2) NOT NULL
)

CREATE TABLE Course(
	CourseID VARCHAR(255) NOT NULL PRIMARY KEY,
	CourseName VARCHAR(255) NOT NULL,
	Credit INT
)

CREATE TABLE Weight(
	Grade VARCHAR(255) NOT NULL PRIMARY KEY,
	ScoreMin INT NOT NULL,
	ScoreMax INT NOT NULL,
	Weight DECIMAL(10,2) NOT NULL
)

CREATE TABLE StudentScore(
	StudentID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Student(StudentID),
	Semester INT NOT NULL,
	CourseID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Course(CourseID),
	TotalScore INT NOT NULL,
	Grade VARCHAR(255) NOT NULL CONSTRAINT Grade_G FOREIGN KEY REFERENCES [Weight](Grade)
)

CREATE TABLE StudentScoreDetail(
	StudentID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Student(StudentID),
	Semester INT NOT NULL,
	CourseID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Course(CourseID),
	Component CHAR(4) NOT NULL FOREIGN KEY REFERENCES ScoreComponent(Component),
	Score INT NOT NULL
	CONSTRAINT ScoreCons CHECK(Score>= 0 AND Score <=100)
)

--#2A
SELECT CourseName
FROM Course
WHERE Credit>3

--#2B
SELECT Student.StudentID, Student.StudentName, Program.ProgramID, Program.ProgramName
FROM Student
INNER JOIN Program ON Program.ProgramID = Student.ProgramID

--INSERT--
INSERT INTO Program
VALUES
	('25','Computer Science'),
	('26','Information Systems'),
	('44','Accounting'),
	('45','Management'),
	('47','International Business'),
	('77','Communication')

INSERT INTO Student
VALUES
	('2301234234','NADYA STUFANY','Makasar','1990-02-24',45,'asdsdfghh'),
	('2301234237','JUAN KANAM','Bandung','1991-03-01',45,'adsa'),
	('2301234614','RANGGA ADATYI','Surabaya','1996-03-11',25,'qweqwrwer'),
	('2301234734','SYLVIA KUYEPUTRA','Jakarta','1995-01-10',45,'asdpijawfi'),
	('2301234866','RYAN RUSLEN','Bekasi','1997-11-05',25,'asdqwrdiujh'),
	('2301234885','ANDRUW TANAMAS','Riau','1995-02-17',25,'zxnbcmnzbxc'),
	('2301234916','AAN AGUNG JULEAN','Jambi','1997-07-09',26,'hjkijkuikyjk')
	
INSERT INTO ScoreComponent
VALUES
	('ASG','Assignment',30.00),
	('MID','Mid Test',35.00),
	('FIN','Final Test',35.00)

INSERT INTO Course
VALUES
	('ACCT6164','Financial Accounting',2),
	('COMP6141','Interactive Computer Graphic',4),
	('COMP6143','Mobile Multimedia',4),
	('COMP6449','Machine Learning',3),
	('ENGL6171','Academic English I',3),
	('FINC6067','International Finance Management',2),
	('ISYS6440','Introduction to Business Databases',4),
	('MKTG6286','Consumer Psychology and Behaviour',4),
	('MKTG6287','Products and Brand Management',4),
	('MKTG6288','Digital Business and Analytics',3)

INSERT INTO [Weight]
VALUES
	('A',91,100,4.00),
	('A-',86,90,3.67),
	('B+',81,85,3.33),
	('B',76,80,3),
	('B-',71,75,2.67),
	('C+',66,70,2.33),
	('C',61,65,2),
	('D',50,60,1),
	('E',1,49,0),
	('F',0,0,0)

INSERT INTO StudentScore
VALUES
	('2301234234',20192,'ACCT6164',94,'A'),
	('2301234237',20192,'COMP6141',82,'B+'),
	('2301234614',20192,'COMP6143',87,'A-'),
	('2301234734',20192,'COMP6449',89,'A-'),
	('2301234866',20192,'ENGL6171',91,'A'),
	('2301234885',20192,'ISYS6440',88,'A-')

SELECT *FROM StudentScore

INSERT INTO StudentScoreDetail 
VALUES
	('2301234234','20192','ACCT6164','ASG',100),
	('2301234237','20192','ACCT6164','MID',90),
	('2301234614','20192','ACCT6164','FIN',95),
	('2301234734','20192','COMP6141','ASG',80),
	('2301234866','20192','COMP6141','MID',83),
	('2301234885','20192','COMP6141','FIN',85)

DELETE FROM Program
DELETE FROM Student
DELETE FROM ScoreComponent
DELETE FROM Course
DELETE FROM [Weight]
DELETE FROM StudentScore
DELETE FROM StudentScoreDetail

--#3
--SELECT emp_name, dept_name FROM Employee e JOIN Register r ON e.emp_id=r.emp_id JOIN Department d ON r.dept_id=d.dept_id;
SELECT Semester,Course.CourseID, CourseName, COUNT(CourseName) AS '#Students',
CASE WHEN StudentScore.Grade = 'A' THEN COUNT(StudentScore.Grade)END AS 'A',
CASE WHEN StudentScore.Grade = 'A-' THEN COUNT(StudentScore.Grade)END AS 'A-',
CASE WHEN StudentScore.Grade = 'B+' THEN COUNT(StudentScore.Grade)END AS 'B+',
CASE WHEN StudentScore.Grade = 'B' THEN COUNT(StudentScore.Grade)END AS 'B',
CASE WHEN StudentScore.Grade = 'B-' THEN COUNT(StudentScore.Grade)END AS 'B-'
FROM Student, Course, StudentScore, Weight
WHERE Student.StudentID = StudentScore.StudentID AND Course.CourseID = StudentScore.CourseID AND StudentScore.Grade = Weight.Grade
GROUP BY CourseName, Semester, Course.CourseID, Studentscore.Grade

--#4
SELECT Student.StudentID, StudentName, Semester, SUM(Credit) AS 'Credit Semester', 
CAST(SUM(Credit*Weight)/SUM(Credit) AS DECIMAL(5,2)) AS 'Semester GPA',
SUM(SUM(Credit)) OVER (ORDER BY Semester) AS 'Credit Cumulative', 
CAST(AVG(SUM(Course.Credit * Weight.Weight)/ SUM(Course.Credit))OVER(ORDER BY Semester)  AS DECIMAL(5,2)) AS 
'Cumulative GPA'
FROM Student, Course, StudentScore, Weight
WHERE Student.StudentID = StudentScore.StudentID AND StudentScore.CourseID = Course.CourseID AND Weight.Grade = StudentScore.Grade
GROUP BY Student.StudentID, Student.StudentName, StudentScore.Semester, Course.Credit, Weight.Weight

--#5
CREATE PROCEDURE Sp_CreateNewStudent
	
	@StudentID NVARCHAR(255),
	@StudentName NVARCHAR(255),
	@PlaceOfBirth NVARCHAR(255),
	@DateofBirth NVARCHAR(255),
	@ProgramID INT,
	@Address NVARCHAR(255)
	
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO Student(StudentID,StudentName,PlaceOfBirth,DateofBirth,ProgramID,Address) VALUES (@StudentID, @StudentName, @PlaceOfBirth, @DateofBirth, @ProgramID, @Address)
END
GO

EXEC Sp_CreateNewStudent '23021321','Mail','Jakarta','7','3213','Gading Serpong';

--#6
--SELECT *FROM StudentScoreDetail
CREATE TRIGGER Trigger_UpdateStudentSCore

ON StudentScoreDetail
AFTER UPDATE, INSERT, DELETE
AS
DECLARE @StudentID VARCHAR(255), @Semester INT, @CourseID VARCHAR(255), @Component VARCHAR(4), @Score INT, 
@Assignment INT, @Mid INT, @Final INT, @Grade VARCHAR(4), @TotalScore INT, @Ass INT, @Midd INT, @Fin INT,
@NewStudentScore INT
SELECT 
	@StudentID = inserted.StudentID,
	@Semester = inserted.Semester,
	@CourseID = inserted.CourseID,
	@Component = inserted.Component,
	@Score = inserted.Score
FROM inserted

--#INSERT
SELECT @Ass = StudentScoreDetail.Score
FROM StudentScoreDetail, inserted
WHERE StudentScoreDetail.Component = 'ASG' AND StudentScoreDetail.Score = inserted.Score AND StudentScoreDetail.StudentID = inserted.StudentID AND StudentScoreDetail.Semester = inserted.Semester AND StudentScoreDetail.CourseID = inserted.CourseID

--Nilai Assignment baru

SELECT @Assignment = (@Ass*Weight)/100
FROM ScoreComponent
WHERE ScoreComponent.Component = 'ASG'

--MID

SELECT @Mid = StudentScoreDetail.Score
FROM StudentScoreDetail, inserted
WHERE StudentScoreDetail.Component = 'MID' AND StudentScoreDetail.Score = inserted.Score AND StudentScoreDetail.StudentID = inserted.StudentID AND StudentScoreDetail.Semester = inserted.Semester AND StudentScoreDetail.CourseID = inserted.CourseID

--Nilai Mid Baru

SELECT @Midd = @Mid*Weight/100
FROM ScoreComponent
WHERE ScoreComponent.Component = 'MID'

--FINAL
SELECT @Fin = StudentScoreDetail.Score
FROM StudentScoreDetail, inserted
WHERE StudentScoreDetail.Component = 'FIN' AND StudentScoreDetail.Score = inserted.Score AND StudentScoreDetail.StudentID = inserted.StudentID AND StudentScoreDetail.Semester = inserted.Semester AND StudentScoreDetail.CourseID = inserted.CourseID

--Nilai Final Baru

SELECT @Final = @Mid*Weight/100
FROM ScoreComponent
WHERE ScoreComponent.Component = 'FIN'

SELECT @NewStudentScore = @Assignment+@Final+@Midd

UPDATE StudentScore SET TotalScore=@NewStudentScore
WHERE StudentScore.StudentID=@StudentID AND StudentScore.CourseID=@CourseID AND StudentScore.Semester=@Semester

END

DROP TRIGGER Trigger_UpdateStudentScore
SELECT *FROM StudentScoreDetail
INSERT INTO Student VALUES(230189089,'Alvin','Jakarta','221321','23','dsadsa')
INSERT INTO Course
SELECT *FROM Course
INSERT INTO StudentScoreDetail VALUES(230189089,20192,'MKTG6286','ASG',90),
	(230189089,20192,'MKTG6286','MID',80),
	(230189089,20192,'MKTG6286','FIN',100)

INSERT INTO Student VALUES(230189088,'anjing','jakarta','asdasd',23,'dsadas')
INSERT INTO StudentScoreDetail VALUES
	(230189088,20192,'ENGL6171','ASG',90),
	(230189088,20192,'ENGL6171','MID',80)

INSERT INTO StudentScoreDetail VALUES(230189089,20192,'MKTG6286','ASG',90)

SELECT *FROM Student

