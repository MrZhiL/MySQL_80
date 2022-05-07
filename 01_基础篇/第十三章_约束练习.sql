## 第十三章 约束练习

## 练习1 已经存在数据库test04_emp，两张表emp2和dept2
CREATE DATABASE IF NOT EXISTS test04_emp;

USE test04_emp;

CREATE TABLE emp2(
id INT,
emp_name VARCHAR(15)
);

CREATE TABLE dept2(
id INT,
dept_name VARCHAR(15)
);

#1. 向表emp2的id列中添加PRIMARY KEY约束
DESC emp2;
ALTER TABLE emp2 ADD PRIMARY KEY (id);

#2. 向表dept2的id列中添加PRIMARY KEY约束
ALTER TABLE dept2 ADD PRIMARY KEY (id);
DESC dept2;

#3. 向表emp2中添加列dept_id，并在其中定义FOREIGN KEY约束，与之相关联的列是dept2表中的id列。
ALTER TABLE emp2 ADD COLUMN dept_id INT;
ALTER TABLE emp2 ADD CONSTRAINT fk_emp2_dept_id FOREIGN KEY (dept_id) REFERENCES dept2(id);

# 练习2：承接《第11章_数据处理之增删改》的综合案例。
# 1、创建数据库test01_library
CREATE DATABASE IF NOT EXISTS test01_library;
USE test01_library;

# 2、创建表 books，表结构如下：
CREATE TABLE IF NOT EXISTS books;

DESC books;

# 3、使用ALTER语句给books按如下要求增加相应的约束
/*
	字段名		字段说明		数据类型		主键		外键		非空		唯一		自增
	id 				书编号			INT(11) 		是			否			是			是			是
	name 			书名				VARCHAR(50) 否			否			是			否			否
	authors 	作者				VARCHAR(100)否			否			是			否			否
	price 		价格				FLOAT 			否			否			是			否			否
	pubdate 	出版日期		YEAR 				否			否			是			否			否
	note 			说明				VARCHAR(100)否			否			否			否			否
	num 			库存				INT(11) 		否			否			是			否			否
 */
# 给id添加主键和自增约束, 需要分开写
ALTER TABLE books ADD CONSTRAINT PRIMARY KEY (id);
ALTER TABLE books MODIFY id INT AUTO_INCREMENT;
DESC books;

# 给name、authors、price、pubdate、num添加非空约束,
# 此时如果表中存在为null的数据，需要先删除不合理的数据
DELETE FROM books;
ALTER TABLE books MODIFY name VARCHAR(50) NOT NULL;
ALTER TABLE books MODIFY authors VARCHAR(100) NOT NULL;
ALTER TABLE books MODIFY price float NOT NULL;
ALTER TABLE books MODIFY pubdate year NOT NULL;
ALTER TABLE books MODIFY num INT NOT NULL;


## 练习3：
#1. 创建数据库test04_company
CREATE DATABASE test04_company;
USE test04_company;

#2. 按照下表给出的表结构在test04_company数据库中创建两个数据表offices和employees
CREATE TABLE offices(
	officeCode INT(10) PRIMARY KEY,
	city VARCHAR(50) NOT NULL,
	address VARCHAR(50),
	country VARCHAR(50) NOT NULL,
	postalCode VARCHAR(50) UNIQUE
);

DESC offices;


CREATE TABLE employees(
	employeeNumber int(11) PRIMARY KEY AUTO_INCREMENT,
	lastName VARCHAR(50) NOT NULL,
	firstName VARCHAR(50) NOT NULL,
	mobile VARCHAR(25) UNIQUE,
	officeCode INT(10) NOT NULL,
	jobTitle VARCHAR(50)	NOT NULL,
	birth DATETIME NOT NULL,
	note VARCHAR(25),
	sex  VARCHAR(5),

	# 外键约束
	CONSTRAINT fk_emp_ofCode FOREIGN KEY (officeCode) REFERENCES offices(officeCode)
);

DESC employees;

#3. 将表employees的mobile字段修改到officeCode字段后面
ALTER TABLE employees MODIFY mobile VARCHAR(25) AFTER officeCode;

#4. 将表employees的birth字段改名为employee_birth
ALTER TABLE employees CHANGE birth employee_birth DATETIME;

#5. 修改sex字段，数据类型为CHAR(1)，非空约束
ALTER TABLE employees MODIFY sex CHAR(1) not NULL;

#6. 删除字段note
ALTER TABLE employees DROP COLUMN note;

#7. 增加字段名favoriate_activity，数据类型为VARCHAR(100)
ALTER TABLE employees ADD COLUMN favoriate_activity VARCHAR(100);

#8. 将表employees名称修改为employees_info
ALTER TABLE employees RENAME employees_info;
-- ALTER TABLE employees_info RENAME employees;

show tables;









