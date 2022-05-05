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




## 6. 日期和时间类型
/* 
	 日期和时间是重要的信息，在我们的系统中，几乎所有的数据表都用得到。原因是客户需要知道数据的时间标签，从而数据查询、统计和处理。
	
	 MySQL有多种表示日期和时间的数据类型，不同的版本可能有所差异，MySQL8.0版本支持的日期和时间类型主要有：
	 YEAR类型、TIME类型、DATE类型、DATETIIME类型和TIMESTAMP类型。 

	 YEAR类型通常用来表示年，
	 DATE类型通常用来表示年、月、日
	 TIME类型通常用来表示时、分、秒
	 DATETIME类型通常用来表示年、月、日、时、分、秒
	 TIMESTAMP类型通常用来表示带有时区的年、月、日、时、分、秒
*/

/* 6.1. YEAR类型

	 YEAR类型用来表示年份(范围：1901-2155)，在所有的日期时间类型中所占用的存储空间最小，只需要一个字节的存储空间。

	 从MySQL5.5.27开始，2位格式的YEAR以及不推荐使用。YEAR默认格式就是“YYYY”，没必要写成YEAR(4)，
	 从MySQL8.0.19开始，不推荐使用指定显示宽度的YEAR(4)数据类型。

	 YEAR中建议还是使用单引号来包裹年份，并使用4位数来表示
 */
CREATE TABLE test_year(
	f1 YEAR,   # 默认为4位
	f2 YEAR(4)
);

DESC test_year;

INSERT INTO test_year VALUES('2021', 2022);
INSERT INTO test_year VALUES('1901', 2155);
INSERT INTO test_year VALUES('1900', 2155); # [Err] 1264 - Out of range value for column 'f1' at row 1
INSERT INTO test_year VALUES('1901', 2156); # [Err] 1264 - Out of range value for column 'f2' at row 1

SELECT * FROM test_year;


INSERT INTO test_year VALUES('69', '70'); # 2069， 1970
INSERT INTO test_year VALUES('00', 0); # 2000 0
INSERT INTO test_year VALUES('0', 00); # 2000 0

/* 6.2. DATE类型
	 DATE类型表示日期，没有时间部分，格式为“YYYY-MM-DD”，其中YYYY表示年份，MM表示月份，DD表示日期。
	 需要三个字节的存储空间。在向DATE类型的字段插入数据时，同样需要满足一定的格式条件。

	 以YYYY-MM-DD格式或者YYYYMMDD格式表示字符串日期，其最小取值为1000-01-01，最大取值为9999=12-03。
	 YYYYMMDD格式会被转化为YYYY-MM-DD格式。

	 以YY-MM-DD格式或者YYYYMMDD表示的字符串日期，此格式中，年份为两位数值或字符串满足YEAR类型的格式条件为：
	 当年份取值为00到69时，会被转化为2000到2069,；当年份为70到99时，会被转化为1970到1999.ALTER
	
	 使用CURRENT_DATE()或者NOW()函数式，会插入当前系统的日期。
 */
# 创建数据表，表中只包含一个DATE类型的字段f1.
CREATE TABLE test_date(
	f1 DATE
);

DESC test_date;

INSERT INTO test_date(f1) VALUES ('2020-10-01'), ('20220101'), (20220202);
SELECT * FROM test_date;

-- INSERT INTO test_date(f1) VALUES (2021-01-01); #  Err 1292 - Incorrect date value: '2019' for column 'f1' at row 1

# 00-01-01, 000101 -> 2000-01-01
# 69-10-01, 691001 -> 2069-10-01
# 70-01-01, 700101 -> 1970-01-01
# 99-01-01, 990101 -> 1999-01-01
INSERT INTO test_date(f1) VALUES ('00-01-01'), ('000101'), ('69-10-01'), ('691001'), ('70-01-01'), ('700101'), ('99-01-01'), ('990101');
SELECT * FROM test_date;

# 使用CURRENT_DATE()或者NOW()函数式，会插入当前系统的日期。
INSERT INTO test_date(f1) VALUES (CURDATE()), (NOW());

/* 6.3. TIME类型
	 TIME类型用来表示时间，不包含日期部分。在MySQL中，需要3个字节的存储空间来存储TIME类型的数据，
	 可以使用“HH:MM:SS”格式来表示TIME类型，其中，HH表示小时，MM表示分钟，SS表示秒。

	 在MySQL中，向TIME类型的字段插入数据时，也可以使用几种不同的格式。 

	（1）可以使用带有冒号的字符串，比如' D HH:MM:SS' 、' HH:MM:SS '、' HH:MM '、' D HH:MM '、' D HH '或' SS '格式，
			 都能被正确地插入TIME类型的字段中。其中D表示天，其最小值为0，最大值为34。如果使用带有D格式的字符串插入TIME类型的
			 字段时，D会被转化为小时，计算格式为D*24+HH。当使用带有冒号并且不带D的字符串表示时间时，表示当天的时间，
			 比如12:10表示12:10:00，而不是00:12:10。 

	（2）可以使用不带有冒号的字符串或者数字，格式为' HHMMSS '或者HHMMSS 。
			 如果插入一个不合法的字符串或者数字，MySQL在存储数据时，会将其自动转化为00:00:00进行存储。
			 比如1210，MySQL会将最右边的两位解析成秒，表示00:12:10，而不是12:10:00。 

	（3）使用CURRENT_TIME() 或者NOW() ，会插入当前系统的时间。
 */
USE test04;

CREATE TABLE test_time1(
	f1 TIME
);

INSERT INTO test_time1 VALUES ('2 12:30:29'), ('12:35:29'), ('12:40'), ('2 12:40'), ('1 05'), ('45');

SELECT * FROM test_time1;

INSERT INTO test_time1 VALUES ('123520'), (124011), (1210);
INSERT INTO test_time1 VALUES (NOW()), (CURRENT_TIME());

/* 6.4. DATETIME类型
	 DATETIME类型在所有的日期时间类型中占用的存储空间最大，总共需要8 个字节的存储空间。在格式上
	 为DATE类型和TIME类型的组合，可以表示为YYYY-MM-DD HH:MM:SS ，其中YYYY表示年份，MM表示月份，
	 DD表示日期，HH表示小时，MM表示分钟，SS表示秒。

	 在向DATETIME类型的字段插入数据时，同样需要满足一定的格式条件。

	 1) 以YYYY-MM-DD HH:MM:SS 格式或者YYYYMMDDHHMMSS 格式的字符串插入DATETIME类型的字段时，
		  最小值为1000-01-01 00:00:00，最大值为9999-12-03 23:59:59。

				以YYYYMMDDHHMMSS格式的数字插入DATETIME类型的字段时，会被转化为YYYY-MM-DD HH:MM:SS格式。
			 
		2) 以YY-MM-DD HH:MM:SS 格式或者YYMMDDHHMMSS 格式的字符串插入DATETIME类型的字段时，
			 两位数的年份规则符合YEAR类型的规则，00到69表示2000到2069；70到99表示1970到1999。

		3) 使用函数CURRENT_TIMESTAMP() 和NOW() ，可以向DATETIME类型的字段插入系统的当前日期和时间。
 */
CREATE TABLE test_datetime1(
	dt datetime
);

INSERT INTO test_datetime1
VALUES ('2021-01-01 06:50:30'), ('20210101065030');

INSERT INTO test_datetime1
VALUES ('99-01-01 00:00:00'), ('990101000000'), ('20-01-01 00:00:00'), ('200101000000');

INSERT INTO test_datetime1
VALUES (20200101000000), (200101000000), (19990101000000), (990101000000);

INSERT INTO test_datetime1
VALUES (CURRENT_TIMESTAMP()), (NOW());

SELECT * FROM test_datetime1;

# `CURRENT_TIMESTAMP`()用来显示当前的时间YYYY-MM-DD HH:MM:SS
SELECT CURRENT_TIMESTAMP() FROM DUAL;

/* 6.5. TIMESTAMP 类型
	 TIMESTAMP类型也可以表示日期时间，其显示格式与DATETIME类型相同，都是YYYY-MM-DD HH:MM:SS，
	 需要4个字节的存储空间。但是TIMESTAMP存储的时间范围比DATETIME要小很多，只能存储“1970-01-01 00:00:01 UTC”
	 到“2038-01-19 03:14:07 UTC”之间的时间。其中，UTC表示世界统一时间，也叫作世界标准时间。

		 存储数据的时候需要对当前时间所在的时区进行转换，查询数据的时候再将时间转换回当前的时区。
		 因此，使用TIMESTAMP存储的同一个时间值，在不同的时区查询时会显示不同的时间。
	 
	 向TIMESTAMP类型的字段插入数据时，当插入的数据格式满足YY-MM-DD HH:MM:SS和YYMMDDHHMMSS时，
	 两位数值的年份同样符合YEAR类型的规则条件，只不过表示的时间范围要小很多。

	 如果向TIMESTAMP类型的字段插入的时间超出了TIMESTAMP类型的范围，则MySQL会抛出错误信息。
 */
CREATE TABLE test_timestamp1(
		ts TIMESTAMP
);

INSERT INTO test_timestamp1
VALUES ('1999-01-01 03:04:50'), ('19990101030405'), ('99-01-01 03:04:05'), ('990101030405');

INSERT INTO test_timestamp1 VALUES ('2020@01@01@00@00@00'), ('20@01@01@00@00@00');

INSERT INTO test_timestamp1 VALUES (CURRENT_TIMESTAMP()), (NOW());

#Incorrect datetime value
INSERT INTO test_timestamp1 VALUES ('2038-01-20 03:14:07');

SELECT * FROM test_timestamp1;


## 对比TIMESTAMP和DATETIME
/*
	TIMESTAMP和DATETIME的区别：

	1) TIMESTAMP存储空间比较小，表示的日期时间范围也比较小

	2) 底层存储方式不同，TIMESTAMP底层存储的是毫秒值，距离1970-1-1 0:0:0 0毫秒的毫秒值。

	3) 两个日期比较大小或日期计算时，TIMESTAMP更方便、更快。

	4) TIMESTAMP和时区有关。TIMESTAMP会根据用户的时区不同，显示不同的结果。而DATETIME则只能
	反映出插入时当地的时区，其他时区的人查看数据必然会有误差的。
*/
CREATE TABLE test_time(
	d1 DATETIME,
	d2 TIMESTAMP
);

INSERT INTO test_time VALUES ('2021-09-02 12:23:34', '2021-09-02 12:23:34');
INSERT INTO test_time VALUES (NOW(), NOW());

SELECT * FROM test_time;
/* 没有修改时区之前的查询
mysql> SELECT * FROM test_time;
+---------------------+---------------------+
| d1                  | d2                  |
+---------------------+---------------------+
| 2021-09-02 12:23:34 | 2021-09-02 12:23:34 |
| 2022-05-05 10:29:09 | 2022-05-05 10:29:09 |
+---------------------+---------------------+
2 rows in set (0.00 sec)
*/

# 修改当前的时区
SET time_zone = '+9:00';

SELECT * FROM test_time;
/* 修改时区之后的查询
mysql> SELECT * FROM test_time;
+---------------------+---------------------+
| d1                  | d2                  |
+---------------------+---------------------+
| 2021-09-02 12:23:34 | 2021-09-02 12:23:34 |
| 2022-05-05 10:29:09 | 2022-05-05 10:29:09 |
+---------------------+---------------------+
2 rows in set (0.00 sec)
*/

## 6.6 总结：开发中的经验
/*
	用得最多的日期时间类型，就是 DATETIME 。虽然 MySQL 也支持 YEAR（年）、 TIME（时间）、	DATE（日期），
	以及 TIMESTAMP 类型，但是在实际项目中，尽量用 DATETIME 类型。

  因为这个数据类型包括了完整的日期和时间信息，取值范围也最大，使用起来比较方便。
	毕竟，如果日期时间信息分散在好几个字段，很不容易记，而且查询的时候，SQL 语句也会更加复杂。

	此外，一般存注册时间、商品发布时间等，不建议使用DATETIME存储，而是使用时间戳，因为DATETIME虽然直观，但不便于计算。
*/


## 7. 文本字符串类型
/*
	 在实际的项目中，我们还经常遇到一种数据，就是字符串数据。
	 
	 MySQL中，文本字符串总体上分为CHAR、VARCHAR、TINYTEXT、TEXT、MEDIUMTEXT、LONGTEXT、ENUM、SET等类型
 */


/* 7.1 CHAR与VARCHAR类型
CHAR和VARCHAR类型都可以存储比较短的字符串。
-------------------------------------------------------------------------------
字符串(文本)类型	特点		长度		长度范围					占用的存储空间
-------------------------------------------------------------------------------
CHAR(M) 					固定长度	M 			0 <= M <= 255 		M个字节
VARCHAR(M) 				可变长度	M 			0 <= M <= 65535 	(实际长度 + 1) 个字节
-------------------------------------------------------------------------------

CHAR类型：
		1) CHAR(M) 类型一般需要预先定义字符串长度。如果不指定(M)，则表示长度默认是1个字符。

		2) 如果保存时，数据的实际长度比CHAR类型声明的长度小，则会在右侧填充空格以达到指定的长
			 度。当MySQL检索CHAR类型的数据时，CHAR类型的字段会去除尾部的空格。

		3) 定义CHAR类型字段时，声明的字段长度即为CHAR类型字段所占的存储空间的字节数。


VARCHAR类型：
		1) VARCHAR(M) 定义时， 必须指定长度M，否则报错。

		2) MySQL4.0版本以下，varchar(20)：指的是20字节，如果存放UTF8汉字时，只能存6个（每个汉字3字
		节） ；MySQL5.0版本以上，varchar(20)：指的是20字符。

		3) 检索VARCHAR类型的字段数据时，会保留数据尾部的空格。VARCHAR类型的字段所占用的存储空间
		为字符串实际长度加1个字节。

## 哪些情况使用CHAR或VARCHAR更好
-------------------------------------------------------------------------------
	类型				特点			空间上				时间上		适用场景
-------------------------------------------------------------------------------
	CHAR(M) 		固定长度	浪费存储空间	效率高		存储不大，速度要求高
	VARCHAR(M) 	可变长度	节省存储空间	效率低		非CHAR的情况
-------------------------------------------------------------------------------

	情况1：存储很短的信息。比如门牌号码101，201……这样很短的信息应该用char，因为varchar还要占个
				 byte用于存储信息长度，本来打算节约存储的，结果得不偿失。

	情况2：固定长度的。比如使用uuid作为主键，那用char应该更合适。因为他固定长度，varchar动态根据
				 长度的特性就消失了，而且还要占个长度信息。

	情况3：十分频繁改变的column。因为varchar每次存储都要有额外的计算，得到长度等工作，如果一个
				 非常频繁改变的，那就要有很多的精力用于计算，而这些对于char来说是不需要的。

	情况4：具体存储引擎中的情况：
			1) MyISAM 数据存储引擎和数据列：MyISAM数据表，最好使用固定长度(CHAR)的数据列代替可变长
			   度(VARCHAR)的数据列。这样使得整个表静态化，从而使数据检索更快，用空间换时间。

		  2) MEMORY 存储引擎和数据列：MEMORY数据表目前都使用固定长度的数据行存储，因此无论使用
				 CHAR或VARCHAR列都没有关系，两者都是作为CHAR类型处理的。

			3) InnoDB 存储引擎，建议使用VARCHAR类型。因为对于InnoDB数据表，内部的行存储格式并没有区
				 分固定长度和可变长度列（所有数据行都使用指向数据列值的头指针），而且主要影响性能的因素
				 是数据行使用的存储总量，由于char平均占用的空间多于varchar，所以除了简短并且固定长度的，
				 其他考虑varchar。这样节省空间，对磁盘I/O和数据存储总量比较好。
*/

# 1) CHAR类型
CREATE TABLE test_char1(
	c1 CHAR,
	c2 CHAR(5)
);

DESC test_char1;

INSERT INTO test_char1(c1) VALUES ('a');

# [Err] 1406 - Data too long for column 'c1' at row 
INSERT INTO test_char1(c1) VALUES ('ab');


INSERT INTO test_char1(c2) VALUES ('hello');
INSERT INTO test_char1(c2) VALUES ('ab');
INSERT INTO test_char1(c2) VALUES ('数据库');
INSERT INTO test_char1(c2) VALUES ('数据库哈哈');

# [Err] 1406 - Data too long for column 'c2' at row 1
INSERT INTO test_char1(c2) VALUES ('mysql数据库');

SELECT * FROM test_char1;

SELECT CONCAT(c2, '***') FROM test_char1;

# 此时读取的时候会自动吧空格去掉
INSERT INTO test_char1(c2) VALUES ('ab  ');
SELECT CHAR_LENGTH(c2) FROM test_char1;


# 2) VARCHAR类型
CREATE TABLE test_varchar1(
	NAME VARCHAR #错误
);

#Column length too big for column 'NAME' (max = 21845);
# 因为最多存储65535个字节，UTF-8中一个字符占用3个字节，因此最多可以存储65535/3=21845个字符
CREATE TABLE test_varchar2(
	NAME VARCHAR(65535) #错误
);

CREATE TABLE test_varchar3(
	NAME VARCHAR(5)
);

INSERT INTO test_varchar3 VALUES('数据库'),('数据库练习');

#Data too long for column 'NAME' at row 1
INSERT INTO test_varchar3 VALUES('MySQL数据库');

SELECT * FROM test_varchar3;


## 7.2 TEXT类型
/*
	在MySQL中，TEXT用来保存文本类型的字符串，总共包含4种类型，分别为TINYTEXT、TEXT、MEDIUMTEXT 和 LONGTEXT 类型。

	在向TEXT类型的字段保存和查询数据时，系统自动按照实际长度存储，不需要预先定义长度。这一点和VARCHAR类型相同。

	由于实际存储的长度不确定，MySQL 不允许 TEXT 类型的字段做主键。遇到这种情况，你只能采用CHAR(M)，或者 VARCHAR(M)。

	开发中的经验：
		 TEXT文本类型，可以存比较大的文本段，搜索速度稍慢，因此如果不是特别大的内容，建议使用CHAR，
		 VARCHAR来代替。还有TEXT类型不用加默认值，加了也没用。而且text和blob类型的数据删除后容易导致
		 “空洞”，使得文件碎片比较多，所以频繁使用的表不建议包含TEXT类型字段，建议单独分出去，单独用一个表。
 */
CREATE TABLE test_text(
	tx TEXT
);

# 其中空格也算一个字符，此时在保存和查询数据时，并没有删除TEXT类型的数据尾部的空格。
INSERT INTO test_text VALUES('helloworld ');
INSERT INTO test_text VALUES('hello world');

SELECT CHAR_LENGTH(tx) FROM test_text; #10


## 8. ENUM类型
/*
		ENUM类型也叫作枚举类型，ENUM类型的取值范围需要在定义字段时进行指定。设置字段值时，ENUM
		类型只允许从成员中选取单个值，不能一次选取多个值。

		其所需要的存储空间由定义ENUM类型时指定的成员个数决定。
    
    --------------------------------------------------------
		文本字符串类型	长度	长度范围					占用的存储空间
		--------------------------------------------------------
		ENUM 						L 		1 <= L <= 65535 	1或2个字节
		--------------------------------------------------------

		1) 当ENUM类型包含1~255个成员时，需要1个字节的存储空间
		2) 当ENUM类型包含256~65535个成员时，需要2个字节的存储空间
		3) ENUM类型的成员个数上限为65535.

 */
CREATE TABLE test01_enum(
	season ENUM('春','夏','秋','冬','unknow')
);

INSERT INTO test01_enum VALUES ('春'), ('冬');
INSERT INTO test01_enum VALUES ('夏'), ('秋');

# 插入时会忽略大小写
INSERT INTO test01_enum VALUES ('unknow');
INSERT INTO test01_enum VALUES ('UNKNOW');

# 可以使用1-xx的编号来插入
INSERT INTO test01_enum VALUES (1), ('3');

# 没有限制非空的情况下，可以添加null值
INSERT INTO test01_enum VALUES (NULL);

# [Err] 1265 - Data truncated for column 'season' at row 1
-- INSERT INTO test01_enum VALUES ('夏天');
-- INSERT INTO test01_enum VALUES ('天');

SELECT * FROM test01_enum;


## 9. SET类型
/*
		SET表示一个字符串对象，可以包含0个或多个成员，但成员个数的上限为64。
		设置字段值时，可以取取值范围内的0个或多个值。

		当SET类型包含的成员个数不同时，其所占用的存储空间也是不同的，具体如下：

		-----------------------------------------------------
		成员个数范围（L表示实际成员个数） 占用的存储空间
		1 <= L <= 8 											1个字节
		9 <= L <= 16 											2个字节
		17 <= L <= 24 										3个字节
		25 <= L <= 32 										4个字节
		33 <= L <= 64 										8个字节
		-----------------------------------------------------

		SET类型在存储数据时成员格式越多，其占用的存储空间越大。
		
		注意：SET类型在选取成员时，可以一次选择多个成员，这一点与ENUM类型不同。
 */ 
CREATE TABLE test_set(
	s SET('A', 'B', 'C')
);

INSERT INTO test_set (s) VALUES ('A');

# note：在进行set集合的插入时，’,‘后面不可以加空格，否则会报错
INSERT INTO test_set (s) VALUES ('A,B'), ('A,B,C');

# 插入重复的SET类成员时，MySql会自动删除重复的成员 
INSERT INTO test_set (s) VALUES ('A,B,C,A'), ('A,C,B,A');

# 向SET类型的字段插入SET成员中不存在的值时，MySQL会报错。
INSERT INTO test_set (s) VALUES ('A,B,C,D');

SELECT * FROM test_set;


## 10. 二进制字符串类型
/*
		mysql中的二进制字符串类型主要存储一些二进制数据，比如可以存储图片、音频和视频等二进制数据。

		mysql中支持的二进制字符串类型主要包括BINARY、VARBINARY、TINYBLOB、BLOB、MEDIUMBLOB和LONGBLOB类型。

10.1 BINARY与VARBINARY类型
		BINARY和VARBINARY类似于CHAR和VARCHAR，只是它们存储的是二进制字符串。

		BINARY (M)为固定长度的二进制字符串，M表示最多能存储的字节数，取值范围是0~255个字符。如果未
		指定(M)，表示只能存储1个字节。例如BINARY (8)，表示最多能存储8个字节，如果字段值不足(M)个字
		节，将在右边填充'\0'以补齐指定长度。

		VARBINARY (M)为可变长度的二进制字符串，M表示最多能存储的字节数，总字节数不能超过行的字节长
		度限制65535，另外还要考虑额外字节开销，VARBINARY类型的数据除了存储数据本身外，还需要1或2个
		字节来存储数据的字节数。VARBINARY类型必须指定(M) ，否则报错

 */
CREATE TABLE test_binary1(
f1 BINARY,  # BINARY默认长度为1
f2 BINARY(3),
-- f3 VARBINARY, # VARBINARY必须指定长度
f4 VARBINARY(10)
);

DESC test_binary1;

INSERT INTO test_binary1(f1, f2) VALUES ('a', 'abc');

SELECT * FROM test_binary1;

# [Err] 1406 - Data too long for column 'f1' at row 1
INSERT INTO test_binary1(f1) VALUES ('ab');

INSERT INTO test_binary1(f2, f4) VALUES ('ab', 'ab');

# LENGTH(2) = 3，是因为BINARY(3)设定的长度为3，
# 而VARBINARY(10)为可变长度，'ab'占用了二个字节
SELECT LENGTH(f2), LENGTH(f4) FROM test_binary1;


INSERT INTO test_binary1(f2, f4) VALUES ('a', 'abcdefg');



## 10.2 BLOB类型
/*
		BLOB是一个二进制大对象，可以容纳可变数量的数据。

		MySQL中的BLOB类型包括TINYBLOB BLOB MDEIUMBLOB和	LONGBLOB 4中类型，它们可容纳值的最大长度不同。
		可以存储一个二进制的大对象，比如图片、音频和视频等。

		需要注意的是，在实际工作中，往往不会在MySQL数据库中使用BLOB类型存储大对象数据，通常会将图片、
		音频和视频文件存储到服务器的磁盘中，并将图片、音频和视频的访问路径存储到MySQL中。

		二进制字符串类型		值的长度		长度范围												占用空间
		TINYBLOB 						L 					0 <= L <= 255 									L + 1 个字节
		BLOB 								L 					0 <= L <= 65535（相当于64KB） 	L + 2 个字节
		MEDIUMBLOB 					L 					0 <= L <= 16777215 （相当于16MB） L + 3 个字节
		LONGBLOB 						L 					0 <= L <= 4294967295（相当于4GB） L + 4 个字节
 

TEXT和BLOB的使用注意事项：
		在使用text和blob字段类型时要注意以下几点，以便更好的发挥数据库的性能。

		① BLOB和TEXT值也会引起自己的一些问题，特别是执行了大量的删除或更新操作的时候。删除这种值
		会在数据表中留下很大的" 空洞"，以后填入这些"空洞"的记录可能长度不同。为了提高性能，建议定期
		使用 OPTIMIZE TABLE 功能对这类表进行碎片整理。

		② 如果需要对大文本字段进行模糊查询，MySQL 提供了前缀索引。但是仍然要在不必要的时候避免检
		索大型的BLOB或TEXT值。例如，SELECT * 查询就不是很好的想法，除非你能够确定作为约束条件的
		WHERE子句只会找到所需要的数据行。否则，你可能毫无目的地在网络上传输大量的值。

		③ 把BLOB或TEXT列分离到单独的表中。在某些环境中，如果把这些数据列移动到第二张数据表中，可
		以让你把原数据表中的数据列转换为固定长度的数据行格式，那么它就是有意义的。这会减少主表中的
		碎片，使你得到固定长度数据行的性能优势。它还使你在主数据表上运行 SELECT * 查询的时候不会通过
		网络传输大量的BLOB或TEXT值。

*/
CREATE TABLE test_blob1(
	id INT,
	img MEDIUMBLOB
);

DESC test_blob1;

INSERT INTO test_blob1(id) VALUES (1001);

SELECT * FROM test_blob1;


## 11. JSON类型
/*
		JSON（JavaScript Object Notation）是一种轻量级的数据交换格式。简洁和清晰的层次结构使得 JSON 成
		为理想的数据交换语言。它易于人阅读和编写，同时也易于机器解析和生成，并有效地提升网络传输效
		率。JSON 可以将 JavaScript 对象中表示的一组数据转换为字符串，然后就可以在网络或者程序之间轻
		松地传递这个字符串，并在需要的时候将它还原为各编程语言所支持的数据格式。


		在MySQL 5.7中，就已经支持JSON数据类型。在MySQL 8.x版本中，JSON类型提供了可以进行自动验证的
		JSON文档和优化的存储结构，使得在MySQL中存储和读取JSON类型的数据更加方便和高效。创建数据
		表，表中包含一个JSON类型的字段 js 。
 */
CREATE TABLE test_json(
	js json
);

INSERT INTO test_json(js) 
VALUES ('{"name":"mrzhi", "age":18, "address":{"province":"beijing", "city":"beijing"}}');

SELECT * FROM test_json;

# note: 当需要检索JSON类型的字段中数据的某个具体值时，可以使用“->”和“->>”符号。
SELECT js -> '$.name' AS NAME, js -> '$.age' AS age, js -> '$.address.province' AS province, js -> '$.address.city' AS city FROM test_json;