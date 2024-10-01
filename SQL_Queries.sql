-- 1 --

CREATE FUNCTION CalculateDiscount(@purchase_amount int)
RETURNS INT
AS
BEGIN
	IF (@purchase_amount >= 1000)
		RETURN 10;
	ELSE IF (@purchase_amount >= 500)
		RETURN 5;
RETURN 0;
END;

UPDATE Orders
SET discount = dbo.CalculateDiscount(amount);


-- 2 --

CREATE PROCEDURE AddNewEmployee
	@EmployeeID INT,
	@FirstName VARCHAR(100),
	@LastName VARCHAR(100),
	@Position VARCHAR(100),
	@Salary INT
AS
BEGIN
	INSERT INTO Employees(employee_id, first_name, last_name, position, salary)
	VALUES (@EmployeeID, @FirstName, @LastName, @Position, @Salary);

	SELECT SCOPE_IDENTITY() AS NewEmployeeId;
END;

EXEC AddNewEmployee 102, 'Oleg', 'Ivanov', 'Manager', 50000;


-- 3 --

CREATE PROCEDURE SellProduct
	@ProductID INT,
	@Quantity INT
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		UPDATE Inventory
		SET quantity = quantity - @Quantity
		WHERE product_id = @ProductID;

		INSERT INTO Transactions (product_id, quantity)
		VALUES (@ProductID, @Quantity);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
	END CATCH
END;


-- 4 --

-- CREATING TABLES --

CREATE TABLE Instructors(
	InstructorId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
	InstructorName VARCHAR(100)
);

CREATE TABLE Courses(
	CourseId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
	CourseName VARCHAR(100)
);

CREATE TABLE InstructorsCoursesRatio(
	RatioId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
	InstructorId INT NOT NULL,
	FOREIGN KEY (InstructorId) REFERENCES Instructors(InstructorId) ON DELETE CASCADE,
	CourseId INT NOT NULL,
	FOREIGN KEY (CourseId) REFERENCES Courses(CourseId) ON DELETE CASCADE
);

CREATE TABLE Students(
	StudentId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
	StudentName VARCHAR(100)
);

CREATE TABLE StudentsCoursesRatio(
	RatioId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
	StudentId INT NOT NULL,
	FOREIGN KEY (StudentId) REFERENCES Students(StudentId) ON DELETE CASCADE,
	CourseId INT NOT NULL,
	FOREIGN KEY (CourseId) REFERENCES Courses(CourseId) ON DELETE CASCADE
);

-- QUERIES --

SELECT s.StudentName, c.CourseName, i.InstructorName
FROM Students s
INNER JOIN StudentsCoursesRatio scr on s.StudentId = scr.StudentId
INNER JOIN Courses c on scr.CourseId = c.CourseId
INNER JOIN InstructorsCoursesRatio icr on c.CourseId = icr.CourseId
INNER JOIN Instructors i on i.InstructorId = icr.InstructorId;