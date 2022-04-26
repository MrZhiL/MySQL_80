select 1; 


# 6. 列的别名
# as：全称（alias，别名），可以省略
# 列的别名可以使用一堆“”引起来，不要使用单引号''
SELECT employee_id emp_id, last_name AS 姓, department_id "dep_id" FROM employees;


# 7, 去除重复行
# 查询员工表中一共有弄些部门的id
# 没有去重：SELECT department_id FROM employees;
# 正确的，已经去重的：
SELECT DISTINCT department_id FROM employees;

# 下面的语句仅仅是没有报错，但是并没有实际意义
SELECT DISTINCT department_id, salary FROM employees;


# 8. 空值参与运算
# 8.1 空值：null
# 8.2 null 不等同于0， ' '，'null'。
SELECT * FROM employees;

# 8.3 空值参与运算, 则结果也一定为null
SELECT employee_id, salary "月工资", 
		   salary * (1 + commission_pct) * 12 "年薪", 
			 commission_pct 
FROM employees;

# 实际问题的解决方案：引入IFNULL(expr1, expr2):如果为null则使用expr2参数；如果不为null则使用expr1
SELECT employee_id, salary "月工资", 
		   salary * (1 + IFNULL(commission_pct, 0)) * 12 "年薪", 
			 commission_pct 
FROM employees;



# 9. 着重号 ``
# 如果表名和mysql关键字相同，则需要使用着重号来修饰：`order`
SELECT * FROM `order`;


# 10. 查询常数
SELECT 'NCEPU', 123, employee_id, last_name FROM employees;


# 11. 显示表结构， DESCRIBE可以简写为DESC
DESCRIBE employees; # 显示了表中字段的详细信息
DESC employees; # 显示了表中字段的详细信息

DESC departments;


# 12. 使用 WHERE 过滤数据
# 查询90号部门的员工信息，此时需要加上过滤条件
SELECT * FROM employees WHERE department_id = 90;

# 练习：查询last_name为'King'的员工信息
# g过滤条件，需要声明在FROM结构的后面，必须挨着，否则会报错
# note：如果将King写为king也可以正常查询出来，因为语法不严谨的原因
SELECT * FROM employees WHERE last_name = 'King'; 

## 练习
# 1): 查询员工12个月的工资总和，并起别名为ANNUAL SALARY
SELECT employee_id, last_name, first_name, salary * (1 + IFNULL(commission_pct, 0)) * 12 "ANNUAL SALARY" FROM employees;

# 2): 查询employees表中去除重复的job_id以后的数据
SELECT DISTINCT job_id FROM employees;

# 3): 查询工资大于12000的员工的姓名和工资
SELECT employee_id, last_name, first_name, salary FROM employees WHERE salary > 12000;

# 4): 查询员工号为176的员工的姓名和部门号
SELECT employee_id, last_name, first_name FROM employees WHERE employee_id = 176;

# 5): 查询表 departments 的结构，并查询其中的全部数据
DESCRIBE departments;
SELECT * FROM departments











