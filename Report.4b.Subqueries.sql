-- =====================================================================
-- Labwork 4b - Subqueries on the "employees" database
-- Run with:   mysql -u root -p -t employees < Report.4b.Subqueries.sql
-- =====================================================================
USE employees;

-- Q1. Who have the same name as the managers of the "Finance" department?
SELECT emp_no, first_name, last_name
FROM employees
WHERE first_name IN (
        SELECT e.first_name
        FROM employees e
        JOIN dept_manager dm ON dm.emp_no  = e.emp_no
        JOIN departments d   ON d.dept_no  = dm.dept_no
        WHERE d.dept_name = 'Finance')
  AND emp_no NOT IN (
        SELECT dm.emp_no
        FROM dept_manager dm
        JOIN departments d ON d.dept_no = dm.dept_no
        WHERE d.dept_name = 'Finance');

-- Q2. Who in the "Production" department were hired after the promotion
--     of the last manager in that department?
SELECT e.emp_no, e.first_name, e.last_name, e.hire_date
FROM employees e
JOIN dept_emp de   ON de.emp_no  = e.emp_no
JOIN departments d ON d.dept_no  = de.dept_no
WHERE d.dept_name = 'Production'
  AND e.hire_date > (
        SELECT MAX(dm.from_date)
        FROM dept_manager dm
        JOIN departments d2 ON d2.dept_no = dm.dept_no
        WHERE d2.dept_name = 'Production');

-- Q3. Find the average salary of each department, from highest to lowest.
SELECT dept_name, avg_salary
FROM (
        SELECT d.dept_name, AVG(s.salary) AS avg_salary
        FROM salaries s
        JOIN dept_emp de   ON de.emp_no = s.emp_no
        JOIN departments d ON d.dept_no = de.dept_no
        GROUP BY d.dept_name
     ) AS dept_avg
ORDER BY avg_salary DESC;

-- Q4. Find the average salary for each type of Engineer, from highest to lowest.
SELECT title, avg_salary
FROM (
        SELECT t.title, AVG(s.salary) AS avg_salary
        FROM titles t
        JOIN salaries s ON s.emp_no = t.emp_no
        WHERE t.title LIKE '%Engineer%'
        GROUP BY t.title
     ) AS engineer_avg
ORDER BY avg_salary DESC;
