## 第九章 子查询
/*
 子查询指一个查询嵌套在另一个查询语句内部的查询，这个特性从MySQL 4.1开始引入。

 SQL中子查询的使用大大增强了SELECT查询的能力，因为很多时候查询需要从结果集中获取数据，
 或者需要从同一个表中先计算得出一个数据结果，然后与这个数据结果（可能是某个标量，也可能是某个集合）进行比较
 */

## 1. 由一个具体的需求引入子查询

# 需求：谁的工资比Abel的高
# 方式1: 
SELECT last_name, salary # 11000
FROM employees
WHERE last_name = 'Abel';

SELECT last_name, salary
FROM employees
WHERE salary > 11000;

# 方式2：自连接
SELECT e2.last_name, e2.salary
FROM employees e1, employees e2
WHERE e1.salary < e2.salary # 多表的连接条件
AND e1.last_name = 'Abel';


# 方式3：子查询
SELECT last_name, salary
FROM employees
WHERE salary > (
		SELECT salary
		FROM employees
		WHERE last_name = 'Abel'
);



## 2. 称谓的规范：外查询（或主查询）、内查询（或子查询）
/* 注意事项
	1. 子查询（内查询）在主查询之前一次执行完成
	2. 子查询的结果被主查询（外查询）使用。
	3. 注意事项：
		3.1 子查询要包含在括号内
		3.2 将子查询放在比较条件的右侧
		3.3 单行操作符对应单行子查询，多行操作符对应多行子查询
 */

## 3. 子查询的分类
/*
	角度1：从内查询返回的结果的条目数
				 单行子查询 vs 多行子查询

	角度2：内查询是否被执行多次
				 相关子查询 vs 不相关子查询
					
				我们按内查询是否被执行多次，将子查询划分为相关(或关联)子查询和不相关(或非关联)子查询。
				子查询从数据表中查询了数据结果，如果这个数据结果只执行一次，然后这个数据结果作为主查询的条
				件进行执行，那么这样的子查询叫做不相关子查询。

				同样，如果子查询需要执行多次，即采用循环的方式，先从外部查询开始，每次都传入子查询进行查
				询，然后再将结果反馈给外部，这种嵌套的执行方式就称为相关子查询。

		比如：相关子查询的需求：查询工资大于 本部门 平均工资的员工信息
		比如：不相关子查询的需求：查询工资大于 本公司 平均工资的员工信息
 */

# 相关子查询的需求：查询工资大于本部门平均工资的员工信息
SELECT last_name, salary
FROM employees
WHERE salary > (
		SELECT AVG(salary)
		FROM employees
		GROUP BY department_id
);

## 4. 单行子查询
# 4.1 单行比较运算符： =  != > < >= <=

/* 子查询的编写技巧（或步骤）：从里往外写， 从外往里写 */

# 题目1：查询工资冬雨149号员工工资的员工的信息
SELECT employee_id, last_name, salary
FROM employees
WHERE salary > (
			SELECT salary
			FROM employees
			WHERE employee_id = 149
);

# 题目2：返回job_id与141号员工相同，salary比143号员工多的员工姓名，job_id和工资
SELECT employee_id, job_id, salary
FROM employees
WHERE job_id = (
			SELECT job_id
			FROM employees
			WHERE employee_id = 141
) AND salary > (
			SELECT salary
			FROM employees
			WHERE employee_id = 143
);

# 查询job_id与141号员工相同的员工
SELECT employee_id, job_id, salary
FROM employees
WHERE job_id = (
			SELECT job_id
			FROM employees
			WHERE employee_id = 141
);

# 查询salary比143号员工多的员工姓名，job_id和工资
SELECT employee_id, job_id, salary
FROM employees
WHERE salary > (
			SELECT salary
			FROM employees
			WHERE employee_id = 143
);

# 题目3：返回公司工资最少的员工的last_name, job_id 和 salary
SELECT last_name, job_id, salary
FROM employees
WHERE salary = (
		SELECT MIN(salary)
		FROM employees
);

# 题目4-1：查询与141号员工的manager_id和department_id相同的
#				 其他员工的employee_id, manager_id, department_id
# 方式一： 使用多次查询并连接
SELECT employee_id, manager_id, department_id
FROM employees
WHERE manager_id IN (
			SELECT manager_id
			FROM employees
			WHERE employee_id = 141
) AND department_id IN (
			SELECT department_id
			FROM employees
			WHERE employee_id = 142
)
AND employee_id <> 141;

# 方式二：(了解)
SELECT employee_id, manager_id, department_id
FROM employees
WHERE (manager_id, department_id) IN (
			SELECT manager_id, department_id
			FROM employees
			WHERE employee_id = 141
) AND employee_id <> 141;


# 题目4：查询与141号或147号员工的manager_id和department_id相同的
#				 其他员工的employee_id, manager_id, department_id
# 方式1：
SELECT employee_id, manager_id, department_id
FROM employees
WHERE manager_id IN (
			SELECT manager_id
			FROM employees
			WHERE employee_id = 141 OR employee_id = 147
) AND department_id IN (
			SELECT department_id
			FROM employees
			WHERE employee_id = 141 OR employee_id = 147
)
AND employee_id <> 141 AND employee_id <> 147;

# 方式2：
SELECT employee_id, manager_id, department_id
FROM employees
WHERE (manager_id, department_id) IN (
			SELECT manager_id, department_id
			FROM employees
			WHERE employee_id = 141
) AND employee_id <> 141
OR (manager_id, department_id) IN (
			SELECT manager_id, department_id
			FROM employees
			WHERE employee_id = 147
) AND employee_id <> 147;

## 4.2 HAVING 中的子查询，首先执行子查询。向主查询中的HAVING 子句返回结果。
# 题目5：查询最低工资大于110号部门最低工资的部门id和其最低工资
SELECT department_id, MIN(salary)
FROM employees 
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING MIN(salary) > (
			SELECT MIN(salary)
			FROM employees
			WHERE department_id = 110
);

## 4.3 CASE中的子查询：在CASE表达式中使用单列子查询
# 题目6-1：显式员工的employee_id,last_name和location。其中，若员工department_id与location_id为1800
#				 的department_id相同，则location为’Canada’，其余则为’USA’。
SELECT employee_id, last_name, department_id, 
CASE department_id WHEN (
														SELECT department_id
														FROM departments 
														WHERE location_id = 1800
													) THEN 'Canada'
													ELSE 'USA' END "location"
FROM employees;


SELECT employee_id, last_name, department_id
FROM employees
WHERE department_id = 20;

SELECT department_id
FROM departments 
WHERE location_id = 1800;


# 4.3.2 子查询中的空值问题
SELECT last_name, job_id
FROM employees
WHERE job_id = (
			SELECT job_id FROM employees  WHERE last_name = 'Haas' # 该子查询为null
);

## 4.3.3 非法使用子查询
SELECT employee_id, last_name
FROM employees
WHERE salary = (
			SELECT MIN(salary)
			FROM employees
			GROUP BY department_id
);


## 5. 多行子查询










