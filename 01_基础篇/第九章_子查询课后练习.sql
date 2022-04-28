## 第九章_子查询课后练习题目：

#1.查询和Zlotkey相同部门的员工姓名和工资
SELECT last_name, salary
FROM employees
WHERE department_id = (
		SELECT department_id
		FROM employees
		WHERE last_name = 'Zlotkey'
) AND last_name <> 'Zlotkey';

SELECT * FROM employees WHERE department_id = 80; # 共有34条记录

#2.查询工资比公司平均工资高的员工的员工号，姓名和工资。
SELECT employee_id, last_name, salary
FROM employees
WHERE salary > (
		SELECT AVG(salary)
		FROM employees
);

#3.选择工资大于所有JOB_ID = 'SA_MAN'的员工的工资的员工的last_name, job_id, salary
# 方法1：使用多行查询
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE salary > ALL(
		SELECT salary
		FROM employees
		WHERE job_id = 'SA_MAN'
);

# 方法2：使用单行查询
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE salary > (
		SELECT MAX(salary)
		FROM employees
		WHERE job_id = 'SA_MAN'
);


#4.查询和姓名中包含字母u的员工在相同部门的员工的员工号和姓名
SELECT employee_id, last_name, department_id
FROM employees
WHERE department_id IN (
		SELECT DISTINCT department_id
		FROM employees
		WHERE last_name REGEXP 'u'
);

#5.查询在部门的location_id为1700的部门工作的员工的员工号
SELECT employee_id, last_name, department_id
FROM employees
WHERE department_id IN (
		SELECT department_id
		FROM departments
		WHERE location_id = 1700
);

#6.查询管理者是King的员工姓名和工资
SELECT last_name, salary, manager_id
FROM employees
WHERE manager_id IN (
		SELECT employee_id
		FROM employees
		WHERE last_name = 'King'
);

SELECT *
FROM employees
WHERE last_name = 'King'; # 此时有两个姓名为King的数据，因此上面的查询中需要使用 IN 来判断

#7.查询工资最低的员工信息: last_name, salary
SELECT last_name, salary
FROM employees
WHERE salary = (
		SELECT MIN(salary)
		FROM employees
);

#8.查询平均工资最低的部门信息
# 方法1：三重子查询
SELECT * 
FROM departments
WHERE department_id = (
			SELECT department_id 
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary) = (
					SELECT MIN(avg_sal)
					FROM (
									SELECT department_id, AVG(salary) avg_sal
									FROM employees
									WHERE department_id IS NOT NULL
									GROUP BY department_id
							 ) sal_avg_tmp 
			)
);

# 方法2：
SELECT * 
FROM departments
WHERE department_id = (
			SELECT department_id 
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary) <= ALL (
					SELECT MIN(avg_sal)
					FROM (
									SELECT department_id, AVG(salary) avg_sal
									FROM employees
									WHERE department_id IS NOT NULL
									GROUP BY department_id
							 ) sal_avg_tmp 
			)
);

# 方法3：使用LIMIT
SELECT * 
FROM departments
WHERE department_id = (
			SELECT department_id 
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary) = (
						SELECT AVG(salary) avg_sal
						FROM employees
						WHERE department_id IS NOT NULL
						GROUP BY department_id
						ORDER BY avg_sal ASC
						LIMIT 0, 1
			)
);

# 方法4：在from语句中进行子查询
SELECT d.*
FROM departments d, (
			SELECT department_id, AVG(salary) avg_sal
			FROM employees
			GROUP BY department_id 
			ORDER BY avg_sal
			LIMIT 0, 1 
		) dept_avg_sal
WHERE d.department_id = dept_avg_sal.department_id


#9.查询平均工资最低的部门信息和该部门的平均工资（相关子查询）
# 方法1：
SELECT d.*, dept_avg_sal.avg_sal
FROM departments d, (
			SELECT department_id, AVG(salary) avg_sal
			FROM employees
			GROUP BY department_id 
			ORDER BY avg_sal
			LIMIT 0, 1 
		) dept_avg_sal
WHERE d.department_id = dept_avg_sal.department_id

# 方法2：
SELECT d.*, (SELECT AVG(salary) FROM employees WHERE department_id = d.department_id)
FROM departments d
WHERE d.department_id = (
			SELECT department_id 
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary) = (
						SELECT AVG(salary) avg_sal
						FROM employees
						WHERE department_id IS NOT NULL
						GROUP BY department_id
						ORDER BY avg_sal ASC
						LIMIT 0, 1
			)
);

# 方法3：三重子查询
SELECT d.*, (SELECT AVG(salary) FROM employees WHERE department_id = d.department_id)
FROM departments d
WHERE d.department_id = (
			SELECT department_id 
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary) = (
					SELECT MIN(avg_sal)
					FROM (
									SELECT department_id, AVG(salary) avg_sal
									FROM employees
									WHERE department_id IS NOT NULL
									GROUP BY department_id
							 ) sal_avg_tmp 
			)
);

# 方法4：
SELECT d.*, (SELECT AVG(salary) FROM employees WHERE department_id = d.department_id) 
FROM departments d
WHERE d.department_id = (
			SELECT department_id 
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary) <= ALL (
					SELECT MIN(avg_sal)
					FROM (
									SELECT department_id, AVG(salary) avg_sal
									FROM employees
									WHERE department_id IS NOT NULL
									GROUP BY department_id
							 ) sal_avg_tmp 
			)
);


#10.查询平均工资最高的 job 信息
# 方法1
SELECT j.*, (SELECT AVG(salary) FROM employees WHERE j.job_id = job_id)
FROM jobs j
WHERE job_id = (
		SELECT job_id
		FROM employees
		GROUP BY job_id
		ORDER BY AVG(salary) DESC
		LIMIT 0, 1
);

# 方法2
SELECT j.*, (SELECT AVG(salary) FROM employees WHERE j.job_id = job_id)
FROM jobs j
WHERE job_id = (
		SELECT job_id
		FROM employees
		GROUP BY job_id
		HAVING AVG(salary) = (
				SELECT AVG(salary)
				FROM employees
				GROUP BY job_id
				ORDER BY AVG(salary) DESC
				LIMIT 0, 1
		)
);

# 方法3
SELECT j.*, (SELECT AVG(salary) FROM employees WHERE j.job_id = job_id)
FROM jobs j
WHERE job_id = (
		SELECT job_id
		FROM employees
		GROUP BY job_id
		HAVING AVG(salary) >= ALL (
				SELECT AVG(salary)
				FROM employees
				GROUP BY job_id
		)
);

# 方法4: 四重子查询
SELECT j.*, (SELECT AVG(salary) FROM employees WHERE j.job_id = job_id)
FROM jobs j
WHERE job_id = (
		SELECT job_id
		FROM employees
		GROUP BY job_id
		HAVING AVG(salary) = (
				SELECT MAX(avg_sal)
				FROM (
						SELECT AVG(salary) avg_sal
						FROM employees
						GROUP BY job_id
				) dept_avg
		)
);

#11.查询平均工资高于公司平均工资的部门有哪些?
SELECT e.department_id, d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id
GROUP BY department_id
HAVING AVG(salary) > (
		SELECT AVG(salary)
		FROM employees
);


#12.查询出公司中所有 manager 的详细信息
# 方法1：使用自连接
SELECT DISTINCT mgr.*
FROM employees emp, employees mgr
WHERE emp.manager_id = mgr.employee_id;

# 方法2：使用子查询
SELECT *
FROM employees 
WHERE employee_id IN (
		SELECT DISTINCT manager_id
		FROM employees
		WHERE manager_id IS NOT NULL
);

# 方法3：使用相关子查询
SELECT *
FROM employees e1
WHERE EXISTS (
		SELECT DISTINCT manager_id
		FROM employees
		WHERE manager_id = e1.employee_id
);


#13.各个部门中 最高工资中最低的那个部门的 最低工资是多少?
# 方法1：
SELECT e.*, (SELECT MIN(salary) FROM employees WHERE e.department_id = department_id)
FROM employees e
WHERE department_id = (
		SELECT department_id
		FROM employees
		WHERE department_id IS NOT NULL
		GROUP BY department_id
		ORDER BY MAX(salary)
		LIMIT 0, 1
);

# 方法2：
SELECT e.*, (SELECT MIN(salary) FROM employees WHERE e.department_id = department_id)
FROM employees e, 
								(
									SELECT department_id
									FROM employees
									WHERE department_id IS NOT NULL
									GROUP BY department_id
									ORDER BY MAX(salary)
									LIMIT 0, 1
								) dept_max_sal
WHERE e.department_id = dept_max_sal.department_id;

# 方法3：
SELECT e.*, (SELECT MIN(salary) FROM employees WHERE e.department_id = department_id)
FROM employees e
WHERE department_id = (
		SELECT department_id
		FROM employees
		WHERE department_id IS NOT NULL
		GROUP BY department_id
		HAVING MAX(salary) = (
					SELECT MAX(salary)
					FROM employees
					WHERE department_id IS NOT NULL
					GROUP BY department_id
					ORDER BY MAX(salary)
					LIMIT 0, 1
		)
);

# 方法4：
SELECT e.*, (SELECT MIN(salary) FROM employees WHERE e.department_id = department_id)
FROM employees e
WHERE department_id = (
		SELECT department_id
		FROM employees
		WHERE department_id IS NOT NULL
		GROUP BY department_id
		HAVING MAX(salary) = (
					SELECT MIN(max_sal)
					FROM (
							SELECT MAX(salary) max_sal
							FROM employees
							GROUP BY department_id
					) dept_max_sal 
		)
);


#14.查询平均工资最高的部门的 manager 的详细信息: last_name, department_id, email, salary
# 方法1：
SELECT e.last_name, e.department_id, e.email, e.salary
FROM employees e
WHERE e.employee_id IN (
		SELECT DISTINCT manager_id
		FROM employees e
		WHERE department_id = (
				SELECT department_id
				FROM employees
				WHERE department_id IS NOT NULL
				GROUP BY department_id
				ORDER BY MAX(salary) DESC
				LIMIT 0, 1
		) AND e.manager_id IS NOT NULL
);

# 方法2：
SELECT DISTINCT e.last_name, e.department_id, e.email, e.salary
FROM employees e, (
											SELECT e.*
											FROM employees e
											WHERE department_id = (
													SELECT department_id
													FROM employees
													WHERE department_id IS NOT NULL
													GROUP BY department_id
													ORDER BY MAX(salary) DESC
													LIMIT 0, 1
											) AND e.manager_id IS NOT NULL
									) dept_tmp
WHERE e.employee_id = dept_tmp.manager_id;



#15. 查询部门的部门号，其中不包括job_id是"ST_CLERK"的部门号
# 方法1：
SELECT department_id
FROM departments
WHERE department_id NOT IN (
		SELECT DISTINCT department_id
		FROM employees
		WHERE job_id = 'ST_CLERK'
);

# 方法2：
SELECT department_id
FROM departments d
WHERE NOT EXISTS (
		SELECT DISTINCT department_id
		FROM employees
		WHERE job_id = 'ST_CLERK'
		AND d.department_id = department_id
);

#16. 选择所有没有管理者的员工的last_name
# 方法1：使用相关子查询
SELECT last_name
FROM employees e1
WHERE NOT EXISTS (
	SELECT *
	FROM employees e2
	WHERE e1.manager_id = e2.employee_id
);

# 方法2：
SELECT last_name
FROM employees
WHERE manager_id IS NULL;

#17．查询员工号、姓名、雇用时间、工资，其中员工的管理者为 'De Haan'
# 方法1：
SELECT employee_id, last_name, hire_date, salary
FROM employees
WHERE manager_id = (
		SELECT employee_id
		FROM employees
		WHERE last_name = 'De Haan'
);

# 方法2：
SELECT e.employee_id, e.last_name, e.hire_date, e.salary
FROM employees e
WHERE EXISTS (
		SELECT employee_id
		FROM employees
		WHERE last_name = 'De Haan'
		AND e.manager_id = employee_id
);

#18.查询各部门中工资比本部门平均工资高的员工的员工号, 姓名和工资（相关子查询）
# 方法1：相关子查询
SELECT e1.employee_id, e1.last_name, e1.salary
FROM employees e1
WHERE salary > (
		SELECT AVG(salary)
		FROM employees
		WHERE e1.department_id = department_id
);

# 方法2：
SELECT e1.employee_id, e1.last_name, e1.salary
FROM employees e1, (
											SELECT department_id, AVG(salary) avg_sal
											FROM employees
											GROUP BY department_id
										) dept_avg_sal
WHERE e1.department_id = dept_avg_sal.department_id
AND e1.salary > dept_avg_sal.avg_sal;

#19.查询每个部门下的部门人数大于 5 的部门名称（相关子查询）
SELECT department_id, department_name
FROM departments d
WHERE 5 < (
	SELECT COUNT(*)
	FROM employees
	WHERE d.department_id = department_id
);

#20.查询每个国家下的部门个数大于 2 的国家编号（相关子查询）
SELECT l.country_id
FROM locations l
WHERE 2 < (
	SELECT COUNT(*)
	FROM departments
	WHERE l.location_id = location_id
);


