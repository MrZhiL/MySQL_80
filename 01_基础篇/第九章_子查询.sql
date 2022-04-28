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

### 结论：
/* 以上的方式2和方式3两种查询方式那个更好：
	
	 答：自连接的方式更好！
			 该题目中可以使用子查询，也可以使用自连接。一般情况下建议使用自连接，
		   因为在许多DBMS的处理过程中，对于自连接的处理速度要比子查询快得多。

			 可以这样理解：子查询实际上是通过未知表进行查询后的条件判断，而自连接
		   是通过已知的自身数据表进行条件判断，因此在大部分DBMS中都对自连接处理进行了优化。
		

 */


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
/*
	多行子查询也称为比较子查询

	内查询返回多行

	使用多行比较操作符：

	多行比较操作符		含义
	IN 								等于列表中的任意一个
	ANY 							需要和单行比较操作符一起使用，和子查询返回的某一个值比较
	ALL 							需要和单行比较操作符一起使用，和子查询返回的所有值比较
	SOME 							实际上是ANY的别名，作用相同，一般常使用ANY
 */

## 代码示例：
# 题目5-1：返回其他job_id中比job_id为'IT_PROG'部门 **任一** 工资低的员工的员工号、姓名、job_id以及salary
# note: 在该题目中，只要比任何一个工资低就可以查询到（相当于小于最高工资即可）
# 方法1：
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id != 'IT_PROG' AND salary < ANY(
			SELECT salary
			FROM employees
			WHERE job_id = 'IT_PROG'
);

# 方法2：使用最高工资查询
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id != 'IT_PROG' AND salary < (
			SELECT MAX(salary)
			FROM employees
			WHERE job_id = 'IT_PROG'
);


## 代码示例：
# 题目5-2：返回其他job_id中比job_id为'IT_PROG'部门 **所有** 工资低的员工的员工号、姓名、job_id以及salary
# note: 在该题目中，只要比任何一个工资低就可以查询到（相当于小于最低工资即可）
# 方法1：
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id != 'IT_PROG' AND salary < ALL(
			SELECT salary
			FROM employees
			WHERE job_id = 'IT_PROG'
);

# 方法2：使用最低工资查询
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id != 'IT_PROG' AND salary < (
			SELECT MIN(salary)
			FROM employees
			WHERE job_id = 'IT_PROG'
);


# 题目5-3：查询平均工资最低的部门id
# 方法1：
SELECT department_id, AVG(salary)
FROM employees
WHERE department_id IS NOT NULL 
GROUP BY department_id
HAVING AVG(salary) <= ALL (
			SELECT AVG(salary)
			FROM employees
			GROUP BY department_id
);

# 方法2：将查询到的每个部门的平均工资当成一个新表
SELECT department_id, AVG(salary)
FROM employees
GROUP BY department_id
HAVING AVG(salary) = (
			SELECT MIN(avg_sal)
			FROM (SELECT department_id dep_id, AVG(salary) avg_sal
						FROM employees
						WHERE department_id IS NOT NULL
						GROUP BY department_id
					 ) dept_avg_sal
);

# 5-6 空值问题
SELECT last_name, manager_id
FROM employees
WHERE employee_id NOT IN (
			SELECT manager_id
			FROM employees
			-- WHERE manager_id IS NOT NULL # 如果不对null值进行去除，则会导致结果中包含null，从而使得所有结果为null
);

SELECT last_name, manager_id
FROM employees
WHERE employee_id NOT IN (
			SELECT manager_id
			FROM employees
			WHERE manager_id IS NOT NULL
);


## 6. 相关子查询（子查询中使用主查询中的列）
/* 相关子查询的执行流程：
	
	 如果子查询的执行依赖于外部查询，通常情况下都是因为子查询中的表用到了外部的表，并进行了条件关联，
	 因此每执行一次外部查询，子查询都要重新计算一次，这样的子查询就称之为 `关联子查询`

	 相关子查询按照一行接一行的顺序执行，主查询的每一行都执行一次子查询。


	 结论：在SELECT中，除了GROUP BY 和 LIMIT 之外，其他位置都可以声明子查询
 */

## 6.1 代码示例：
# 题目6-1：查询员工中工资大于本部门平均工资的员工的last_name和其department_id
# 方式一：相关子查询
SELECT last_name, department_id, salary
FROM employees e1
WHERE salary > (
		SELECT AVG(salary)
		FROM employees
		WHERE department_id = e1.department_id
);

# 方式二：在FROM中声明子查询
SELECT e1.last_name, e1.department_id, e1.salary
FROM employees e1, (
										SELECT department_id, AVG(salary) avg_sal
										FROM employees
										GROUP BY department_id
									 ) tmp	
WHERE e1.department_id = tmp.department_id
AND e1.salary > tmp.avg_sal;

# 题目6-2：查询员工的id, salary, 按照department_name排序
SELECT employee_id, salary
FROM employees e
ORDER BY (
	SELECT department_name
	FROM departments d
	WHERE e.department_id = d.department_id
) ASC;


# 题目6-3：若employees表中employee_id与job_history表中employee_id相同的数目不小于2，输出这些相同
#					 id的员工的employee_id,last_name和其job_id 
# 方式1：使用相关子查询
SELECT e1.employee_id, e1.last_name, e1.job_id
FROM employees e1
WHERE 2 <= (
				SELECT count(employee_id )
				FROM job_history
				WHERE employee_id = e1.employee_id
);


## 6.2 EXISTS 与 NOT EXISTS 关键字
/* 关联子查询通常也会和EXISTS操作符一起来使用，用来检查在子查询中是否存在满足条件的行
	 
	 如果在子查询中不存在满足条件的行：条件返回FALSE；继续在子查询中查找

	 如果在子查询中存在满足条件的行：不再子查询中继续查找；条件返回TRUE

	 NOT EXISTS 关键字表示如果不存在某种条件，则返回TRUE，否则返回FALSE
 */
# 题目6-2-1：查询公司管理者的employee_id，last_name, job_id,  department_id
# 方式1：直接使用子查询进行查询
SELECT e1.employee_id, e1.last_name, e1.job_id, e1.department_id
FROM employees e1
WHERE e1.employee_id IN (
				SELECT DISTINCT manager_id
				FROM employees
				WHERE manager_id IS NOT NULL
			);

# 方式2：使用自连接
SELECT DISTINCT e2.employee_id, e2.last_name, e2.job_id, e2.department_id
FROM employees e1 JOIN employees e2
ON e1.manager_id = e2.employee_id;

# 方式3：使用EXISTS
SELECT e1.employee_id, e1.last_name, e1.job_id, e1.department_id
FROM employees e1
WHERE EXISTS (
				SELECT *
				FROM employees e2
				WHERE e1.employee_id = e2.manager_id
			);


# 题目6-2-2：查询departments表中，不存在于employees表中的部门的department_id和department_name
# 方式1：使用NOT EXISTS
SELECT department_id, department_name
FROM departments d
WHERE NOT EXISTS (
			SELECT *
			FROM employees e
			WHERE d.department_id = e.department_id
);

# 方式2：使用子查询
SELECT department_id, department_name
FROM departments d 
WHERE d.department_id NOT IN (
			SELECT DISTINCT department_id
			FROM employees
			WHERE department_id IS NOT NULL
);

# 方式3：使用右外连接
SELECT d.department_id, d.department_name
FROM departments d LEFT JOIN employees e
ON d.department_id = e.department_id
WHERE e.department_id IS NULL;




