## 第十五章 存储过程与函数
/*
		MySQL从5.0版本开始支持存储过程和函数。存储过程和函数能够将复杂的SQL逻辑封装在一起，
		应用程序无须关注存储过程和函数内部复杂的SQL逻辑，而只需要简单地调用存储过程和函数即可。


1. 存储过程概述
		
	1.1 含义：存储过程(Stored procedure)。它的思想很简单，就是一组经过预先编译的SQL语句的封装。

	1.2 执行过程：存储过程预先存储在MySQL服务器上，需要执行的时候，客户端只需要向服务端发出调用
							  存储过程的命令，服务端就可以把预先存储好的这一系列SQL语句全部执行。

	1.3 好处： 1) 简化操作，提高了SQL语句的重用性，减少了开发程序员的压力
						 2) 减少了操作过程中的失误，提高效率
						 3) 减少网络传输量（客户端不需要把所有的SQL语句通过网络发送给服务器）
						 4) 减少了SQL语句暴露在网上的风险，也提高了数据查询的安全性


	1.4 和视图、函数的对比：
			
			它和视图有着同样的优点，清晰、安全，还可以减少网络传输量。不过它和视图不同，视图是虚拟表，
			通常不对底层数据表直接操作，而存储过程是程序化的SQL，可以直接操作底层数据表，相比于面向
			集合的操作方式，能够实现一些更复杂的数据处理。

			一旦存储过程被创建出来，使用它就像使用函数一样简单，我们直接通过调用存储过程名即可。相较于
			函数，存储过程是没有返回值的。

	1.5 分类：
			
			存储过程的参数类型可以是IN、OUT和INOUT。根据这点分类如下：
			1) 没有参数（无参数无返回）
			2) 仅仅带IN类型（有参数无返回）
			3) 仅仅带OUT类型（无参数有返回值）
			4) 既带IN又带OUT（有参数有返回）
			5) 带INOUT（有参数又返回）
			
			note: in、out、inout都可以在一个存储过程中带多个


2. 创建存储过程

	2.1 语法分析：
			CREATE PROCEDURE 存储过程名(IN|OUT|INOUT 参数名 参数类型,...)
			[characteristics ...]ALTER		
			BEGIN 
				存储过程体
			END

			类似于Java中的方法：
			修饰符 返回类型 方法名(参数类型 参数名, ...) {
					方法体;
			}

3. 如何调试
	 在mysql中，存储过程不像普通的编程语言（比如VC++,java等）那样有专门的集成开发环境。
	 因此，我们可以通过SELECT语句，把程序执行的中间结果查询出来，来调试一个SQL语句的正确性。
	 调试成功之后，把SELECT语句后移到下一个SQL语句之后，再调试下一个SQL语句。这样`逐步推进`，
	 就可以完成对存储过程中所有操作的调试了。当然，我们可以把存储过程中的SQL语句复制出来，
	 逐段单独调试。

4. 存储函数的使用：
	 前面学习了很多函数，使用这些函数可以对数据进行各种处理操作，极大地提高用户对数据库的管理效率。
	 MySQL支持自定义函数，定义好之后，调用方式与调用MySQL预定义的系统函数一样。

	 
	 4.1 语法分析
		 学过的函数：LENGTH、SUBSTR、CONCAT等
		 语法格式：
				CREATE FUNCTION 函数名(参数名 参数类型, ...)
				RETURNS 返回值类型
				[characteristics ...]	
				BEGIN	
						函数体 # 函数体中肯定有RETURN语句
				END
			

			说明：
				1) 参数列表：指定参数IN、out或INOUT只对procedure是合法的，FUNCTION中总是默认为IN参数
				2) RETURNS TYPE 语句表示函数返回数据的类型
					 RETURNs子句只能对FUNCTION做指定，对函数而言这是强制的。它用来指定函数的返回类型，而且函数
					 体必须包含一个RETURN value语句。
				3) characteristic 创建函数时指定的对函数的约束。取值与创建存储过程相同。
				4) 函数体也可以用BEGIN ... END来表示SQL代码的开始和结束。如果函数体只有一条语句，也可以省略BEGIN ... END.

		4.2 调用存储函数
			  在MySQL中，存储函数的使用方法与MySQL内部函数的使用方法是一样的。换言之，用户自己定义的存
				储函数与MySQL内部函数是一个性质的。区别在于，存储函数是用户自己定义的，而内部函数是MySQL
				的开发者定义的。

				SELECT 函数名(实参列表)

5. 对比存储过程和存储函数
								关键字				调用语法					返回值							应用场景
		存储过程    PROCEDURE 		CALL 存储过程()		理解为有0个或多个		一般用于更新
		存储函数		FUNCTION  		SELECT 函数() 		只能是一个      		一般用于查询结果为一个值并返回时

		此外，存储函数可以放在查询语句中使用，存储过程不行。反之，存储过程的功能更加强大，
		包括能够执行对表的操作（比如创建表，删除表等）和事物操作，这些功能的存储函数是不具备的。
 */
# 0. 准备工作
CREATE DATABASE dbtest15;

USE dbtest15;

CREATE TABLE employees
AS
SELECT * FROM dbtest2.employees;

CREATE TABLE departments
AS 
SELECT * FROM dbtest2.departments;

SELECT * FROM employees;
SELECT * FROM departments;

# 1. 创建存储过程

# 1.1 无参数，无返回值
# 举例1：创建存储过程select_all_data(), 查看emps表的所有数据
DELIMITER $ # nivicat不支持该关键字, 但是在命令行中如果不执行该语句会报错

CREATE PROCEDURE select_all_data()
BEGIN 
	SELECT * FROM employees;
END ;
DELIMITER ;

# 举例2：创建存储过程avg_employee_salary(), 返回所有员工的平均工资
DELIMITER // # 常用的delimiter修饰符为 $ 或 // 
CREATE PROCEDURE avg_employee_salary()
BEGIN
	SELECT AVG(salary) avg_sal
	FROM employees;
END //

DELIMITER ;

# 举例3：创建存储过程show_max_salary()，用来查看employees表的最高薪资
CREATE PROCEDURE show_max_salary()
BEGIN
		SELECT MAX(salary) FROM employees;
END


# 1.2 带OUT的
# 举例4：创建存储过程show_min_salary()，查看employees表的最低薪资，并将最低薪资通过OUT参数“ms”输出
DELIMITER //

DESC employees;
# note: 输出类型需要和定义的类型一致，此时employees表中的salary定义为double类型
CREATE PROCEDURE show_min_salary(OUT ms DOUBLE)
BEGIN
		SELECT MIN(salary) INTO ms FROM employees;
END // 

DELIMITER ;


# 1.3 带IN输入的存储过程
# 举例5：创建存储过程show_someone_salary(), 查看employees表中某个员工的薪资
# 			 并用IN参数empname输入员工姓名
DELIMITER //
CREATE PROCEDURE show_someone_salary(IN empname VARCHAR(20))
BEGIN
	SELECT last_name, salary FROM employees WHERE last_name = empname;
END //

DELIMITER ;

# 1.4 带IN和OUT的存储过程
# 举例6：创建存储过程show_someone_salary2(), 查看employees表的某个员工的薪资，
#				 并用IN参数empname输入员工姓名，用out参数empsalary输出员工薪资
DELIMITER //
CREATE PROCEDURE show_someone_salary2(IN empname VARCHAR(20), OUT empsalary DOUBLE(8, 2))
BEGIN
	SELECT salary INTO empsalary FROM employees WHERE last_name = empname;
END //

DELIMITER ;

# 举例7：创建存储过程show_mgr_name()，查询某个员工领导的姓名，并用INOUT参数“empname”输入员工姓名，输出领导的姓名。
DELIMITER //

CREATE PROCEDURE show_mgr_name(INOUT empname varchar(25))
BEGIN
	SELECT last_name INTO empname 
	FROM employees
	WHERE employee_id = (
													SELECT manager_id FROM employees WHERE last_name = empname
											);
END //

DELIMITER ;

# 2. 存储过程的调用
# 2.1 无参的存储过程调用
CALL select_all_data();
CALL avg_employee_salary();
CALL show_max_salary();

# 2.2 带返回参数的存储过程调用
# 查看变量值 SELECT @变量名
CALL show_min_salary(@ms);
SELECT @ms;

# 2.3 带输入参数的存储过程调用
# 调用方式1：
CALL show_someone_salary('King');
CALL show_someone_salary('P_ataballa');

# 调用方式2：
SET @empname = 'Abel'; # 或者 @empname := 'Abel'
CALL show_someone_salary(@empname);

# 2.4 带输入和输出的存储过程调用
SET @empname = 'Abel'; # 或者 @empname := 'Abel'
CALL show_someone_salary2(@empname, @empsalary);
SELECT @empsalary;

# 2.5 INOUT的存储过程调用
SET @empname = 'Abel';
CALL show_mgr_name(@empname);
SELECT @empname;


/* 
4. 存储函数的使用：
	 前面学习了很多函数，使用这些函数可以对数据进行各种处理操作，极大地提高用户对数据库的管理效率。
	 MySQL支持自定义函数，定义好之后，调用方式与调用MySQL预定义的系统函数一样。

	 
	 4.1 语法分析
		 学过的函数：LENGTH、SUBSTR、CONCAT等
		 语法格式：
				CREATE FUNCTION 函数名(参数名 参数类型, ...)
				RETURNS 返回值类型
				[characteristics ...]	
				BEGIN	
						函数体 # 函数体中肯定有RETURN语句
				END
			

			说明：
				1) 参数列表：指定参数IN、out或INOUT只对procedure是合法的，FUNCTION中总是默认为IN参数
				2) RETURNS TYPE 语句表示函数返回数据的类型
					 RETURNs子句只能对FUNCTION做指定，对函数而言这是强制的。它用来指定函数的返回类型，而且函数
					 体必须包含一个RETURN value语句。
				3) characteristic 创建函数时指定的对函数的约束。取值与创建存储过程相同。
				4) 函数体也可以用BEGIN ... END来表示SQL代码的开始和结束。如果函数体只有一条语句，也可以省略BEGIN ... END.

		4.2 调用存储函数
			  在MySQL中，存储函数的使用方法与MySQL内部函数的使用方法是一样的。换言之，用户自己定义的存
				储函数与MySQL内部函数是一个性质的。区别在于，存储函数是用户自己定义的，而内部函数是MySQL
				的开发者定义的。

				SELECT 函数名(实参列表)

		4.3 注意：
				若在创建存储函数中报错"you might want to use the less safe log_bin_trust_function_creators variable"，有两种处理方法：
				1) 加上必要的函数特性"[NOT] DETERMINISTIC" 和 "{CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA}"
				2) mysql> SET GLOBAL log_bin_trust_function_creators = 1;
 */
## 3. 存储函数
# 举例1：创建存储函数，名称为email_by_name()，参数定义为空，该函数查询Abel的email，并返回，数据类型为字符串类型。
# 1) 加上必要的函数特性"[NOT] DETERMINISTIC" 和 "{CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA}"
DELIMITER //

CREATE FUNCTION email_by_name()
RETURNS VARCHAR(25)
			  DETERMINISTIC
				CONTAINS SQL
				READS SQL DATA
BEGIN
	RETURN (SELECT email FROM employees WHERE last_name = 'Abel');

END //

DELIMITER ;

# 调用
SELECT email_by_name();

# 举例2：创建存储函数，名称为email_by_id()，参数传入emp_id，该函数查询emp_id的email，并返回，数据类型为字符串型。

# 创建函数签执行此语句，保证函数的创建会成功
# 2) SET GLOBAL log_bin_trust_function_creators = 1;
SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER //

-- CREATE FUNCTION email_by_id(IN emp_id INT) # error, 此时不可以写IN，因为FUNCTION中只可以为IN类型
CREATE FUNCTION email_by_id(emp_id INT) # 此时不可以写IN，因为FUNCTION中只可以为IN类型
RETURNS VARCHAR(25)
BEGIN
	RETURN (SELECT email FROM employees WHERE employee_id = emp_id);

END //

DELIMITER ;

# 调用
SELECT email_by_id('100');
SELECT email_by_id(100);
SELECT email_by_id(101);


# 举例3：创建存储函数count_by_id()，参数传入dept_id，该函数查询dept_id部门的员工人数，并返回，数据类型为整型。
DELIMITER //
CREATE FUNCTION count_by_id(dept_id INT)
RETURNS INT
# 因为举例2中已经调用过SET GLOBAL log_bin_trust_function_creators = 1;，因此这里可以直接创建成功
-- 			  DETERMINISTIC
-- 				CONTAINS SQL
-- 				READS SQL DATA
BEGIN
	RETURN (SELECT count(*) FROM employees WHERE department_id = dept_id);

END //
DELIMITER ;

SELECT count_by_id(50);



