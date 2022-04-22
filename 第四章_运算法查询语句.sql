## 1. 算数运算法：+ - * / %， 
# SELECT A / B 或 SELECT A DIV B
# SELECT A % B 或 SELECT A MOD B
SELECT 10 % 6; # 4
SELECT 10 MOD 6; # 4

SELECT 10 / 6; # 1.6667
SELECT 10 DIV 6; # 1
 

SELECT 100, 100 + 0, 100 - 0.0, 100 + 50, 100 + 50 -30, 100 - 35.5, 100 +35.5
FROM DUAL;

SELECT 100 + '1' # 在Java语言中，结果是1001；在sql中结果为101
FROM DUAL;

# 在SQL中，+没有连接的作用，就表示加法引用。此时，会将字符串转换为数值（隐式转换）
# 如果其中存在字母，则会看出0处理
SELECT 100 + '1', 10 + 'a' # 在Java语言中，结果是1001, 100a；在sql中结果为101, 10
FROM DUAL;


SELECT 100 + NULL FROM DUAL; # null值参与运算，则结果为null


# 如果SQL中分母为0，则结果为null
SELECT 100, 100* 1, 100 * 1.0, 100 / 1.0, 100 / 2, 100 + 2 * 5 / 2, 100 / 3, 100 DIV 0
FROM DUAL;

# 取模运算：%， mod，结果与被除数的正负相同
SELECT 12 % 3, 12 % 5, 12 MOD -5, -12 % 5, -12 % -5 # 0 2 2 -2 -2
FROM DUAL;

# 练习：查询员工ID为偶数的员工信息
SELECT employee_id FROM employees WHERE employee_id % 2 = 0;


## 2.1 比较运算符
# 比较运算符来对表达式左边的操作数和右边的操作数进行比较，比较的结果为真则返回1；
# 比较的结果为假则返回0，其他情况则返回null。
# 比较运算符经常被用来作为SELECT查询语句的条件来使用，返回符合条件的结果记录

/*比较运算符
	1. =   等于运算符, 判断两个值、字符串或表达式是否相等
	: SELECT C FROM TABLE WHERE A = B

	2. <=> 安全等于运算符，安全判断两个值、字符串或表达式是否相等
	: SELECT C FROM TABLE WHERE A <=> B

	3. <>(!=) 不等于运算符，判断两个值、字符串或表达式是否不相等
	: SELECT C FROM TABLE WHERE A <> B

	4. <  小于运算符，判断前面的值、字符串或表达式是否小于后面的值、字符串或表达式
	: SELECT C FROM TABLE WHERE A != B

	5. <= 小于等于运算符，判断前面的值、字符串或表达式是否小于等于后面的值、字符串或表达式
	: SELECT C FROM TABLE WHERE A <= B

	6. >  大于运算符，判断前面的值、字符串或表达式是否大于后面的值、字符串或表达式
	: SELECT C FROM TABLE WHERE A > B

	7. >= 大于等于运算符，判断前面的值、字符串或表达式是否大于等于后面的值、字符串或表达式
	: SELECT C FROM TABLE WHERE A >= B

*/
## 2.1 字符串存在隐式转换，如果转换数值不成功，则会默认为0
SELECT 1 = 2, 1 != 2, 1 = '1', 1 = 'a', 1 <>'a', 0 = 'abc'
FROM DUAL;

# 两边都是字符串的话，则按照ANSI的比较规则进行比较（直接对字符串进行比较，而不进行转换）
SELECT 'a' = 'a', 'ab' = 'ab', 'a' = 'b'
FROM DUAL;

# 只要有NULL参与判断，在结果就为null
SELECT 1 = NULL, NULL = NULL # 结果：null, null
FROM DUAL;

SELECT last_name, salary, commission_pct
FROM employees
-- WHERE salary = 6000;
WHERE commission_pct = NULL; # 此时执行，不会有任何的结果

## 2.2 <=>： 安全等于，可以与NULL进行判断
SELECT 1 <=> 2, 1 != 2, 1 <=> '1', 1 <=> 'a', 1 <>'a', 0 <=> 'abc'
FROM DUAL;

SELECT 1 <=> NULL, NULL <=> NULL # 结果：0, 1
FROM DUAL;

# 练习：查询employees表中commission_pct为null的数据
SELECT last_name, salary, commission_pct
FROM employees
-- WHERE salary = 6000;
WHERE commission_pct <=> NULL; # 此时执行，可以查询出72条数据


## 2.2 非符号类型的比较运算符：IS NULL, IS NOTNULL, LEAST(value1,value2,...), GREATEST(value1,value2,...) ...
# 1): IS NULL \ IS NOT NULL \ ISNULL
# 练习1：查询表中commission_pct为null的数据
SELECT last_name, salary, commission_pct
FROM employees
WHERE commission_pct IS NULL; # 此时执行，可以查询出72条数据

# 练习2：查询表中commission_pct为null的数据
SELECT last_name, salary, commission_pct
FROM employees
WHERE ISNULL(commission_pct); # 此时执行，可以查询出72条数据

# 练习：查询表中commission_pct不为null的数据
SELECT last_name, salary, commission_pct
FROM employees
WHERE commission_pct IS NOT NULL; # 此时执行，可以查询出35条数据
# 或者
SELECT last_name, salary, commission_pct
FROM employees
WHERE NOT commission_pct <=> NULL; # 此时执行，可以查询出35条数据


# 2): LEAST() \ GREATEST : 最小，最大运算符
SELECT LEAST('g', 'a', 'b', 't', 'm'), GREATEST('g', 'a', 'b', 't', 'm');
SELECT LEAST('abcd', 'bcd'); # abcd
# LEAST(): 会先比较手写字母，然后再依次比较
SELECT first_name, last_name, LEAST(first_name, last_name) FROM employees;


# 3): BETWEEN expr1 AND expr2 : 查询expr1和expr2范围内的数据，包含边界[expr1, expr2]
##    expr1为条件下限，expr2为条件上限；如果交换expr1和expr2，则可能查询不到数据

# 查询工资在6000到8000的员工信息
SELECT employee_id, last_name, salary FROM employees WHERE salary BETWEEN 6000 AND 8000;
# 方式二：
SELECT employee_id, last_name, salary FROM employees WHERE salary >= 6000 AND salary <= 8000;

# 查询工资不在6000到8000的员工信息
SELECT employee_id, last_name, salary FROM employees WHERE salary NOT BETWEEN 6000 AND 8000;
SELECT employee_id, last_name, salary FROM employees WHERE salary < 6000 OR salary > 8000;

# 4): IN (SET)\ NOT IN (SET): 属于、不属于运算符
# 练习：查询部门为10,20,30部门的员工信息
SELECT employee_id, last_name, salary, department_id 
FROM employees 
WHERE department_id IN (10, 20, 30);
# 方式二：
SELECT employee_id, last_name, salary, department_id 
FROM employees 
WHERE department_id = 10 OR department_id = 20 OR department_id = 30;

# 练习：查询工资不是6000， 7000， 8000 的员工信息
SELECT employee_id, last_name, salary, department_id 
FROM employees 
WHERE department_id NOT IN (6000, 7000, 8000);


# 5): LIKE: 模糊匹配运算符，判断一个值是否符合模糊匹配规则
# 其中%代表不确定个数的字符(可以为0,1,...)，正则表达式。

# 练习：查询last_name中包含字符'a'的员工信息
SELECT employee_id, last_name, department_id
FROM employees
WHERE last_name LIKE '%a%';

# 练习：查询last_name中包含首字符为'a'的员工信息
SELECT employee_id, last_name, department_id
FROM employees
WHERE last_name LIKE 'a%';

# 练习：查询last_name中包含字符'a'且包含字符'e'的员工信息
SELECT employee_id, last_name, department_id
FROM employees
#WHERE last_name LIKE '%a%' AND last_name LIKE '%e%'; # 20 行数据
WHERE last_name LIKE '%a%e%' OR last_name LIKE '%e%a%'; 

# 练习：查询第2个字符时'a'的员工信息
# _ ：代表一个不确定的字符
SELECT employee_id, last_name, department_id
FROM employees
WHERE last_name LIKE '_a%'; 

# 练习：查询第二个字符为’_‘，且第3个字符为'a'的员工信息
# 此时需要使用转义字符：\
SELECT employee_id, last_name, department_id
FROM employees
WHERE last_name LIKE '_\_a%'; 

# 或者：
SELECT employee_id, last_name, department_id
FROM employees
# ESCAPE : 自定义转移字符为$
WHERE last_name LIKE '_$_a%' ESCAPE '$'; 

# 6): REGEXP、RLIKE: 正则表达式运算符，判断一个值是否符合正则表达式的规则
# 6.1) ‘^’匹配以该字符后面的字符开头的字符串。
# 6.2) ‘$’匹配以该字符前面的字符结尾的字符串。
# 6.3) '.’匹配任何一个单字符。
# 6.4) “[...]”匹配在方括号内的任何字符。例如，“[abc]”匹配“a”或“b”或“c”。为了命名字符的范围，使用一
#			个‘-’。“[a-z]”匹配任何字母，而“[0-9]”匹配任何数字。
SELECT 'helloworld' REGEXP '^h', 'helloworld' REGEXP 'ld$', 'helloworld' REGEXP 'hk'
FROM DUAL;

SELECT 'helloworld' REGEXP 'o.o' FROM DUAL; # 1

SELECT 'helloworld' REGEXP '[ab]' FROM DUAL; # 0
SELECT 'helloworld' REGEXP '[hd]' FROM DUAL; # 1


## 3. 逻辑运算符：NOT 或 !, AND 或 &&，OR 或 ||，XOR（逻辑异或）
SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE department_id = 50 AND ( salary > 8000 || salary < 2400 );

# XOR: a XOR b, a 和 b中需要一个为真，一个为假
SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE department_id = 50 XOR salary > 6000;

# 0 1 0 null 1 0
SELECT 1 XOR -1, 1 XOR 0, 0 XOR 0, 1 XOR NULL, 1 XOR 1 XOR 1, 0 XOR 0 XOR 0;



## 4. 位运算符 & | ^ ~ >> <<: 与、或、异或、取反、右移、左移
# 12: 1100, 5: 0101
# 1100 & 0101 = 0100; 1100 | 0101 = 1101; 1100 ^ 0101 = 1001
SELECT 12 & 5, 12 | 5, 12 ^ 5 FROM DUAL; # 4, 13, 9
SELECT 10 & ~1; # 1010 & 1110 = 1010 -> 10;
SELECT ~1, ~12, ~5 FROM DUAL; # 18446744073709551614, xxx, xxx；应该是64位的


SELECT 8 >> 1, 8 << 1 FROM DUAL; # 4, 16


#$ 课后练习：
DESCRIBE employees;
/* DESCRIBE employees; 输出：
	last_name
	email
	phone_number
	hire_date
	job_id
	salary
	commission_pct
	manager_id
	department_id
*/
# 1. 选择工资不在5000到12000的员工的姓名和工资
SELECT employee_id, last_name, first_name, salary
FROM employees
WHERE salary < 5000 || salary > 12000;

# 2. 选择在20或50号部门工作的员工姓名和部门号
SELECT employee_id, last_name, first_name, department_id
FROM employees
WHERE department_id IN (20, 50);

SELECT employee_id, last_name, first_name, department_id
FROM employees
WHERE department_id = 20 || department_id = 50;

# 3. 选择公司中没有管理者的员工姓名及job_id
SELECT employee_id, last_name, first_name, job_id
FROM employees
WHERE manager_id is NULL;

# 4. 选择公司中有奖金的员工姓名，工资和奖金级别
SELECT employee_id, last_name, first_name, salary, commission_pct
FROM employees
WHERE commission_pct is NOT NULL;

# 5. 选择员工姓名的第三个字母是a的员工姓名
SELECT employee_id, first_name
FROM employees
WHERE first_name LIKE '__a%'; # 使用模糊匹配

SELECT employee_id, first_name
FROM employees
WHERE first_name REGEXP '^..a'; # 使用正则表达式

# 7. 选择姓名中有字母a和k的员工姓名
SELECT employee_id, first_name
FROM employees
WHERE first_name REGEXP 'a' && first_name REGEXP 'k';

SELECT employee_id, first_name
FROM employees
WHERE first_name LIKE '%a%' AND first_name LIKE '%k%';

# 8. 显示出表 employees 表中first_name以'e'结尾的员工信息
SELECT employee_id, first_name
FROM employees
WHERE first_name REGEXP 'e$';

# 9. 显示出表employees的manager_id是100，101,110的员工姓名、工资、管理者id
# 方式一：推荐
SELECT employee_id, first_name, salary, manager_id
FROM employees
WHERE manager_id IN (100, 101, 110);

# 10. 显示出表employees的部门编号在80-100之间的姓名、工种
# 方式一：推荐
SELECT employee_id, first_name, job_id, manager_id
FROM employees
WHERE department_id BETWEEN 80 AND 100;

# 方式二：推荐，和方式一相同
SELECT employee_id, first_name, job_id, manager_id
FROM employees
WHERE department_id <= 100 && department_id >= 80;

# 方式三：仅适用于本题
SELECT employee_id, first_name, job_id, manager_id
FROM employees
WHERE department_id IN (80, 90, 100);