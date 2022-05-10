## 第十六章 - 1 变量、流程控制与游标
/* 
		date: 2022-05-09
		author: mr.zhi
		descript: mysql变量、流程控制与游标
		
		1. 变量
			 在MySQL数据库的存储过程和函数中，可以使用变量来存储查询或计算的中间结果数据，或者输出最终的结果数据。

			 在MySQL数据库中，变量分为系统变量(全局系统变量、会话系统变量)  以及  用户自定义变量。

	 
		2. 系统变量
 */
## 1. 系统变量

# 1.1 查看系统变量
# 1) 查看所有系统变量
SHOW GLOBAL VARIABLES; # 624

# 2) 查看所有会话变量
SHOW SESSION VARIABLES; # 647
SHOW VARIABLES; # 和上面的结果一样，默认查询的是会话系统变量

# 3) 查看满足条件的部门系统变量
SHOW GLOBAL VARIABLES LIKE 'admin_%';

# 4) 查看满足条件的部分会话变量
SHOW SESSION VARIABLES LIKE 'character_%';

# 1.2 查看指定系统变量
/*
		作为MySQL编码规范，MySQL中的系统变量以两个@@开头，其中“@@global”仅用于标记全局系统变量，
		"@@session"仅用于标记会话系统变量。“@@”首先标记会话系统变量，如果会话系统变量不存在，则标记全局系统变量
 */
# 1) 查看指定的系统变量的值
SELECT @@global.变量名;
select @@global.max_connections; # 151
select @@global.character_set_client; # utf8mb4

# 2) 查看指定的会话变量的值
SELECT @@session.变量名;
#或者
SELECT @@变量名;
-- select @@session.max_connections; # 错误，max_connextions为全局变量
SELECT @@session.pseudo_thread_id; # 31
select @@character_set_client; # utf8mb4


# 1.3 修改系统变量的值
/*
	有些时候，数据库管理员需要修改系统变量的默认值，以便修改当前会话或者MySQL服务实例的属性、特征。具体方法：

	方式1：修改MySQL 配置文件，继而修改MySQL系统变量的值（该方法需要重启MySQL服务）
	方式2：在MySQL服务运行期间，使用“set”命令重新设置系统变量的值

	# 1) 为某个系统变量赋值
	# 方式1：
	SET @@global.变量名 = 变量值;

	# 方式2：
	SET GLOBAL 变量名 = 变量值;

	# 2) 为某个会话变量赋值
	# 方式1：
	SET @@session.变量名 = 变量值;

	# 方式2：
	SET SESSION 变量名 = 变量值;
*/
# 1) 为某个系统变量赋值
# 针对于当前的数据库实例是有效的，一旦重启MySQL服务将会失效
# 方式1：
select @@global.max_connections; # 151
SET @@global.MAX_CONNECTIONS = 160;
select @@global.max_connections; # 160

# 方式2：
SET GLOBAL max_connections = 151; # 151

# 2) 为某个会话变量赋值
# 针对于当前的数据库会话是有效的，一旦关闭该会话将会失效
# 方式1：
SET @@session.character_set_client = 'gbk';

SELECT @@session.character_set_client;
SELECT @@global.character_set_client;

# 方式2：
SET SESSION character_set_client = 'utf8mb4';


## 2 用户变量
/*
	用户变量是用户自己定义的，作为 MySQL 编码规范，MySQL 中的用户变量以一个“@” 开头。根据作用范围不同，又分为会话用户变量和局部变量。

	会话用户变量：作用域和会话变量一样，只对当前连接会话有效。

	局部变量：只在 BEGIN 和 END 语句块中有效。
	局部变量只能在存储过程和函数中使用

	# 2.1 会话用户变量
	# 变量的定义
	# 方式1：使用=或者:=
	SET @用户变量 = 值;
	SET @用户变量 := 值;

	# 方式2: “:=” 或 INTO关键字
	SELECT @用户变量 := 表达式 [FROM 等子句]; # 注意这里是select，而不是set
	SET 表达式 INTO @用户变量 [FROM 等子句];

	# 查看用户变量的值（查看、比较、运算等）
	SELECT @用户变量
 */
# 2.0 准备工作
CREATE DATABASE dbtest16;

USE dbtest16;

CREATE TABLE employees
AS
SELECT * FROM dbtest2.employees;

CREATE TABLE departments
AS
SELECT * FROM dbtest2.departments;

SELECT * FROM employees;
SELECT * FROM departments;

# 2.1 会话用户变量
# 方式1
SET @m1 = 1;
SET @m2 := 2;
SET @sum := @m1 + @m2;

SELECT @sum; # 3

-- ------------------
# 方式2
SELECT @count:=COUNT(*) FROM employees;
SELECT @count;

SELECT AVG(salary) INTO @avg_sal FROM employees;
SELECT @avg_sal;

# 2.2 局部变量
/* 
	 定义：必须使用declare语句定义一个局部变量
	
	 作用域：仅仅在定义它的BEGIN...END中有效

	 位置：只能放在BEGIN ... END中，而且只能放在第一句

	BEGIN
		#声明局部变量
		DECLARE 变量名1 变量数据类型 [DEFAULT 变量默认值];
		DECLARE 变量名2,变量名3,... 变量数据类型 [DEFAULT 变量默认值];

		#为局部变量赋值
		SET 变量名1 = 值;
		SELECT 值 INTO 变量名2 [FROM 子句];

		#查看局部变量的值
		SELECT 变量1,变量2,变量3;
	END
*/

# 举例：
DELIMITER //

CREATE PROCEDURE test_var()
BEGIN
		# 声明局部变量
		DECLARE a INT DEFAULT(0);
		DECLARE b INT;
		# 如果多个变量的默认值相同，则可以在一行中赋值
		# DECLARE a, b INT DEFAULT(0);
		DECLARE emp_name VARCHAR(25);

		# 赋值
		SET a = 1;
		SET b := 2;

		SELECT last_name INTO emp_name FROM employees WHERE employee_id = 101;

		# 使用局部变量
		SELECT a, b, emp_name;
END //

DELIMITER ;

CALL test_var();

# 举例2：声明局部变量，并分别赋值为employees表中employee_id为102的last_name和salary
DELIMITER //

CREATE PROCEDURE test_var2()
BEGIN
		# 声明局部变量;
		DECLARE emp_name VARCHAR(25);
		DECLARE emp_sal DOUBLE(10,2);

		SELECT last_name, salary INTO emp_name, emp_sal FROM employees WHERE employee_id = 102;

		# 使用局部变量
		SELECT emp_name, emp_sal;
END //

DELIMITER ;

CALL test_var2();

# 举例2：声明两个变量，求和并打印 （分别使用会话用户变量、局部变量的方式实现）
# 会话用户变量
SET @a = 1;
SET @b = 2;
SET @result := @a + @b;

SELECT @result;

# 局部变量
DELIMITER //
CREATE PROCEDURE test_var3()
BEGIN
		# 声明局部变量;
		DECLARE a, b INT DEFAULT(1);
		DECLARE res_sum INT;

		SET a = 10;
		SET b = 20;
		SET res_sum = a + b;

		# 使用局部变量
		SELECT res_sum;
END //
DELIMITER ;
# 调用
CALL test_var3();

# 举例3：创建存储过程“different_salary”查询某员工和他领导的薪资差距，并用IN参数emp_id接收员工
#			   id，用OUT参数dif_salary输出薪资差距结果。
DROP PROCEDURE different_salary;

DELIMITER //
CREATE PROCEDURE different_salary(IN emp_id INT, OUT dif_salary DOUBLE)
BEGIN
		# 声明局部变量;
		DECLARE emp_sal, mgr_sal DECIMAL(10, 2) DEFAULT(0.0);
		DECLARE mgr_id INT;

		SELECT salary INTO emp_sal FROM employees WHERE employee_id = emp_id;
		SELECT manager_id INTO mgr_id FROM employees WHERE employee_id = emp_id;

		SELECT salary INTO mgr_sal FROM employees WHERE employee_id = mgr_id;

		# SELECT mgr_sal - emp_sal INTO dif_salary;
		SET dif_salary = mgr_sal - emp_sal;
END //
DELIMITER ;

# 调用
SET @emp_id = 101;
SET @dif_salary = 0;
CALL different_salary(@emp_id, @dif_salary);
SELECT @dif_salary;



## 3. 定义条件与处理程序
/*
		定义条件时事先定义程序执行过程中可能遇到的问题。
		处理程序定义了在遇到问题时应当采取的处理方式，并且保证存储过程或函数在遇到警告或错误时能继续执行。
		这样可以增强存储处理问题的能力，避免程序异常停止运行。

		说明：定义条件和处理程序在存储过程、存储函数中都是支持的。
	

		3.1 定义条件
		
				定义条件就是给MySQL中的错误码命名，这有助于存储的程序代码更清晰。他将一个错误名字和指定的错误条件关联起来。
				这个名字可以随后被用在定义处理程序的DECLARE HANDLER语句中。

				定义条件使用DECLARE语句，语法格式如下：
				DECLARE 错误名称CONDITION FOR 错误码 (或错误条件)

				错误码的说明：
					1) MySql_error_code 和 salstate_value都可以表示MySQL的错误
							* MySQL_error_code是数值类型错误代码。
							* sqlstate_value是长度为5的字符串类型错误代码。
					
					2) 例如，在ERROR 1418(HY000)中，1418是MySql_error_code，’HY000‘是salstate_value。
					3) 例如，在ERROR 1142(42000)中，1142是MySQL_error_code，'42000'是sqlstate_value。
 */
# 3.1 案例分析
DELIMITER //
CREATE PROCEDURE UpdateDataNoCondition()
BEGIN
		SET @x = 1;
		UPDATE employees SET email = NULL WHERE last_name = 'Abel';
		SET @x = 2;
		UPDATE employees SET email = 'aabbel' WHERE last_name = 'Abel';
		SET @x = 3;
END //
DELIMITER ;

# 测试上述案例：
# ERROR 1048 (23000): Column 'email' cannot be null: 1048为数值类型错误代码；23000位长度为5的字符串类型错误代码
CALL UpdateDataNoCondition();

SELECT @x;


# 3.2 定义条件
# 格式: DECLARE 错误名称 CONDITION FOR 错误码(或错误条件)
# 举例1：定义“Field_Not_Be_NULL”错误名与MySQL中违反非空约束的错误类型是“ERROR 1048 (23000)”对应。
# 方式1：使用MySQL_error_code
DECLARE Field_Not_Be_NULL CONDITION FOR 1048;

# 方式2：使用sqlstate_value, 加上sqlstate关键字可以避免引起歧义
DECLARE Field_Not_Be_NULL CONDITION FOR SQLSTATE '23000';

# 举例2：定义"ERROR 1148(42000)"错误，名称为command_not_allowed。
DECLARE command_not_allowed CONDITION FOR 1148;
DECLARE command_not_allowed CONDITION FOR SQLSTATE '42000';


# 3.2 定义处理程序
/*
	可以为SQL执行过程中发生的某种类型的错误定义特殊的处理程序。定义处理程序时，使用DECLARE语句的语法如下：
	
	DECLARE 处理方式 HANDLER FOR 错误类型 处理语句

	1) 处理方式：处理方式有3个取值：CONTINUE、EXIT、UNDO。
			* CONTINUE ：表示遇到错误不处理，继续执行。
			* EXIT ：表示遇到错误马上退出。
			* UNDO ：表示遇到错误后撤回之前的操作。MySQL中暂时不支持这样的操作。
	2) 错误类型（即条件）可以有如下取值：
			* SQLSTATE '字符串错误码' ：表示长度为5的sqlstate_value类型的错误代码；
			* MySQL_error_code ：匹配数值类型错误代码；
			* 错误名称：表示DECLARE ... CONDITION定义的错误条件名称。
			* SQLWARNING ：匹配所有以01开头的SQLSTATE错误代码；
			* NOT FOUND ：匹配所有以02开头的SQLSTATE错误代码；
			* SQLEXCEPTION ：匹配所有没有被SQLWARNING或NOT FOUND捕获的SQLSTATE错误代码；
	3) 处理语句：如果出现上述条件之一，则采用对应的处理方式，并执行指定的处理语句。
		 语句可以是像“ SET 变量 = 值”这样的简单语句，也可以是使用BEGIN ... END 编写的复合语句。
	

	定义处理程序的几种方式，代码如下：
	#方法1：捕获sqlstate_value
	DECLARE CONTINUE HANDLER FOR SQLSTATE '42S02' SET @info = 'NO_SUCH_TABLE';

	#方法2：捕获mysql_error_value
	DECLARE CONTINUE HANDLER FOR 1146 SET @info = 'NO_SUCH_TABLE';

	#方法3：先定义条件，再调用
	DECLARE no_such_table CONDITION FOR 1146;
	DECLARE CONTINUE HANDLER FOR NO_SUCH_TABLE SET @info = 'NO_SUCH_TABLE';

	#方法4：使用SQLWARNING
	DECLARE EXIT HANDLER FOR SQLWARNING SET @info = 'ERROR';

	#方法5：使用NOT FOUND
	DECLARE EXIT HANDLER FOR NOT FOUND SET @info = 'NO_SUCH_TABLE';

	#方法6：使用SQLEXCEPTION
	DECLARE EXIT HANDLER FOR SQLEXCEPTION SET @info = 'ERROR';
 */
# 3.3 案例分析：
# 案例1：在存储过程中，定义处理程序，捕获sqlstate_value值，当遇到MySQL_error_code值为1048时，执行
#				 CONTINUE操作，并且将@proc_value的值设置为-1。
DELIMITER //
CREATE PROCEDURE sqlstate_value()
BEGIN
			# 方式1：
			DECLARE CONTINUE HANDLER FOR 1048 SET @proc_value = -1;
			# 方式2：
			-- DECLARE CONTINUE HANDLER FOR SQLSTATE '23000' SET @proc_value = -1;

			SET @x = 1;
			UPDATE employees SET email = NULL WHERE last_name = 'Abel';
			SET @x = 2;
			UPDATE employees SET email = 'aabbel' WHERE last_name = 'Abel';
			SET @x = 3;
END //
DELIMITER ;

CALL sqlstate_value();
select @x, @proc_value; # 3, -1

# 案例2：创建一个名称为“InsertDataWithCondition”的存储过程，代码如下。
# 			 在存储过程中，定义处理程序，捕获sqlstate_value值，当遇到sqlstate_value值为23000时，执行EXIT操
#				 作，并且将@proc_value的值设置为-1。
# 步骤1: 准备工作
DESC departments;
ALTER TABLE departments ADD CONSTRAINT uk_dept_id UNIQUE(department_id);

# 步骤2：没有处理程序之前
DELIMITER //
CREATE PROCEDURE InsertDataWithCondition()
BEGIN	

		SET @x = 1;
		INSERT INTO departments(department_name) VALUES('测试');
		SET @x = 2;
		INSERT INTO departments(department_name) VALUES('测试');
		SET @x = 3;
END //
DELIMITER ;

# ERROR 1062 (23000): Duplicate entry '0' for key 'departments.uk_dept_id'
CALL InsertDataWithCondition();
SELECT @x; # 2

# 步骤3：移除InsertDataWithCondition
DROP PROCEDURE InsertDataWithCondition;

# 步骤4：添加处理程序
DELIMITER //
CREATE PROCEDURE InsertDataWithCondition()
BEGIN	
		
		# 处理程序
		# 方式1
		-- DECLARE EXIT HANDLER FOR SQLSTATE '23000' SET @proc_value = -1;

		# 方式2
		DECLARE duplicate_entry CONDITION FOR SQLSTATE '23000';
		DECLARE EXIT HANDLER FOR duplicate_entry SET @proc_value = -1; 

		SET @x = 1;
		INSERT INTO departments(department_name) VALUES('测试'); # 上面的案例中已经运行过改行代码，因此这里再次运行的时候将会报错
		SET @x = 2;
		INSERT INTO departments(department_name) VALUES('测试');
		SET @x = 3;
END //
DELIMITER ;

CALL InsertDataWithCondition();
SELECT @x, @proc_value; # 1, -1

## 4. 流程控制
/*
		解决复杂问题不可能通过一个SQL语句完成，我们需要执行多个SQL操作。
		流程控制语句的作用就是控制存储过程中SQL语句的执行顺序，使我们完成
		复杂操作必不可少的一部分。只要是执行的程序，流程就分为三大类：

			* 顺序结构：程序从上往下依次执行
			* 分支结构：程序按照条件进行选择执行，从两条或多条路径中选择一条执行
			* 循环结构：程序满足一定条件下，重复执行一组语句

		针对于MySQL的流程控制语句主要有3类。注意：只能用于存储程序。
			1) 条件判断语句：IF语句和CASE语句
			2) 循环语句：LOOP、WHILE和REPEAT语句
			3) 跳转语句：ITERATE和LEAVE语句。
 */
# 4.1 分支结构 - IF
/* IF语句的语法结构是：
	
	 IF 表达式1 THEN 操作1
	 [ELSEIF 表达式2 THEN 操作2] .....
	 [ELSE 操作N]
	 END IF

	 根据表达式的结果为TRUE或FALSE执行相应的语句。这里[]中的内容是可选的。

	 特点：不同的表达式对应不同的操作；
				 使用在begin end中

 */
# 举例1：
DROP PROCEDURE IF EXISTS test_if;

DELIMITER //
CREATE PROCEDURE test_if()
BEGIN
		# NOTE: 所有的变量声明必须在存储过程的开始处
		DECLARE stu_name VARCHAR(15);
		DECLARE email VARCHAR(25) DEFAULT 'xxx@sina.com';
		DECLARE age INT DEFAULT(20);

		# case1:
		IF stu_name IS NULL THEN SELECT 'stu_name is null';
		END IF;
		
		# case2:
		IF email is NULL THEN SELECT 'email is null';
		ELSE SELECT email; #CONCAT('email is : ', email);
		END IF;

		# case3:
		IF age > 40 THEN SELECT '中年';
		ELSEIF age > 18 THEN SELECT '青年';
		ELSEIF age > 12 THEN SELECT '少年';
		ELSE SELECT '幼年';
		END IF;

END //
DELIMITER ;

CALL test_if();

# 举例2：声明存储过程“update_salary_by_eid1”，定义IN参数emp_id，输入员工编号。判断该员工
#				 薪资如果低于8000元并且入职时间超过5年，就涨薪500元；否则就不变。
DELIMITER //
CREATE PROCEDURE update_salary_by_eid1(IN emp_id INT)
BEGIN
		# 定义变量
		DECLARE emp_sal DOUBLE; # 用来记录员工的薪资
		DECLARE hire_year DOUBLE; # 用来记录员工工作的年限

		SELECT salary INTO emp_sal FROM employees WHERE employee_id = emp_id;
		SELECT DATEDIFF(CURDATE(),hire_date)/365 INTO hire_year FROM employees WHERE employee_id = emp_id;

		# IF语句进行判断
		IF emp_sal < 8000 AND hire_year >= 5 
				THEN UPDATE employees SET salary = salary + 500 WHERE employee_id = emp_id;
		END IF;		
		
END //
DELIMITER ;

# 查看薪资低于8000且工作年限大于5的工作人员
SELECT DATEDIFF(CURDATE(),hire_date)/365 hire_year, employee_id, last_name, salary, hire_date 
FROM employees 
WHERE salary < 8000 AND DATEDIFF(CURDATE(),hire_date)/365 >= 5;

# 调用update_salary_by_eid1
CALL update_salary_by_eid1(104); # 104的salary从6000->6500

# 举例3：声明存储过程“update_salary_by_eid2”，定义IN参数emp_id，输入员工编号。判断该员工
# 			 薪资如果低于9000元并且入职时间超过5年，就涨薪500元；否则就涨薪100元。
DELIMITER //
CREATE PROCEDURE update_salary_by_eid2(IN emp_id INT)
BEGIN
		# 定义变量
		DECLARE emp_sal DOUBLE; # 用来记录员工的薪资
		DECLARE hire_year DOUBLE; # 用来记录员工工作的年限

		SELECT salary INTO emp_sal FROM employees WHERE employee_id = emp_id;
		SELECT DATEDIFF(CURDATE(),hire_date)/365 INTO hire_year FROM employees WHERE employee_id = emp_id;

		# IF语句进行判断
		IF emp_sal < 9000 AND hire_year >= 5 
				THEN UPDATE employees SET salary = salary + 500 WHERE employee_id = emp_id;
		ELSE UPDATE employees SET salary = salary + 100 WHERE employee_id = emp_id;
		END IF;		
		
END //
DELIMITER ;

# 查看薪资低于8000且工作年限大于5的工作人员
SELECT DATEDIFF(CURDATE(),hire_date)/365 hire_year, employee_id, last_name, salary, hire_date 
FROM employees 
WHERE salary < 9000 AND DATEDIFF(CURDATE(),hire_date)/365 >= 5;

# 调用update_salary_by_eid1
CALL update_salary_by_eid2(104); # 104的salary从6500->7000
CALL update_salary_by_eid2(103); # 103的salary从9000->9100

# 举例4：声明存储过程“update_salary_by_eid3”，定义IN参数emp_id，输入员工编号。判断该员工
#				 薪资如果低于9000元，就更新薪资为9000元；薪资如果大于等于9000元且低于10000的，但是奖金
# 			 比例为NULL的，就更新奖金比例为0.01；其他的涨薪100元。
DELIMITER //
CREATE PROCEDURE update_salary_by_eid3(IN emp_id INT)
BEGIN
		# 定义变量
		DECLARE emp_sal DOUBLE; # 用来记录员工的薪资
		DECLARE bound DOUBLE;   # 用来记录员工的奖金比例

		SELECT salary INTO emp_sal FROM employees WHERE employee_id = emp_id;
		SELECT commission_pct INTO bound FROM employees WHERE employee_id = emp_id;

		# IF语句进行判断
		IF emp_sal < 9000
				THEN UPDATE employees SET salary = 9000 WHERE employee_id = emp_id;
		ELSEIF emp_sal < 10000 AND bound IS NULL
				THEN UPDATE employees SET commission_pct = 0.01 WHERE employee_id = emp_id;
		ELSE 
				UPDATE employees SET salary = salary + 100 WHERE employee_id = emp_id;
		END IF;		
		
END //
DELIMITER ;

# 查看员工信息
SELECT * FROM employees WHERE employee_id IN (102, 103, 104);

# 调用update_salary_by_eid1
CALL update_salary_by_eid3(102); # 102的salary从17100->17200
CALL update_salary_by_eid3(103); # 103的commission_pct从0->0.1
CALL update_salary_by_eid3(104); # 104的salary从7000->9100


# 4.2 分支结构 - CASE
/*
		# CASE语句的语法结构1：类似于switch
				CASE 表达式
				WHEN 值1 THEN 结果1或语句1(如果是语句，需要加分号)
				WHEN 值2 THEN 结果2或语句2(如果是语句，需要加分号)
				...
				ELSE 结果n或语句n(如果是语句，需要加分号)
				END [case]（如果是放在begin end中需要加上case，如果放在select后面不需要）

		# CASE语句的语法结构2：类似于多重IF
				CASE
				WHEN 条件1 THEN 结果1或语句1(如果是语句，需要加分号)
				WHEN 条件2 THEN 结果2或语句2(如果是语句，需要加分号)
				...
				ELSE 结果n或语句n(如果是语句，需要加分号)
				END [case]（如果是放在begin end中需要加上case，如果放在select后面不需要）
 */
# 举例1：使用CASE流程控制语句的第2种格式，判断val1和val2值的大小。
DELIMITER //
CREATE PROCEDURE test_case1() 
BEGIN
		# 定义局部变量
		DECLARE val1, val2 INT;
		SET val1 = 100;
		set val2 = 10;

		# 使用case语句进行判断
		CASE WHEN val1 > val2 THEN SELECT CONCAT(val1, ' > ', val2);
				 WHEN val1 < val2 THEN SELECT CONCAT(val1, ' < ', val2);
				 ELSE SELECT CONCAT(val1, ' = ', val2);
		END CASE; # 在begin ... end语句中需要使用end case; 在select语句中使用end（无case）
END //
DELIMITER ;

CALL test_case1();

# 举例2：使用CASE流程控制语句的第1种格式，判断val值等于1、等于2，或者两者都不等。
DELIMITER //
CREATE PROCEDURE test_case2(IN val INT)
BEGIN
		# 定义变量
-- 		DECLARE val INT DEFAULT(2);

		# case语句
		case val WHEN 1 THEN SELECT 'val is 1';
						 WHEN 2 THEN SELECT 'val is 2';
						 WHEN 3 THEN SELECT 'val is 3';
						 ELSE SELECT 'val greater 3';
		END CASE;
END //
DELIMITER ;

CALL test_case2(1);
CALL test_case2(2);
CALL test_case2(3);
CALL test_case2(10);

# 举例3：声明存储过程“update_salary_by_eid4”，定义IN参数emp_id，输入员工编号。判断该员工
#				 薪资如果低于9000元，就更新薪资为9000元；薪资大于等于9000元且低于10000的，但是奖金比例
#				 为NULL的，就更新奖金比例为0.01；其他的涨薪100元。
DROP PROCEDURE update_salary_by_eid4;

DELIMITER //
CREATE PROCEDURE update_salary_by_eid4(IN emp_id INT)
BEGIN
		# 定义变量
		DECLARE emp_sal DOUBLE;
		DECLARE bound INT;

		SELECT salary INTO emp_sal FROM employees WHERE employee_id = emp_id;
		SELECT commission_pct INTO bound FROM employees WHERE employee_id = emp_id;
		
		# 使用case语句进行判断
		CASE WHEN emp_sal < 9000 THEN UPDATE employees SET salary = 9000 WHERE employee_id = emp_id;
				 WHEN emp_sal < 10000 AND bound IS NULL	
														 THEN UPDATE employees SET commission_pct = 0.01 WHERE employee_id = emp_id;
				 ELSE UPDATE employees SET salary = salary + 100 WHERE employee_id = emp_id;
		END case;

END // 
DELIMITER ;

SELECT * FROM employees WHERE employee_id in (103, 104, 105);

CALL update_salary_by_eid4(103); # salary = 9200->9300
CALL update_salary_by_eid4(104); # commission_Pct = 0->0.1
CALL update_salary_by_eid4(105); # salary = 4800->9000


# 举例4：声明存储过程update_salary_by_eid5，定义IN参数emp_id，输入员工编号。判断该员工的
#				 入职年限，如果是0年，薪资涨50；如果是1年，薪资涨100；如果是2年，薪资涨200；如果是3年，
#				 薪资涨300；如果是4年，薪资涨400；其他的涨薪500。
DROP PROCEDURE update_salary_by_eid5;

DELIMITER //
CREATE PROCEDURE update_salary_by_eid5(IN emp_id INT)
BEGIN
		# 定义变量
		DECLARE hire_year INT;

		SELECT FLOOR(DATEDIFF(CURDATE(), hire_date)/365) INTO hire_year FROM employees WHERE employee_id = emp_id;
		
		# 使用case语句进行判断
		CASE hire_year WHEN 0 THEN UPDATE employees SET salary = salary + 50 WHERE employee_id = emp_id;
									 WHEN 1 THEN UPDATE employees SET salary = salary + 100 WHERE employee_id = emp_id;
									 WHEN 2 THEN UPDATE employees SET salary = salary + 200 WHERE employee_id = emp_id;
									 WHEN 3 THEN UPDATE employees SET salary = salary + 300 WHERE employee_id = emp_id;
									 WHEN 4 THEN UPDATE employees SET salary = salary + 400 WHERE employee_id = emp_id;
									 ELSE UPDATE employees SET salary = salary + 500 WHERE employee_id = emp_id;
		END case;

END // 
DELIMITER ;

SELECT DATEDIFF(CURDATE(),hire_date)/365 hire_year, employee_id, last_name, salary, hire_date 
FROM employees 

CALL update_salary_by_eid5(100);
CALL update_salary_by_eid5(101);
CALL update_salary_by_eid5(102);
CALL update_salary_by_eid5(103);

