### 第06章 多表查询

/*
 SELECT ..., ..., ....
 FROM ....
 WHERE ... AND / OR / NOT
 ORDER BY ... (ASC/DESC), ..., ...
 LIMIT ..., ...
 */

## 1. 熟悉常见的几个表
DESC employees;

DESC departments;

DESC locations;

## 练习1 : 查询员工“Abel” 在那个城市工作

## 方法1. 较为复杂的逻辑操作
# 1) 首先查询该员工的department_id
# 下面的查询可以得到该员工的department_id = 80
SELECT * FROM employees WHERE last_name = 'Abel';

# 2) 根据该department_id 查询对应的location_id
# 下面的查询可以得到该员工的location_id = 2500
SELECT * FROM departments WHERE department_id = 80;

# 3) 根据location_id查询对应的城市
# 下面的查询可以得到对应的city 为 Oxford
SELECT * FROM locations WHERE location_id = 2500;


## 方法2. 直接进行多表查询：将上述操作简化为1个操作


## 2. 出现笛卡尔积的错误方式：
# 错误的原因：缺少了多表的连接操作

# 错误的实现方式：每个员工都与每个部门匹配了一遍。
SELECT employee_id, department_name
FROM employees, departments  # 该命令会查询出2889条记录

# 直接使用CROSS JOIN进行连接也是错误的，错误的实现方式：每个员工都与每个部门匹配了一遍。
SELECT employee_id, department_name
FROM employees CROSS JOIN departments  # 该命令会查询出2889条记录

SELECT * FROM departments; # 共27条数据


## 3. 多表查询的正确操作：需要有连接条件

# 直接进行多表查询：将上述操作简化为1个操作
SELECT employee_id, department_name
FROM employees, departments  
# 两个表的连接条件，此时如果employees.department_id为null，则不会显示
WHERE employees.department_id = departments.department_id # 共查询出106条记录
ORDER BY employee_id ASC;


## note. 如果查询语句中出现了多个表中都存在的字段，则必须指明该字段所在的表
## 建议1：从sql优化的角度，建议多表查询时，每个字段前都指明其所在的表

# 直接进行多表查询2，如果多个表中有相同的名字，则需要指明要想的输出
SELECT employees.employee_id, departments.department_name, employees.department_id
FROM employees, departments  
# 两个表的连接条件，此时如果employees.department_id为null，则不会显示
WHERE employees.department_id = departments.department_id # 共查询出106条记录
ORDER BY employee_id ASC;

## 建议2：由于每个字段都添加表名，则导致SQL语句较长，使得可读性变差。
##        因此可以给表起别名，在SELECT 和 WHERE 中使用表的别名
##
## note: 如果对表起别名了，一旦在SELECT或WHERE中使用了表的别名的话，则必须使用别名，不能使用表的原名，否则会报错

SELECT emp.employee_id, dep.department_name, emp.department_id
FROM employees emp, departments dep # 对表其别名
# 两个表的连接条件，此时如果employees.department_id为null，则不会显示
WHERE emp.department_id = dep.department_id # error: WHERE emp.department_id = departments.department_id
ORDER BY employee_id ASC;


## 4. 结论：如果有n个表需要实现多表的查询，则需要n-1个连接条件（至少需要n-1个条件）

# 练习：查询员工的employee_id, last_name, department_name, city
SELECT emp.employee_id, emp.last_name, dep.department_name, loc.city
FROM employees emp, departments dep, locations loc
WHERE emp.department_id = dep.department_id 
AND dep.location_id = loc.location_id
ORDER BY emp.employee_id ASC;


/*  */
## 5. 多表查询的分类
/*
 角度1：等值连接 vs 非等值连接

 角度2：自连接 vs 非自连接

 角度3：内连接 vs 外连接
 */
# 5.1 等值连接(=) vs 非等值连接（!= > <, >=, <=）
# 上述的测试均为等值连接
# 非等值连接的例子：
SELECT * FROM job_grades;

SELECT e.employee_id, e.last_name, e.salary, j.grade_level
FROM employees e, job_grades j
WHERE e.salary BETWEEN j.lowest_sal AND j.highest_sal;


# 5.2 自连接 和 非自连接
# 上述的案例均为非自连接
# 自连接的测试：查询员工id，姓名及其管理者的id和姓名
SELECT e1.employee_id, e1.last_name, e2.employee_id, e2.last_name 
FROM employees e1, employees e2 # e1表示员工，e2表示管理者
WHERE e1.manager_id = e2.employee_id;




