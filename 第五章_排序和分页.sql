### 第五章_排序和分页

## 默认查询：
# 如果没有使用排序的话，默认情况下查询返回的数据是按照添加数据的顺序
SELECT * FROM employees;

## 一、 排序


# 练习1：按照salary从高到低排序
# 使用 ORDER BY 对查询的数据进行排序操作，默认为升序排序
# 升序： ASC(ascend);  降序：DESC(descend)
SELECT employee_id, last_name, salary 
FROM employees
ORDER BY salary DESC;

## 2. 我们可以使用列的别名进行排序
# note: 列的别名只能在ORDER BY中使用，不能在WHERE中使用
SELECT employee_id, salary, salary*12 annual_sal
FROM employees句，然后执行WHERE语句，再执行SELECt语句，最后执行ORDER BY语句
WHERE salary*12 > 81600
# WHERE annual_sal > 81600 # error, 会报错。因为SQL中会先执行FROM语
ORDER BY annual_sal;


## 3. 二级排序；
# 练习：显示员工信息，按照department_id的降序排列，salary的升序排列
SELECT employee_id, last_name, salary, department_id
FROM employees
ORDER BY department_id DESC, salary ASC;


## 二、 分页
# 背景1：查询返回的记录太多了，查看起来很不方便，怎么样才能实现分页查询呢？
# 背景2：表里有4条数据，我们只想要显示第2,3条数据怎么办呢？

## 2.1 MySQL使用limit实现数据的分页显示
# 语法：LIMIT [位置偏移量,] 行数
# note: LIMIT子句必须放在整个SELECT语句的最后！
# 好处：约束返回结果的数量，可以减少数据表的网络传输量，也可以提升查询效率。
#       如果我们知道返回结果只有1条，就可以使用LIMIT 1，告诉SELECT 语句只需要
#       返回一条记录即可。这样的好处就是SELECT不需要扫描完整的表，只需要检索
#			  的一条符合条件的记录返回即可。

#   第一个“位置偏移量”参数指示MySQL从哪一行开始显示，是一个可选参数，如果不指定“位置偏移
#   量”，将会从表中的第一条记录开始（第一条记录的位置偏移量是0，第二条记录的位置偏移量是
#   1，以此类推）；第二个参数“行数”指示返回的记录条数。

# 需求1：每页显示20条记录，此时显示第1页
SELECT employee_id, last_name, salary, department_id
FROM employees
LIMIT 0, 20; # [0, 20)

# 需求2：每页显示20条记录，此时显示第2页
SELECT employee_id, last_name, salary, department_id
FROM employees
LIMIT 20, 20; # [20, 40)

# 需求3：每页显示20条记录，此时显示第3页
SELECT employee_id, last_name, salary, department_id
FROM employees
LIMIT 40, 20; # [20, 40)

# 需求：每页显示papgSize条记录，此时显示第pageNo页
# 公式： LIMIT (pageNo - 1) * pageSize, pageSize;

## 2.2 WHERE ... ORDER By ... LIMIT 声明顺序如下：
# LIMIT格式：limit 偏移量， 条目数
# LIMIT 0, 条目数； 《等价于》 LIMIT 条目数
SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE salary > 6000
ORDER By salary DESC
LIMIT 0, 10; # 相当于LIMIT 10; 此时会默认从0开始


# 练习：表里有107条数据，显示第32,33条数据：
SELECT employee_id, last_name, salary, department_id
FROM employees
LIMIT 31, 2;

## mysql 8.0 中可以使用"LIMIT 3 OFFSET 4"，
## 意思是获取从第5条记录开始后面的3条件记录，其中OFFSET后面为偏移量
SELECT employee_id, last_name, salary, department_id
FROM employees
LIMIT 2 OFFSET 31; # 相当于LIMIT 31, 2;

 
## 三、课后题
# 1. 查询员工的姓名、部门号、年薪，按年薪降序，按姓名升序显示
SELECT employee_id, last_name, department_id, salary*(1 + IFNULL(commission_pct, 0))*12 sum_sal
FROM employees
ORDER BY sum_sal DESC, last_name ASC;

# 2. 选择工资不在8000到17000的员工和工资，按工资降序，显示第21到40位置的数据
SELECT employee_id, last_name, department_id, salary
FROM employees
WHERE salary > 17000 || salary < 8000
ORDER BY salary DESC
LIMIT 20, 20;

# 3. 查询邮箱中包含e的员工信息，并先按邮箱的字节数降序，再按部门号升序
SELECT employee_id, last_name, email
FROM employees
#WHERE email REGEXP 'e'
WHERE email like '%e%'
ORDER BY email DESC, department_id ASC;










