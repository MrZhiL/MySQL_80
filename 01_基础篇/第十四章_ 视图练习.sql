## 第十四章 视图的练习
USE dbtest14;
SHOW tables;

## 练习1：
#1. 使用表dbtest2.employees创建视图employee_vu，其中包括姓名（LAST_NAME），员工号（EMPLOYEE_ID），部门号(DEPARTMENT_ID)
CREATE VIEW employee_vu
AS
SELECT employee_id, last_name, department_id FROM dbtest2.employees;

#2. 显示视图的结构
DESC employee_vu;

#3. 查询视图中的全部内容
SELECT * FROM employee_vu;

#4. 将视图中的数据限定在部门号是80的范围内
CREATE OR REPLACE VIEW employee_vu
AS
SELECT employee_id, last_name, department_id 
FROM dbtest2.employees
WHERE department_id = 80;


## 练习2：
CREATE TABLE emps
AS
SELECT * FROM dbtest2.employees;

#1. 创建视图emp_v1,要求查询电话号码以‘011’开头的员工姓名和工资、邮箱
CREATE VIEW emp_v1
AS
SELECT employee_id, last_name, salary, email
FROM emps
WHERE phone_number LIKE '011%';

DESC emp_v1;
SELECT * FROM emp_v1;

#2. 要求将视图 emp_v1 修改为查询电话号码以‘011’开头的并且邮箱中包含 e 字符的员工姓名和邮箱、电话号码
ALTER VIEW emp_v1
AS
SELECT employee_id, last_name, salary, email, phone_number
FROM emps
WHERE phone_number LIKE '011%' AND email LIKE '%e%';

#3. 向 emp_v1 插入一条记录，是否可以？
# 理论可以，实测不可以
INSERT INTO emp_v1 VALUES(1111, 'zhi', 30000, 'lenovo', '999.111.333.111');

#4. 修改emp_v1中员工的工资，每人涨薪1000
# note: 一定要从emp中创建view，如果从dbtest2.employees中创建，则会将原始数据修改！！！！！
UPDATE emp_v1 SET salary = salary + 1000;
SELECT * FROM emp_v1;

#5. 删除emp_v1中姓名为Olsen的员工
DELETE FROM emp_v1 WHERE last_name = 'Olsen';

#6. 创建视图emp_v2，要求查询部门的最高工资高于 12000 的部门id和其最高工资
CREATE VIEW emp_v2 
AS
SELECT department_id, MAX(salary) max_sal
FROM emps
GROUP BY department_id
HAVING max_sal > 12000;

SELECT * FROM emp_v2;

#7. 向 emp_v2 中插入一条记录，是否可以？
# 不可以，因为这里面进行了联合查询
INSERT INTO emp_v2 VALUES (111, 30000); # error

#8. 删除刚才的emp_v2 和 emp_v1
DROP VIEW IF EXISTS emp_v2, emp_v1;

show tables;









