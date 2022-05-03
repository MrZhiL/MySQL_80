### 第十一章 数据处理之增删改


# 0. 准备工作
USE dbtest2;

CREATE TABLE IF NOT EXISTS myemp5(
	id INT, 
	`name` VARCHAR(15),
	hire_date DATE,
	salary DOUBLE(10, 2)
);

DESC myemp5;
SELECT * FROM myemp5;

## 1. 插入数据
# 方式1：一条一条的添加数据

# 1) 如果没有指明添加的字段，则一定要按照声明的字段的先后顺序添加，否则将会报错
INSERT INTO myemp5 VALUES (1001, 'Tom', '2015-09-01', 5000);
# INSERT INTO myemp5 VALUES (1002, 5500, 'Jack', '2014-01-01'); # error, 插入的字段不匹配

# 2) 可以通过指明要添加的字段来插入数据（推荐）
INSERT INTO myemp5(id, hire_date, salary, `name`) VALUES (1002, '2014-01-01', 5500, 'Jack');

# note: 采用方式二时，如果没有对一些字段进行赋值，则默认为null
INSERT INTO myemp5(id, salary, `name`) VALUES (1003, 5500, 'Merry');

# 3) 同时插入多条记录(推荐)
INSERT INTO myemp5(id, hire_date, salary, `name`) 
VALUES (1004, '2016-08-07', 4900, '王五'),
			 (1005, '2016-10-11', 3800, '李四'),
			 (1006, '2014-03-16', 5200, '张三');


INSERT INTO myemp5(id, hire_date, salary, `name`) 
VALUES (1009, '2017-11-11', 4700, '孙然'),
			 (1010, 5555, '赵似然'); # 当有一个数据错误时，所有的数据均不会插入到其中

/* 小结：
			  1. VALUES 也可以谢伟VALUE，但是VALUES是标准写法
			  2. 字符和日期型数据应该包含在单引号中

				3. 一个同时插入多行记录的INSET语句等同于多个单行插入的INSERT语句，但是多行的INSERT语句
					 在处理过程中 **效率更高**。因为MySQL执行单条INSERT语句差若多行数据比使用多条INSERT语句快，
					 所以在插入多条记录时最好使用单条INSERT语句的方式插入。

				4. 使用INSERT同时插入多条记录时，MySQL会返回一些在执行单行插入时没有的额外信息，这些信息的含义如下：
					 1) Records: 表明插入的记录数
					 2) Duplicates: 表明插入时被忽略的记录，原因可能是这些记录包含了重复的主键值
					 3) Warnings: 表明有问题的数据值，例如发生数据类型转换

 */

# 方式2：将查询的结果插入到表中
/*
	INSERT还可以将SELECT语句查询的结果插入到表中，此时不需要把每一条记录的值一个一个输入，只需
	要使用一条INSERT语句和一条SELECT语句组成的组合语句即可快速地从一个或多个表中向一个表中插入
	多行。

	基本语法格式如下：

	INSERT INTO 目标表名
	(tar_column1 [, tar_column2, …, tar_columnn])
	SELECT
	(src_column1 [, src_column2, …, src_columnn])
	FROM 源表名
	[WHERE condition]


	小结：
			 1) 在INSERT语句中加入子查询
			 2) 不必书写 VALUES 子句 （重点记住）
			 3) 子查询中的值列表应与INSERT子句中的列名对应。
 */
SELECT * FROM myemp5;

DESC myemp5;

INSERT INTO myemp5(id, `name`, salary, hire_date) 
# VALUES -- 如果要将查询的结果插入到表中，则一定不可以写VALUES，否则会报错
SELECT employee_id, last_name, salary, hire_date
FROM employees
WHERE department_id IN (60, 70);

DESC myemp5;
DESC employees;

# 说明：myemp5表中要添加数据的字段不能低于employees表中查询字段的长度，否则可能会报错。
# 		  如果myemp5表中药添加数据的字段低于employees表中查询字段的长度，就有添加不成功的风险



## 2. 更新数据(修改数据)
## note: 修改数据时，是可能存在不成功的情况的，可能是由于约束的影响造成的。
/* 1) 基本语法：
						UPDATE table_name
						SET column1=value1, column2=vaule2, ..., column=valuen
						[WHERE condition]
			可以实现批量修改数据(只要不使用WHERE过滤即可)

	 2) 可以一次更新多条数据

	 3) 如果需要回滚数据，需要保证在DML前进行设置： SET AUTOCOMMIT = FALSE;

	 4) 使用WHERE子句指定 需要更新的数据
						UPDATE employees
						SET department_id = 70
						WHERE employee_id = 113;
 */

UPDATE myemp5 SET hire_date = CURDATE()
WHERE id = 1003; # 如果不指明约束条件，则会将表中的该字段的全部内容进行覆盖

UPDATE myemp5 SET hire_date = CURDATE(), salary = 6000
WHERE id = 1003; # 如果不指明约束条件，则会将表中的该字段的全部内容进行覆盖

SELECT * FROM myemp5;

# 题目：将表中姓名中包含字符a的salary提高20%
UPDATE myemp5 SET salary = salary*1.2
WHERE name LIKE '%a%';

SELECT * FROM employees WHERE employee_id = 102;

# 下面的修改操作将会失败，因为部门表里面没有10000的部门编号
UPDATE employees 
SET department_id = 10000 
WHERE employee_id = 102;

## 3. 删除数据
## 		DELETE FROM ... WHERE ...ALTER

SELECT * FROM myemp5;

DELETE FROM myemp5 WHERE id = 1006;
DELETE FROM myemp5 WHERE id = 102; # 如果数据表中不存在要删除的元素，则不会报错，而是直接结束运行
DELETE FROM myemp5 WHERE id IN (103, 104);

# 以下的命令会删除失败，因为会受到其他表中的约束
DELETE FROM departments WHERE department_id = 50; 

# 将SET AUTOCOMMIT = FALSE之后，可以进行数据的回滚
SET AUTOCOMMIT = FALSE;
ROLLBACK;

## 小节：DML操作的默认情况下，执行完之后都会自动提交数据。
##       如果希望执行完以后不自动提交数据，则需要使用SET AUTOCOMMIT = FALSE。


## 4. MySQL8新特性：计算列
/* 什么叫计算列呢？
	 
	 简单来说就是某一列的值通过别的列计算得来的。例如，a列值为1，b列值为2，c列不需要手动插入，
	 定义 a + b 的结果为c的值，那么c就是计算列，是通过别的列计算得来的。

	 在MySQL8.0中，CREATE TABLE和ALTER TABLE中都支持增加计算列。下面以CREATE TABLE为例进行讲解。

	 举例：定义数据表tb1，然后定义字段id, 字段a, 字段b和字段c，其中字段c为计算列，用于计算a+b的值。
 */
USE dbtest2;

CREATE TABLE IF NOT EXISTS tb1(
		id INT,
		a INT,
		b INT,
		c INT GENERATED ALWAYS AS (a + b) VIRTUAL # 该字段c即为计算列
);

DESC tb1;
SELECT * from tb1;

INSERT INTO tb1(a, b) VALUES (10, 20);

UPDATE tb1 SET a = 100;

## 5. 综合案例















