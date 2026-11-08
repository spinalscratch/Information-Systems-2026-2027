USE employees;

-- Q1. Who have the same name as the managers of the "Finance" department?
CREATE OR REPLACE VIEW finance_managers AS
    SELECT e.emp_no, e.first_name, e.last_name
    FROM employees e
    JOIN dept_manager dm ON dm.emp_no = e.emp_no
    JOIN departments d   ON d.dept_no = dm.dept_no
    WHERE d.dept_name = 'Finance';

SELECT emp_no, first_name, last_name
FROM employees
WHERE first_name IN (SELECT first_name FROM finance_managers)
  AND emp_no NOT IN (SELECT emp_no FROM finance_managers);

-- Q2. Who in the "Production" department were hired after the promotion
--     of the last manager in that department?
CREATE OR REPLACE VIEW production_employees AS
    SELECT e.emp_no, e.first_name, e.last_name, e.hire_date
    FROM employees e
    JOIN dept_emp de   ON de.emp_no = e.emp_no
    JOIN departments d ON d.dept_no = de.dept_no
    WHERE d.dept_name = 'Production';

CREATE OR REPLACE VIEW production_last_manager AS
    SELECT MAX(dm.from_date) AS last_promotion
    FROM dept_manager dm
    JOIN departments d ON d.dept_no = dm.dept_no
    WHERE d.dept_name = 'Production';

SELECT emp_no, first_name, last_name, hire_date
FROM production_employees
WHERE hire_date > (SELECT last_promotion FROM production_last_manager);

-- Q3. Find the average salary of each department, from highest to lowest.
CREATE OR REPLACE VIEW dept_avg_salary AS
    SELECT d.dept_name, AVG(s.salary) AS avg_salary
    FROM salaries s
    JOIN dept_emp de   ON de.emp_no = s.emp_no
    JOIN departments d ON d.dept_no = de.dept_no
    GROUP BY d.dept_name;

SELECT dept_name, avg_salary
FROM dept_avg_salary
ORDER BY avg_salary DESC;

-- Q4. Find the average salary for each type of Engineer, from highest to lowest.
CREATE OR REPLACE VIEW engineer_avg_salary AS
    SELECT t.title, AVG(s.salary) AS avg_salary
    FROM titles t
    JOIN salaries s ON s.emp_no = t.emp_no
    WHERE t.title LIKE '%Engineer%'
    GROUP BY t.title;

SELECT title, avg_salary
FROM engineer_avg_salary
ORDER BY avg_salary DESC;
