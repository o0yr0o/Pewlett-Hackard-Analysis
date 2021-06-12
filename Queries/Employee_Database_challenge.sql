-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
	dept_no VARCHAR(4) NOT NULL,
	dept_name VARCHAR(40) NOT NULL,
	PRIMARY KEY (dept_no),
	UNIQUE (dept_name)
);
SELECT * FROM departments;

CREATE TABLE employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	gender VARCHAR NOT NULL,
	hire_date DATE NOT NULL,
	PRIMARY KEY (emp_no)
);
SELECT * FROM employees;

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);
SELECT * FROM dept_manager;

DROP TABLE IF EXISTS dept_emp;
CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);
SELECT * FROM dept_emp;

CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no)
);
SELECT * FROM salaries;

DROP TABLE IF EXISTS titles;
CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES salaries (emp_no),
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);
SELECT * FROM titles;

-- Deliverable 1 
-- Create retirement_titles table
SELECT e.emp_no, e.first_name, e.last_name, t.title, t.from_date, t.to_date
INTO retirement_titles
FROM employees AS e
LEFT JOIN titles AS t
ON e.emp_no = t.emp_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY emp_no;
SELECT * FROM retirement_titles;

-- Use Dictinct with Orderby to remove duplicate rows
SELECT DISTINCT ON (r.emp_no) r.emp_no, r.first_name, r.last_name, r.title
INTO unique_titles
FROM retirement_titles AS r
ORDER BY r.emp_no, r.to_date DESC;
SELECT * FROM unique_titles;

-- Retrieve number of employees by titles
SELECT COUNT(u.emp_no) AS count, u.title
INTO retiring_titles
FROM unique_titles AS u
GROUP BY u.title
ORDER BY count DESC;


-- Deliverable 2
SELECT DISTINCT ON (e.emp_no) e.emp_no, e.first_name, e.last_name, e.birth_date, d.from_date, d.to_date, t.title
INTO mentorship_eligibility
FROM employees AS e
LEFT JOIN dept_emp AS d
ON e.emp_no = d.emp_no
LEFT JOIN titles AS t
ON e.emp_no = t.emp_no
WHERE (d.to_date = '9999-01-01')
AND (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
ORDER BY e.emp_no;


-- Addtional Queries
-- Total retiring employees
SELECT SUM(r.count) AS total_retiring_employees
FROM retiring_titles AS r;

-- Comparing retiring employees and eligible mentors
CREATE VIEW mentor_count AS
SELECT m.title, COUNT(m.emp_no) AS count
FROM mentorship_eligibility as m
GROUP BY m.title
ORDER BY count DESC;

SELECT r.title, r.count AS retiring_count, m.title, m.count AS mentor_count
FROM retiring_titles AS r
FULL JOIN mentor_count AS m
ON r.title = m.title
ORDER BY retiring_count DESC;
