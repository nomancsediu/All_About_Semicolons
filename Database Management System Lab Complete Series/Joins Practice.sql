create database jp;
use jp;
drop database jp;
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    department VARCHAR(20)
);
drop table students;
INSERT INTO students (name, department) VALUES
('Alice', 'CSE'),
('Bob', 'EEE'),
('Charlie', 'CSE'),
('David', 'BBA'),
('Eva', 'CSE'),
('Frank', 'EEE'),
('Grace', 'CSE');


CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY AUTO_INCREMENT,
    instructor_name VARCHAR(50)
);

INSERT INTO instructors (instructor_name) VALUES
('Prof. Smith'),
('Dr. Johnson'),
('Dr. Lee'),
('Dr. Brown');

select * from enrollments;
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(50),
    instructor_id INT,
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

INSERT INTO courses (course_name, instructor_id) VALUES
('Database', 1),
('Networking', 2),
('Algorithms', 1),
('Math', 3),
('Physics', 2);


CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    score INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

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

show tables;

#Section 1 – Basic INNER JOIN + GROUP BY + HAVING (Q1–Q10)
#-------------------------------------------------------
-- Q1. List all students with their enrolled courses
select s.name,c.course_name from students s
inner join enrollments e on s.student_id=e.student_id
inner join courses c on c.course_id=e.course_id;

-- Q2. Show each student’s total score
select s.name,sum(e.score) from students s
inner join enrollments e on s.student_id= e.student_id
group by e.student_id;

-- Q3. Students with total score > 200
select s.name,sum(e.score) as total_score from students s
inner join enrollments e on s.student_id= e.student_id
group by e.student_id
having sum(e.score) >200 ;

-- Q4. Average score per course
select c.course_name, avg(e.score) as avg_score
from courses c inner join enrollments e on c.course_id = e.course_id
group by e.course_id;

-- Q5. Average score per course (only if >2 students)
select c.course_name, avg(e.score) as avg_score, count(e.student_id) as student_count
from courses c inner join enrollments e on c.course_id=e.course_id
group by e.course_id having student_count > 2;

-- Q6. CSE students average > 85
/* cse student,,,each student avg marks*/
select s.name, avg(e.score) as avg_score
from students s inner join enrollments e on s.student_id=e.student_id
where s.department='CSE' group by e.student_id
having avg_score > 85;

-- Q7. Courses highest score <90
select c.course_name, max(e.score) as max_score
from courses c inner join enrollments e on c.course_id=e.course_id
group by e.course_id
having max_score < 90;

-- Q8. Students scored >80 per course
select c.course_name, count(e.student_id) as high_scorer
from courses c inner join enrollments e on c.course_id = e.course_id
where e.score > 80
group by e.course_id;

-- Q9. Courses where all scores > 60
select c.course_name
from courses c inner join enrollments e on c.course_id=e.course_id
group by e.course_id
having min(e.score) > 60 ;

-- Q10. Highest scorer per course
select s.name, c.course_name, e.score
from students s inner join enrollments e on s.student_id=e.student_id
inner join courses c on c.course_id=e.course_id
where e.score =
(select max(score) from enrollments where course_id=e.course_id);






#Section 2 – LEFT JOIN / RIGHT JOIN (Q11–Q17)
#-------------------------------------------
-- Q11. All students even if no enrollment
select s.name, c.course_name
from students s left join
enrollments e on s.student_id=e.student_id
left join courses c on c.course_id=e.course_id;

-- Q12. All courses even if no students
select c.course_name, s.name from courses c
left join enrollments e on e.course_id=c.course_id
left join students s on s.student_id=e.student_id;

-- Q13. Students not enrolled in any course
select s.name from students s 
left join enrollments e on s.student_id=e.student_id
where e.course_id is NULL;

-- Q15. Instructors + courses (even if none)
select i.instructor_name , c.course_name
from instructors i left join courses c on c.instructor_id = i.instructor_id;
-- Q16. Course + student count (0 if none)
select c.course_name , count(e.student_id) 
from courses c left join  enrollments e on c.course_id=e.course_id
group by c.course_name;

-- Q17. Students + number of courses (0 if none)
select s.name, count(e.course_id) from students s 
left join enrollments e on s.student_id=e.student_id
group by s.name;

#Section 3 – Multiple Join & CROSS JOIN (Q18–Q21)
#------------------------------------------------

-- Q18. Students with instructors
select s.name, i.instructor_name
from students s inner join enrollments e 
on s.student_id=e.student_id
inner join courses c on c.course_id=e.course_id
inner join instructors i on i.instructor_id=c.instructor_id;

-- Q19. All possible student-course combinations
select s.name , c.course_name from students s
cross join courses c;

-- Q20. Students + distinct instructors
select distinct s.name, i.instructor_name
from students s inner join enrollments e 
on s.student_id=e.student_id
inner join courses c on c.course_id=e.course_id
inner join instructors i on i.instructor_id=c.instructor_id;

-- Q21. Number of students per instructor
select i.instructor_name , count(e.student_id) from
instructors i inner join courses c on i.instructor_id=c.instructor_id
inner join enrollments e on c.course_id=e.course_id
group by i.instructor_name;

#Section 4 – Advanced Aggregates & HAVING (Q22–Q26)
#--------------------------------------------------

-- Q22. Student who took most courses
/*name select...course count...student & enroll...group by...order desc...limit 1...*/
select s.name,count(e.course_id) as course_count
from students s inner join enrollments e on s.student_id=e.student_id
group by e.student_id
order by course_count desc
limit 1;
-- Q23. Instructor with most courses
select i.instructor_name, count(e.course_id) as course_count
from instructors i inner join courses c on i.instructor_id=c.instructor_id
inner join enrollments e on e.course_id=c.course_id
group by i.instructor_name
order by course_count desc
limit 1;

-- Q24. Course with biggest score gap
SELECT c.course_name,
       MAX(e.score) - MIN(e.score) AS score_gap
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
#Section 5 – Complex Subqueries & Advanced (Q27–Q30)
#---------------------------------------------------

-- Q27. Second highest score per course

-- Q28. Students who took courses from all instructors

-- Q29. Courses with more than one student scoring same

-- Q30. Students who never scored below 70












