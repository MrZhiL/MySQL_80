## 第十二章 MySQL数据类型概述
## 本章的内容测试使用的是MySQL8.27, 但是建议使用MySQL5.7进行测试。

# 1. 关于字符集设置：character set NAME
# 创建数据库时指明字符集
CREATE DATABASE IF NOT EXISTS test04 CHARACTER SET 'utf8'

# 可以使用SHOW CREATE 命令查看
SHOW CREATE DATABASE test04;

USE test04;


# 在创建表的时候，也可以指明表的字符集
CREATE TABLE temp(
	id int
) CHARACTER SET 'utf8';

SHOW CREATE TABLE temp;

# 创建表的时候，指明表中的字段时，也可以指明字段的字符集
CREATE TABLE temp1(
	id INT,
	NAME VARCHAR(15) CHARACTER SET 'gbk'
);

SHOW CREATE TABLE temp1;
DESC temp1;


## 2. 整数类型详解
/* 2.1 整数类型一共有5类，包括TINTINT, SMALLINT, MEDIUMINT, INT(INTEGER) and BIGINT.
	 它们的区别如下所示：
	
	  整数类型			字节			有符号数取值范围										无符号数取值范围
		TINYINT		  	1 				-128~127 														0~255
		SMALLINT 			2	 				-32768~32767 												0~65535
		MEDIUMINT 		3 				-8388608~8388607 										0~16777215
		INT、INTEGER 	4 				-2147483648~2147483647 							0~4294967295
		BIGINT 				8 				-9223372036854775808~9223372036854775807 0~18446744073709551615

	 2.2 可选属性（整数类型的可选属性有三个：）
	 
	 2.2.1 M
			
			M: 表示显示宽度，M的取值范围是(0, 255)。
				 例如，int(5)：当数据宽度小于5位的时候在数字前面需要用字符填满宽度。
			   该项功能需要配合"ZEROFILL"使用，表示用"0"填满宽度，否则指定显示宽度无效。

		  如果设置了显示宽度，那么插入的数据宽度超过显示宽度限制，会不会截断或者插入失败？

			答：不会对插入的数据有任何影响，还是按照类型的实际宽度进行保存，即显示宽度与类型可以存储
					范围无关。从MySQL 8.0.17开始，整数数据类型不推荐使用显示宽度属性。

			整数数据类型在定义表结构时指定所需要的显示宽度，如果不指定，则系统为每一种类型指定默认的宽度值。
	
	 2.2.2 UNSIGNED
	
			UNSIGNED: 无符号类型（非负），所有的整数类型都有一个可选的属性UNSIGNED（无符号属性），无符号整数类型
							  的最小值为0.所以，如果需要在MySQL数据库中保存非负整数时，可以将整数类型设置为无符号类型。

		  INT类型默认显示宽度为int(11)，无符号int类型默认显示宽度为int(10)
	
	 2.2.3 ZEROFILL
			
			ZEROFILL: 0填充（如果某列是zerofill，那么mysql会自动为当前列添加unsigned属性），如果指定了zerofill只是表示不够M位时，
								用0在左边填充，如果超过M位，只要不超过数据存储范围即可。

			原来，在int(M)中，M的值跟ing(M)所占用多少存储空间并无任何关系。int(3), int(4), int(8)在磁盘上都是占用4 bytes的存储空间。
			也就是说，int(M)必须和UNSIGNED ZEROFILL一起使用才有意义。如果数值超过M位，就按照实际位数存储。只是无需再用字符0填充。

	2.3 使用场景

		TINYINT: 一般用于枚举类型，比如系统设定取值范围很小且固定的场景。

		SMALLINT: 可以用于较小范围的统计数据，比如统计工厂的固定资产库存数量等。

		MEDIUM: 用于较大整数的计算，比如车站每日的客流量等。

		INT\INTEGER: 取值范围足够大，一般不考虑超限问题，用的最多，比如商品编号。

		BIGINT: 只有当在处理特别巨大的整数时才会用到。比如双十一的交易量，大型门户网站点击量，
						证券公司衍生产品持仓等。
 */
USE test04;

CREATE TABLE test_int1(
	f1 TINYINT,
	f2 SMALLINT,
	f3 MEDIUMINT,
	f4 INT, # int或者integer都可以
	f5 BIGINT
);

DESC test_int1;

INSERT INTO test_int1(f1) VALUES (12), (-12), (-128), (127);
SELECT * FROM test_int1;

# [Err] 1264 - Out of range value for column 'f1' at row 1
INSERT INTO test_int1(f1) VALUES (128), (-129); # 当超出TINYINT的范围后，会报错

INSERT INTO test_int1(f2) VALUES (32767), (-32768), (-128), (127);


# 2.2.1 测试2：指定宽度
-- DROP TABLE test_int2;
CREATE TABLE test_int2(
	f1 INT,
	f2 INT(5), 
	# 显示宽度为5，当insert的值不足5位是，使用0填充。
	#	当使用ZEROFILL时，会自动填充为UNSIGNED ZEROFILL
	f3 INT(5) ZEROFILL 
);

DESC test_int2;

INSERT INTO test_int2(f1, f2) VALUES (123, 123), (-12345, 123456), (-123456, 12345);
INSERT INTO test_int2(f3) VALUES (1), (1234), (12345), (123456);

SELECT * FROM test_int2;
/* 命令行中的打印

	mysql> select * from test_int2;
	+------+------+--------+
	| f1   | f2   | f3     |
	+------+------+--------+
	| NULL | NULL |  00001 |
	| NULL | NULL |  01234 |
	| NULL | NULL |  12345 |
	| NULL | NULL | 123456 |
	+------+------+--------+
	4 rows in set (0.00 sec)

 */

# 2.2.2 UNSIGNED
CREATE TABLE test_int3(
	id INT UNSIGNED
);

DESC test_int3;


## 3. 浮点类型
/* 3.1 类型介绍：
		
		浮点数和定点数类型的特点是可以处理小数，我们可以把整数看成小数的一个特例。
	  因此，浮点数和定点数的是使用场景相比于整数则多了很多。MySQL支持的浮点数类型：
		分别是FOLAT，DOUBLE，REAL

			- FLOAT表示单精度浮点数（4个字节）
			- DOUBLE表示双精度浮点数（8个字节）

		  - REAL 默认就是DOUBLE。如果把SQL模式设定为启用“REAL_AS_FLOAT”，那么，MySQL就
				认为REAL是FLOAT。如果要启用“REAL_AS_FLAOT”，可以通过以下的SQL语句实现：

				SET sql_mode = "REAL_AS_FLOAT";

		问题1：FLOAT和DOUBLE类型的区别？
		问题2：为什么浮点数类型的无符号取值范围，只有相当于有符号取值范围的一半，也就是只相当于有符号数
					 取值范围大于零的部分呢？

					 MySQL存储浮点数的格式为：符号(S), 尾数(M)和阶码(E)。因此，无论有没有符号，mysql的浮点数都
					 会存储表示符号的部门。因此，所谓的无符号数取值范围，其实就有有符号数取值范围大于等于零的部门。

		3.2 精度误差说明
			
				浮点数类型有个缺陷，就是不准确。

				这里我们解释一下为什么MySQL的浮点数不够精确。比如，我们设计一个表，有price这个字段，插入值分别为
				0.47, 0.44, 0.19，我们期待的运行结果是：0.47 + 0.44 + 0.19 = 1.1。而是用SUM查询的结果为：1.09999999999
				如果将数据类型改为float，则得到的结果是1.099999940395355, 可以发现误差更大了。

				存着这样误差的原因在于：mysql对浮点数据的存储方式上。
				MySQL 用4个字节存储FLOAT类型数据，用8个字节来存储DOUBLE类型数据。无论那个，都是采用二进制的方式来进行存储的。
				比如9.625，用二进制来表达，就是1001.101，或者表达成1.001101*2^3。如果尾数不是0或5（比如9.624），我们就无法用
				一个二进制数来精确表达。进而，就只好在取值范围允许的范围内进行四舍五入。

				在编程中，如果用到浮点数，要特别主要误差问题，因为浮点数是不准确的，所有我们要避免使用’=‘来判断两个数是否相等。
				同时，在一些对精度要求比较高的项目中，千万不要使用浮点数，不然会导致结果错误，甚至造成不可挽回的损失。那么，
				Mysql有没有精准的数据类型呢？当然有，就是定点数类型：DECIMAL。
				
 */

CREATE TABLE test_double1(
	f1 float,
	f2 float(5, 2),
	f3 double,
	f4 double(5,2)
);

DESC test_double1;

INSERT INTO test_double1(f1, f2) VALUES (123.45, 123.45);

INSERT INTO test_double1(f3, f4) VALUES (123.45, 123.456);
INSERT INTO test_double1(f3, f4) VALUES (999.99, 999.989);
INSERT INTO test_double1(f3, f4) VALUES (1234.456, 999.99);
INSERT INTO test_double1(f3, f4) VALUES (1234.456, 999.999); # [Err] 1264 - Out of range value for column 'f4' at row 1
INSERT INTO test_double1(f3, f4) VALUES (1234.456, 123.456); # [SQL] # [Err] 1264 - Out of range value for column 'f4' at row 1

SELECT * FROM test_double1;


# 3.3 精度损失问题
# 测试float和double的精度
CREATE TABLE test_double2(
f1 DOUBLE
);

INSERT INTO test_double2 VALUES(0.47),(0.44),(0.19);

SELECT SUM(f1) FROM test_double2; # 1.0999999999999999

SELECT SUM(f1) = 1.1, 1.1 = 1.1 FROM test_double2;


## 4. 定点数类型
/* 类型介绍：
	 1) MySQL中的定点数类型只有DECIMAL一种类型
	
	 数据类型											字节数				含义

	 DECIMAL(M,D), DEC, NUMERIC		M+2字节				有效范围由M和D决定

	 使用DECIMAL(M,D)的方式表示高精度小数。其中，M被称为精度，D被称为标度。
	 0<=M<=65, 0<=D<=30, D < M。例如，定义DECIMAL(5,2)，表示该列取值范围是-999.99 ~ 999.99

	 2) DECIMAL(M,D) 的最大取值范围和DOUBLE类型一样，但是有效的数据范围是由M和D决定的。DECIMAL的存储空间并不是固定的，
			由精度值M决定，总共占用的存储空间为M+2个字节。也就是说，在一些对精度要求不高的场景下，比起占用同样字节长度的
			定点数，返点数表达的数值范围可以更大一些。
	
	 3) 定点数在MySQL内部是以 字符串 的形式进行存储，这就决定了它一定是精确的。

	 4) 当DECIMAL类型不指定精度和标度时，其默认为DEICMAL(10, 0)。当数据的精度超出了定点数类型的精度范围时，则MySQL
			同样会进行四舍五入处理。

	 5) 浮点数 vs 定点数
			
			* 浮点数相对于定点数的有点是在长度一定的情况下，浮点类型取值范围大，但是不精准，适用于需要取值范围大，
			  又可以容忍微小误差的科学计算场景（比如计算化学、分子建模、流体动力系等）

			* 定点数类型取值范围相对小，但是精准，没有误差，适用于对精度要求极高的场景（比如设计金额计算的场景）

 */

CREATE TABLE test_decimal1(
	f1 DECIMAL,
	f2 DECIMAL(5,2)
);

DESC test_decimal1;

# 此时存在四舍五入的情况
INSERT INTO test_decimal1(f1, f2) VALUES(123.123, 123.456);

SELECT * FROM test_decimal1;

# Out of range value for column 'f2' at row 1
INSERT INTO test_decimal1(f2) VALUES(1234.34);
 
INSERT INTO test_decimal1(f2) VALUES(999.99); 
INSERT INTO test_decimal1(f2) VALUES(999.995); 

# 举例：把test_double2表中的f1字段的数据类型修改为decimal(5,2)
ALTER TABLE test_double2 MODIFY f1 DECIMAL(5,2);

DESC test_double2;

SELECT SUM(f1) FROM test_double2; # 1.10

SELECT SUM(f1) = 1.1, 1.1 = 1.1 FROM test_double2; # 1 1
 


## 5. 位类型：BIT
/* BIT类型中存储的是二进制值，类似010110。

	 二进制字符串类型		长度		长度范围			占用空间
	 BIT(M) 						M	 			1 <= M <= 64 	约为(M + 7)/8个字节
 
	 BIT类型，如果没有指定(M)，默认是1位。这个1位，表示只能存1位的二进制值。这里(M)是表示二进制的位数，位数最小值为1，最大值为64。


	# 可以使用BIN来查看二进制, HEX查看十六进制
	SELECT BIN(f1), BIN(f2), BIN(f3), HEX(f1), HEX(f2), HEX(f3), FROM test_bit1;

	# 显示十进制：通过加0，可以以十进制的方式显示数据
	SELECT f1 + 0, f2 + 0, f3 + 0 FROM test_bit1;
 */
CREATE TABLE test_bit1(
	f1 BIT,
  f2 BIT(5),
	f3 BIT(64)
);

DESC test_bit1;

-- CREATE TABLE test_bit2(
-- 	f1 BIT,
--   f2 BIT(5),
-- 	f3 BIT(65) # [Err] 1439 - Display width out of range for column 'f3' (max = 64)
-- );

INSERT INTO test_bit1(f1) VALUES (0), (1);
INSERT INTO test_bit1(f1) VALUES (01), (01);
INSERT INTO test_bit1(f1) VALUES (10); # [Err] 1406 - Data too long for column 'f1' at row 1

INSERT INTO test_bit1(f1, f2, f3) VALUES (1, 1001, 111111000000111111);

SELECT * FROM test_bit1;
/*
mysql> SELECT * FROM test_bit1;
+------------+------------+------------+
| f1         | f2         | f3         |
+------------+------------+------------+
| 0x00       | NULL       | NULL       |
| 0x01       | NULL       | NULL       |
| 0x01       | NULL       | NULL       |
| 0x01       | NULL       | NULL       |
+------------+------------+------------+
4 rows in set (0.00 sec)
*/

INSERT INTO test_bit1(f1) VALUES (2); # [Err] 1406 - Data too long for column 'f1' at row 1

INSERT INTO test_bit1(f2) VALUES (2); # right
INSERT INTO test_bit1(f2) VALUES (31); # 11111: 最大是31
SELECT * FROM test_bit1;

INSERT INTO test_bit1(f3) VALUES (123891);
/*
mysql> SELECT * FROM test_bit1;
+------------+------------+--------------------+
| f1         | f2         | f3                 |
+------------+------------+--------------------+
| 0x00       | NULL       | NULL               |
| 0x01       | NULL       | NULL               |
| 0x01       | NULL       | NULL               |
| 0x01       | NULL       | NULL               |
| NULL       | 0x02       | NULL               |
| NULL       | 0x1F       | NULL               |
| NULL       | NULL       | 0x000000000001E3F3 |
+------------+------------+--------------------+
7 rows in set (0.00 sec)
*/


# 可以使用BIN来查看二进制, HEX查看十六进制
SELECT BIN(f1), BIN(f2), BIN(f3), HEX(f1), HEX(f2), HEX(f3), FROM test_bit1;

# 显示十进制：通过加0，可以以十进制的方式显示数据
SELECT f1 + 0, f2 + 0, f3 + 0 FROM test_bit1;