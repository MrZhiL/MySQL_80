## 第十章 创建和管理表

## 1. 创建和管理数据库
## note: DATABASE 不能改名。一些可视化工具可以改名，它是新建库，把所有表复制到新库
##			 再删除旧库完成的。

# 1.1 创建数据库
# 方式1：创建数据库
#CREATE DATABASE 数据库名; #此时创建的此数据库使用的是默认的字符集
CREATE DATABASE mytest1;

# 方式2：创建数据库并指定字符集
#CREATE DATABASE 数据库名 CHARACTER SET 字符集
CREATE DATABASE mytest2 CHARACTER SET 'gbk';
SHOW CREATE DATABASE mytest2;

# 方式4：判断数据库是否已经存在，不存在则创建数据库（推荐）
# CREATE DATABASE IF NOT EXISTS 数据库名;
CREATE DATABASE IF NOT EXISTS mytest2 CHARACTER SET 'utf8';
SHOW CREATE DATABASE mytest2;

CREATE DATABASE IF NOT EXISTS mytest3 CHARACTER SET 'utf8';
SHOW CREATE DATABASE mytest3;

# 1.2 使用数据库
# 1) 查看当前所有的数据库
SHOW DATABASES; # 有一个s，代表多个数据库

# 2) 查看当前正在使用的数据库
SELECT DATABASE() FROM DUAL;

# 3) 查看指定库下的所有表
# SHOW TABLES FROM 数据库名;
SHOW TABLES FROM dbtest2;
SHOW TABLES FROM mytest1;

# 4) 查看数据库的创建信息
# SHOW CREATE DATABASE 数据库名;
# 或者
# SHOW CREATE DATABASE 数据库名\G
SHOW CREATE DATABASE dbtest2;
SHOW CREATE DATABASE dbtest2\G # 在MySQL中不支持该语法

# 5) 使用或切换数据库
# USE 数据库名;
USE dbtest2;
USE mytest2;

# 6) 查看当前使用的数据库中的表
SHOW TABLES;

# 1.3 修改数据库
# 更改数据库字符集
#ALTER DATABASE 数据库名 CHARACTER SET 字符集; 比如:gbk, utf8
ALTER DATABASE mytest2 CHARACTER SET 'utf8';
ALTER DATABASE mytest3 CHARACTER SET 'gbk';

SHOW CREATE DATABASE mytest2;
SHOW CREATE DATABASE mytest3;

# 1.4 删除数据库(注意：删除数据库不能回滚)
# 方式1：DROP DATABASE 数据库名
CREATE DATABASE IF NOT EXISTS mytest3;
SHOW DATABASES;
DROP DATABASE mytest3; # 删除mytest3数据库, 此时如果不存在该数据库，则会报错
SHOW DATABASES;

# 方式2: 如果存在该数据库，则删除；如果不存在，则无操作直接退出
DROP DATABASE IF EXISTS mytest3;
DROP DATABASE IF EXISTS mytest2;
SHOW DATABASES;


## 2.创建表
/* 创建方式一：
	 
	 必须具备：CREATE TABLE 权限；存储空间
	 语法格式：
						CREATE TABLE [IF NOT EXISTS] 表明(
							字段1, 数据类型 [约束条件] [默认值],
							字段2, 数据类型 [约束条件] [默认值],
							字段3, 数据类型 [约束条件] [默认值],
						  ...
						  [表约束条件]
				    );
 */ 
USE dbtest2; # 该数据库中默认使用的是UTF-8
SHOW CREATE DATABASE dbtest2;

# 如果创建表示没有指明使用的字符集，则默认使用表所在的数据库的字符集
CREATE TABLE IF NOT EXISTS myemp1(
		id INT,
		emp_name VARCHAR(15), # 使用VARCHAR来定义字符串，必须在使用VARCHAR时指明其长度
		hire_data DATE
);

# 查看表结构
DESC myemp1;

# 查看数据库中表的创建信息
SHOW CREATE TABLE myemp1;

# 查看表中的数据
SELECT * FROM myemp1;

/* 创建表的 方式2：基于现有的表 
	 此时会将现有的表中的数据复制到新创建的表中
 */
CREATE TABLE myemp2 
AS 
SELECT employee_id, last_name, salary
FROM employees

DESC myemp2;
SHOW CREATE TABLE myemp2;
SELECT * FROM myemp2;

# 说明1：查询语句中字段的别名，可以作为新创建的表的字段的名称
# 说明2：此时的查询语句可以结构比较丰富，使用前面章节中讲过的SELECT语句
CREATE TABLE myemp3
AS 
SELECT e.employee_id emp_id, e.last_name lname, e.department_id, d.department_name
FROM employees e JOIN departments d
USING (department_id)

DESC myemp3;
SELECT * FROM myemp3;

# 练习1：创建一个表employees_copy，实现对employees表的复制，包括表数据
CREATE TABLE employees_copy
AS 
SELECT * FROM employees;

SELECT * FROM employees_copy;

# 练习2：创建一个表employees_blank，实现对employees表的复制，不包括表数据
# 此时只需要通过过滤条件查询出没有数据的表即可
CREATE TABLE employees_blank
AS 
SELECT * FROM employees
-- WHERE employee_id IS NULL;
WHERE 1 = 2;

SELECT * FROM employees_blank;


## 3 修改表 --> ALTER TABLE 
# 3.1 添加一个字段, 默认添加到表中的最后一个字段的位置
# ALTER TABLE 表名 [COLUMN] 字段名 字段类型 [FIRST|AFTER 字段名]；
DESC myemp1;
ALTER TABLE myemp1 ADD salary DOUBLE(10, 2);
ALTER TABLE myemp1 ADD phone_number VARCHAR(20) FIRST;
ALTER TABLE myemp1 ADD email VARCHAR(45) AFTER emp_name;
DESC myemp1;

# 3.2 修改一个字段：数据类型、长度、默认值
ALTER TABLE myemp1 
MODIFY emp_name VARCHAR(20);

ALTER TABLE myemp1 
MODIFY emp_name VARCHAR(30) DEFAULT 'hhh';

# 3.3 重命名一个字段（此时可以同时修改数据类型）
ALTER TABLE myemp1
CHANGE salary month_salary DOUBLE(10, 3);

ALTER TABLE myemp1
CHANGE email e_mail VARCHAR(50) DEFAULT 'xxx@xxx.email';

# 3.4 删除一个字段
DESC myemp1;
SELECT * FROM myemp1;
ALTER TABLE myemp1 DROP e_mail;
DESC myemp1;

CREATE TABLE myemp4
AS 
SELECT e.employee_id emp_id, e.last_name lname, e.department_id, d.department_name
FROM employees e JOIN departments d
USING (department_id);

SELECT * FROM myemp4;
# 删除myemp4中的department_id字段
ALTER TABLE myemp4 DROP department_id;
SELECT * FROM myemp4;
DESC myemp4;
ROLLBACK; # 通过ALTER修改之后的数据不可以回滚，调用该语句后删除的department_id数据没有回复

## 4. 重命名表
# 方式一：使用RENAME
# 方式二：ALTER TABLE dept RENAME [To] detail_dept; -- [T]可以省略
RENAME TABLE myemp1 To myemp;
ALTER TABLE myemp RENAME To myemp1;

## 5. 删除表
## 注意：删除表不能回滚
## 此时不只将表结构删除掉，同时删除表中的数据，释放表空间
DROP TABLE IF EXISTS myemp3;
DROP TABLE IF EXISTS myemp3;

## 6. 清空表 
# TRUNCATE TABLE 语句：删除表中所有的数据；释放表的存储空间，但是保留了表结构
# 举例：TRUNCATE TABLE detail_dept;
# note: TRUNCATE语句不能回滚，而使用DELETE语句删除数据，可以回滚
SELECT * FROM employees_copy;
TRUNCATE TABLE employees_copy;
SELECT * FROM employees_copy;
DESC employees_copy;


## 7. DCL中的 COMMIT 和 ROLLBACK 的使用
# COMMIT：提交数据。一旦执行COMMIT，则数据就永久的保存在了数据库中，意味着数据不可以回滚。
# ROLLBACK：回滚数据。一旦执行ROLLBACK，则可以实现数据的回滚。回滚到最近的一次COMMIT之后。


## 8. 对比 TRUNCATE TABLE 和 DELETE FROM
# 相同点：都可以实现对表中所有数据的删除，同时保留表结构
# 不同点：
#				   TRUNCATE TABLE，一旦执行此操作，表数据全部清楚。同时，该数据是 不可以 回滚的。
#				   DELETE FROM，一旦执行此操作，表数据可以清楚（不带WHERE则全部清楚）。同时，该数据是 可以 实现回滚的。

/*
 9. DDL 和 DML 
	
	1) DDL的操作一旦执行,就不可以回滚。SET autocommit = FALSE对DDL操作失效
		 因为在执行完DDL操作之后，一定会执行一次COMMIT。而此COMMIT操作不受SET autocommit = FLASE 影响。
	
	2) DML的操作默认情况,一旦执行,也是不可以回滚的。
		 但是，如果在执行DML之前，执行了SET autocommit = FALSE, 则执行的DML操作就可以回滚

	DDL（Data Definition Languages、数据定义语言），这些语句定义了不同的数据库、表、视图、索引等数据库对象，还可以用来创建、删除、修改数据库和数据表的结构。
	主要的语句关键字包括CREATE 、DROP 、ALTER 等。

	DML（Data Manipulation Language、数据操作语言），用于添加、删除、更新和查询数据库记录，并检查数据完整性。
	主要的语句关键字包括INSERT 、DELETE 、UPDATE 、SELECT 等。SELECT是SQL语言的基础，最为重要。

	DCL（Data Control Language、数据控制语言），用于定义数据库、表、字段、用户的访问权限和安全级别。
	主要的语句关键字包括GRANT 、REVOKE 、COMMIT 、ROLLBACK 、SAVEPOINT 等。
 */
# 演示：DELETE FROM
# 1)
COMMIT;
# 2)
DROP TABLE myemp3;
# 3)
CREATE TABLE myemp3
AS 
SELECT e.employee_id emp_id, e.last_name lname, e.department_id, d.department_name
FROM employees e JOIN departments d
USING (department_id);
# 4)
SELECT * FROM myemp3;
# 5)
SET autocommit = FALSE; # 如果想要回滚成功，则需要将autocommit 设置为 FALSE
# 6)
DELETE FROM myemp3;
# 7) 通过ROLLBACK回滚数据
ROLLBACK; # 此时可以将数据恢复
# 8)
SELECT * FROM myemp3; 

# 演示：TRUNCATE TABLE
# 1)
COMMIT;
# 2)
DROP TABLE myemp3;
# 3)
CREATE TABLE myemp3
AS 
SELECT e.employee_id emp_id, e.last_name lname, e.department_id, d.department_name
FROM employees e JOIN departments d
USING (department_id);
# 4)
SELECT * FROM myemp3;
# 5)
SET autocommit = FALSE;
# 6)
TRUNCATE TABLE myemp3;
# 7) 通过ROLLBACK回滚数据
ROLLBACK;
# 8)
SELECT * FROM myemp3; # 此时的数据为null





