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

# 1.4 删除数据库
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


## 3 修改表


## 4. 重命名表

## 5. 删除表

## 6. 清空表 





