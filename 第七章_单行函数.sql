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


## 1. 数值函数
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


## 2. 三角函数
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




