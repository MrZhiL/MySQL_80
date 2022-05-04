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



