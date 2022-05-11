## 第十六章_变量_流程控制与游标练习

## 练习1：变量
#0.准备工作
CREATE DATABASE test16_var_cur;

use test16_var_cur;

CREATE TABLE employees
AS
SELECT * FROM dbtest2.employees;

CREATE TABLE departments
AS
SELECT * FROM dbtest2.departments;


#无参有返回
#1. 创建函数get_count(),返回公司的员工个数
# 方法1：使用存储过程
DELIMITER //
CREATE PROCEDURE get_count(OUT num INT)
BEGIN
		SELECT count(*) INTO num FROM employees;
END //
DELIMITER ;

CALL get_count(@num);
SELECT @num;

# 方法2：使用存储函数
# 如果不调用下面的代码，可能会报如下的错误：
#	 you *might* want to use the less safe log_bin_trust_function_creators variable

SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER //
CREATE FUNCTION get_count_f() 
RETURNS INT
BEGIN
		DECLARE num INT DEFAULT 0; # 定义临时变量

		SELECT count(*) INTO num FROM employees;

		RETURN num;
END //
DELIMITER ;

SELECT get_count_f();


#有参有返回
#2. 创建函数ename_salary(),根据员工姓名，返回它的工资
DELIMITER //
CREATE FUNCTION ename_salary(emp_name VARCHAR(20))
RETURNS DOUBLE
BEGIN
		RETURN (SELECT salary FROM employees WHERE last_name = emp_name);
END //
DELIMITER ;

SELECT ename_salary('Abel');

SELECT salary FROM employees WHERE last_name = 'Abel';

#3. 创建函数dept_sal() ,根据部门名，返回该部门的平均工资
DELIMITER //
CREATE FUNCTION dept_sal(dept_name VARCHAR(15))
RETURNS DOUBLE
BEGIN
		DECLARE avg_sal DOUBLE DEFAULT 0.0;
		
		SELECT AVG(salary) INTO avg_sal 
		FROM employees e JOIN departments d
		USING (department_id)
		WHERE d.department_name = dept_name;

		RETURN avg_sal;
END //
DELIMITER ;

SELECT dept_sal('Shipping');

SELECT AVG(salary)
FROM employees e JOIN departments d
USING (department_id)
WHERE d.department_name = 'Shipping'; # dept_id = 50 --> 3475.555556


#4. 创建函数add_float()，实现传入两个float，返回二者之和
DELIMITER //
CREATE FUNCTION add_float(f1 FLOAT, f2 FLOAT)
RETURNS FLOAT
BEGIN
		DECLARE add_f FLOAT DEFAULT 0.0;
	
		SET add_f = f1 + f2;

		RETURN add_f;
END //
DELIMITER ;

SET @f1 = 11.2;
SET @f2 = 11.8;
SELECT add_float(@f1, @f2);


## 练习2：流程控制
#1. 创建函数test_if_case()，实现传入成绩，
#		如果成绩>90,返回A，如果成绩>80,返回B，如果成绩>60,返回C，否则返回D
#要求：分别使用if结构和case结构实现
-- 使用if语句---------------------
DELIMITER //
CREATE FUNCTION test_if_case1(score FLOAT)
RETURNS CHAR
BEGIN
		
		DECLARE ch CHAR;
		
		IF score > 90 THEN SET ch =  'A';
		ELSEIF score > 80 THEN SET ch =  'B';
		ELSEIF score > 60 THEN SET ch =  'C';
		ELSE SET ch =  'D';
		END IF;

		RETURN ch;
end //
DELIMITER ;

SELECT test_if_case1(50);
SELECT test_if_case1(70);
SELECT test_if_case1(90);
SELECT test_if_case1(95);

-- 使用case语句---------------------
DELIMITER //
CREATE FUNCTION test_if_case2(score FLOAT)
RETURNS CHAR
BEGIN
		CASE WHEN score > 90 THEN RETURN 'A';
				 WHEN score > 80 THEN RETURN 'B';
				 WHEN score > 60 THEN RETURN 'C';
				 ELSE RETURN 'D';

		END CASE;
end //
DELIMITER ;

SELECT test_if_case2(100);
SELECT test_if_case2(90);
SELECT test_if_case2(80);
SELECT test_if_case2(60);

#2. 创建存储过程test_if_pro()，传入工资值，
#		如果工资值<3000,则删除工资为此值的员工，
#		如果3000 <= 工资值 <= 5000,则修改此工资值的员工薪资涨1000，否则涨工资500
DELIMITER //
CREATE PROCEDURE test_if_pro(IN sal DOUBLE)
BEGIN
		IF sal < 3000 THEN
				DELETE FROM employees WHERE salary = sal;
		ELSEIF sal <= 5000 THEN
				UPDATE employees SET salary = salary + 1000 WHERE salary = sal;
		ELSE UPDATE employees SET salary = salary + 500 WHERE salary = sal;
		END IF;
		
END //
DELIMITER ;

SELECT count(*) FROM employees; # 107
SELECT * FROM employees ORDER BY salary ASC;
SELECT * FROM employees WHERE salary IN (2100, 3000, 9000) ORDER BY salary; # 共6条记录

CALL test_if_pro(2100);
CALL test_if_pro(3000);
CALL test_if_pro(9000);

SELECT count(*) FROM employees; # 106
SELECT * FROM employees WHERE salary IN (2100, 3000+1000, 9000+500) ORDER BY salary;

#3. 创建存储过程insert_data(),传入参数为 IN 的 INT 类型变量 insert_count,实现向admin表中批量插
#		入insert_count条记录
DROP table admin;
CREATE TABLE admin(
		id INT PRIMARY KEY AUTO_INCREMENT,
		user_name VARCHAR(25) NOT NULL,
		user_pwd VARCHAR(35) NOT NULL
);

SELECT * FROM admin;

DROP PROCEDURE insert_data;

DELIMITER //
CREATE PROCEDURE insert_data(IN insert_count INT)
BEGIN
		DECLARE i INT DEFAULT 1; # 设置变量，用来统计已经插入的数据量
		
		WHILE i < insert_count DO
				INSERT INTO admin(user_name, user_pwd) VALUES(
						(SELECT last_name FROM employees WHERE employee_id = 1 + 100), # 通过加小括号可以设置为子查询
						IFNULL((SELECT first_name FROM employees WHERE employee_id = i + 100), 'aaaaa')
				);

				SET i = i + 1;
		END WHILE;
		
END //
DELIMITER ;

CALL insert_data(100);

SELECT * FROM admin;

SELECT * FROM admin where user_pwd = 'aaaaa';

## 练习3：游标的使用
# 创建存储过程update_salary()，参数1为 IN 的INT型变量dept_id，表示部门id；参数2为 IN的INT型变量
#	change_sal_count，表示要调整薪资的员工个数。查询指定id部门的员工信息，按照salary升序排列，根
# 据hire_date的情况，调整前change_sal_count个员工的薪资，详情如下。
DROP PROCEDURE update_salary;

DELIMITER //
CREATE PROCEDURE update_salary(IN dept_id INT, IN change_sal_count INT)
BEGIN
		DECLARE count INT DEFAULT 0; # 用来记录当前的编号
		DECLARE sal DOUBLE; # 用来记录员工的薪资
		DECLARE sal_rate DOUBLE; # 用来记录员工薪资涨幅的比例
		DECLARE emp_id INT; # 用来记录员工的id
		DECLARE hireDate Date; # 用来记录hire_date
		

		# 1) 创建游标
		DECLARE cursor_emp CURSOR FOR 
			SELECT employee_id, hire_date
			FROM employees WHERE department_id = dept_id 
			ORDER BY salary ASC;
		
		# 2) 打开游标		
		OPEN cursor_emp;

		# 3) 使用游标		
		WHILE count < change_sal_count DO 
				FETCH cursor_emp INTO emp_id, hireDate;

				IF YEAR(hireDate) < 1995 THEN SET sal_rate = 1.2;
				ELSEIF YEAR(hireDate) <= 1998 THEN SET sal_rate = 1.15;
				ELSEIF YEAR(hireDate) <= 2001 THEN SET sal_rate = 1.10;
				ELSE SET sal_rate = 1.05;
				END IF;

				UPDATE employees SET salary = salary * 1.2 WHERE employee_id = emp_id;

				SET count = count + 1;
		END WHILE;

		# 4) 关闭游标		
		CLOSE cursor_emp;
END //
DELIMITER ;

SELECT employee_id, hire_date, salary
FROM employees WHERE department_id = 50
ORDER BY salary ASC
LIMIT 0, 2;
# 上述命令的输出结果如下所示：
# 136	2000-02-06	2200
# 128	2000-03-08	2200

CALL update_salary(50, 2);

SELECT employee_id, hire_date, salary
FROM employees WHERE department_id = 50
ORDER BY salary ASC
LIMIT 0, 2;
# 上述命令的输出结果如下所示：
# 136	2000-02-06	2400
# 128	2000-03-08	2400
