## 第十章 创建和管理表 - 课后习题

## 练习一：
#1. 创建数据库test01_office,指明字符集为utf8。并在此数据库下执行下述操作
CREATE DATABASE IF NOT EXISTS test01_office CHARACTER SET 'utf8';

SHOW DATABASES;
USE test01_office;
SHOW CREATE DATABASE test01_office;

#2. 创建表dept01
/*
	字段 类型
	id INT(7)
	NAME VARCHAR(25)
*/
SHOW TABLES;

CREATE TABLE IF NOT EXISTS dept01 (
	id INT(7),
	`NAME` VARCHAR(25)
);

DESC dept01;

#3. 将表departments中的数据插入新表dept02中
CREATE TABLE IF NOT EXISTS dept02
AS
SELECT * FROM dbtest2.departments;

DESC dept02;
SELECT * FROM dept02;

#4. 创建表emp01
/*
	字段 类型
	id INT(7)
	first_name VARCHAR (25)
	last_name VARCHAR(25)
	dept_id INT(7)
*/
CREATE TABLE IF NOT EXISTS emp01 (
		id INT(7),
		first_name VARCHAR(25),
		last_name VARCHAR(25),
		dept_id INT(7)
);

DESC emp01;
SELECT * FROM emp01;

#5. 将emp01表中 列last_name的长度增加到50
ALTER TABLE emp01 
MODIFY last_name VARCHAR(50);

#6. 根据表employees创建emp02
CREATE TABLE emp02
AS
SELECT * FROM dbtest2.employees;

DESC emp02;
SHOW tables;

#7. 删除表emp01
DROP TABLE IF EXISTS emp01;

#8. 将表emp02重命名为emp01
ALTER TABLE emp02 RENAME TO emp01;
# 或者
RENAME TABLE emp02 TO emp01;

SELECT * FROM emp01;

#9.在表dept02和emp01中添加新列test_column，并检查所作的操作
DESC dept02; # department_id, department_name, manager_id, location_id
ALTER TABLE dept02 ADD COLUMN test_column VARCHAR(10);
DESC dept02; # department_id, department_name, manager_id, location_id, test_column

DESC emp01; # 此时共有11条记录
ALTER TABLE emp01 ADD COLUMN test_column VARCHAR(10);
DESC emp01; # 此时共有12条记录

#10.直接删除表emp01中的列 department_id
ALTER TABLE emp01 DROP COLUMN department_id;

## 练习二：
# 1、创建数据库 test02_market
CREATE DATABASE test02_market CHARACTER SET 'utf8';

USE test02_market;
SELECT DATABASE();
SHOW CREATE DATABASE test02_market;

# 2、创建数据表 customers
/*
		字段名		数据类型
		c_num 		int
		c_name 		varchar(50)
		c_contact varchar(50)
		c_city 		varchar(50)
		c_birth 	date
 */
CREATE TABLE IF NOT EXISTS customers (
		c_num INT,
		c_name VARCHAR(50),
		c_contact VARCHAR(50),
		c_city VARCHAR(50),
		c_birth DATE
);

DESC customers;
SHOW TABLES;

# 3、将表 customers 中的 c_contact 字段移动到 c_birth 字段后面
ALTER TABLE customers 
MODIFY c_contact VARCHAR(50) AFTER c_birth;

# 4、将 c_name 字段数据类型改为 varchar(70)
ALTER TABLE customers MODIFY c_name VARCHAR(70);

# 5、将c_contact字段改名为c_phone
ALTER TABLE customers CHANGE c_contact c_phone VARCHAR(50);

# 6、增加c_gender字段到c_name后面，数据类型为char(1)
ALTER TABLE customers ADD c_gender char(1) AFTER c_name;

# 7、将表名改为customers_info
RENAME TABLE customers TO customers_info;

SHOW tables; # customers_info

# 8、删除字段c_city
DESC customers_info;
ALTER TABLE customers_info DROP COLUMN c_city;

## 练习三：
# 1、创建数据库test03_company
CREATE DATABASE test03_company CHARACTER SET 'utf8';

USE test03_company;
SHOW CREATE DATABASE test03_company;
# 2、创建表offices
/*
			字段名			数据类型
			officeCode 	int
			city 				varchar(30)
			address 		varchar(50)
			country 		varchar(50)
			postalCode 	varchar(25)
 */
SHOW TABLES; # NULL

CREATE TABLE IF NOT EXISTS offices(
		officeCode INT,
		city 		VARCHAR(30),
		address VARCHAR(50),
		country 	VARCHAR(50),
		postalCode VARCHAR(25)
);

SHOW TABLES; # offices, 共查询出一个表

# 3、创建表employees
/*
			字段名			数据类型
			empNum 			int
			lastName 		varchar(50)
			firstName 	varchar(50)
			mobile 			varchar(25)
			code 				int
			jobTitle 		varchar(50)
			birth 			date
			note 				varchar(255)
			sex 				varchar(5)
 */
CREATE TABLE IF NOT EXISTS employees(
			empNum 			int,
			lastName 		varchar(50),
			firstName 	varchar(50),
			mobile 			varchar(25),
			`code` 			int,
			jobTitle 		varchar(50),
			birth 			date,
			note 				varchar(255),
			sex 				varchar(5)
);

DESC employees;
SHOW TABLES;

# 4、将表employees的mobile字段修改到code字段后面
ALTER TABLE employees MODIFY mobile varchar(25) AFTER code;

# 5、将表employees的birth字段改名为birthday
ALTER TABLE employees CHANGE birth birthday DATE;

# 6、修改sex字段，数据类型为char(1)
ALTER TABLE employees MODIFY sex CHAR(1);

# 7、删除字段note
ALTER TABLE employees DROP COLUMN note;

# 8、增加字段名favoriate_activity，数据类型为varchar(100)
ALTER TABLE employees ADD COLUMN favoriate_activity VARCHAR(100);

# 9、将表employees的名称修改为 employees_info
RENAME TABLE employees TO employees_info;
ALTER TABLE employees RENAME TO employees_info;

SHOW tables;
DESC employees_info;

