## 第六章——多表查询-课后练习

# 1.显示所有员工的姓名，部门号和部门名称。
SELECT e.employee_id, e.last_name, e.department_id, d.department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id


# 2.查询90号部门员工的job_id和90号部门的location_id
# 使用SQL的JOIN语法
SELECT e.employee_id, e.last_name, e.department_id, j.job_id, d.location_id
FROM employees e JOIN departments d
ON e.department_id = d.department_id
JOIN jobs j
ON e.job_id = j.job_id
WHERE d.department_id = 90;

# 使用USING语法
SELECT e.employee_id, e.last_name, e.department_id, j.job_id, d.location_id
FROM employees e JOIN departments d
USING (department_id)
JOIN jobs j
USING (job_id)
WHERE d.department_id = 90;


-- 查询指令
desc jobs;
desc departments;
desc employees;

SELECT employee_id, last_name
FROM employees
WHERE employees.department_id = 90;

# 3.选择 **所有有奖金的员工** 的 last_name , department_name , location_id , city
SELECT * FROM employees WHERE commission_pct IS NOT NULL; # 可以查询出共有35条记录

# 方法一：（应该查询出共有35条记录）
SELECT e.last_name, e.commission_pct, d.department_name , d.location_id, l.city
FROM employees e LEFT OUTER JOIN departments d # 因为employee中存在department_id存在NULL的元素，因此需要使用LEFT JOIN
USING (department_id)
LEFT OUTER JOIN locations l # 因为此时存在department_name为null的元素，所有该元素的location_id也为null，因此也需要使用LEFT JOIN
USING (location_id)
WHERE commission_pct IS NOT NULL;

# 方法二：比较复杂，右连接 UNION ALL 左外连接
SELECT e.employee_id, e.last_name, e.commission_pct, d.department_name, d.location_id, l.city
FROM employees e JOIN departments d
USING (department_id)
JOIN locations l
USING (location_id)
WHERE e.commission_pct IS NOT NULL

UNION ALL

SELECT e.employee_id, e.last_name, e.commission_pct, d.department_name, d.location_id, NULL
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id
WHERE e.department_id IS NULL 
AND e.commission_pct IS NOT NULL;


-- WHERE e.employee_id IS NOT NULL
-- AND e.department_id IS NULL
-- AND e.commission_pct IS NOT NULL;
-- AND e.last_name IS NOT NULL;


-- -------------测试-----------------
SELECT * FROM locations;
SELECT * FROM employees WHERE commission_pct IS NOT NULL; # 35 条记录
SELECT * FROM employees WHERE department_id IS NULL; # 1条记录

# 4.选择city在Toronto工作的员工的 last_name , job_id , department_id , department_name
SELECT e.employee_id, e.last_name, e.job_id, e.department_id, d.department_name, l.city
FROM employees e JOIN departments d
USING (department_id)
JOIN locations l
USING (location_id)
WHERE l.city = 'Toronto';

# 5.查询员工所在的部门名称、部门地址、姓名、工作、工资，其中员工所在部门的部门名称为’Executive’
SELECT e.employee_id, e.last_name, e.job_id, e.salary, e.department_id, d.department_name, l.city, l.street_address
FROM employees e RIGHT JOIN departments d
USING (department_id)
LEFT JOIN locations l
USING (location_id)
WHERE d.department_name = 'Executive';

SELECT * FROM employees WHERE department_id = 90; # Executive 对应的部门编号为90

# 6.选择指定员工的姓名，员工号，以及他的管理者的姓名和员工号，结果类似于下面的格式
#   employees Emp# manager Mgr#
#   kochhar 101 king 100
SELECT emp.last_name "employees", emp.employee_id "EMP", mgr.last_name "manager", mgr.employee_id "Mgr"
FROM employees emp, employees mgr
WHERE emp.manager_id = mgr.employee_id; # error，只有106条记录

SELECT emp.last_name "employees", emp.employee_id "EMP#", mgr.last_name "manager", mgr.employee_id "Mgr#"
FROM employees emp LEFT JOIN employees mgr
ON emp.manager_id = mgr.employee_id; # 107条记录

# 7.查询哪些部门没有员工
# 方法一：
SELECT departments.department_id, departments.department_name
FROM employees RIGHT JOIN departments
USING (department_id)
WHERE employees.department_id IS NULL;

# 方法二：
SELECT departments.department_id, departments.department_name
FROM departments LEFT JOIN employees
USING (department_id)
WHERE employees.department_id IS NULL;

SELECT DISTINCT department_id FROM employees ORDER BY department_id ASC; # 11，共使用了11个部门
SELECT DISTINCT department_id FROM departments ORDER BY department_id ASC; # 27个部门id，因此有16个部门没有员工

# 8. 查询哪个城市没有部门
# 需要使用右外连接
SELECT DISTINCT l.location_id, l.city
FROM departments d RIGHT JOIN locations l
ON d.location_id = l.location_id
WHERE d.location_id IS NULL;

# 只有7个城市中存在部门,
SELECT DISTINCT l.location_id, l.city
FROM departments d, locations l
WHERE d.location_id = l.location_id; 

# 可以查询到共有23个城市，因此有16个尝试没有部门
SELECT DISTINCT city FROM locations;

# 9. 查询部门名为 Sales 或 IT 的员工信息
SELECT e.*, d.department_name # 可以查询出共有39条数据
FROM employees e JOIN departments d
USING (department_id)
WHERE d.department_name = 'Sales'
OR d.department_name = 'IT'

# Sales的部门id为80，可以查询到共有34条数据
# IT 部门的id为60，可以查询到共有5条数据
SELECT * FROM employees WHERE department_id = 80;
SELECT * FROM employees WHERE department_id = 60;