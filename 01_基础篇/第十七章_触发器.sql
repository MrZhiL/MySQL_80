## 第十七章_触发器
/*
		在实际开发中，我们经常会遇到这样的情况：有 2 个或者多个相互关联的表，如商品信息和库存信息分
		别存放在 2 个不同的数据表中，我们在添加一条新商品记录的时候，为了保证数据的完整性，必须同时
		在库存表中添加一条库存记录。

		这样一来，我们就必须把这两个关联的操作步骤写到程序里面，而且要用事务包裹起来，确保这两个操
		作成为一个原子操作，要么全部执行，要么全部不执行。要是遇到特殊情况，可能还需要对数据进行手
		动维护，这样就很容易忘记其中的一步，导致数据缺失。

		这个时候，可以使用触发器。通过创建一个触发器，让商品信息数据的插入操作自动触发库存数
		据的插入操作。这样一来，就不用担心因为忘记添加库存数据而导致的数据缺失了。


		1. 触发器概述

			MySQL从5.0.2版本开始支持触发器。MySQL的触发器和存储过程一样，都是嵌入到MySQL服务器的一段程序。

  		触发器是由事件来触发某个操作，这些事件包括INSERT 、UPDATE 、DELETE 事件。所谓事件就是指
			用户的动作或者触发某项行为。如果定义了触发程序，当数据库执行这些语句时候，就相当于事件发生
			了，就会自动激发触发器执行相应的操作。

			当对数据表中的数据执行插入、更新和删除操作，需要自动执行一些数据库逻辑时，可以使用触发器来
			实现。


		2. 触发器的创建

			2.1 创建触发器的语法：
					CREATE TRIGGER 触发器名称
					{BEFORE | AFTER} {INSERT | UPDATE | DELETE} ON 表名
					FOR EACH ROW
					触发器执行的语句块;

				说明：表名：表示触发器监控的对象
							BEFORE | AFTER: 表示触发的时间。BEFORE表示在事件之前触发；AFTER表示在事件之后触发。
							INSERT | UPDATE | DELETE：表示触发的事件（插入、更新、删除记录时触发）

				触发器执行的语句块：可以是单条SQL语句，也可以是由BEGIN...END结构组成的复合语句块。



 */
## 0. 准备工作，创建本章的数据库dbtest17
CREATE DATABASE dbtest17;

USE dbtest17;

show tables;

## 1. 创建触发器
# 1.1 创建触发器的操作表test_trigger, test_trigger_log
CREATE TABLE test_trigger (
	id INT PRIMARY KEY AUTO_INCREMENT,
	t_note VARCHAR(30)
);

CREATE TABLE test_trigger_log (
	id INT PRIMARY KEY 	AUTO_INCREMENT,
	t_log VARCHAR(30)
);

SELECT * FROM test_trigger;
SELECT * FROM test_trigger_log;

# 1.2 创建触发器：创建名称为before_insert_test_tri的触发器，
#				向test_trigger数据表插入数据之前，向test_trigger_log数据表中插入before_insert的日志信息。
DELIMITER $
CREATE TRIGGER before_insert_test_tri
BEFORE INSERT ON test_trigger
FOR EACH ROW
BEGIN
		INSERT INTO test_trigger_log(t_log) VALUES ('before insert...');
END $
DELIMITER ;

# 因此此时为test_trigger表创建了一个触发器，所以此时插入一条数据会在表test_trigger_log中产生一条数据
INSERT INTO test_trigger(t_note) VALUES ('Tom');
INSERT INTO test_trigger(t_note) VALUES ('Tom1');

SELECT * FROM test_trigger;
SELECT * FROM test_trigger_log; # 此时可以发现该表中有一个数据


# 1.3 创建名称为after_insert_test_tri的触发器，
# 向test_trigger数据表插入数据之后，向test_trigger_log数据表中插入after_insert的日志信息。
drop trigger after_insert_test_tri;

DELIMITER //
CREATE TRIGGER after_insert_test_tri
AFTER INSERT ON test_trigger
FOR EACH ROW
BEGIN
		INSERT INTO test_trigger_log(t_log) VALUES ('after insert...');
END //
DELIMITER ;

# 因此此时为test_trigger表创建了两个触发器，所以此时插入一条数据会在表test_trigger_log中产生两条数据
INSERT INTO test_trigger(t_note) VALUES ('Tom2');

SELECT * FROM test_trigger;
SELECT * FROM test_trigger_log; # 此时可以发现该表中有一个数据

# 举例3：定义触发器“salary_check_trigger”，基于员工表“employees”的INSERT事件，在INSERT之前检查
# 			 将要添加的新员工薪资是否大于他领导的薪资，如果大于领导薪资，则报sqlstate_value为'HY000'的错
#				 误，从而使得添加失败。
# 1) 首先创建employees表
CREATE TABLE employees
AS
SELECT * FROM dbtest2.employees;

# 添加主键约束
ALTER TABLE employees ADD PRIMARY KEY(employee_id);

# 添加AUTO_INCREMENT约束
ALTER TABLE employees MODIFY employee_id INT AUTO_INCREMENT;

DESC employees;

SELECT * FROM employees;

# 2) 创建触发器
DELIMITER //
CREATE TRIGGER salary_check_trigger
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
		DECLARE sal DOUBLE; # 定义临时变量，用来记录薪资

		# 因为要插入数据，所以插入的数据为NEW
		# 如果要查看删除的数据，需要使用OLD
		SELECT salary INTO sal FROM employees WHERE employee_id = NEW.manager_id;

		# 使用If语句进行薪资的判断
		IF NEW.salary > sal THEN 
					# 手动抛出异常
					SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = '薪资高于领导薪资，错误！';
		END IF;

END //
DELIMITER ;

# 3) 进行测试，设置manager_id为103（salary = 9000）
# 此时新员工的salary为8000<9000，因此可以插入成功，编号为207
INSERT INTO employees(last_name, email, hire_date, salary, manager_id, job_id, department_id)
VALUES ('TomJ', 'TomJ@123.com', CURDATE(), 8000, 103, 'AD_VP', 50);

# 此时新员工的salary为9900 > 9000，因此插入失败
INSERT INTO employees(last_name, email, hire_date, salary, manager_id, job_id, department_id)
VALUES ('TomJJ', 'TomJJ@123.com', CURDATE(), 9900, 103, 'AD_VP', 50);

SELECT * FROM employees; 

