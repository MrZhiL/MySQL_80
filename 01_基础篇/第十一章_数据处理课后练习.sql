## 第十一章_数据处理 课后练习

## 练习一：
#1. 创建数据库myemp6
CREATE DATABASE IF NOT EXISTS myemp6 CHARACTER SET 'utf8';

#2. 运行以下脚本创建表my_employees

USE myemp6;

CREATE TABLE my_employees(
	id INT(10),
	first_name VARCHAR(10),
	last_name VARCHAR(10),
	userid VARCHAR(10),
	salary DOUBLE(10,2)
);

CREATE TABLE users(
	id INT,
	userid VARCHAR(10),
	department_id INT
);

SELECT DATABASE();
SHOW TABLES;


#3. 显示表my_employees的结构
DESC my_employees;
DESC users;

#4. 向my_employees表中插入下列数据
-- ID FIRST_NAME LAST_NAME USERID 	SALARY
-- 1 	patel 		 Ralph 		 Rpatel 	895
-- 2 	Dancs 		 Betty 		 Bdancs 	860
-- 3 	Biri 			 Ben 			 Bbiri 		1100
-- 4 	Newman 		 Chad 		 Cnewman 	750
-- 5 	Ropeburn 	 Audrey 	 Aropebur 1550
INSERT INTO my_employees(id, first_name, last_name, userid, salary)
VALUES (1, 'pate1', 'Ralph', 'Rpatel', 895),
			 (2, 'Dancs', 'Betty', 'Bdancs', 860),
			 (3, 'Biri', 'Ben', 'Bbiri', 1100),
			 (4, 'Newman', 'Chad', 'Cnewman', 750),
			 (5, 'Ropeburn', 'Audery', 'Aropebur', 1550);

SELECT * FROM my_employees;

#5. 向users表中插入数据
-- 1 Rpatel 10
-- 2 Bdancs 10
-- 3 Bbiri 20
-- 4 Cnewman 30
-- 5 Aropebur 40
INSERT INTO users(id, userid, department_id)
VALUES (1, 'Rpatel', 10),
			 (2, 'Bdancs', 10),
			 (3, 'Bbiri', 20),
			 (4, 'Cnewman', 30),
			 (5, 'Aropebur', 40);

SELECT * FROM users;
SELECT * FROM my_employees;

#6. 将my_employees中3号员工的last_name修改为“drelxer”
UPDATE my_employees SET last_name = 'drelxer'
WHERE id = 3;

#7. 将所有工资少于900的员工的工资修改为1000
UPDATE my_employees SET salary = 1000
WHERE salary < 900;

#8. 将userid为Bbiri的user表和my_employees表的记录全部删除
DELETE FROM my_employees WHERE userid = 'Bbiri';

#9. 删除my_employees、users表所有数据
DELETE FROM my_employees;
DELETE FROM users;

#10. 检查所作的修正
SELECT * FROM users;
SELECT * FROM my_employees;

#11. 清空表my_employees
# note：使用TRUNCATE前一定要再三检查，最好提前备份下表的数据
#       由于TRUNCATE无法通过binlog回滚，因此不建议使用TRUNCATE
TRUNCATE TABLE my_employees;


## 练习二：
# 1. 使用现有数据库myemp6
USE myemp6;

# 2. 创建表格pet
/*
		字段		名字段说明		数据类型
		name 		宠物名称			VARCHAR(20)
		owner 	宠物主人			VARCHAR(20)
		species 种类					VARCHAR(20)
		sex 		性别					CHAR(1)
		birth 	出生日期			YEAR
		death 	死亡日期			YEAR
 */
CREATE TABLE IF NOT EXISTS pet(
	name VARCHAR(20),
	owner VARCHAR(20),
	species VARCHAR(20),
	sex CHAR(1),
	birth YEAR,
	death YEAR
);

SHOW TABLES;

# YEAR只显示当前的年份，而不显示月份和日期
SELECT YEAR(CURDATE()) FROM DUAL;

# 3. 添加记录
INSERT pet(name, owner, species, sex, birth, death)
VALUES ('Fluffy', 'harold', 'Cat', 'f', 2003, 2010);

INSERT pet(name, owner, species, sex, birth)
VALUES ('Claws', 'gwen', 'Cat', 'm', 2004);

INSERT pet(name, species, sex, birth)
VALUES ('Buffy', 'Dog', 'f', 2009);

INSERT pet(name, owner, species, sex, birth)
VALUES ('Fang', 'benny', 'Dog', 'm', 2000);

INSERT pet(name, owner, species, sex, birth, death)
VALUES ('Bowser', 'dian3', 'Dog', 'm', 2003, 2009);

INSERT pet(name, species, sex, birth)
VALUES ('Chirpy', 'Bird', 'f', 2008);

# DELETE FROM pet;
SELECT * FROM pet;

# 4. 添加字段:主人的生日owner_birth DATE类型
DESC pet;
ALTER TABLE pet ADD COLUMN owner_brith DATE;

# 5. 将名称为Claws的猫的主人改为kevin
UPDATE pet SET owner = 'kevin' WHERE name = 'Claws';

# 6. 将没有死的狗的主人改为duck
# 可以查询到共有3条Dog的记录，其中有两条的记录death为null
SELECT * FROM pet WHERE species = 'Dog' AND death IS NULL;

UPDATE pet SET owner = 'duck' WHERE species = 'Dog' AND death IS NULL;

# 7. 查询没有主人的宠物的名字；
SELECT * FROM pet WHERE owner IS NULL;

# 8. 查询已经死了的cat的姓名，主人，以及去世时间；
SELECT * FROM pet WHERE species = 'Cat' AND death IS NOT NULL;

# 9. 删除已经死亡的狗
DELETE FROM pet WHERE species = 'Dog' AND death IS NOT NULL;

# 10. 查询所有宠物信息
SELECT * FROM pet;


## 练习三：
# 1. 使用已有的数据库myemp6
USE myemp6;

# 2. 创建表employee，并添加记录
CREATE TABLE IF NOT EXISTS employee(
	id INT, 
	name VARCHAR(50),
	sex CHAR(2),
	tel VARCHAR(20),
	addr VARCHAR(50),
	salary DOUBLE(10,2)
);
# DROP TABLE IF EXISTS employee;
DESC employee;
SHOW TABLES;

INSERT INTO employee(id, name, sex, tel, addr, salary)
VALUES (10001, '张一一', '男', '13456789000', '山东青岛', 1001.58),
			 (10002, '刘小红', '女', '13454319000', '河北保定', 1201.21),
			 (10003, '李四', '男', '0751-1234567', '广东佛山', 1004.11),
			 (10004, '刘小强', '男', '0755-5555555', '广东深圳', 1501.23),
			 (10005, '王艳', '女', '020-1232133', '广东广州', 1405.16);

SELECT * FROM employee;

# 3. 查询出薪资在1200~1300之间的员工信息。
INSERT INTO employee(id, name, sex, tel, addr, salary)
VALUES (10006, '李四', '男', '12317888918', 'China', 1200),
			 (10007, '赵红', '女', '989891-18231', '新疆', 1300);

SELECT * FROM employee WHERE salary >= 1200 AND salary <= 1300;
SELECT * FROM employee WHERE salary BETWEEN 1200 AND 1300;

# 4. 查询出姓“刘”的员工的工号，姓名，家庭住址。
SELECT * FROM employee WHERE name LIKE '%刘%'; # 方式1：通过like语句
SELECT * FROM employee WHERE name REGEXP '刘'; # 方式2：通过正则表达式语句

# 5. 将“李四”的家庭住址改为“广东韶关”
UPDATE employee set addr = '广东韶关' WHERE name = '李四';

# 6. 查询出名字中带“小”的员工
SELECT * FROM employee WHERE name REGEXP '小';
