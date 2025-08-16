-- DATABASE CREATION
DROP DATABASE IF EXISTS jp;
CREATE DATABASE jp;
USE jp;

-- TABLE CREATION

-- Students table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    department VARCHAR(20)
);

-- Instructors table
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY AUTO_INCREMENT,
    instructor_name VARCHAR(50)
);

-- Courses table
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(50),
    instructor_id INT,
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

-- Enrollments table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    score INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- INSERT DATA

-- Students
INSERT INTO students (name, department) VALUES
('Alice', 'CSE'),
('Bob', 'EEE'),
('Charlie', 'CSE'),
('David', 'BBA'),
('Eva', 'CSE'),
('Frank', 'EEE'),
('Grace', 'CSE');

-- Instructors
INSERT INTO instructors (instructor_name) VALUES
('Prof. Smith'),
('Dr. Johnson'),
('Dr. Lee'),
('Dr. Brown');

-- Courses
INSERT INTO courses (course_name, instructor_id) VALUES
('Database', 1),
('Networking', 2),
('Algorithms', 1),
('Math', 3),
('Physics', 2);

-- Enrollments
INSERT INTO enrollments (student_id, course_id, score) VALUES
(1, 1, 95),
(1, 2, 88),
(2, 2, 76),
(3, 1, 89),
(3, 3, 94),
(4, 4, 80),
(5, 1, 78),
(6, 2, 92),
(7, 3, 91);

-- SHOW TABLES
SHOW TABLES;

--------------------------------------------------------
-- SECTION 1: Basic INNER JOIN + GROUP BY + HAVING (Q1–Q10)
--------------------------------------------------------

-- Q1. List all students with their enrolled courses
SELECT s.name, c.course_name
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON c.course_id = e.course_id;

-- Q2. Show each student’s total score
SELECT s.name, SUM(e.score) AS total_score
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
GROUP BY e.student_id;

-- Q3. Students with total score > 200
SELECT s.name, SUM(e.score) AS total_score
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
GROUP BY e.student_id
HAVING SUM(e.score) > 200;

-- Q4. Average score per course
SELECT c.course_name, AVG(e.score) AS avg_score
FROM courses c
INNER JOIN enrollments e ON c.course_id = e.course_id
GROUP BY e.course_id;

-- Q5. Average score per course (only if >2 students)
SELECT c.course_name, AVG(e.score) AS avg_score, COUNT(e.student_id) AS student_count
FROM courses c
INNER JOIN enrollments e ON c.course_id = e.course_id
GROUP BY e.course_id
HAVING student_count > 2;

-- Q6. CSE students average > 85
SELECT s.name, AVG(e.score) AS avg_score
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
WHERE s.department='CSE'
GROUP BY e.student_id
HAVING avg_score > 85;

-- Q7. Courses highest score <90
SELECT c.course_name, MAX(e.score) AS max_score
FROM courses c
INNER JOIN enrollments e ON c.course_id = e.course_id
GROUP BY e.course_id
HAVING max_score < 90;

-- Q8. Students scored >80 per course
SELECT c.course_name, COUNT(e.student_id) AS high_scorer
FROM courses c
INNER JOIN enrollments e ON c.course_id = e.course_id
WHERE e.score > 80
GROUP BY e.course_id;

-- Q9. Courses where all scores > 60
SELECT c.course_name
FROM courses c
INNER JOIN enrollments e ON c.course_id = e.course_id
GROUP BY e.course_id
HAVING MIN(e.score) > 60;

-- Q10. Highest scorer per course
SELECT s.name, c.course_name, e.score
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON c.course_id = e.course_id
WHERE e.score = (
    SELECT MAX(score) 
    FROM enrollments 
    WHERE course_id = e.course_id
);

--------------------------------------------------------
-- SECTION 2: LEFT JOIN / RIGHT JOIN (Q11–Q17)
--------------------------------------------------------

-- Q11. All students even if no enrollment
SELECT s.name, c.course_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON c.course_id = e.course_id;

-- Q12. All courses even if no students
SELECT c.course_name, s.name
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.course_id
LEFT JOIN students s ON s.student_id = e.student_id;

-- Q13. Students not enrolled in any course
SELECT s.name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.course_id IS NULL;

-- Q15. Instructors + courses (even if none)
SELECT i.instructor_name, c.course_name
FROM instructors i
LEFT JOIN courses c ON c.instructor_id = i.instructor_id;

-- Q16. Course + student count (0 if none)
SELECT c.course_name, COUNT(e.student_id) AS student_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name;

-- Q17. Students + number of courses (0 if none)
SELECT s.name, COUNT(e.course_id) AS course_count
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.name;

--------------------------------------------------------
-- SECTION 3: Multiple Join & CROSS JOIN (Q18–Q21)
--------------------------------------------------------

-- Q18. Students with instructors
SELECT s.name, i.instructor_name
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON c.course_id = e.course_id
INNER JOIN instructors i ON i.instructor_id = c.instructor_id;

-- Q19. All possible student-course combinations
SELECT s.name, c.course_name
FROM students s
CROSS JOIN courses c;

-- Q20. Students + distinct instructors
SELECT DISTINCT s.name, i.instructor_name
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON c.course_id = e.course_id
INNER JOIN instructors i ON i.instructor_id = c.instructor_id;

-- Q21. Number of students per instructor
SELECT i.instructor_name, COUNT(e.student_id) AS student_count
FROM instructors i
INNER JOIN courses c ON i.instructor_id = c.instructor_id
INNER JOIN enrollments e ON c.course_id = e.course_id
GROUP BY i.instructor_name;

--------------------------------------------------------
-- SECTION 4: Advanced Aggregates & HAVING (Q22–Q26)
--------------------------------------------------------

-- Q22. Student who took most courses
SELECT s.name, COUNT(e.course_id) AS course_count
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
GROUP BY e.student_id
ORDER BY course_count DESC
LIMIT 1;

-- Q23. Instructor with most courses
SELECT i.instructor_name, COUNT(e.course_id) AS course_count
FROM instructors i
INNER JOIN courses c ON i.instructor_id = c.instructor_id
INNER JOIN enrollments e ON e.course_id = c.course_id
GROUP BY i.instructor_name
ORDER BY course_count DESC
LIMIT 1;

-- Q24. Course with biggest score gap
SELECT c.course_name, MAX(e.score) - MIN(e.score) AS score_gap
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id
ORDER BY score_gap DESC
LIMIT 1;

-- Q25. Students enrolled in all courses
SELECT s.name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.name
HAVING COUNT(DISTINCT e.course_id) = (SELECT COUNT(*) FROM courses);

-- Q26. Students scored above course avg in all courses
SELECT s.name
FROM students s
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments e
    JOIN (
        SELECT course_id, AVG(score) AS avg_score
        FROM enrollments
        GROUP BY course_id
    ) avg_table ON e.course_id = avg_table.course_id
    WHERE e.student_id = s.student_id
      AND e.score < avg_table.avg_score
);

--------------------------------------------------------
-- SECTION 5: Complex Subqueries & Advanced (Q27–Q30)
--------------------------------------------------------

-- Q27. Second highest score per course
SELECT e1.course_id, e1.student_id, e1.score
FROM enrollments e1
WHERE 1 = (
    SELECT COUNT(DISTINCT e2.score)
    FROM enrollments e2
    WHERE e2.course_id = e1.course_id AND e2.score > e1.score
);

-- Q28. Students who took courses from all instructors
SELECT s.name
FROM students s
WHERE NOT EXISTS (
    SELECT 1
    FROM instructors i
    WHERE NOT EXISTS (
        SELECT 1
        FROM enrollments e
        JOIN courses c ON e.course_id = c.course_id
        WHERE e.student_id = s.student_id
          AND c.instructor_id = i.instructor_id
    )
);

-- Q29. Courses with more than one student scoring the same
SELECT e.course_id, c.course_name, e.score, COUNT(*) AS student_count
FROM enrollments e
JOIN courses c ON e.course_id = c.course_id
GROUP BY e.course_id, e.score
HAVING student_count > 1;

-- Q30. Students who never scored below 70
SELECT s.name
FROM students s
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments e
    WHERE e.student_id = s.student_id AND e.score < 70
);
