## 第十三章 约束
/* 1. 约束概述
	
	 1.1 为什么需要约束
		
		   数据完整性（Date Integrity）是指数据的精确性(Accuracy)和可靠性(Reliability)。它是防止数据库中
			 存在不符合语义规定的数据和防止因错误信息的输入输出造成无效操作或错误信息而提出的。

			 为了保证数据的完整性，SQL规范以约束的方式对表数据进行额外的条件限制。从以下四个方面考虑：
			 1) 实体完整性（Entity Integerity）: 例如，同一个表中，不能存在两条完全相同无法区分的记录
			 2) 域完整性（Domain Integerity）:例如，年龄范围0-120，姓名范围“男/女”
			 3) 引用完整性（Referential Integrity）：例如，员工所在部门，在部门表中要能找到这个部门
			 4) 用户自定义完整性（User-defined Integrity）: 例如，用域名唯一、密码不能为空等，本部门经历的工资不得高于本部门职工平均工资的5倍。


	 1.2 什么是约束
		
			约束是表级的强制规定。

			可以在创建表时规定约束（通过CREATE TABLE 语句），或者在表创建之后通过ALTER TABLE语句增加/删除约束。

	 1.3 约束的分类
			
			 1) 根据约束数据列的限制，约束可分为：
					单列约束：每个约束只约束一列
					多列约束：每个约束可约束多列数据
		
			 2) 根据约束的作用范围，约束可分为：
					列级约束：只能作用在一个列上，跟在列的定义后面
					表级约束：可以作用在多个列上，不与列一起，而是单独定义

			 3) 根据约束其的作用，约束可分为：
					* NOT NULL 非空约束，规定某个字段不能为空
					* UNIQUE 唯一约束，规定某个字段在整个表中是唯一的
					* PRIMARY KEY 主键（非空且唯一）约束
					* FORGEIGN KEY 外键约束
					* CHECK 检查约束
					* DEFAULT 默认值约束

		note；MySQL不支持check约束，但可以使用check约束，而没有任何效果。
 */

## 如何查看表中的约束
USE ;

SELECT DATABASE();

SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'employees';

DESC information_schema.TABLE_CONSTRAINTS;

## 2. 非空约束
/* 
		2.1 作用：限定某个字段/某列的值不允许为空。
		2.2 关键字：NOT NULL
		2.3 特点：
				1) 默认，所有的类型的值都可以是NULL，包括InT、FLOAT等数据类型
				2) 非空约束只能出现在表对象的列上，只能某个列单独限定非空，不能组合非空
				3) 一个表可以有很多列都分别限定了非空
				4) 字符串''不等于NULL，0也不等于NULL

		2.4 添加非空约束
				1) 建表时
						CREATE TABLE 表名称(
						字段名 数据类型,
						字段名 数据类型 NOT NULL,
						字段名 数据类型 NOT NULL
						);
				2) 建表后
						alter table 表名称 modify 字段名 数据类型 not null;

		2.5 删除非空约束
				alter table 表名称 modify 字段名 数据类型 NULL;#去掉not null，相当于修改某个非注解字段，该字段允许为空
				或
				alter table 表名称 modify 字段名 数据类型;#去掉not null，相当于修改某个非注解字段，该字段允许为空
			
 */

CREATE DATABASE myemp7 CHARACTER SET 'utf8';

USE myemp7;

SELECT DATABASE();

# 2.1 在CREATE TABLE时添加约束
CREATE TABLE test1(
	id INT NOT NULL, # 设置为非空约束
	last_name VARCHAR(15) NOT NULL,
	email VARCHAR(25),
	salary DECIMAL(10, 2)
);

DESC test1;

INSERT INTO test1(id, last_name, email, salary) VALUES (1, 'Tom', 'tom@163.com', 3400);

# [Err] 1048 - Column 'last_name' cannot be null
INSERT INTO test1(id, last_name, email, salary) VALUES (2, NULL, 'null@126.com', 4400);

# [Err] 1048 - Column 'id' cannot be null
INSERT INTO test1(id, last_name, email, salary) VALUES (NULL, 'Tom', 'tom@163.com', 3400);

# [Err] 1364 - Field 'last_name' doesn't have a default value
INSERT INTO test1(id, email) VALUES (2, 'anc@126.com');

SELECT * FROM test1;
# [Err] 1048 - Column 'last_name' cannot be null
UPDATE test1 SET last_name = NULL WHERE id = 1;

UPDATE test1 SET email = NULL WHERE id = 1; # 此时将id为1的email设置为null

-- DELETE FROM test1 WHERE email = 'tom@163.com';

# 2.2 在创建表之后添加约束：alter table 时添加和删除约束
/*
	如果要修改的表中的email列存在null值，则使用alter table添加非空约束时会报错：
	[Err] 1138 - Invalid use of NULL value

	必须将要修改的列中的null值元素全部替换掉才可以。
 */
UPDATE test1 SET email = 'tom@126.com' WHERE id = 1;

ALTER TABLE test1 MODIFY email VARCHAR(25) NOT NULL; # 将email设为不为空

ALTER TABLE test1 MODIFY email VARCHAR(25) NULL; # 将email取消不为空约束

DESC test1;


## 3. 唯一性约束
/*
		1) 作用：用来限制某个字段/某列的值不能重复。

	  2) 关键字：UNIQUE

		3) 特点：
				* 同一个表可以有多个唯一约束
				* 唯一约束可以是某一个列的值唯一，也可以多个列组合的值唯一
				* 唯一性约束允许列值为空
				* 在创建唯一约束的时候，如果不给唯一约束命名，就默认和列名相同
				* MySQL会给唯一约束的列上默认创建一个唯一索引

		4) 删除唯一性约束
				* 添加唯一性约束的列上也会自动创建唯一索引。
				* 删除唯一约束只能通过删除唯一索引的方式删除。
				* 删除时需要指定唯一索引名，唯一索引名和唯一约束名一样。
				* 如果创建唯一约束时未指定名称，如果是单列，就默认和列名相同；
				* 如果是组合列，那么默认和()中排在第一个的列名相同。也可以自定义唯一性约束名。
 */

# UNIQUE约束
# 3.1 在创建表的时候添加约束
CREATE table test_unique(
	id INT UNIQUE, # 添加唯一性约束，此时为列级约束
	last_name VARCHAR(15),
-- 	email VARCHAR(25) UNIQUE, # 列级约束
	email VARCHAR(25), # 通过表级约束添加UNIQUE
	salary DECIMAL(10, 2),

# 表级约束
CONSTRAINT uk_test_unique_email UNIQUE(email) # 全写
-- UNIQUE(email) # 简写
);

DESC test_unique;

# 在创建唯一约束的时候，如果不给唯一约束命名，就默认和列名相同
SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'test_unique';

SHOW TABLES;


# 插入数据
INSERT INTO test_unique(id, last_name, email, salary) VALUES (1, 'Tom', 'tom@163.com', 3400);

# [Err] 1062 - Duplicate entry '1' for key 'test_unique.id'
INSERT INTO test_unique(id, last_name, email, salary) VALUES (1, 'jack', 'jack@163.com', 4300);

INSERT INTO test_unique(id, last_name, email, salary) VALUES (2, 'jack', 'jack@163.com', 4300);

# 可以向声明为unique的字段上添加null值，而且可以多次添加null值
INSERT INTO test_unique(id, last_name, email, salary) VALUES (3, 'lisi', NULL, 4300); # 添加成功

INSERT INTO test_unique(id, last_name, email, salary) VALUES (4, 'merry', NULL, 4400); # 添加成功

SELECT * FROM test_unique;


## 3.2 在ALTER TABLE时添加约束(建表后指定唯一键约束)
## 此时需要表中要添加唯一性约束的键值没有重复的元素，否则会报错
DESC test_unique;
UPDATE test_unique SET salary = 4500 WHERE id = 2;

# 1) 方式1：
ALTER TABLE test_unique ADD CONSTRAINT uk_test_unique_salary UNIQUE(salary);

# 2) 方式2：
ALTER TABLE test_unique MODIFY salary DECIMAL(10, 2) UNIQUE;


## 3.3 复合约束
CREATE TABLE test_user(
	id INT,
	`name` VARCHAR(15),
	`password` VARCHAR(25),

# 表级约束
CONSTRAINT uk_test_user_name_pwd UNIQUE(`name`, `password`)
);

DESC test_user;

# 此时name和password一起构成了一个约束，只有当name和password都相同的时候才会报错
INSERT INTO test_user(id, name, password) VALUES (1, 'Tom', '123');
INSERT INTO test_user(id, name, password) VALUES (1, 'Tom1', '123');

SELECT * FROM test_user;

SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'test_user';


## 3.4 复合唯一约束案例：

# 1) 学生表
CREATE TABLE student(
	sid int, # 学号
	sname varchar(20), # 姓名
	tel char(11) unique key, # 电话
	cardid char(18) unique key # 身份证号
);

# 2) 课程表
CREATE TABLE course(
	cid int, # 课程编号
	cname varchar(20) # 课程名称
);

# 3) 选课表
create table student_course(
	id int,
	sid int,
	cid int,
	score int,
	unique key(sid, cid) # 复合唯一约束，此时constraint_name 为sid
);

# 
SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'student_course';

insert into student values(1,'张三','13710011002','101223199012015623');#成功
insert into student values(2,'李四','13710011003','101223199012015624');#成功
insert into course values(1001,'Java'),(1002,'MySQL');#成功


SELECT * FROM student;
SELECT * FROM course;

insert into student_course values
(1, 1, 1001, 89),
(2, 1, 1002, 90),
(3, 2, 1001, 88),
(4, 2, 1002, 56);#成功

SELECT * FROM student_course;

# [Err] 1062 - Duplicate entry '1-1001' for key 'student_course.sid'
insert into student_course values (5, 1, 1001, 88);#失败


## 3.5 删除UNIQUE约束
/*
	* 添加唯一性约束的列上也会自动创建唯一索引。
	* 删除唯一约束只能通过删除唯一索引的方式删除。
	* 删除时需要指定唯一索引名，唯一索引名和唯一约束名一样。
	* 如果创建唯一约束时未指定名称，如果是单列，就默认和列名相同；
	* 如果是组合列，那么默认和()中排在第一个的列名相同。也可以自定义唯一性约束名。

	# note: 可以通过show index from 表名称; 查看表的索引
	show index from test_unique;
 */
SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'test_unique';

DESC test_unique;
show index from test_unique;


# 删除Unique索引
ALTER TABLE test_unique DROP INDEX uk_test_unique_salary;

## 4. PRIMARY KEY 约束（主键约束）
/*  
		1) 作用：用来唯一标识表中的一行记录
		2) 关键字：primary key
		3) 特点：主键约束相当于唯一约束 + 非空约束的组合，主键约束列不允许重复，也不允许出现空值
				* 一个表最多只能有一个主键约束，建立主键约束可以在列级别创建，也可以在表级别创建
				* 主键约束对应着表中的一列或者多列（复合主键）
				* 如果是多列组合的复合主键约束，那么这些列都不允许为空值，并且组合的值不允许重复。
				* MySQL的主键名总是PRIMARY，就算自己命名了主键约束也没用。
				* 当创建主键约束时，系统默认会在所在的列或列组合上建立对应的主键索引（能够根据主键
				  查询的，就根据主键查询，效率更高）。如果删除了主键约束，主键约束对应的索引就自动删除了。

				* 需要注意的一点是，不要修改主键字段的值。因为主键是数据记录的唯一标识，如果修改了主键
				  的值，就有可能破坏数据的完整性。
			
		4) 添加主键约束：建表时指定主键约束(列级模式和表级模式)；建表后增加主键约束

				create table 表名称(
				字段名 数据类型 primary key, #列级模式
				字段名 数据类型,
				字段名 数据类型
				);

				create table 表名称(
				字段名 数据类型,
				字段名 数据类型,
				字段名 数据类型,
				[constraint 约束名] primary key(字段名) #表级模式
				);
 */
# 4.1 在create table时添加约束
# note: 一个表中最多只能有一个primary key
create TABLE test3(
	id INT PRIMARY KEY, # 列级约束
-- 	last_name VARCHAR(15) PRIMARY KEY, # [Err] 1068 - Multiple primary key defined
	last_name VARCHAR(15),
	salary DECIMAL(10, 2),
	email VARCHAR(25)
);

create TABLE test4(
	id INT,
	last_name VARCHAR(15),
	salary DECIMAL(10, 2),
	email VARCHAR(25),

	# 表级约束，MySQL的主键名总是PRIMARY，就算自己命名了主键约束也没用。
	CONSTRAINT pk_test4_id PRIMARY KEY(id) # 此时没有必要其名字
);


# note1: 主键约束的特征：非空且唯一，用于唯一的标识表中的一条记录。
DESC test3;
DESC test4;

# note2: MySQL的主键名总是PRIMARY，就算自己命名了主键约束也没用。
SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'test3';

SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'test4';

SHOW index FROM test3;
SHOW index FROM test4;


INSERT INTO test3(id, last_name, salary, email)
VALUES (1, 'Tom', 4500, 'tom@163.com');

# [Err] 1062 - Duplicate entry '1' for key 'test3.PRIMARY'
INSERT INTO test3(id, last_name, salary, email)
VALUES (1, 'Tom', 4500, 'tom@163.com');
# [Err] 1048 - Column 'id' cannot be null
INSERT INTO test3(id, last_name, salary, email)
VALUES (NULL, 'Tom', 4500, 'tom@163.com');
# 正确
INSERT INTO test3(id, last_name, salary, email)
VALUES (2, 'Tom', 4500, null);
# 正确
INSERT INTO test3(id, last_name, salary, email)
VALUES (3, 'Tom', 4500, null);

SELECT * FROM test3;


# 4.2 复合类型
CREATE TABLE test_user2(
	id INT,
	name varchar(15),
	passwd varchar(25),

	PRIMARY KEY(name, passwd) # 设置复合主键约束
);

SHOW INDEX FROM test_user2;

# 如果是多列组合的复合主键约束，那么这些列都不允许为空值，并且组合的值不允许重复
INSERT INTO test_user2(id, name, passwd) VALUES (1, 'Tom', '1c2d');
INSERT INTO test_user2(id, name, passwd) VALUES (1, 'Tom1', '1c2d');
INSERT INTO test_user2(id, name, passwd) VALUES (1, 'null', '1c2d'); # 正确
# [Err] 1048 - Column 'name' cannot be null
INSERT INTO test_user2(id, name, passwd) VALUES (1, null, '1c2d');


SELECT * FROM test_user2;

# 4.3 在ALTER TABLE中添加主键约束
create TABLE test5(
	id INT,
	last_name VARCHAR(15),
	salary DECIMAL(10, 2),
	email VARCHAR(25)
);

DESC test5;

ALTER TABLE test5 ADD PRIMARY KEY (id);

# 4.4 删除主键约束(在实际开发中，不会去删除表中的主键约束！！)
# 说明：删除主键约束，不需要指定主键名，因为一个表只有一个主键，删除主键约束后，非空还存在。
ALTER TABLE test5 DROP PRIMARY KEY;



## 5. 自增列：AUTO_INCREMENT
/*
		1) 作用：某个字段的值自增
		2) 关键字：auto_increament
		3) 特点和要求：
					* 一个表中最多只能有一个自增长列
					* 当需要产生唯一标识符或顺序值时，可设置自增长
					* 自增长列约束的列必须是键列（主键列，唯一键列）
					* 自增约束的列的数据类型必须是整形类型
					* 如果自增列指定了0和null，会在当前最大值的基础上自增；如果自增列手动指定了具体值，直接赋值为具体值
					* 
		4) 开发中，一旦主键作用的字段上声明有AUTO_INCREMENT，则我们在添加数据时，就不要给主键对应的字段去赋值了。

 */
# 5.1 创建auto_increament方式1：
CREATE TABLE test6(
-- 	id INT AUTO_INCREMENT, # error, auto_increament必须指定在主键列或者唯一键列上
	id INT PRIMARY KEY AUTO_INCREMENT,
-- 	last_name VARCHAR(15) UNIQUE AUTO_INCREMENT # error, 自增约束的列的数据类型必须是整形类型
	last_name VARCHAR(15)
);

show index from test6;

# 创建auto_increament方式2：
CREATE TABLE test7(
-- 	id INT AUTO_INCREMENT, # error, auto_increament必须指定在主键列或者唯一键列上
	id INT AUTO_INCREMENT,
-- 	last_name VARCHAR(15) UNIQUE AUTO_INCREMENT # error, 自增约束的列的数据类型必须是整形类型
	last_name VARCHAR(15),

	PRIMARY KEY(id)
);
show index from test7;


INSERT INTO test6(last_name) VALUES ('Tom'); # 这里连续运行了4次(1,2,3,4)
SELECT * FROM test6;

# 5.2 当我们向主键(含AUTO_INCREMENT)的字段上添加0或null时，实际上会自动的往上添加指定的id值
INSERT INTO test6(id, last_name) VALUES (0, 'Tom'); # 5
INSERT INTO test6(id, last_name) VALUES (null, 'Tom'); # 6

# 5.3 如果自增列手动指定了具体值，直接赋值为具体值
INSERT INTO test6(id, last_name) VALUES (10, 'JACK'); # id = 10
INSERT INTO test6(id, last_name) VALUES (-10, 'JACK'); # id = -10
INSERT INTO test6(last_name) VALUES ('Tom'); # id = 11


# 5.4 使用ALTER TABLE来向表中添加AUTO_INCREMENT
CREATE TABLE test8(
	id INT PRIMARY KEY,
	last_name VARCHAR(15)
);

DESC test8;

ALTER TABLE test8 MODIFY id INT AUTO_INCREMENT;

# 5.5 在ALTER TABLE中删除auto_increment
ALTER TABLE test8 MODIFY id INT;

# 5.6 MySQL 8.0新特性——自增变量的持久化
/*
	在MySQL 8.0之前，自增主键AUTO_INCREMENT的值如果大于max(primary key)+1，在MySQL重启后，会重
	置AUTO_INCREMENT=max(primary key)+1，这种现象在某些情况下会导致业务主键冲突或者其他难以发
	现的问题。 下面通过案例来对比不同的版本中自增变量是否持久化。 在MySQL 5.7版本中，测试步骤如
	下： 创建的数据表中包含自增主键的id字段，语句如下
*/

/* 在mysql5.7版本中
		## MySQL5.7中的AUTO_INCREMENT自增测试

		CREATE DATABASE dbtest12;

		USE dbtest12;

		CREATE TABLE test9(
			id INT PRIMARY KEY AUTO_INCREMENT
		);

		DESC test9;

		# 1. 连续插入4个元素
		INSERT INTO test9 VALUES (0), (0), (0), (0);

		SELECT * FROM test9; # 1,2,3,4

		# 2. 当删除id=4以后
		DELETE FROM test9 WHERE id = 4;
		SELECT * FROM test9; # 1,2,3

		# 3. 继续插入一个元素，此时会从5开始，即使删除掉4以后
		INSERT INTO test9 VALUES (0);
		SELECT * FROM test9; # 1,2,3,5

		# 4. 删除id=5的元素
		DELETE FROM test9 WHERE id = 5;
		SELECT * FROM test9; # 1,2,3

		# 5. 重启服务器，然后继续插入
		# 在DOS(管理员)中使用net stop/start mysql57重启服务器
		# 可以发现只有重启服务器之后才会继续从编号4插入
		INSERT INTO test9 VALUES (0), (0);
		SELECT * FROM test9; # 1,2,3,4,5

 */


## MySQL5.7中的AUTO_INCREMENT自增测试


## 在 mysql8.0 版本中
CREATE TABLE test9(
	id INT PRIMARY KEY AUTO_INCREMENT
);

DESC test9;

# 1. 连续插入4个元素
INSERT INTO test9 VALUES (0), (0), (0), (0);

SELECT * FROM test9; # 1,2,3,4

# 2. 当删除id=4以后
DELETE FROM test9 WHERE id = 4;
SELECT * FROM test9; # 1,2,3

# 3. 继续插入一个元素，此时会从5开始，即使删除掉4以后
INSERT INTO test9 VALUES (0);
SELECT * FROM test9; # 1,2,3,5

# 4. 删除id=5的元素
DELETE FROM test9 WHERE id = 5;
SELECT * FROM test9; # 1,2,3

# 5. 重启服务器，然后继续插入
# 在DOS(管理员)中使用net stop/start mysql80重启服务器
# 可以发现只有重启服务器之后会继续从编号5之后插入，即插入6,7
INSERT INTO test9 VALUES (0), (0);
SELECT * FROM test9; # 1,2,3,6,7

INSERT INTO test9 VALUES (4); # 此时可以继续插入编号4，从而可以续上，减少碎片化



## 6. FOREIGN KEY 约束（外键约束）
/*
		1) 作用：限定某个表的某个字段的引用完整性
			 比如：员工表的员工所在部门的选择，必须在部门表能找到对应的部分。
			
		2) 关键字：FOREIGN KEY
		3) 主表和从表/父表和子表
				
			 主表（父表）：被引用的表，被参考的表
			 从表（子表）：引用别人的表，参考别人的表
			 
			 例如：员工表的员工所在部门的这个字段的值要参考部门表：部门表时主表，员工表是从表。
			 例如：学生表、课程表、选课表：选课表的学生和课程要分别参考学生表和课程表，学生表和课程表是主表，选课表是从表。

		4) 特点： 
				a) 从表的外键列，必须引用/参考主表的主键或唯一约束的列。
					 因为被依赖/被参考的值必须是唯一的。
				b) 在创建外键约束时，如果不给外键约束命名，默认名不是列名，
					 而是自动产生一个外键名（例如student_ibfk_1），也可以指定外键约束名。
				c) 创建(CREATE)表时就指定外键约束的话，先创建主表，在创建从表。 
				d) 删表时，先删从表（或先删除外键约束），再删除主表
				e) 当主表的记录被从表参考时，主表的记录将不允许删除，
					 如果要删除数据，需要先删除从表中依赖该记录的数据，然后才可以删除主表的数据。
				f) 在“从表”中指定外键约束，并且一个表可以建立多个外键约束。
				j) 从表的外键列与主表被草考的列名字可以不相同，但是数据类型必须一样，逻辑意义一致。
					 如果类型不一样，创建子表时，就会出现错误：ERROR 1005(HY000): Can't create table'DATABASE.tablename'(errno:150)
				h) 当创建外键约束时，系统默认会在所在的列上建立对应的普通索引。但是索引名是外键的约束名。（根据外键查询效率很高）
				i) 删除外键约束后，必须手动删除对应的索引。
 */
# 7.1 在CREATE TABLE时添加

# 主表和从表；父表和子表：先创建主表dept1, 再创建从表emp1
USE myemp7;

# 1) 创建主表
CREATE TABLE dept1(
	dept_id INT,
	dept_name VARCHAR(15)
);

# 1) 创建从表
CREATE TABLE emp1(
	emp_id INT,
	emp_name VARCHAR(15),
	department_id INT,

	# 表级约束，外键约束 FOREIGN KEY
	CONSTRAINT fk_emp1_dept_id FOREIGN KEY (department_id) REFERENCES dept1(dept_id)
);

ALTER TABLE emp1 ADD PRIMARY KEY (emp_id); # 可以对emp_id添加主键约束
ALTER TABLE emp1 MODIFY emp_id INT AUTO_INCREMENT; # 添加auto_increment约束

# 运行606-613行的代码时会报错，因为主表中的dept_id没有主键约束或唯一性约束
# 调用以下代码后，继续运行606-613行代码进行测试，可以发现创建成功
ALTER TABLE dept1 ADD PRIMARY KEY (dept_id);
-- ALTER TABLE dept1 DROP PRIMARY KEY; # 删除主键约束

DESC dept1;
DESC emp1;

# 可以使用show index from xxx来查看约束
SHOW INDEX FROM dept1;
SHOW INDEX FROM emp1;

-- INSERT INTO emp1(emp_id, emp_name) VALUES (0, 'jack'); # right
-- INSERT INTO emp1(emp_name) VALUES ('jack1'); # right
-- INSERT INTO emp1(emp_name) VALUES ('jack2'); # right
-- DELETE FROM emp1;
SELECT * FROM emp1;
SELECT * FROM dept1;

# 7.2 演示外键效果
# 1) 添加失败, 因为主表中没有相应的部门编号
INSERT INTO emp1 VALUES (1001, 'Tom', 10);

# 2) 添加成功，现在主表中创建该部门编号，然后再从表中插入
INSERT INTO dept1 VALUES (10, 'IT');
INSERT INTO emp1 VALUES (1001, 'Tom', 10);

# 3) 如果直接对主表中的数据进行操作，可能会失败（因为从表关联，从而导致从表中关联的数据无法更改，除非先把从表中的数据删除）
UPDATE dept1 SET dept_id = 20 WHERE dept_id = 10;
UPDATE dept1 SET dept_name = 'HR' WHERE dept_id = 10; # 这个可以修改成功，因为从表中没有对dept_name 列进行关联
DELETE FROM dept1 WHERE dept_id = 10;


# 7.3 在ALTER TABLE时添加外键约束
# 1) 创建主表
CREATE TABLE dept2(
	dept_id INT PRIMARY KEY,
	dept_name VARCHAR(15)
);

# 2) 创建从表
CREATE TABLE emp2(
	emp_id INT PRIMARY KEY AUTO_INCREMENT,
	emp_name VARCHAR(15),
	department_id INT
);

# 3) 使用ALTER TABLE创建关联
ALTER TABLE emp2 ADD CONSTRAINT pk_emp2_dept_id FOREIGN KEY (department_id) REFERENCES dept2(dept_id);

SELECT * FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_NAME = 'emp2';


## 7.4 约束等级
/* 
	 1) Cascade方式：在父表上update/delete记录时，同步update/delete子表的匹配记录
	 2) Set null方式：在父表上update/delete记录时，将子表上匹配的记录的列设为null，
										但是要主要子表的外键列不能为not null
	 3) No action方式：如果子表中有匹配的记录，则不允许对父表对应候选键进行update/delete操作
	 4) Restrict方式：同 no action，都是立即检查外键约束
	 5) Set default方式：(在可视化工具SQLyog中可能显示空白)：父表有变更时，子表将外键列设置成一个默认的值，单Innodb不能识别。

	 note1: 如果没有指定等级，就相等于RESTRICT方式
	 note2: 对于外键约束，最好采用ON UPDATE CASCADE ON DELETE RESTRICT的方式
 */
# 1) 演示1：on update cascade on delete set NULL
# a. 创建主表和从表
CREATE TABLE dept3(
	did INT PRIMARY KEY, # 部门编号
	dname VARCHAR(5)		 # 部门名称
);

CREATE TABLE emp3(
	eid INT PRIMARY KEY, # 员工编号
	ename varchar(5),		 # 员工姓名
	deptid INT,					 # 员工所在的部门

	# 把修改操作设置为级联修改等级，把删除操作设置为set null等级
	FOREIGN KEY (deptid) REFERENCES dept3 (did) ON UPDATE CASCADE ON DELETE SET NULL
);

insert into dept3 values(1001,'教学部'), (1002, '财务部'), (1003, '咨询部');

# b. 在添加这条记录时，要求部门表有1001部门
insert into emp3 values(1,'张三',1001), (2,'李四',1001), (3,'王五',1002);

SELECT * FROM emp3;
SELECT * FROM dept3;

# c. 修改主表内容，从表也跟着修改
UPDATE dept3 SET did = 1004 WHERE did = 1002;

# d. 删除主表的记录，从表对应的字段将会修改为Null
DELETE FROM dept3 WHERE did = 1004;
/*
mysql> SELECT * FROM emp3;
+-----+-------+--------+
| eid | ename | deptid |
+-----+-------+--------+
|   1 | 张三  |   1001 |
|   2 | 李四  |   1001 |
|   3 | 王五  |   NULL |
+-----+-------+--------+
3 rows in set (0.00 sec)

	*/

# 2) 演示2：on update set null on delete cascade
create table dept4(
	did int primary key, #部门编号
	dname varchar(50) #部门名称
);

create table emp4(
	eid int primary key, #员工编号
	ename varchar(5), #员工姓名
	deptid int, #员工所在的部门

	# 把修改操作设置为set null等级，把删除操作设置为级联删除等级
	foreign key (deptid) references dept4(did) on update set null on delete cascade
);

insert into dept4 values(1001,'教学部');
insert into dept4 values(1002, '财务部');
insert into dept4 values(1003, '咨询部');

insert into emp4 values(1,'张三',1001); #在添加这条记录时，要求部门表有1001部门
insert into emp4 values(2,'李四',1001);
insert into emp4 values(3,'王五',1002);

select * from dept4;
select * from emp4;

# 修改主表，从表对应的字段设置为null
UPDATE dept4 SET did = 1004 WHERE did = 1002;

# 删除主表，从表对应的字段将会被删除
DELETE FROM dept4 WHERE did = 1001;

# 3) 演示3：on update cascade on delete cascade
CREATE TABLE dept5(
	did INT PRIMARY KEY,
	dname VARCHAR(50)
);

CREATE TABLE emp5(
	eid INT PRIMARY KEY AUTO_INCREMENT,
	ename VARCHAR(15),
	deptid INT,
	
	# 将修改操作设置为级联修改等级，把删除操作也设置为级联删除等级。
	FOREIGN KEY (deptid) REFERENCES dept5 (did) ON UPDATE CASCADE ON DELETE CASCADE
);

insert into dept5 values(1001,'教学部'), (1002, '财务部'), (1003, '咨询部');
insert into emp5 values(1,'张三',1001), (2,'李四',1001), (3,'王五',1002);

select * from dept5;
select * from emp5;

# 修改主表，从表对应的字段自动修改
update dept5 SET did = 1004 WHERE did = 1002;

# 删除主表，从表中对应的字段也自动被删除
DELETE FROM dept5 WHERE did = 1004;


# 7.5 删除外键约束
/*
		1) 第一步先查看约束名和删除外键约束
			 SELECT * FROM information_schema.table_constraints WHERE table_name = '表名称';#查看某个表的约束名

			 ALTER TABLE 从表明 DROP FOREIGN KEY 外键约束名;

		2) 第二部查看索引名和删除索引（注意，只能手动删除）

			 SHOW INDEX FROM 表名称; # 查看某个表的索引名

			 ALTER TABLE 从表名 DROP INDEX 索引名。
 */
SELECT * FROM information_schema.table_constraints WHERE table_name = 'emp5';

# 1) 可以直接使用CONSTRAINT来删除指定的索引(以下两种方式均可以)
ALTER TABLE emp5 DROP CONSTRAINT emp5_ibfk_1;
ALTER TABLE emp5 DROP PRIMARY KEY emp5_ibfk_1;

# 2) 删除索引
SHOW INDEX FROM emp5;
ALTER TABLE emp5 DROP INDEX deptid;



## 8 小结：
问题1：如果两个表之间有关系（一对一、一对多），比如：员工表和部门表（一对多），它们之间是否
一定要建外键约束？
答：不是的

问题2：建和不建外键约束有什么区别？
答：建外键约束，你的操作（创建表、删除表、添加、修改、删除）会受到限制，从语法层面受到限
制。例如：在员工表中不可能添加一个员工信息，它的部门的值在部门表中找不到。
不建外键约束，你的操作（创建表、删除表、添加、修改、删除）不受限制，要保证数据的引用完整
性，只能依靠程序员的自觉，或者是在Java程序中进行限定。例如：在员工表中，可以添加一个员工的
信息，它的部门指定为一个完全不存在的部门。

问题3：那么建和不建外键约束和查询有没有关系？
答：没有

note: 在 MySQL 里，外键约束是有成本的，需要消耗系统资源。对于大并发的 SQL 操作，有可能会不适
			合。比如大型网站的中央数据库，可能会因为外键约束的系统开销而变得非常慢。所以， MySQL 允
			许你不使用系统自带的外键约束，在应用层面完成检查数据一致性的逻辑。也就是说，即使你不
			用外键约束，也要想办法通过应用层面的附加逻辑，来实现外键约束的功能，确保数据的一致性



