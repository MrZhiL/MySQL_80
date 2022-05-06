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



# 2.2 在创建表之后添加约束：alter table 时添加约束
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

