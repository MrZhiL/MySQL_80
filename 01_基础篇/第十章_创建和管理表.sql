## 第十章 创建和管理表

## 1. 创建和管理数据库
## note: DATABASE 不能改名。一些可视化工具可以改名，它是新建库，把所有表复制到新库
##			 再删除旧库完成的。

# 1.1 创建数据库
# 方式1：创建数据库
#CREATE DATABASE 数据库名; #此时创建的此数据库使用的是默认的字符集
CREATE DATABASE mytest1;

# 方式2：创建数据库并指定字符集
#CREATE DATABASE 数据库名 CHARACTER SET 字符集
CREATE DATABASE mytest2 CHARACTER SET 'gbk';
SHOW CREATE DATABASE mytest2;

# 方式4：判断数据库是否已经存在，不存在则创建数据库（推荐）
# CREATE DATABASE IF NOT EXISTS 数据库名;
CREATE DATABASE IF NOT EXISTS mytest2 CHARACTER SET 'utf8';
SHOW CREATE DATABASE mytest2;

CREATE DATABASE IF NOT EXISTS mytest3 CHARACTER SET 'utf8';
SHOW CREATE DATABASE mytest3;

# 1.2 使用数据库
# 1) 查看当前所有的数据库
SHOW DATABASES; # 有一个s，代表多个数据库

# 2) 查看当前正在使用的数据库
SELECT DATABASE() FROM DUAL;

# 3) 查看指定库下的所有表
# SHOW TABLES FROM 数据库名;
SHOW TABLES FROM dbtest2;
SHOW TABLES FROM mytest1;

# 4) 查看数据库的创建信息
# SHOW CREATE DATABASE 数据库名;
# 或者
# SHOW CREATE DATABASE 数据库名\G
SHOW CREATE DATABASE dbtest2;
SHOW CREATE DATABASE dbtest2\G # 在MySQL中不支持该语法

# 5) 使用或切换数据库
# USE 数据库名;
USE dbtest2;
USE mytest2;

# 6) 查看当前使用的数据库中的表
SHOW TABLES;

# 1.3 修改数据库
# 更改数据库字符集
#ALTER DATABASE 数据库名 CHARACTER SET 字符集; 比如:gbk, utf8
ALTER DATABASE mytest2 CHARACTER SET 'utf8';
ALTER DATABASE mytest3 CHARACTER SET 'gbk';

SHOW CREATE DATABASE mytest2;
SHOW CREATE DATABASE mytest3;

# 1.4 删除数据库
# 方式1：DROP DATABASE 数据库名
CREATE DATABASE IF NOT EXISTS mytest3;
SHOW DATABASES;
DROP DATABASE mytest3; # 删除mytest3数据库, 此时如果不存在该数据库，则会报错
SHOW DATABASES;

# 方式2: 如果存在该数据库，则删除；如果不存在，则无操作直接退出
DROP DATABASE IF EXISTS mytest3;
DROP DATABASE IF EXISTS mytest2;
SHOW DATABASES;


## 2.创建表


## 3 创建表

## 4 修改表

## 5. 重命名表

## 6. 删除表

## 7. 清空表 





