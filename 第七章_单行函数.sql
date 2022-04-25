### 第七章 单行函数

## 函数分类：单行函数 vs 多行函数

/* 1) 单行函数：
	操作数据对象；
	接收参数返回一个结果；
	**只对一行进行变换；**
	**每行返回一个结果；**
	可以嵌套；
	参数可以是一列或一个值。
*/

SELECT 'hello' || 'World' FROM DUAL; # 运行无结果

# CONCAT(str1,str2,...): 字符串拼接函数，在Oracle中为"||"连接符
SELECT CONCAT('hello','world') FROM DUAL; # 运行结果：helloworld


## 一、数值函数

## 1.1 基本函数
/*函数用法
	ABS(x) : 返回x的绝对值
	SIGN(X) : 返回X的符号。正数返回1，负数返回-1，0返回0
	PI() : 返回圆周率的值
	CEIL(x)，CEILING(x) : 返回大于或等于某个值的最小整数
	FLOOR(x) : 返回小于或等于某个值的最大整数
	LEAST(e1,e2,e3…) : 返回列表中的最小值
	GREATEST(e1,e2,e3…) : 返回列表中的最大值
	MOD(x,y) : 返回X除以Y后的余数
	RAND() : 返回0~1的随机值
	RAND(x) : 返回0~1的随机值，其中x的值用作种子值，相同的X值会产生相同的随机数
	ROUND(x) : 返回一个对x的值进行四舍五入后，最接近于X的整数
	ROUND(x,y) : 返回一个对x的值进行四舍五入后最接近X的值，并保留到小数点后面Y位
	TRUNCATE(x,y) : 返回数字x截断为y位小数的结果
	SQRT(x) : 返回x的平方根。当X的值为负数时，返回NULL
*/


SELECT ABS(-123), ABS(32), SIGN(-23), SIGN(43), PI(), 
CEIL(32.23), CEILING(32.23), CEILING(-43.34), FLOOR(32.23), FLOOR(-43.23), MOD(12, 5)
FROM DUAL;

# RAND() : 返回0~1的随机值
# RAND(x) : 返回0~1的随机值，其中x的值用作种子值，相同的X值会产生相同的随机数
SELECT RAND(), RAND(), RAND(10), RAND(10), RAND(-1), RAND(-1)
FROM DUAL;

# 产生[0,100)之间的随机数
SELECT ROUND(RAND() * 100) FROM DUAL; 

# 四舍五入，截断操作
# 输出：123	123	123.5	123.46	123.456	120	100	0
SELECT ROUND(123.4231), ROUND(123.456, 0), ROUND(123.456, 1), ROUND(123.456, 2), 
ROUND(123.456, 4), ROUND(123.456, -1), ROUND(123.456, -2), ROUND(123.456, -3)
FROM DUAL;


# 截断操作：TRUNCATE(x, y)
SELECT TRUNCATE(123.456,0), TRUNCATE(123.456,1), TRUNCATE(123.456,2), TRUNCATE(123.456,4), TRUNCATE(123.456,-1), TRUNCATE(123.456,-3)
FROM DUAL;


# 单行函数可以嵌套
SELECT TRUNCATE(ROUND(123.456, 2), 0) FROM DUAL; # 123


## 1.2 角度与弧度互换函数
/**
	RADIANS(x) 将角度转化为弧度，其中，参数x为角度值
	DEGREES(x) 将弧度转化为角度，其中，参数x为弧度值
 */
SELECT RADIANS(30),RADIANS(60),RADIANS(90),DEGREES(2*PI()),DEGREES(RADIANS(90))
FROM DUAL;

SELECT RADIANS(0), RADIANS(90), RADIANS(180), RADIANS(270), RADIANS(360)
FROM DUAL;

SELECT DEGREES(0), DEGREES(PI()), DEGREES(0.8), DEGREES(1), DEGREES(1.8)
FROM DUAL;

## 1.3 三角函数
/**
 函数用法
	SIN(x) 返回x的正弦值，其中，参数x为弧度值
	ASIN(x) 返回x的反正弦值，即获取正弦为x的值。如果x的值不在-1到1之间，则返回NULL
	COS(x) 返回x的余弦值，其中，参数x为弧度值
	ACOS(x) 返回x的反余弦值，即获取余弦为x的值。如果x的值不在-1到1之间，则返回NULL
	TAN(x) 返回x的正切值，其中，参数x为弧度值
	ATAN(x) 返回x的反正切值，即返回正切值为x的值
	ATAN2(m,n) 返回两个参数的反正切值
	COT(x) 返回x的余切值，其中，X为弧度值
	
	ATAN2(M,N)函数返回两个参数的反正切值。 与ATAN(X)函数相比，ATAN2(M,N)需要两个参数，例如有两个
	点point(x1,y1)和point(x2,y2)，使用ATAN(X)函数计算反正切值为ATAN((y2-y1)/(x2-x1))，使用ATAN2(M,N)计
	算反正切值则为ATAN2(y2-y1,x2-x1)。由使用方式可以看出，当x2-x1等于0时，ATAN(X)函数会报错，而
	ATAN2(M,N)函数则仍然可以计算。
  */
SELECT SIN(RADIANS(30)), DEGREES(ASIN(1)), DEGREES(ASIN(SIN(RADIANS(30))))
FROM DUAL;

SELECT TAN(RADIANS(45)), DEGREES(ATAN(1))
FROM DUAL;

SELECT DEGREES(ATAN2(SQRT(2), 1)) FROM DUAL; # atan(SQRT(2))


## 1.4 指数和对数函数
/**
	POW(x,y)，POWER(X,Y) 返回x的y次方
	EXP(X) 返回e的X次方，其中e是一个常数，2.718281828459045
	LN(X)，LOG(X) 返回以e为底的X的对数，当X <= 0 时，返回的结果为NULL
	LOG10(X) 返回以10为底的X的对数，当X <= 0 时，返回的结果为NULL
	LOG2(X) 返回以2为底的X的对数，当X <= 0 时，返回NULL
 */
SELECT POW(2, 4), POWER(2, 5), EXP(2)
FROM DUAL;

SELECT LN(EXP(2)), LOG(2), LOG(EXP(2)), LOG10(10), LOG10(100), LOG2(10), LOG2(2)
FROM DUAL;


## 1.5 进制间的转换
/**
	函数用法
	BIN(x) 返回x的二进制编码
	HEX(x) 返回x的十六进制编码
	OCT(x) 返回x的八进制编码
	CONV(x,f1,f2) 返回f1进制数变成f2进制数
 */
SELECT BIN(10), HEX(10), OCT(10), CONV(1110, 2, 10)
FROM DUAL;



## 二、字符串函数
/** 
	函数用法(注意：MySQL中，字符串的位置是从1开始的。)

	ASCII(S) 返回字符串S中的第一个字符的ASCII码值
	CHAR_LENGTH(s) 返回字符串s的字符数。作用与CHARACTER_LENGTH(s)相同
	LENGTH(s) 返回字符串s的字节数，和字符集有关
	CONCAT(s1,s2,......,sn) 连接s1,s2,......,sn为一个字符串
	CONCAT_WS(x,s1,s2,......,sn) 同CONCAT(s1,s2,...)函数，但是每个字符串之间要加上x
	INSERT(str, idx, len, replacestr)	将字符串str从第idx位置开始，len个字符长的子串替换为字符串replacestr
	REPLACE(str, a, b) 用字符串b替换字符串str中所有出现的字符串a
	UPPER(s) 或 UCASE(s) 将字符串s的所有字母转成大写字母
	LOWER(s) 或LCASE(s) 将字符串s的所有字母转成小写字母
	LEFT(str,n) 返回字符串str最左边的n个字符
	RIGHT(str,n) 返回字符串str最右边的n个字符
	LPAD(str, len, pad) 用字符串pad对str最左边进行填充，直到str的长度为len个字符
	RPAD(str ,len, pad) 用字符串pad对str最右边进行填充，直到str的长度为len个字符
	LTRIM(s) 去掉字符串s左侧的空格
	RTRIM(s) 去掉字符串s右侧的空格
	TRIM(s) 去掉字符串s开始与结尾的空格
	TRIM(s1 FROM s) 去掉字符串s开始与结尾的s1
	TRIM(LEADING s1	FROM s)	去掉字符串s开始处的s1
	TRIM(TRAILING s1FROM s)	去掉字符串s结尾处的s1
	REPEAT(str, n) 返回str重复n次的结果
	SPACE(n) 返回n个空格
	STRCMP(s1,s2) 比较字符串s1,s2的ASCII码值的大小
	SUBSTR(s,index,len)	返回从字符串s的index位置其len个字符，作用与SUBSTRING(s,n,len)、
	MID(s,n,len)相同
	LOCATE(substr,str) 返回字符串substr在字符串str中首次出现的位置，作用于POSITION(substr
	IN str)、INSTR(str,substr)相同。未找到，返回0
	ELT(m,s1,s2,…,sn) 返回指定位置的字符串，如果m=1，则返回s1，如果m=2，则返回s2，如果m=n，则返回sn	FIELD(s,s1,s2,…,sn) 返回字符串s在字符串列表中第一次出现的位置

	FIND_IN_SET(s1,s2) 返回字符串s1在字符串s2中出现的位置。其中，字符串s2是一个以逗号分隔的字符串
	REVERSE(s) 返回s反转后的字符串
	NULLIF(value1,value2) 比较两个字符串，如果value1与value2相等，则返回NULL，否则返回value1
 */

# ASCII 返回str中第一个字符的ASCII的位置
# CHAR_LENGTH()中用来计算字符数； 
# LENGTH()用来计算字节数，中与字符编码有关（我们采用的UTF-8存储，因此一个字符占用3个字节）
SELECT ASCII('abc'), ASCII('Abceid'), CHAR_LENGTH('hello'), CHAR_LENGTH('欢迎来到'), LENGTH('hello'), LENGTH('欢迎来到')
FROM DUAL;

# xxx worked for yyy
SELECT emp.employee_id, CONCAT(emp.last_name, ' worked for ', mgr.last_name) worked
FROM employees emp JOIN employees mgr
ON emp.manager_id = mgr.employee_id;

# CONCAT_WS(x,s1,s2,......,sn) 同CONCAT(s1,s2,...)函数，但是每个字符串之间要加上x
SELECT CONCAT_WS('-', 'hello', 'world', 'welcome to', 'beijing')
FROM DUAL;

SELECT emp.employee_id, CONCAT_WS(' - ', emp.last_name, 'worked for', mgr.last_name) worked
FROM employees emp JOIN employees mgr
ON emp.manager_id = mgr.employee_id;

# insert(str, idx, len, replacestr), note: 字符串的索引是从1开始的！
SELECT INSERT('helloworld',2, 3, 'aaaaa'), REPLACE('hello', 'll', 'mmm'), REPLACE('hello', 'lol', 'mmm'), REPLACE('hello', 'l', 'mmm')
FROM DUAL;

# LEFT、RIGHT
SELECT LEFT('hello', 2), RIGHT('hello', 3)
FROM DUAL;

# LPAD RPAD(): 用字符串pad对str最左(右)边进行填充，直到str的长度为len个字符
# LPAD ：实现右对齐效果
# RPAD ：实现左对齐效果
SELECT employee_id, last_name, LPAD(salary, 10, '*'), RPAD(salary, 10, '*')
FROM employees;

# REPEAT,
SELECT REPEAT('hello', 4), LENGTH(SPACE(5)), STRCMP('abc', 'abe')
FROM DUAL;

# SUBSTR
SELECT SUBSTR('hello', 2, 2), LOCATE('l', 'hello'), LOCATE('lll', 'hello')
FROM DUAL;


# ELT, FIELD, FIND_IN_SET(str,strlist)
SELECT ELT(2, 'a', 'b', 'c', 'd'), FIELD('gg', 'kk', 'll', 'gg', 'oo', 'gg'),
FIND_IN_SET('gg', 'kk,ll,gg,oo,gg')
FROM DUAL;


# NULLIF(expr1,expr2), 如果expr1==expr2，则返回null，否则返回expr1
SELECT employee_id, NULLIF(LENGTH(first_name), LENGTH(last_name)) "length compare"
FROm employees


## 三、时间和日期函数
## 3.1 获取日期和时间
/*
	函数用法
	CURDATE() ，CURRENT_DATE() 	返回当前日期，只包含年、月、日
	CURTIME() ， CURRENT_TIME()	返回当前时间，只包含时、	分、秒
	NOW() / SYSDATE() / CURRENT_TIMESTAMP() / LOCALTIME() /	LOCALTIMESTAMP()返回当前系统日期和时间
	UTC_DATE()	返回UTC（世界标准时间）日期
	UTC_TIME()	返回UTC（世界标准时间）	时间
 */
SELECT CURDATE(), CURRENT_DATE(), CURTIME(), CURRENT_TIME(), 
NOW(), SYSDATE(), CURRENT_TIMESTAMP(), LOCALTIME(), LOCALTIMESTAMP(),
UTC_DATE(), UTC_TIME()
FROM DUAL;

SELECT CURDATE(), CURDATE() + 0, CURTIME(), CURTIME() + 0, NOW(), NOW()+0
FROM DUAL;

## 3.2 日期和时间戳的转换
/*
	函数						用法
	UNIX_TIMESTAMP() 以UNIX时间戳的形式返回当前时间。SELECT UNIX_TIMESTAMP() -> 1634348884
	UNIX_TIMESTAMP(date) 将时间date以UNIX时间戳的形式返回。
	FROM_UNIXTIME(timestamp) 将UNIX时间戳的时间转换为普通格式的时间
 */
SELECT UNIX_TIMESTAMP(), UNIX_TIMESTAMP('2021-09-01 09:19:20'), FROM_UNIXTIME(1650870331), FROM_UNIXTIME(1630459160)
FROM DUAL;


## 3.3 获取月份、星期、星期数、天数等函数
/*
	函数						用法
	YEAR(date) / MONTH(date) / DAY(date) 返回具体的日期值
	HOUR(time) / MINUTE(time) /	SECOND(time)	返回具体的时间值
	MONTHNAME(date) 返回月份：January，...
	DAYNAME(date) 返回星期几：MONDAY，TUESDAY.....SUNDAY
	WEEKDAY(date) 返回周几，注意，周1是0，周2是1，。。。周日是6
	QUARTER(date) 返回日期对应的季度，范围为1～4
	WEEK(date) ， WEEKOFYEAR(date) 返回一年中的第几周
	DAYOFYEAR(date) 返回日期是一年中的第几天
	DAYOFMONTH(date) 返回日期位于所在月份的第几天
	DAYOFWEEK(date) 返回周几，注意：周日是1，周一是2，。。。周六是7
 */
SELECT YEAR('2022-04-01'), MONTH('2022-04-01'), DAY('2022-04-01'),
HOUR('2021-09-01 09:19:20'), MINUTE('2021-09-01 09:19:20'), SECOND('2021-09-01 09:19:20') 
FROM DUAL;

SELECT DAYNAME(NOW()), WEEKDAY(NOW()), 
QUARTER(NOW()), WEEK(NOW()), 
DAYOFYEAR(NOW()), DAYOFMONTH(NOW()), 
DAYOFWEEK(NOW())
FROM DUAL;


## 3.4 日期的操作函数
/*
	函数										用法
	EXTRACT(type FROM date) 返回指定日期中特定的部分，type指定返回的值
 */
SELECT EXTRACT(YEAR FROM NOW()), EXTRACT(MONTH FROM NOW()), EXTRACT(DAY FROM NOW()), 
EXTRACT(HOUR FROM NOW()), EXTRACT(MINUTE FROM NOW()), EXTRACT(SECOND FROM NOW()), 
EXTRACT(WEEK FROM NOW()), EXTRACT(QUARTER FROM NOW())
FROM DUAL;

SELECT EXTRACT(YEAR_MONTH FROM NOW()), EXTRACT(DAY FROM NOW()), 
EXTRACT(HOUR_MINUTE FROM NOW()), EXTRACT(SECOND_MICROSECOND FROM NOW()), 
EXTRACT(WEEK FROM NOW()), EXTRACT(QUARTER FROM NOW())
FROM DUAL;

## 3.5 时间和秒钟转换的函数
/*
	函数							用法
	TIME_TO_SEC(time)	将 time 转化为秒并返回结果值。转化的公式为：小时*3600+分钟*60+秒
	SEC_TO_TIME(seconds) 将 seconds 描述转化为包含小时、分钟和秒的时间
 */
SELECT TIME_TO_SEC(NOW()), SEC_TO_TIME(3000)
FROM DUAL;


## 3.6 计算日期和时间的函数
/* 第一组：
	函数						用法
	DATE_ADD(datetime, INTERVAL expr type)，ADDDATE(date,INTERVAL expr type)	返回与给定日期时间相差INTERVAL时间段的日期时间	
	DATE_SUB(datetime, INTERVAL expr type)，SUBDATE(date,INTERVAL expr type)	返回与date相差INTERVAL时间间隔的日期
 */
SELECT NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR), ADDDATE(NOW(), INTERVAL -1 YEAR), 
DATE_SUB(NOW(), INTERVAL 1 YEAR), SUBDATE(NOW(), INTERVAL 1 YEAR)
FROM DUAL;

SELECT DATE_ADD(NOW(), INTERVAL 1 DAY) AS col1,DATE_ADD('2021-10-21 23:32:12',INTERVAL 1 SECOND) AS col2,
ADDDATE('2021-10-21 23:32:12',INTERVAL 1 SECOND) AS col3,
DATE_ADD('2021-10-21 23:32:12',INTERVAL '1_1' MINUTE_SECOND) AS col4,
DATE_ADD(NOW(), INTERVAL -1 YEAR) AS col5, #可以是负数
DATE_ADD(NOW(), INTERVAL '1_1' YEAR_MONTH) AS col6 #需要单引号
FROM DUAL;



/* 第二组：
	函数								用法
	ADDTIME(time1,time2)	返回time1加上time2的时间。当time2为一个数字时，代表的是秒，可以为负数
	SUBTIME(time1,time2)	返回time1减去time2后的时间。当time2为一个数字时，代表的	是秒，可以为负数
	DATEDIFF(date1,date2) 返回date1 - date2的日期间隔天数
	TIMEDIFF(time1, time2) 返回time1 - time2的时间间隔
	FROM_DAYS(N) 返回从0000年1月1日起，N天以后的日期
	TO_DAYS(date) 返回日期date距离0000年1月1日的天数
	LAST_DAY(date) 返回date所在月份的最后一天的日期
	MAKEDATE(year,n) 针对给定年份与所在年份中的天数返回一个日期
	MAKETIME(hour,minute,second) 将给定的小时、分钟和秒组合成时间并返回
	PERIOD_ADD(time,n) 返回time加上n后的时间
 */
SELECT NOW(), 
ADDTIME(NOW(),20), SUBTIME(NOW(),30), SUBTIME(NOW(),'1:1:3'), DATEDIFF(NOW(),'2021-10-01'),
TIMEDIFF(NOW(), '2021-10-25 22:10:10'), FROM_DAYS(366), TO_DAYS('0000-12-25'),
LAST_DAY(NOW()), MAKEDATE(YEAR(NOW()),122), MAKETIME(10,21,23), PERIOD_ADD(20200101010101,10)
FROM DUAL;

# 举例：查询 7 天内的新增用户数有多少？
SELECT COUNT(*) as num FROM new_user WHERE TO_DAYS(NOW())-TO_DAYS(regist_time) <= 7

## 3.7 日期的格式化和解析
# 格式化：日期 -> 字符串
# 解析：  字符串 -> 日期
# 此时我们谈的是日期的显示格式化和解析，之前的SELECT YEAR('2022-04-01') FROM DUAL为隐式的格式化或解析
/*
	函数									用法
	DATE_FORMAT(date,fmt) 按照字符串fmt格式化日期date值
	TIME_FORMAT(time,fmt) 按照字符串fmt格式化时间time值
	GET_FORMAT(date_type,format_type) 返回日期字符串的显示格式
	STR_TO_DATE(str, fmt) 按照字符串fmt对str进行解析，解析为一个日期


	格式符 说明  																	格式符 说明
	%Y 4位数字表示年份														%y 表示两位数字表示年份
	%M 月名表示月份（January,....） 							%m	两位数字表示月份	（01,02,03。。。）
	%b 缩写的月名（Jan.，Feb.，....） 						%c 数字表示月份（1,2,3,...）
	%D 英文后缀表示月中的天数（1st,2nd,3rd,...）	%d 两位数字表示月中的天数(01,02...)
	%e 数字形式表示月中的天数（1,2,3,4,5.....）
	%H 两位数字表示小数，24小时制（01,02..）			%h和%I	两位数字表示小时，12小时制（01,02..）
	%k 数字形式的小时，24小时制(1,2,3) 						%l 数字形式表示小时，12小时制	（1,2,3,4....）
	%i 两位数字表示分钟（00,01,02）								%S 和%s	两位数字表示秒(00,01,02...)

	%W 一周中的星期名称（Sunday...） 							%a	一周中的星期缩写（Sun.，Mon.,Tues.，..）
	%w 以数字表示周中的天数(0=Sunday,1=Monday....)%j 以3位数字表示年中的天数(001,002...) 
  %U 以数字表示年中的第几周，（1,2,3。。）其中Sunday为周中第一天
	%u 以数字表示年中的第几周，（1,2,3。。）其中Monday为周中第一天
	%T 24小时制%r 12小时制
	%p AM或PM %% 表示%
 */

# 格式化：
SELECT DATE_FORMAT(CURDATE(), '%Y-%M-%D'), DATE_FORMAT(CURDATE(), '%Y-%m-%d'),
DATE_FORMAT(CURDATE(), '%Y-%b-%e'), DATE_FORMAT(CURDATE(), '%Y-%c-%e'), DATE_FORMAT('2022-04-01', '%Y-%c-%d')
FROM DUAL;

SELECT DATE_FORMAT(NOW(), '%H:%i:%S'), DATE_FORMAT(NOW(), '%h:%i:%S'), DATE_FORMAT(NOW(), '%k:%i:%S'),
DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%S %W %w %U %u %T %r'),
DATE_FORMAT(NOW(), '%Y-%c-%e %H:%i:%S %W %w %U %u %T %r')
FROM DUAL;

# 解析：格式化的逆过程
SELECT STR_TO_DATE('2022-04-25 16:01:29 Monday 1 17 17 16:01:29 04:01:29 PM', '%Y-%m-%d %H:%i:%S %W %w %U %u %T %r') time,
STR_TO_DATE('2022-4-25 16:05:49 Monday 1 17 17 16:05:49 04:05:49 PM', '%Y-%c-%e %H:%i:%S %W %w %U %u %T %r') time2
FROM DUAL;

# 需要使用%H表示24小时制才行
SELECT DATE_FORMAT(NOW(),'%Y-%M-%D %h:%i:%S %W %w %T %r') time, # 2022-April-25th 04:09:45 Monday 1 16:09:45 04:09:45 PM
STR_TO_DATE('2022-April-25th 04:09:45 Monday 1 16:09:45 04:09:45 PM', '%Y-%M-%D %H:%i:%S %W %w %T %r')
FROM DUAL;


SELECT STR_TO_DATE('2022-April-25th 16:09:45 Monday 1 16:09:45 04:09:45 PM', '%Y-%M-%D %h:%i:%S %W %w %T %r') time1,
STR_TO_DATE('2022-April-25th 04:07:28 Monday 1 04:07:28 PM', '%Y-%M-%D %h:%i:%S %W %w %r') time2, #error 
STR_TO_DATE('2022-April-25th 04:07:28 Monday 1 16:07:28', '%Y-%M-%D %h:%i:%S %W %w %T') time3, #error
STR_TO_DATE('2022-April-25th 04:07:28 Monday 1', '%Y-%M-%D %h:%i:%S %W %w') time4
FROM DUAL;

# %h 和 %H 的区别 : %h为12小时制，%H为24小时制
SELECT DATE_FORMAT('2022-04-25 02:01:29', '%H:%i:%S'),  DATE_FORMAT('2022-04-25 02:01:29', '%h:%i:%S'),
DATE_FORMAT('2022-04-25 14:01:29', '%H:%i:%S'),  DATE_FORMAT('2022-4-25 14:01:29', '%h:%i:%S'),
DATE_FORMAT(NOW(), '%H:%i:%S'),  DATE_FORMAT(NOW(), '%h:%i:%S')
FROM DUAL;


# GET_GFORMAT()
SELECT GET_FORMAT(DATE, 'USA'), GET_FORMAT(DATE, 'ISO'),
DATE_FORMAT(CURDATE(), GET_FORMAT(DATE, 'USA'))
FROM DUAL;


## 四、流程控制函数
/*
  流程控制函数可以根据不同的条件，执行不同的处理流程，可以在SQL语句中实现不同的条件选择。
	MySQL流程处理函数主要包括IF(), IFNULL() 和 CASE() 函数

	函数															用法
	IF(value,value1,value2)						如果value的值为TRUE，返回value1，否则返回value2
	IFNULL(value1, value2)						如果value1不为NULL，返回value1，否则返回value2
	CASE WHEN 条件1 THEN 结果1 WHEN 条件2 THEN 结果2	.... [ELSE resultn] END    :相当于Java的if...else if...else...
	
	CASE expr WHEN 常量值1 THEN 值1 WHEN 常量值1 THEN	值1 .... [ELSE 值n] END	   :相当于Java的switch...case...
 */

SELECT IF(1 > 0, 'true', 'false'),
IFNULL(1, 2), IFNULL(NULL, 0)
FROM DUAL;

SELECT last_name, salary, IF(salary >= 6000, 'high salary', 'low salary') details
FROM employees;


SELECT last_name, commission_pct, IFNULL(commission_pct, 0) details,
salary * 12 * (1 + IFNULL(commission_pct,0)) 'annual_sal'
FROM employees;

# CASE WHEN ... THEN ... WHEN ... THEN ... END
SELECT last_name, salary, CASE WHEN salary >= 15000 THEN 'high salary'
															 WHEN salary >= 10000 THEN 'middle salary'
															 WHEN salary >= 8000  THEN 'low-middle salary'
															 ELSE 'low salary' END "salary details"
FROM employees;

# 可以省略掉ELSE ..., 此时ELSE中存在的数据会返回NULL
SELECT last_name, salary, CASE WHEN salary >= 15000 THEN 'high salary'
															 WHEN salary >= 10000 THEN 'middle salary'
															 WHEN salary >= 8000  THEN 'low-middle salary'
															 END "salary details"
FROM employees;

# CASE expr WHEN ... THEN ... WHEN ... THEN ... END
SELECT e.last_name, e.department_id, CASE e.department_id WHEN 30 THEN CONCAT(d.department_name, 1)
																 WHEN 50 THEN CONCAT(d.department_name, 2)
																 WHEN 60 THEN CONCAT(d.department_name, 3)
																 WHEN 90 THEN CONCAT(d.department_name, 4)
																 WHEN 100 THEN CONCAT(d.department_name, 5)
																 ELSE d.department_name END 'department_name'
FROM employees e LEFT JOIN departments d
USING (department_id);

# 练习：查询部门号为 10,20, 30 的员工信息, 若部门号为 10, 则打印其工资的 1.1 倍, 20 号部门, 则打印其
#       工资的 1.2 倍, 30 号部门打印其工资的 1.3 倍数。其他部门打印原本工资
SELECT last_name, department_id, salary, CASE department_id WHEN 10 THEN salary*1.1
																										WHEN 20 THEN salary*1.2
																										WHEN 30 THEN salary*1.3
																										ELSE salary	END 'salary'
FROM employees;

# 优化
SELECT last_name, department_id, salary, CASE department_id WHEN 10 THEN salary*1.1
																										WHEN 20 THEN salary*1.2
																										WHEN 30 THEN salary*1.3
																										END 'salary'
FROM employees
WHERE department_id IN (10, 20, 30);


## 五、加密和解码函数
/*
	加密与解密主要用于对数据库中的数据进行加密和解密处理，以防止数据被他人窃取。这些函数在保证数据库安全时非常有用。

	函数			用法
	PASSWORD(str)	返回字符串str的加密版本，41位长的字符串。加密结果不可逆，常用于用户的密码加密
	MD5(str)	返回字符串str的md5加密后的值，也是一种加密方式。若参数为NULL，则会返回NULL
	SHA(str)	从原明文密码str计算并返回加密后的密码字符串，当参数为NULL时，返回NULL。SHA加密算法比MD5更加安全。
	ENCODE(value,password_seed) 返回使用password_seed作为加密密码加密value
	DECODE(value,password_seed) 返回使用password_seed作为加密密码解密value
 */

# `PASSWORD`(str), 在MySQL5.7中：
mysql> SELECT PASSWORD('mysql');
+-------------------------------------------+
| PASSWORD('mysql')                         |
+-------------------------------------------+
| *E74858DB86EBA20BC33D0AECAE8A8108C56B17FA |
+-------------------------------------------+
1 row in set, 1 warning (0.00 sec)

# PASSWORD(str) : 在mysql8.0中已经被弃用

# MD5(str), 不可逆的加密方式
SELECT MD5('mysql'), SHA('mysql'),
LENGTH('81c3b080dad537de7e10e0987a4bf52e'), LENGTH('f460c882a18c1304d88854e902e11b85d71e7e1b')
FROM DUAL;

# ENCODE(str,pass_str), DECODE(crypt_str,pass_str) 在mysql8.0中被弃用
SELECT ENCODE('mysql', 'zhileixin')
FROM DUAL;

# ENCODE(str,pass_str), DECODE(crypt_str,pass_str) 在5.7数据库中的操作
mysql> SELECT ENCODE('mysql', 'zhileixin');
+------------------------------------------------------------+
| ENCODE('mysql', 'zhileixin')                               |
+------------------------------------------------------------+
| 0x1599CBF113                                               |
+------------------------------------------------------------+
1 row in set, 1 warning (0.00 sec)

mysql> SELECT DECODE('mysql','zhileixin');
+----------------------------------------------------------+
| DECODE('mysql','zhileixin')                              |
+----------------------------------------------------------+
| 0xAFFA323196                                             |
+----------------------------------------------------------+
1 row in set, 1 warning (0.00 sec)

# 在mysql的图形界面中可以正常显示
mysql> SELECT DECODE(ENCODE('mysql', 'zhileixin'), 'zhileixin')
    -> FROM DUAL;
+------------------------------------------------------------------------------------------------------+
| DECODE(ENCODE('mysql', 'zhileixin'), 'zhileixin')                                                    |
+------------------------------------------------------------------------------------------------------+
| 0x6D7973716C                                                                                         |
+------------------------------------------------------------------------------------------------------+
1 row in set, 2 warnings (0.00 sec)


## 六、MySQL信息函数
/*
		MySql中内置了一些可以查询MySQL信息的函数，这些函数主要用于帮助数据库开发或者运维人员更好地对数据库进行维护操作

	函数			用法
	VERSION() 返回当前MySQL的版本号
	CONNECTION_ID() 返回当前MySQL服务器的连接数
	DATABASE()，SCHEMA() 返回MySQL命令行当前所在的数据库
	USER()，CURRENT_USER()、SYSTEM_USER()，SESSION_USER() 	返回当前连接MySQL的用户名，返回结果格式为“主机名@用户名”
	CHARSET(value) 返回字符串value自变量的字符集
	COLLATION(value) 返回字符串value的比较规则
 */

SELECT VERSION(), CONNECTION_ID(), DATABASE(), SCHEMA(), USER(), CURRENT_USER(), CHARSET('数据库'), COLLATION('数据库')
FROM DUAL;




