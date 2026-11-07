USE employees;

-- ---------------------------------------------------------------------
-- Part 1 - SQL versions of the Labwork 2 relational algebra expressions
-- ---------------------------------------------------------------------

-- Q1. All info of all employees                      ( employees )
SELECT * FROM employees;

-- Q2. All info of all departments                    ( departments )
SELECT * FROM departments;

-- Q3. Full names of all employees                    ( pi first_name,last_name (employees) )
SELECT first_name, last_name FROM employees;

-- Q4. Names of all departments                       ( pi dept_name (departments) )
SELECT dept_name FROM departments;

-- Q5. Full names of employees working in the "Sales" department
SELECT DISTINCT e.first_name, e.last_name
FROM employees e
JOIN dept_emp de    ON de.emp_no  = e.emp_no
JOIN departments d  ON d.dept_no  = de.dept_no
WHERE d.dept_name = 'Sales';

-- Q6. Full names of male employees working in the "Finance" department
SELECT DISTINCT e.first_name, e.last_name
FROM employees e
JOIN dept_emp de    ON de.emp_no  = e.emp_no
JOIN departments d  ON d.dept_no  = de.dept_no
WHERE d.dept_name = 'Finance'
  AND e.gender = 'M';

-- Q7. Salaries of female employees working in the "Marketing" department
SELECT e.emp_no, e.first_name, e.last_name, s.salary, s.from_date, s.to_date
FROM employees e
JOIN dept_emp de    ON de.emp_no  = e.emp_no
JOIN departments d  ON d.dept_no  = de.dept_no
JOIN salaries s     ON s.emp_no   = e.emp_no
WHERE d.dept_name = 'Marketing'
  AND e.gender = 'F';

-- Q8. Full names of employees who have the same last name as their manager
--     (the manager of a department the employee belongs to; the manager
--      himself/herself is excluded)
SELECT DISTINCT e.first_name, e.last_name
FROM employees e
JOIN dept_emp de      ON de.emp_no  = e.emp_no
JOIN dept_manager dm  ON dm.dept_no = de.dept_no
JOIN employees m      ON m.emp_no   = dm.emp_no
WHERE e.last_name = m.last_name
  AND e.emp_no <> m.emp_no;

-- Q9. Full names of managers who have been doing the job at least twice
SELECT e.first_name, e.last_name, COUNT(*) AS times_manager
FROM dept_manager dm
JOIN employees e ON e.emp_no = dm.emp_no
GROUP BY e.emp_no, e.first_name, e.last_name
HAVING COUNT(*) >= 2;
-- On the real data this returns an EMPTY SET: the 24 rows of dept_manager
-- belong to 24 different employees, so nobody has been a manager twice.

-- Q10. Full names of employees who were paid more than $100000
SELECT DISTINCT e.first_name, e.last_name
FROM employees e
JOIN salaries s ON s.emp_no = e.emp_no
WHERE s.salary > 100000;

-- Q11. Names of all departments that have employees paid more than $100000
SELECT DISTINCT d.dept_name
FROM departments d
JOIN dept_emp de ON de.dept_no = d.dept_no
JOIN salaries s  ON s.emp_no   = de.emp_no
WHERE s.salary > 100000
ORDER BY d.dept_name;

-- ---------------------------------------------------------------------
-- Part 3 - merging departments
--   Development (d005) + Research (d008) -> Research and Development (d010)
--   Marketing   (d001) + Sales    (d007) -> Marketing and Sales      (d011)
--
-- A plain  UPDATE dept_emp SET dept_no='d010' WHERE dept_no IN ('d005','d008')
-- FAILS with "Duplicate entry" because the primary key of dept_emp is
-- (emp_no, dept_no) and many people worked in both old departments
-- (5234 for d005+d008, 3652 for d001+d007). So for every employee we
-- insert ONE row in the new department covering the whole period, then
-- delete the old rows.
-- ---------------------------------------------------------------------
START TRANSACTION;

-- 1. create the new departments
INSERT INTO departments (dept_no, dept_name) VALUES
    ('d010', 'Research and Development'),
    ('d011', 'Marketing and Sales');

-- 2. move employees (one row per employee, earliest start / latest end)
INSERT INTO dept_emp (emp_no, dept_no, from_date, to_date)
SELECT emp_no, 'd010', MIN(from_date), MAX(to_date)
FROM dept_emp
WHERE dept_no IN ('d005', 'd008')
GROUP BY emp_no;

INSERT INTO dept_emp (emp_no, dept_no, from_date, to_date)
SELECT emp_no, 'd011', MIN(from_date), MAX(to_date)
FROM dept_emp
WHERE dept_no IN ('d001', 'd007')
GROUP BY emp_no;

-- 3. move managers (no collisions here: each manager ran only one department).
--    Note: afterwards each merged department has TWO current managers
--    (to_date = 9999-01-01), one from each old department; the company has
--    to decide who stays and close the other one with an UPDATE of to_date.
INSERT INTO dept_manager (emp_no, dept_no, from_date, to_date)
SELECT emp_no, 'd010', MIN(from_date), MAX(to_date)
FROM dept_manager
WHERE dept_no IN ('d005', 'd008')
GROUP BY emp_no;

INSERT INTO dept_manager (emp_no, dept_no, from_date, to_date)
SELECT emp_no, 'd011', MIN(from_date), MAX(to_date)
FROM dept_manager
WHERE dept_no IN ('d001', 'd007')
GROUP BY emp_no;

-- 4. remove the old departments' rows, then the departments themselves
--    (the foreign keys are ON DELETE CASCADE, so step 4c alone would also
--     clean dept_emp / dept_manager, but doing it explicitly is clearer)
DELETE FROM dept_emp     WHERE dept_no IN ('d001', 'd005', 'd007', 'd008');
DELETE FROM dept_manager WHERE dept_no IN ('d001', 'd005', 'd007', 'd008');
DELETE FROM departments  WHERE dept_no IN ('d001', 'd005', 'd007', 'd008');

COMMIT;

-- 5. check the result
SELECT * FROM departments ORDER BY dept_no;

SELECT dept_no, COUNT(*) AS employees
FROM dept_emp
GROUP BY dept_no
ORDER BY dept_no;

SELECT dm.dept_no, e.first_name, e.last_name, dm.from_date, dm.to_date
FROM dept_manager dm
JOIN employees e ON e.emp_no = dm.emp_no
WHERE dm.dept_no IN ('d010', 'd011')
ORDER BY dm.dept_no, dm.from_date, dm.emp_no;
