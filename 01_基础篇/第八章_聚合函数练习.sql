## 第八章 聚合函数课后练习【题目】

#1.where子句可否使用组函数进行过滤?
不可以！

#2.查询公司员工工资的最大值，最小值，平均值，总和
SELECT MAX(salary), MIN(salary), AVG(salary), SUM(salary)
FROM employees;

#3.查询各job_id的员工工资的最大值，最小值，平均值，总和
SELECT job_id, MAX(salary), MIN(salary), AVG(salary), SUM(salary)
FROM employees
GROUP BY job_id;

#4.选择具有各个job_id的员工人数
SELECT job_id, COUNT(IFNULL(job_id, 0)), COUNT(*)
FROM employees
GROUP BY job_id;

# 5.查询员工最高工资和最低工资的差距（DIFFERENCE）
SELECT MAX(salary) - MIN(salary) DIFFERENCE
FROM employees;

# 6.查询各个管理者手下员工的最低工资，其中最低工资不能低于6000，没有管理者的员工不计算在内
# 方法一：(不准确)
SELECT manager_id, MIN(salary)
FROM employees
WHERE manager_id IS NOT NULL AND salary >= 6000 # 这时候会将salary<6000的过滤掉，因此后续操作已经错误了
GROUP BY manager_id;

# 方法二：正确的操作：使用HAVING进行过滤！！！
SELECT manager_id, MIN(salary)
FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id
HAVING MIN(salary) >= 6000;

# 7.查询所有部门的名字，location_id，员工数量和平均工资，并按平均工资降序
SELECT d.department_name, d.location_id, COUNT(employee_id), AVG(salary) avg_sal
FROM employees e RIGHT JOIN departments d
ON e.department_id = d.department_id
GROUP BY department_name, location_id
ORDER BY avg_sal DESC;

# 8.查询每个工种、每个部门的部门名、工种名和最低工资
SELECT e.job_id, e.department_id, d.department_name, COUNT(employee_id), MIN(salary) min_sal
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id
GROUP BY e.job_id, e.department_id, d.department_name;

