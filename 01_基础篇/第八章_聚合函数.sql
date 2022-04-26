## 第八章 聚合函数
/*
	上一章中对SQL的单行函数进行了介绍。实际上SQL函数还有一类，叫做聚合（或聚焦、分组）函数，它是对一组数据进行汇总的函数，
	输入的是一组数据的集合，输出的是单个值。

  聚合函数：作用于一组数据，并对一组数据返回一个值


  聚合函数的常用函数：AVG(), SUM(), MIN(), MAX(), COUNT()
 */

## 1. 常见的集合聚合函数：均会自动忽略null值
# 1.1 AVG / SUM : 只适用于数值类型的字段（或变量）
SELECT AVG(salary), SUM(salary), AVG(salary)*107
FROM employees;

# 如下的操作没有意义
SELECT SUM(last_name), AVG(last_name),SUM(hire_date) # 字符串求和没有意义，在ORACLE中会报错
FROM employees;

# 1.2 MAX / MIN : 适用于数值类型、字符串类型、日期时间类型的字段（或变量）
SELECT MAX(salary), MIN(salary), MAX(last_name), MIN(last_name), MAX(hire_date), MIN(hire_date)
FROM employees

# 1.3 COUNT 
# 1) 作用：计算指定字段在查询结果中出现的个数
SELECT COUNT(employee_id), COUNT(salary), COUNT(2*salary), COUNT(department_id), COUNT(commission_pct), COUNT(1), # employees 中的 COUNT(1) = 107
COUNT(2), COUNT(*)
FROM employees;

SELECT count(1) FROM DUAL; # 1

# 如果计算表中有多少条记录，如何实现？
# 方式1： COUNT(*)
# 方式2： COUNT(1)
# 方式3： COUNT(具体字段) ：不一定对
-- SELECT * FROM employees;
# 2）注意：计算指定字段出现的个数时，是不包含NULL值的
SELECT COUNT(employee_id), COUNT(department_id), COUNT(commission_pct), COUNT(1), COUNT(0)
FROM employees;

SELECT commission_pct
FROM employees
WHERE commission_pct IS NOT NULL;

# 3）AVG = SUM / COUNT
SELECT SUM(salary)/COUNT(salary), AVG(salary), SUM(commission_pct), AVG(commission_pct), SUM(commission_pct)/COUNT(commission_pct)
FROM employees;

# 需求：查询公司中的平均奖金率，应该使用SUM(commission_pct) / COUNT(*)，而不是AVG(commission_pct)，因为有一部分员工没有commission_pct
SELECT AVG(commission_pct) 'error_avg', SUM(commission_pct) / COUNT(*) 'right avg',
SUM(commission_pct) / COUNT(IFNULL(commission_pct, 0)) 'right avg2',
AVG(IFNULL(commission_pct, 0))
FROM employees;


# 如果需要统计表中的记录数，使用COUNT(*), COUNT(1), COUNT(具体字段) 那个效率更高呢？
# 如果使用的是MyISAM 存储引擎，则三者效率相同，都是O(1)
# 如果使用的是InnoDB 存储引擎，则三者效率：COUNT(*) = COUNT(1) > COUNT (字段)

# 其实，对于MyISAM引擎的表是没有区别的。这种引擎内部有一计数器在维护着行数。
# Innodb引擎的表用count(*),count(1)直接读行数，复杂度是O(n)，因为innodb真的要去数一遍。但好于具体的count(列名)。

# 其他：方差、标准差，中位数


## 2. GROUP BY 的使用
# 需求：查询各个部门的平均工资，最高工资
SELECT department_id, AVG(salary), MAX(salary)
FROM employees
GROUP BY department_id;

# 需求：查询各个job_id的平均工资
SELECT job_id, AVG(salary), MAX(salary)
FROM employees
GROUP BY job_id;

# 需求：查询各个department_id和job_id的平均工资
# 方式一：
SELECT department_id, job_id, AVG(salary), MAX(salary)
FROM employees
GROUP BY department_id, job_id
ORDER BY department_id;

# 方式二：和上面的结果相同
SELECT department_id, job_id, AVG(salary), MAX(salary)
FROM employees
GROUP BY job_id, department_id
ORDER BY department_id;


# 错误的写法：因为一个department_id中可能存在多个job_id，导致结果出错
# 结论1：SELECT中出现的非主函数的字段 必须在 GROUP BY 中进行声明；但是GROUP BY中出现的字段，不一定要出现在SELECT中（因为可以不输出）
# 结论2：GROUP BY 声明在FROM后面，WHERE 后面，ORDER BY前面，LIMIT前面。
# 结论3：MySQL中GROUP BY 中使用WITH ROLLUP
#        使用WITH ROLLUP 关键字之后，在所有查询出的分组记录之后增加一条记录，该记录计算查询出的所有记录的总和，即统计记录数量
SELECT department_id, job_id, AVG(salary), MAX(salary)
FROM employees
GROUP BY department_id;

# 结论3：MySQL中GROUP BY 中使用WITH ROLLUP，使用WITH ROLLUP后最后会计算一下整体的平均工资
SELECT department_id, AVG(salary), MAX(salary)
FROM employees
GROUP BY department_id;

SELECT department_id, AVG(salary), MAX(salary)
FROM employees
GROUP BY department_id WITH ROLLUP;

# 需求：查询各个部门的平均工资，按照平均工资升序排序
SELECT department_id, AVG(salary) avg_sal, MAX(salary)
FROM employees
GROUP BY department_id
ORDER BY avg_sal ASC; 

# 说明：当使用ROLLUP是，不能同时使用ORDER BY 子句进行排序，即ROLLUP和ORDER BY是互斥的
# 但是在8.0.27的版本中没有报错，在5.7的版本中进行了报错
SELECT department_id, AVG(salary) avg_sal
FROM employees
GROUP BY department_id WITH ROLLUP
ORDER BY avg_sal ASC;

# 在5.8中：
[Err] 1221 - Incorrect usage of CUBE/ROLLUP and ORDER BY


## 3. HAVING 的使用（作用：用来过滤数据的）
# 练习：查询各个部门中最高工资比10000高的部门信息
SELECT department_id, MAX(salary) max_sal
FROM employees
WHERE MAX(salary) > 1000 # error, [Err] 1111 - Invalid use of group function
GROUP BY department_id

# 要求1：如果过滤条件中使用了聚合函数，则必须使用HAVING来替换WHERE。否则，会报错
# 要求2：HAVING必须声明在GROUP BY的后面
# 要求3：开发中，我们使用HAVING的前提是SQL中使用了GROUP BY，如果没有使用GROUP BY，则一般不再使用HAVING
# 结论：当过滤条件中有聚合函数时，则此过滤条件必须声明在HAVING中；
#       当过滤条件中没有聚合函数时，则此过滤条件声明在WHERE中或HAVING中都可以。但是建议声明在WHERE中。
#				因为WHERE的执行效率高于HAVING的执行效率

# 正确的写法：
SELECT department_id, MAX(salary) max_sal
FROM employees
GROUP BY department_id
HAVING max_sal > 10000;

# 练习：查询部门id为10,20,30,40这4个部门中最高工资比10000高的部门信息
# 方式1：使用WHERE进行过滤 （推荐使用该方式，因为该方式执行效率高于方式2）
SELECT department_id, MAX(salary) max_sal
FROM employees
WHERE department_id IN (10, 20, 30, 40)
GROUP BY department_id
HAVING max_sal > 10000;

# 方式2：使用HAVING进行过滤
SELECT department_id, MAX(salary) max_sal
FROM employees
GROUP BY department_id
HAVING department_id IN (10, 20, 30, 40) AND max_sal > 10000;

# 3.2 WHERE和HAVING的对比
/*
  1. 从使用范围来讲：HAVING的适用范围更广；
	2. 如果过滤条件中没有聚合函数：在这种情况下，WHERE的执行效率高于HAVING
  3. 

	区别1：WHERE 可以直接使用表中的字段作为筛选条件，但不能使用分组中的计算函数作为筛选条件；
	HAVING 必须要与 GROUP BY 配合使用，可以把分组计算的函数和分组字段作为筛选条件。

	这决定了，在需要对数据进行分组统计的时候，HAVING 可以完成 WHERE 不能完成的任务。这是因为，
	在查询语法结构中，WHERE 在 GROUP BY 之前，所以无法对分组结果进行筛选。HAVING 在 GROUP BY 之
	后，可以使用分组字段和分组中的计算函数，对分组的结果集进行筛选，这个功能是 WHERE 无法完成
	的。另外，WHERE排除的记录不再包括在分组中。

	区别2：如果需要通过连接从关联表中获取需要的数据，WHERE 是先筛选后连接，而 HAVING 是先连接
	后筛选。 这一点，就决定了在关联查询中，WHERE 比 HAVING 更高效。因为 WHERE 可以先筛选，用一
	个筛选后的较小数据集和关联表进行连接，这样占用的资源比较少，执行效率也比较高。HAVING 则需要
	先把结果集准备好，也就是用未被筛选的数据集进行关联，然后对这个大的数据集进行筛选，这样占用
	的资源就比较多，执行效率也较低。

	小结：
				 优点															缺点
	WHERE  先筛选数据再关联，执行效率高			不能使用分组中的计算函数进行筛选
	HAVING 可以使用分组中的计算函数					在最后的结果集中进行筛选，执行效率较低

	开发中的选择：
	WHERE 和 HAVING 也不是互相排斥的，我们可以在一个查询里面同时使用 WHERE 和 HAVING。包含分组
	统计函数的条件用 HAVING，普通条件用 WHERE。这样，我们就既利用了 WHERE 条件的高效快速，又发
	挥了 HAVING 可以使用包含分组统计函数的查询条件的优点。当数据量特别大的时候，运行效率会有很
	大的差别。
*/


## 4. SQL语句的执行原理
# 4.1 SELECT 语句的完整结构
/* 
	#SQL92语法：
	SELECT ..., ..., ... (存在聚合函数)
	FROM ..., ..., ...
	WHERE 多表的连接条件 AND 不包含聚合函数的过滤条件
	GROUP BY ..., ...
	HAVING 包含聚合函数的过滤条件
	ORDER BY ..., ... (ASC, DESC)
	LIMIT ..., ...

	#SQL99语法：
	SELECT ..., ..., ... (存在聚合函数)
	FROM ... (LEFT | RIGHT)JOIN ... ON 多表的连接条件 
	(LEFT | RIGHT)JOIN ... ON 多表的连接条件 
	WHERE 不包含聚合函数的过滤条件
	GROUP BY ..., ...
	HAVING 包含聚合函数的过滤条件
	ORDER BY ..., ... (ASC, DESC)
 */

# 4.2 SQL语句的执行过程
# FROM ..., ... -> ON -> (LEFT/RIGHT JOIN) -> WHERE -> GROUP BY -> HAVING -> SELECT -> DISTINCT -> ORDER BY -> LIMIT
# 因为HAVING的执行要在WHERE后面，因此WHERE的执行效率更高

/*
	比如你写了一个 SQL 语句，那么它的关键字顺序和执行顺序是下面这样的：
 */
SELECT DISTINCT player_id, player_name, count(*) as num # 顺序 5
FROM player JOIN team ON player.team_id = team.team_id # 顺序 1
WHERE height > 1.80 # 顺序 2
GROUP BY player.team_id # 顺序 3
HAVING num > 2 # 顺序 4
ORDER BY num DESC # 顺序 6
LIMIT 2 # 顺序 7
/*
	在 SELECT 语句执行这些步骤的时候，每个步骤都会产生一个虚拟表，然后将这个虚拟表传入下一个步
	骤中作为输入。需要注意的是，这些步骤隐含在 SQL 的执行过程中，对于我们来说是不可见的。
 */

# 4.3 SQL的执行原理
/* SQL 的执行原理
SELECT 是先执行 FROM 这一步的。在这个阶段，如果是多张表联查，还会经历下面的几个步骤：
1. 首先先通过 CROSS JOIN 求笛卡尔积，相当于得到虚拟表 vt（virtual table）1-1；
2. 通过 ON 进行筛选，在虚拟表 vt1-1 的基础上进行筛选，得到虚拟表 vt1-2；
3. 添加外部行。如果我们使用的是左连接、右链接或者全连接，就会涉及到外部行，也就是在虚拟表 vt1-2 的基础上增加外部行，得到虚拟表 vt1-3。

当然如果我们操作的是两张以上的表，还会重复上面的步骤，直到所有表都被处理完为止。这个过程得到是我们的原始数据。

当我们拿到了查询数据表的原始数据，也就是最终的虚拟表 vt1 ，就可以在此基础上再进行 WHERE 阶
段。在这个阶段中，会根据 vt1 表的结果进行筛选过滤，得到虚拟表 vt2 。

然后进入第三步和第四步，也就是 GROUP 和 HAVING 阶段。在这个阶段中，实际上是在虚拟表 vt2 的
基础上进行分组和分组过滤，得到中间的虚拟表 vt3 和 vt4 。

当我们完成了条件筛选部分之后，就可以筛选表中提取的字段，也就是进入到 SELECT 和 DISTINCT阶段。

首先在 SELECT 阶段会提取想要的字段，然后在 DISTINCT 阶段过滤掉重复的行，分别得到中间的虚拟表vt5-1 和 vt5-2 。

当我们提取了想要的字段数据之后，就可以按照指定的字段进行排序，也就是 ORDER BY 阶段，得到虚拟表 vt6 。

最后在 vt6 的基础上，取出指定行的记录，也就是 LIMIT 阶段，得到最终的结果，对应的是虚拟表vt7 。

当然我们在写 SELECT 语句的时候，不一定存在所有的关键字，相应的阶段就会省略。

同时因为 SQL 是一门类似英语的结构化查询语言，所以我们在写 SELECT 语句的时候，还要注意相应的关键字顺序，所谓底层运行的原理，就是我们刚才讲到的执行顺序。

 */

