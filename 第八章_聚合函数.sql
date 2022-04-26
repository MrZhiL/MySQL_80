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

# 其他：方差、标准差，中位数


## 2. GROUP BY 的使用


## 3. HAVING 的使用


## 4. SQL地址的执行原理


