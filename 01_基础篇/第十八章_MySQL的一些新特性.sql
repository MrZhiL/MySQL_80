##第十八章 MySQL的一些新特性
/* 1. MySQL 8.0新特性概述
		MySQL从5.7版本直接跳跃发布了8.0版本，可见这是一个令人兴奋的里程碑版本。MySQL 8版本在功能上
		做了显著的改进与增强，开发者对MySQL的源代码进行了重构，最突出的一点是多MySQL Optimizer优化
		器进行了改进。不仅在速度上得到了改善，还为用户带来了更好的性能和更棒的体验。

	
1.1 MySQL8.0新增特性
		1) 更简便的NoSQL支持
			 NoSQL反之非关系型数据库和数据存储。随着互联网平台的规模飞速发展，传统的关系型数据库已经越来
			 越不能满足需求。从5.6版本开始，MySQL就开始支持简单的NoSQL存储功能。MySQL8对这一功能做了优化，
			 以更灵活的方式实现NoSQL功能，不再依赖模式(schema)。

		2) 更好的索引
			 在查询中，正确地使用索引可以提高查询的效率。MySQL 8中新增了隐藏索引和降序索引。隐藏索引可以
			 用来测试去掉索引对查询性能的影响。在查询中混合存在多列索引时，使用降序索引可以提高查询的性能。
	
		3) 更完善的JSON支持
			 MySQL从5.7开始支持原生JSON数据的存储，MySQL 8对这一功能做了优化，增加了聚合函数JSON_ARRAYAGG() 
			 和JSON_OBJECTAGG() ，将参数聚合为JSON数组或对象，新增了行内操作符 ->>，是列路径运算符 ->的增强，
			 对JSON排序做了提升，并优化了JSON的更新操作。

		4) 安全和账户管理
			 MySQL 8中新增了caching_sha2_password 授权插件、角色、密码历史记录和FIPS模式支持，这些特性提高了
			 数据库的安全性和性能，使数据库管理员能够更灵活地进行账户管理工作。

		5) InNoDB的变化
		6) 数据字典
		7) 原子数据定义语句
		8) 资源管理
		9) 字符集支持
		10) 优化器增强
		11) 公用表表达式
		12) 窗口函数
		13) 正则表达式支持
		14) 内部临时表
		15) 日志记录
		16) 备份锁
		17) 增强的MySQL复制


1.2 MySQL8.0移除的旧特性

			在MySQL 5.7版本上开发的应用程序如果使用了MySQL8.0 移除的特性，语句可能会失败，或者产生不同
			的执行结果。为了避免这些问题，对于使用了移除特性的应用，应当尽力修正避免使用这些特性，并尽
			可能使用替代方法。

		1) 查询缓存，查询缓存中删除的项有：
			a) 语句：FLUSH QUERY CACHE \ RESET QUERY CACHE
			b) 系统变量: query_cache_limit、query_cache_min_res_unit、query_cache_size、query_cache_type、quert_cache_wlock_invalidate、
			c) 状态变量: Qcache_free_blocks、Qcache_free_memory、Qcache_hits、Qcache_inserts、Qcache_lowmem_prunes、Qcache_not_cached、
									 Qcache_queries_in_cache、Qcache_total_blocks
			d) 线程状态: checking privileges on cached query、checking query cache for query、invalidating query cache entries、
									 sending cached result to client、storing result in query cache、waiting for query cache lock。
		2) 加密相关
				删除的加密相关的内容有：ENCODE()、DECODE()、ENCRYPT()、DES_ENCRYPT()和
				DES_DECRYPT()函数，配置项des-key-file，系统变量have_crypt，FLUSH语句的DES_KEY_FILE选项，
				HAVE_CRYPT CMake选项。 对于移除的ENCRYPT()函数，考虑使用SHA2()替代，对于其他移除的函数，使
				用AES_ENCRYPT()和AES_DECRYPT()替代。

		3) 空间函数相关
				在MySQL 5.7版本中，多个空间函数已被标记为过时。这些过时函数在MySQL 8中都已被移除，只保留了对应的ST_和MBR函数。

		4) \N和NULL
				在SQL语句中，解析器不再将\N视为NULL，所以在SQL语句中应使用NULL代替\N。这项变化
				不会影响使用LOAD DATA INFILE或者SELECT...INTO OUTFILE操作文件的导入和导出。在这类操作中，NULL
				仍等同于\N。

		5) mysql_install_db
				在MySQL分布中，已移除了mysql_install_db程序，数据字典初始化需要调用带着--
				initialize或者--initialize-insecure选项的mysqld来代替实现。另外，--bootstrap和INSTALL_SCRIPTDIR
				CMake也已被删除。

		6) 通用分区处理程序
				通用分区处理程序已从MySQL服务中被移除。为了实现给定表分区，表所使用的存
				储引擎需要自有的分区处理程序。 提供本地分区支持的MySQL存储引擎有两个，即InnoDB和NDB，而在
				MySQL 8中只支持InnoDB。

		7) 系统和状态变量信息
				在INFORMATION_SCHEMA数据库中，对系统和状态变量信息不再进行维护。
				GLOBAL_VARIABLES、SESSION_VARIABLES、GLOBAL_STATUS、SESSION_STATUS表都已被删除。另外，系
				统变量show_compatibility_56也已被删除。被删除的状态变量有Slave_heartbeat_period、
				Slave_last_heartbeat,Slave_received_heartbeats、Slave_retried_transactions、Slave_running。以上被删除
				的内容都可使用性能模式中对应的内容进行替代。

		8) mysql_plugin工具
				mysql_plugin工具用来配置MySQL服务器插件，现已被删除，可使用--plugin-load或-
				-plugin-load-add选项在服务器启动时加载插件或者在运行时使用INSTALL PLUGIN语句加载插件来替代该
				工具。

 */
## 新特性1. 窗口函数
CREATE DATABASE dbtest18;

use dbtest18;

#1.1 使用窗口函数前后对比
# 1) 假设现有这样一个数据表，它显示了某购物网站在每个城市每个区的销售额：
CREATE TABLE sales(
	id INT PRIMARY KEY AUTO_INCREMENT,
	city VARCHAR(15),
	county VARCHAR(15),
	sales_value DECIMAL
);

INSERT INTO sales(city,county,sales_value)
VALUES
('北京','海淀',10.00),
('北京','朝阳',20.00),
('上海','黄埔',30.00),
('上海','长宁',10.00);

DESC sales;

SELECT * FROM sales;

# 2) 需求：
# 现在计算这个网站在每个城市的销售总额、在全国的销售总额、每个区的销售额占所在城市销售
# 额中的比率，以及占总销售额中的比率。

# 方式1：采用mysql5.7中的方法
# 可以使用分组和聚合函数，此时需要分好几步来计算
# a) 计算总销售金额，并存入临时表a
CREATE TEMPORARY TABLE a AS -- 使用TEMPORARY创建临时表a
SELECT SUM(sales_value) AS sales_value FROM sales; -- 计算总金额

SELECT * FROM a;

# b) 计算每个城市的销售额并存入临时表b
CREATE TEMPORARY TABLE b AS -- 使用TEMPORARY创建临时表b
SELECT city, SUM(sales_value) AS sales_value FROM sales  -- 计算每个城市的总金额
GROUP BY city;

SELECT * FROM b;

# c) 计算各区的销售占所在城市的总计金额的比例，和占全部销售总计金额的比例。我们可以通过
#		 下面的连接查询获得需要的结果：
SELECT s.city AS '城市', s.county AS '区', s.sales_value AS '区销售额',
b.sales_value AS '市销售额', s.sales_value/b.sales_value AS '市比率',
a.sales_value AS '总销售额', s.sales_value/a.sales_value AS '总比率'
FROM sales s JOIN b -- 连接市统计结果临时表
USING (city) JOIN a -- 连接总计金额临时表
ORDER BY s.city DESC, s.sales_value;


# 方式2：可以使用MYSQL8.0中的窗口函数
SELECT city AS '城市', county AS '区', sales_value AS '区销售额',
SUM(sales_value) OVER(PARTITION BY city) AS '市销售额', -- 计算市销售额
sales_value/SUM(sales_value) OVER(PARTITION BY city) AS '市比率',
SUM(sales_value) OVER() AS '总销售额', -- 计算-- 计算市销售额销售额
sales_value/SUM(sales_value) OVER() AS '总比率'
FROM sales
ORDER BY city, county;


# 可以发现，上面两种方式可以得到相同的结果。
# 且使用窗口函数，只需要一步就可以完成查询，而且没有用到临时表，使得执行效率更高。
# 很明显，在这种需要用到分组统计的结果对每一条记录进行计算的场景下，使用窗口函数更好。


## 1.2 窗口函数分类：
/*
		1) MySQL从8.0版本开始支持窗口函数。窗口函数的作用类似于在查询中对数据进行分组，不同的是，
		分组操作会把分组的结果聚合成一条记录，而窗口函数是将结果置于每一条数据记录中。

		2) 窗口函数可以分为：静态窗口函数和动态窗口函数。
			* 静态窗口函数的窗口大小是固定的，不会因为记录的不同而不同；
			* 动态窗口函数的大小会随着记录的不同而变化。

		3) 窗口函数总体上可以分为：序号函数、分布函数、前后函数、首尾函数和其他函数，如下表：

		---------------------------------------------------------------------------------
		函数分类		函数					函数说明
		---------------------------------------------------------------------------------
							  ROW_NUMBER()	顺序排序
		序号函数		RANK()				并列排序，会跳过重复的序号，比如序号为1、1、3
								DENSE_RANK()	并列排序，不会跳过重复的序号，比如序号为1、1、2
		---------------------------------------------------------------------------------
		分布函数		PERCENT_RANK() 等级值百分比
								CUME_DIST()		累积分布值
		---------------------------------------------------------------------------------
		前后函数		LAG(expr, n)	返回当前行的前n行的expr的值
								LEAD(expr, n) 返回当前行的后n行的expr的值
		---------------------------------------------------------------------------------
		首尾函数		FIRST_VALUE(expr) 返回第一个expr的值
								LAST_VALUE(expr) 返回最后一个expr的值
		---------------------------------------------------------------------------------
		其他函数		NTH_VALUE(expr,n) 返回第n个expr的值
								NTILE(n)					将分区中的有序数据分为n个通，记录桶编号
		---------------------------------------------------------------------------------
		
		
		---------------------------------------------------------------------------------
 
		
	  4) 语法结构
		窗口函数的语法结构是：
			函数 OVER([PARTITION BY 字段名 ORDER BY 字段名 ASC|DESC])

			OR

			函数 OVER 窗口名 ... WINDOW 窗口名 AS ([PARTITION BY 字段名 ORDER BY 字段名 ASC|DESC])

			* OVER 关键字指定函数窗口的范围。
					如果省略后面括号中的内容，则窗口会包含满足WHERE条件的所有记录，窗口函数会基于所
					有满足WHERE条件的记录进行计算。
					如果OVER关键字后面的括号不为空，则可以使用如下语法设置窗口。
			* 窗口名：为窗口设置一个别名，用来标识窗口。
			* PARTITION BY子句：指定窗口函数按照哪些字段进行分组。分组后，窗口函数可以在每个分组中分别执行。
			* ORDER BY子句：指定窗口函数按照哪些字段进行排序。执行排序操作使窗口函数按照排序后的数据记录的顺序进行编号。
			* FRAME子句：为分区中的某个子集定义规则，可以用来作为滑动窗口使用。
			

		5) 小结
			窗口函数的特点是可以分组，而且可以在分组内排序。另外，窗口函数不会因为分组而减少原表中的行
			数，这对我们在原表数据的基础上进行统计和排序非常有用。
*/

# 2 分类讲解
# 创建表goods，并添加数据
CREATE TABLE goods(
	id INT PRIMARY KEY AUTO_INCREMENT,
	category_id INT,
	category VARCHAR(15),
	NAME VARCHAR(30),
	price DECIMAL(10,2),
	stock INT,
	upper_time DATETIME
);

INSERT INTO goods(category_id,category,NAME,price,stock,upper_time)
VALUES
(1, '女装/女士精品', 'T恤', 39.90, 1000, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '连衣裙', 79.90, 2500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '卫衣', 89.90, 1500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '牛仔裤', 89.90, 3500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '百褶裙', 29.90, 500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '呢绒外套', 399.90, 1200, '2020-11-10 00:00:00'),
(2, '户外运动', '自行车', 399.90, 1000, '2020-11-10 00:00:00'),
(2, '户外运动', '山地自行车', 1399.90, 2500, '2020-11-10 00:00:00'),
(2, '户外运动', '登山杖', 59.90, 1500, '2020-11-10 00:00:00'),
(2, '户外运动', '骑行装备', 399.90, 3500, '2020-11-10 00:00:00'),
(2, '户外运动', '运动外套', 799.90, 500, '2020-11-10 00:00:00'),
(2, '户外运动', '滑板', 499.90, 1200, '2020-11-10 00:00:00');

SELECT * FROM goods;

# 2.1 序号函数

# 1) ROW_NUMBER()函数：ROW_NUMBER()函数能够对数据中的序号进行顺序显示
# 举例1：查询 goods 数据表中每个商品分类下价格降序排列的各个商品信息。
SELECT ROW_NUMBER() OVER(PARTITION BY category ORDER BY price DESC)
AS row_num, id, category_id, category, NAME, price, stock
FROM goods;

# 举例2：查询 goods 数据表中每个商品分类下价格最高的3种商品信息。
SELECT * FROM (
								SELECT ROW_NUMBER() OVER(PARTITION BY category ORDER BY price DESC)
								AS row_num, id, category_id, category, NAME, price, stock
								FROM goods
							) t -- 嵌套子查询时必须有一个别名，否则会报错
WHERE row_num <= 3;

# note：在名称为“女装/女士精品”的商品类别中，有两款商品的价格为89.90元，分别是卫衣和牛仔裤。两款商品
# 			的序号都应该为2，而不是一个为2，另一个为3。此时，可以使用RANK()函数和DENSE_RANK()函数解决。

# 2) RANK()函数：使用RANK()函数能够对序号进行并列排序，并且会跳过重复的序号，比如序号为1、1、3。
# 举例1：使用RANK()函数获取 goods 数据表中各类别的价格从高到低排序的各商品信息。
SELECT RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
id, category_id, category, NAME, price, stock
FROM goods;

# 举例2：使用RANK()函数获取 goods 数据表中类别为“女装/女士精品”的价格最高的4款商品信息。
# note: 可以看到，使用RANK()函数得出的序号为1、2、2、4，相同价格的商品序号相同，后面的商品序号是不
#				连续的，跳过了重复的序号。
SELECT * FROM (
								SELECT RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
								id, category_id, category, NAME, price, stock
								FROM goods
							) t 
WHERE category_id = 1 AND row_num <= 4; # 共有4条记录


# 3) DENSE_RANK()函数: DENSE_RANK()函数对序号进行并列排序，并且不会跳过重复的序号，比如序号为1、1、2。
# 举例1：使用DENSE_RANK()函数获取 goods 数据表中各类别的价格从高到低排序的各商品信息。
SELECT DENSE_RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
id, category_id, NAME, price, stock
FROM goods;

# 举例2：使用DENSE_RANK()函数获取 goods 数据表中类别为“女装/女士精品”的价格最高的4款商品信息。
# note: 可以看到，使用DENSE_RANK()函数得出的行号为1、2、2、3，相同价格的商品序号相同，后面的商品序
#				号是连续的，并且没有跳过重复的序号。
SELECT * FROM (
									SELECT DENSE_RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
									id, category_id, NAME, price, stock
									FROM goods
							) t
WHERE category_id = 1 AND row_num <= 4; # 共有5条记录


# 2.2 分布函数
# 1) PERCENT_RANK()函数
#    PERCENT_RANK()函数是等级值百分比函数。按照(rank - 1) / (rows - 1)进行计算。
#    其中，rank的值为使用RANK()函数产生的序号，rows的值为当前窗口的总记录数。

# 举例：计算 goods 数据表中名称为“女装/女士精品”的类别下的商品的PERCENT_RANK值。
# 写法一：
SELECT RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS r,
PERCENT_RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS pr,
id, category_id, category, NAME, price, stock
FROM goods
WHERE category_id = 1;

# 写法二：
SELECT RANK() OVER w AS r,
PERCENT_RANK() OVER w AS pr,
id, category_id, category, NAME, price, stock
FROM goods
WHERE category_id = 1 WINDOW w AS (PARTITION BY category_id ORDER BY price DESC);

# 2) CUME_DIST()函数
#		 CUME_DIST()函数主要用于查询小于或等于某个值的比例
# 举例：查询goods数据表中小于或等于当前价格的比例。
SELECT CUME_DIST() OVER(PARTITION BY category_id ORDER BY price ASC) AS cd,
id, category_id, category, NAME, price, stock
FROM goods;



# 2.3 前后函数
# 1)．LAG(expr,n)函数: 函数返回当前行的前n行的expr的值
# 举例：查询goods数据表中前一个商品价格与当前商品价格的差值。
SELECT id, category, NAME, price, pre_price, price - pre_price AS diff_price
FROM (
				SELECT id, category, NAME, price, LAG(price, 1) OVER w AS pre_price
				FROM goods
				WINDOW w AS (PARTITION BY category_id ORDER BY price) # window w as xxx 相当于是预定义，w = (PARTITION BY category_id ORDER BY price)
		 ) t;

# 2) LEAD(expr,n)函数: 函数返回当前行的后n行的expr的值。
# 举例：查询goods数据表中后一个商品价格与当前商品价格的差值。
SELECT id, category, NAME, behind_price, price, behind_price - price AS diff_price
FROM (
				SELECT id, category, NAME, price, LEAD(price, 1) OVER w AS behind_price
				FROM goods
				WINDOW w AS (PARTITION BY category_id ORDER BY price)
		 ) t;


# 2.4 首尾函数
# 1) FIRST_VALUE(expr)函数：返回第一个expr的值。
# 举例：按照价格排序，查询第1个商品的价格信息。
SELECT id, category, NAME, price, stock, FIRST_VALUE(price) OVER W AS first_price
FROM goods WINDOW w AS (PARTITION BY category_id ORDER BY price);

# 2) LAST_VALUE(expr)函数：返回最后一个expr的值。
# 举例：按照价格排序，查询最后一个商品的价格信息。
SELECT id, category, NAME, price, stock, LAST_VALUE(price) OVER W AS first_price
FROM goods WINDOW w AS (PARTITION BY category_id ORDER BY price);


# 2.5 其他函数
# 1) NTH_VALUE(expr, n): 返回第n个expr值
# 举例：查询goods数据表中排名第2和第3的价格信息
SELECT id, category, NAME, price, NTH_VALUE(price, 2) OVER w AS second_price,
NTH_VALUE(price, 3) OVER w AS third_price
FROM goods WINDOW w AS (PARTITION BY category_id ORDER BY price);

SELECT id, category, NAME, price, NTH_VALUE(price, 2) OVER (PARTITION BY category_id ORDER BY price) AS second_price,
NTH_VALUE(price, 3) OVER (PARTITION BY category_id ORDER BY price) AS third_price
FROM goods;

SELECT * FROM (
									SELECT RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
									id, category_id, category, NAME, price, stock
									FROM goods
							) t
WHERE row_num IN (2, 3);


# 2) NTILE(n)函数：将分区中的有序数据分为n个桶，记录桶编号。
# 举例：将goods表中的商品按照价格分为3组。
SELECT NTILE(3) OVER w AS nt, id, category, name, price
FROM goods WINDOW w AS (PARTITION BY category_id ORDER BY price);



##
CREATE TABLE employees
AS
SELECT * FROM dbtest2.employees;

SELECT * FROM (
								SELECT employee_id, last_name, email, salary FROM employees where department_id = 
										(SELECT department_id FROM employees WHERE employee_id = 185)
							) t;

# 查询employees表中的数据，先按照部门id降序，然后按照salary升序
SELECT * FROM employees
ORDER BY department_id DESC, salary;


## 3. 新特性2： 公用表表达式
/* 
	公用表表达式（或通用表表达式）简称为CTE(Common Table Expressions)。CTE是一个命名的临时结果集，
	作用范围时当前语句。CTE可以理解成一个可以复用的子查询，当然跟子查询还是有点区别的，CTE可以引用
	其他CTE，但子查询不能引用其他子查询。所以，可以考虑替代子查询。


	依据语法结构和执行方式的不同，共用表表达式分为 普通公用表表达式 和 递归公用表表达式 2种

	3.1 普通公用表表达式：
		WITH CTE名称
		AS (子查询)
		SELECT | DELETE | UPDATE 语句;

		普通公用表表达式类似于子查询，不过，和子查询不同的是，它可以被多次引用，而且可以被其他的普通公用表表达式所引用。

	3.2 递归公用表表达式
		递归公用表表达式也是一种公用表表达式，只不过，除了普通公用表表达式的特点以为，它还有自己的特点，
		就是可以调用自己。

		WITH RECURSIVE 
		CTE名称 AS (子查询)
		SELECT | DELETE | UPDATE 语句;

		递归公用表表达式由 2 部分组成，分别是种子查询和递归查询，中间通过关键字 UNION [ALL]进行连接。
		这里的种子查询，意思就是获得递归的初始值。这个查询只会运行一次，以创建初始数据集，之后递归
		查询会一直执行，直到没有任何新的查询数据产生，递归返回。

 */
# 1) 普通公用表表达式
# 准备工作
CREATE TABLE departments
AS
SELECT * FROM dbtest2.departments;

# 举例：查询员工所在部门的详细信息
# 如果不使用公用表表达式，则需要使用以下语法：
SELECT * FROM departments
WHERE department_id IN (
													SELECT DISTINCT department_id FROM employees
											 );

# 使用公用表表达式
WITH cte_emp
AS (SELECT DISTINCT department_id FROM employees)
SELECT * FROM departments d JOIN cte_emp e 
USING (department_id);


WITH emp_dept_id
AS (SELECT DISTINCT department_id FROM employees)
SELECT *
FROM departments d JOIN emp_dept_id e
ON d.department_id = e.department_id;


# 2) 递归公用表表达式
# 递归公用表表达式由 2 部分组成，分别是种子查询和递归查询，中间通过关键字 UNION [ALL]进行连接。
#	这里的种子查询，意思就是获得递归的初始值。这个查询只会运行一次，以创建初始数据集，之后递归
# 查询会一直执行，直到没有任何新的查询数据产生，递归返回。

# 案例：针对于我们常用的employees表，包含employee_id，last_name和manager_id三个字段。如果a是b
#			  的管理者，那么，我们可以把b叫做a的下属，如果同时b又是c的管理者，那么c就是b的下属，是a的下下属。
/*
		下面我们尝试用查询语句列出所有具有下下属身份的人员信息。
		如果用我们之前学过的知识来解决，会比较复杂，至少要进行 4 次查询才能搞定：

			第一步，先找出初代管理者，就是不以任何别人为管理者的人，把结果存入临时表；
			第二步，找出所有以初代管理者为管理者的人，得到一个下属集，把结果存入临时表；
			第三步，找出所有以下属为管理者的人，得到一个下下属集，把结果存入临时表。
			第四步，找出所有以下下属为管理者的人，得到一个结果集。

		如果第四步的结果集为空，则计算结束，第三步的结果集就是我们需要的下下属集了，否则就必须继续
		进行第四步，一直到结果集为空为止。比如上面的这个数据表，就需要到第五步，才能得到空结果集。
		而且，最后还要进行第六步：把第三步和第四步的结果集合并，这样才能最终获得我们需要的结果集。

		如果用递归公用表表达式，就非常简单了。我介绍下具体的思路。

			* 用递归公用表表达式中的种子查询，找出初代管理者。字段 n 表示代次，初始值为 1，表示是第一代管理者。
			* 用递归公用表表达式中的递归查询，查出以这个递归公用表表达式中的人为管理者的人，并且代次的值加 1。
				直到没有人以这个递归公用表表达式中的人为管理者了，递归返回。
			* 在最后的查询中，选出所有代次大于等于 3 的人，他们肯定是第三代及以上代次的下属了，也就是下下属了。
				这样就得到了我们需要的结果集。

		这里看似也是 3 步，实际上是一个查询的 3 个部分，只需要执行一次就可以了。而且也不需要用临时表
		保存中间结果，比刚刚的方法简单多了。
 */
WITH RECURSIVE cte
AS
(
	SELECT employee_id, last_name, manager_id, 1 AS n FROM employees WHERE employee_id = 100 -- 种子查询，找出第一代领导
	UNION ALL
	SELECT a.employee_id, a.last_name, a.manager_id, n+1 FROM employees AS a JOIN cte
	ON a.manager_id = cte.employee_id -- 递归查询，找出以递归公用表表达式的人为领导的人
)
SELECT employee_id, last_name FROM cte WHERE n >= 3;


# 使用普通查询
# 创建临时表，查询第一代和第二代领导
drop TEMPORARY TABLE manager1;
CREATE TEMPORARY TABLE manager1 
AS
SELECT employee_id FROM employees 
WHERE employee_id IN (
												SELECT DISTINCT employee_id FROM employees WHERE manager_id = 100 OR employee_id = 100
											);

SELECT * FROM manager1; # 15条记录

SELECT employee_id, last_name
FROM employees 
WHERE employee_id NOT IN (
		SELECT DISTINCT employee_id FROM employees WHERE manager_id = 100 OR employee_id = 100
);


# 或者使用for循环



## 4. 练习
CREATE TABLE students(
id INT PRIMARY KEY AUTO_INCREMENT,
student VARCHAR(15),
points TINYINT
);

#2). 向表中添加数据如下
INSERT INTO students(student,points)
VALUES
('张三',89),
('李四',77),
('王五',88),
('赵六',90),
('孙七',90),
('周八',88);

#3). 分别使用RANK()、DENSE_RANK() 和 ROW_NUMBER()函数对学生成绩降序排列情况进行显示
SELECT student,points,
RANK() OVER w AS 排序1,
DENSE_RANK() OVER w AS 排序2,
ROW_NUMBER() OVER w AS 排序3
FROM students
WINDOW w AS (ORDER BY points DESC);
