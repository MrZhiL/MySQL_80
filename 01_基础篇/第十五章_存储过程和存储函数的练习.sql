## 第十五章 存储过程和存储函数的练习

## 练习一：存储过程

#0.准备工作
CREATE DATABASE test15_pro_func;
USE test15_pro_func;

#1. 创建存储过程insert_user(),实现传入用户名和密码，插入到admin表中
CREATE TABLE admin(
	id INT PRIMARY KEY AUTO_INCREMENT,
	user_name VARCHAR(15) NOT NULL,
	pwd VARCHAR(25) NOT NULL
);

DELIMITER //
CREATE PROCEDURE insert_user(IN name varchar(15), IN pwd VARCHAR(25) )
BEGIN
		INSERT INTO admin(user_name, pwd) VALUES (name, pwd);
END //

DELIMITER ;

CALL insert_user('lisi', 'lisi123');
CALL insert_user('jack', 'jack123');
SELECT * FROM admin;

#2. 创建存储过程get_phone(),实现传入女神编号，返回女神姓名和女神电话
CREATE TABLE beauty(
	id INT PRIMARY KEY AUTO_INCREMENT,
	NAME VARCHAR(15) NOT NULL,
	phone VARCHAR(15) UNIQUE,
	birth DATE
);

INSERT INTO beauty(NAME,phone,birth)
VALUES
		('朱茵','13201233453','1982-02-12'),
		('孙燕姿','13501233653','1980-12-09'),
		('田馥甄','13651238755','1983-08-21'),
		('邓紫棋','17843283452','1991-11-12'),
		('刘若英','18635575464','1989-05-18'),
		('杨超越','13761238755','1994-05-11');
SELECT * FROM beauty;

DELIMITER \\
CREATE PROCEDURE get_phone(IN get_id int)
BEGIN
		SELECT NAME, phone FROM beauty WHERE id = get_id;
END \\
DELIMITER ;


DELIMITER \\
CREATE PROCEDURE get_phone2(IN get_id int, OUT get_name VARCHAR(20), OUT get_phone VARCHAR(20))
BEGIN
		SELECT NAME, phone INTO get_name, get_phone FROM beauty WHERE id = get_id;
END \\
DELIMITER ;

CALL get_phone(1);
CALL get_phone(2);

CALL get_phone2(1, @get_name, @get_phone);
SELECT @get_name, @get_phone;

#3. 创建存储过程date_diff()，实现传入两个女神生日，返回日期间隔大小
DELIMITER \\
CREATE PROCEDURE date_diff(IN birthday1 DATE, IN birthday2 DATE, OUT res INT)
BEGIN
		SELECT DATEDIFF(birthday1, birthday2) INTO res FROM DUAL;
END \\
DELIMITER ;

SET @birth1 = '1992-09-08';
SET @birth2 = '1989-01-03';
CALL date_diff(@birth1, @birth2, @result);
SELECT @result;

#4. 创建存储过程format_date(),实现传入一个日期，格式化成xx年xx月xx日并返回
DELIMITER \\
CREATE PROCEDURE format_date(IN date DATE, OUT str_date VARCHAR(50))
BEGIN
		SELECT DATE_FORMAT(date, '%Y年%m月%d日') INTO str_date FROM DUAL;
END \\
DELIMITER ;

CALL format_date(@birth1, @ret1);
CALL format_date(@birth2, @ret2);
SELECT @ret1, @ret2;

#5. 创建存储过程beauty_limit()，根据传入的起始索引和条目数，查询女神表的记录
DELIMITER \\
CREATE PROCEDURE beauty_limit(IN `index` INT, IN size INT)
BEGIN
		SELECT * FROM beauty LIMIT `index`, size; # 1) 可以使用LIMIT进行查询
-- 		SELECT * FROM beauty WHERE id BETWEEN `index` AND (index + size); # 2) 也可以使用between ... and 来进行筛选
END \\
DELIMITER ;

CALL beauty_limit(1, 3);

#6. 传入a和b两个值，最终a和b都翻倍并返回(#创建带inout模式参数的存储过程)
DROP PROCEDURE add_double;

DELIMITER \\
CREATE PROCEDURE add_double(INOUT a INT, INOUT b INT)
BEGIN
		SET a = a * 2;
		SET b = b * 2;
END \\
DELIMITER ;

SET @a = 1, @b = 2; # 此时需要连续定义a和b变量，否则会报错
CALL add_double(@a,@b);
SELECT @a, @b;

#7. 删除题目5的存储过程
DROP PROCEDURE IF EXISTS beauty_limit;

#8. 查看题目6中存储过程的信息
SHOW CREATE PROCEDURE add_double;

SHOW PROCEDURE STATUS LIKE 'add_double';

SELECT * FROM information_schema.ROUTINES WHERE ROUTINE_NAME = 'add_double';


## 练习二：存储函数
#0. 准备工作
USE test15_pro_func;

CREATE TABLE employees
AS
SELECT * FROM dbtest2.employees;

CREATE TABLE departments
AS
SELECT * FROM dbtest2.departments;

show tables;

#无参有返回
#1. 创建函数get_count(),返回公司的员工个数
DELIMITER //
CREATE FUNCTION get_count()
RETURNS INT
		# 需要加入下面的语句，否则会报错
		DETERMINISTIC
		CONTAINS SQL
		READS SQL DATA
BEGIN
	 RETURN (SELECT count(*) emp_num FROM employees);
END //
DELIMITER ;

SELECT get_count();


#有参有返回
#2. 创建函数ename_salary(),根据员工姓名，返回它的工资
DELIMITER //
CREATE FUNCTION ename_salary(emp_name VARCHAR(25))
RETURNS DOUBLE(10, 2)
		# 需要加入下面的语句，否则会报错
		DETERMINISTIC
		CONTAINS SQL
		READS SQL DATA
BEGIN
	 RETURN (SELECT salary FROM employees WHERE last_name = emp_name);
END //
DELIMITER ;

SELECT ename_salary('Abel');

#3. 创建函数dept_sal() ,根据部门名，返回该部门的平均工资
DELIMITER //
CREATE FUNCTION dept_sal(dept_id INT)
RETURNS DOUBLE(10, 2)
		# 需要加入下面的语句，否则会报错
		DETERMINISTIC
		CONTAINS SQL
		READS SQL DATA
BEGIN
	 RETURN (SELECT AVG(salary) FROM employees WHERE department_id = dept_id);
END //
DELIMITER ;

SELECT dept_sal(50);

SELECT AVG(salary) FROM employees WHERE department_id = 50;

#4. 创建函数add_float()，实现传入两个float，返回二者之和
DELIMITER //
CREATE FUNCTION add_float(f1 FLOAT, f2 FLOAT)
RETURNS FLOAT(10, 2)
		# 需要加入下面的语句，否则会报错
		DETERMINISTIC
		CONTAINS SQL
		READS SQL DATA
BEGIN
	 RETURN (SELECT f1 + f2 FROM DUAL);
END //
DELIMITER ;

SELECT add_float(10.2, 11.8);



