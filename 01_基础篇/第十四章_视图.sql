##第十四章 数据库对象与视图
/*
		1. 常见的数据库对象

			对象								描述
			表(TABLE) 	 				表是存储数据的逻辑单元，以行和列的形式存在，列就是字段，行就是记录
			数据字典     				就是系统表，存放数据库相关信息的表。系统表的数据通常由数据库系统维护，程序员通常不应该修改，只可查看
			约束(CONSTRAINT)		执行数据校验的规则，用于保证数据完整性的规则
			视图(VIEW) 					一个或者多个数据表里的数据的逻辑显示，视图并不存储数据
			索引(INDEX) 				用于提高查询性能，相当于书的目录
			存储过程(PROCEDURE) 用于完成一次完整的业务处理，没有返回值，但可通过传出参数将多个值传给调用环境
			存储函数(FUNCTION)	用于完成一次特定的计算，具有一个返回值
			触发器(TRIGGER)			相当于一个事件监听器，当数据库发生特定事件后，触发器被触发，完成相应的处理
 

		2. 视图概述

			视图一方面可以帮我们使用表的一部分而不是所有的表，另一方面也可以针对不同的用户制定不同的查
			询视图。比如，针对一个公司的销售人员，我们只想给他看部分数据，而某些特殊的数据，比如采购的
			价格，则不会提供给他。再比如，人员薪酬是个敏感的字段，那么只给某个级别以上的人员开放，其他
			人的查询视图中则不提供这个字段。

		2.1 视图的优点：
			
			1) 视图是一种虚拟表，本身是不具有数据的，占用甚少的内存空间，他是SQL中的一个重要概念。
		  2) 视图建立在已有表的基础上，视图赖以建立的这些表称为基表。
			3) 视图的创建和删除值影响视图本身，不影响对应的基表。但是当对视图中的数据进行增加、删除
				 和修改时，数据表中的数据会相应的发生变化，反之亦然。
			4) 向视图提供数据内容的语句为SELECT语句，可以将视图理解为存储起来的SELECT语句
				 在数据库中，视图不会保存数据，数据真正保存在数据表中。当对视图中的数据进行增加、删除和
				 修改操作时，数据表中的数据会相应的发生变化；反之亦然。
			5) 视图，是向用户提供基表数据的另一种表现形式。通常情况下，小型项目的数据库可以不使用视图，
				 但是在大型项目中，以及数据表比较复杂的情况下，视图的价值加凸显出来了，它可以帮助我们把
				 经常查询的结果集放到虚拟表中，提示使用效率。理解和使用起来都非常方便。
			
		3. 创建视图：
		1) 在CREATE VIEW语句中嵌入子查询
			 CREATE [OR REPLACE] [ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
			 VIEW 视图名称 [(字段列表)]
			 AS 查询语句
		   [WITH [CASCADED | LOCAL] CHECK OPTION]
			
		2) 精简语句
			 CREATE VIEW 视图名称 AS 查询语句

		note1: 查询语句中字段的别名会作为视图中字段的名字出现，如1.1的案例测试


		3. 不可更新的视图
			  要使视图可更新，视图中的行和底层基表中的行之间必须存在一对一的关系。另外当视图
			  定义出现如下情况时，视图不支持更新操作：

			 1) 在定义视图的时候指定了“ALGORITHM = TEMPTABLE”, 视图将不支持INSERT和DELETE操作；
			 2) 视图中不包含基表中所有被定义为非空又未指定默认值的列，视图将不支持INSERT操作；
			 3) 在定义视图的SELECT语句中使用了`JOIN联合查询`，视图将不支持INSERT和DELETE操作；
			 4) 在定义视图的SELECT语句后的字段列表中使用了数学表达式或子查询，视图将不支持INSERT，也不支持
					UPDATE使用了数学表达式、子查询的字段值；
			 5) 在定义视图的SELECT语句后的字段列表中使用DISTINCE、聚合函数、gruop by、HAVING、UNION等，视图将不支持INSERT\UPDATE、DELETE
			 6) 视图定义基于一个不可更新视图； 
			 7) 常量视图
		
		4. # note: 基于视图a、b创建了新的视图c，如果将视图a或者视图b删除了，会导致视图c的查询失败。
			 #       这样的视图c需要手动删除或修改，否则影响使用。

		5. 总结：
		优点：
				1). 操作简单
				将经常使用的查询操作定义为视图，可以使开发人员不需要关心视图对应的数据表的结构、表与表之间
				的关联关系，也不需要关心数据表之间的业务逻辑和查询条件，而只需要简单地操作视图即可，极大简
				化了开发人员对数据库的操作。

				2). 减少数据冗余
				视图跟实际数据表不一样，它存储的是查询语句。所以，在使用的时候，我们要通过定义视图的查询语
				句来获取结果集。而视图本身不存储数据，不占用数据存储的资源，减少了数据冗余。

				3). 数据安全
				MySQL将用户对数据的访问限制在某些数据的结果集上，而这些数据的结果集可以使用视图来实现。用
				户不必直接查询或操作数据表。这也可以理解为视图具有隔离性。视图相当于在用户和实际的数据表之
				间加了一层虚拟表。
				同时，MySQL可以根据权限将用户对数据的访问限制在某些视图上，用户不需要查询数据表，可以直接
				通过视图获取数据表中的信息。这在一定程度上保障了数据表中数据的安全性。

				4). 适应灵活多变的需求 当业务系统的需求发生变化后，如果需要改动数据表的结构，则工作量相对较
				大，可以使用视图来减少改动的工作量。这种方式在实际工作中使用得比较多。

				5). 能够分解复杂的查询逻辑 数据库中如果存在复杂的查询逻辑，则可以将问题进行分解，创建多个视图
				获取数据，再将创建的多个视图结合起来，完成复杂的查询逻辑。

		缺点：
				如果我们在实际数据表的基础上创建了视图，那么，如果实际数据表的结构变更了，我们就需要及时对
				相关的视图进行相应的维护。特别是嵌套的视图（就是在视图的基础上创建视图），维护会变得比较复
				杂， 可读性不好，容易变成系统的潜在隐患。因为创建视图的 SQL 查询可能会对字段重命名，也可能包
				含复杂的逻辑，这些都会增加维护的成本。

				实际项目中，如果视图过多，会导致数据库维护成本的问题。

				所以，在创建视图的时候，你要结合实际项目需求，综合考虑视图的优点和不足，这样才能正确使用视
				图，使系统整体达到最优。

*/
## 1. 创建视图

# 准备工作
CREATE DATABASE dbtest14; # 第十四章，用14来替代
USE dbtest14;

# 情况1：
# note: 此时复制表的时候，不会复制原表中的一些约束
CREATE table emps AS SELECT * FROM dbtest2.employees;
CREATE table depts AS SELECT * FROM dbtest2.departments;

SELECT * FROM emps;
SELECT * FROM depts;

DESC emps;
SHOW tables;

# 1.1 针对单表创建视图
CREATE VIEW vw_emp1
AS 
SELECT employee_id, last_name, salary FROM emps;

SELECT * FROM vw_emp1;

# 确定视图中字段名的方式1: 查询语句中字段的别名会作为视图中字段的名字出现
CREATE VIEW vw_emp2
AS 
SELECT employee_id emp_id, last_name lname, salary FROM emps;

SELECT * FROM vw_emp2;

# 确定视图中字段名的方式2: 小括号内字段个数与SELECT中的字段个数需要相同
CREATE VIEW vw_emp3(emp_id, name, monthly_sal)
AS 
SELECT employee_id emp_id, last_name lname, salary FROM emps
WHERE salary > 8000;

SELECT * FROM vw_emp3;

# 情况2：视图中的字段在基本中可能没有对对应的字段
CREATE VIEW vw_emp_avgSal
AS
SELECT department_id, AVG(salary) avg_sal
FROM emps
WHERE department_id IS NOT NULL
GROUP BY department_id;

SELECT * FROM vw_emp_avgSal;


## 1.2 针对多表
CREATE VIEW vw_emp_dept
AS
SELECT e.employee_id, e.last_name, d.department_id, d.department_name
FROM emps e JOIN depts d
USING (department_id);

SELECT * FROM vw_emp_dept;


## 1.3 利用视图对数据进行格式化
CREATE VIEW vw_emp_dept1
AS
SELECT CONCAT(e.last_name, "(", d.department_name, ")") emp_info
FROM emps e JOIN depts d
USING (department_id);

SELECT * FROM vw_emp_dept1;


## 1.4 基于视图创建视图
CREATE VIEW vw_emp4
AS
SELECT employee_id, last_name FROM vw_emp1;

SELECT * FROM vw_emp4;


## 2. 查看视图
# 语法1：查看数据库的表对象、视图对象
SHOW TABLES;

# 语法2：查看视图的结构
DESC vw_emp1;
DESC vw_emp4;

# 语法3：查看视图的属性信息
SHOW TABLE status like 'vw_emp1';
SHOW TABLE status like 'emps';
/*
mysql> show table status like 'emps'\G
*************************** 1. row ***************************
           Name: emps
         Engine: InnoDB
        Version: 10
     Row_format: Dynamic
           Rows: 107
 Avg_row_length: 153
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2022-05-07 20:13:13
    Update_time: 2022-05-07 20:13:13
     Check_time: NULL
      Collation: utf8mb4_0900_ai_ci
       Checksum: NULL
 Create_options:
        Comment:
1 row in set (0.00 sec)

mysql> show table status like 'vw_emp1'\G
*************************** 1. row ***************************
           Name: vw_emp1
         Engine: NULL
        Version: NULL
     Row_format: NULL
           Rows: NULL
 Avg_row_length: NULL
    Data_length: NULL
Max_data_length: NULL
   Index_length: NULL
      Data_free: NULL
 Auto_increment: NULL
    Create_time: 2022-05-07 20:20:58
    Update_time: NULL
     Check_time: NULL
      Collation: NULL
       Checksum: NULL
 Create_options: NULL
        Comment: VIEW
1 row in set (0.00 sec)

 */

# 语法4：查看视图的详细定义信息
SHOW CREATE VIEW vw_emp1;


## 3. 更新/删除 视图数据
# 3.1: 一般情况下，可以更新视图中的数据
SELECT * FROM vw_emp1;
SELECT * FROM emps;

# note: 更新视图的数据，会导致基表中的数据也随之修改
UPDATE vw_emp1 SET salary = 20000 WHERE employee_id = 101;
# note: 更新表的数据，会导致对应的视图中的数据也随之修改
UPDATE emps SET salary = 10000 WHERE employee_id = 101;

# 删除视图中的数据，也会导致基表中对应的数据被删除
DELETE FROM vw_emp1 WHERE employee_id = 101;
-- DELETE FROM emps WHERE employee_id = 101;

# 3.2：存在更新失败的情况
SELECT * FROM vw_emp_avgsal;

# 更新和删除均会失败：
UPDATE vw_emp_avgsal SET avg_sal = 5000 WHERE department_id = 30;
DELETE FROM vw_emp_avgsal WHERE department_id = 30;



## 4. 修改视图
DESC vw_emp1;

# 方式1：使用or replace view 修改
CREATE OR REPLACE VIEW vw_emp1
AS
SELECT employee_id, last_name, salary, email
FROM emps;

# 方式2：使用alter view修改
ALTER VIEW vw_emp1
AS
SELECT employee_id, last_name, salary, email, hire_date
FROM emps
WHERE salary > 10000;

SELECT * FROM vw_emp1;


## 5. 删除视图, DROP VIEW 视图名
# note: 基于视图a、b创建了新的视图c，如果将视图a或者视图b删除了，会导致视图c的查询失败。
#       这样的视图c需要手动删除或修改，否则影响使用。
SHOW tables;

DROP VIEW vw_emp4;

DROP VIEW IF EXISTS vw_emp3, vw_emp4;

# note: 基于视图a、b创建了新的视图c，如果将视图a或者视图b删除了，会导致视图c的查询失败。
#       这样的视图c需要手动删除或修改，否则影响使用。
CREATE VIEW vw_emp4_4
AS
SELECT * FROM vw_emp4 WHERE employee_id > 200;

DROP VIEW vw_emp4;
# [Err] 1356 - View 'dbtest14.vw_emp4_4' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them
SELECT * FROM vw_emp4_4;
