USE employees;

-- Q1. What is the average salary of each employee?
SELECT emp_no, AVG(salary) AS avg_salary
FROM salaries
GROUP BY emp_no;

-- Q2. How much was each employee paid in total?
SELECT emp_no, SUM(salary) AS total_paid
FROM salaries
GROUP BY emp_no;

-- Q3. Minimum, maximum and total salaries of each department?
SELECT d.dept_no, d.dept_name,
       MIN(s.salary) AS min_salary,
       MAX(s.salary) AS max_salary,
       SUM(s.salary) AS dept_sum
FROM salaries s
JOIN dept_emp de   ON s.emp_no  = de.emp_no
JOIN departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no, d.dept_name;

-- Q4. Which departments have paid more than 20 billion dollars for their employees?
SELECT d.dept_no, d.dept_name, SUM(s.salary) AS dept_sum
FROM salaries s
JOIN dept_emp de   ON s.emp_no  = de.emp_no
JOIN departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no, d.dept_name
HAVING dept_sum > 20000000000;

-- Q5. Total salaries of male employees in each department?
SELECT d.dept_no, d.dept_name, SUM(s.salary) AS dept_sum
FROM salaries s
JOIN employees e   ON e.emp_no  = s.emp_no
JOIN dept_emp de   ON s.emp_no  = de.emp_no
JOIN departments d ON d.dept_no = de.dept_no
WHERE e.gender = 'M'
GROUP BY d.dept_no, d.dept_name;

-- Q6. Total salaries of department managers for each department, from highest to lowest?
SELECT d.dept_name, d.dept_no, SUM(s.salary) AS mngr_dep_sum
FROM salaries s
JOIN dept_manager dm ON dm.emp_no  = s.emp_no
JOIN departments d   ON d.dept_no  = dm.dept_no
GROUP BY d.dept_no, d.dept_name
ORDER BY mngr_dep_sum DESC;
