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

# LPAD RPAD(str,len,padstr): 用字符串pad对str最左(右)边进行填充，直到str的长度为len个字符
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


