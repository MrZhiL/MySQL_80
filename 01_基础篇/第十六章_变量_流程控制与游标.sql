## 第十六章 变量、流程控制与游标
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
SHOW GLOBAL VARIABLES;

# 2) 查看所有会话变量
SHOW SESSION VARIABLES;
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



