---
Title: Structured Query Language
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2023-04-25
Modified: 2023-05-19
---
# Database Introduction

### Database management system (DBMS)

* 关系型数据库（RDBMS, Relational Database Management System）
  * 执行规模小而读写频繁，或者大批量极少写访问的事务
* 非关系型数据库 （NoSQL）
  * 轻量、开源、不提供SQL功能的关系数据库，为巨量文档创建索引、高流量网站的网页服务，以及发送流式媒体

### SQL Product
1. 商用数据库，例如：Oracle，SQL Server，DB2等；
2. 开源数据库，例如：MySQL，PostgreSQL等；
3. 桌面数据库，以微软Access为代表，适合桌面应用程序使用；
4. 嵌入式数据库，以Sqlite为代表，适合手机应用和桌面程序。

数据库设计：PowerDesigner

***

## Structured Query Language

### SQL Command
1. Data Definition Language: **SHOW**, **CREATE**, **DROP**, **ALTER**, **TRUNCATE**
2. Data Manipulation Language: **INSERT**, **UPDATE**, **DELETE**, **CALL**
3. Data Query Language: **SELECT**, **FROM**, **WHERE**, **ORDER BY**
4. Data Control Language: **GRANT**, **REVOKE**

***

### DDL

#### Manage Database

```sql
-- Show all database
SHOW DATABASES;
-- Create database
CREATE DATABASE <DatabaseName>;
-- Switch database
USE <DatabaseName>;
-- Show databases in use
SELECT DATABASE();
-- Delete Database
DROP DATABASE <DatabaseName>;
```

#### Manage Data Sheets

```sql
-- Create a new table
CREATE TABLE IF NOT EXISTS <tableName> (
    <colName1> <dataType> UNSIGNED NOT NULL AUTO_INCREMENT,
    <colName2> <dataType> DEFAULT NULL,
	...,
	PRIMARY KEY (<colName1>)
) ENGINE = InnoDB DEFAULT CHARSET=utf8;
-- Show all table in a database
SHOW TABLES;
-- Display the data structure of the table
DESC <tableName>;
-- Rename table
ALTER TABLE <old_tableName> RENAME TO <new_tableName>;
-- Delete table
DROP TABLE <tableName>;
```

```sql
-- Adding a new column to a table
ALTER TABLE <tableName> ADD COLUMN <new_colname> <dataType> <Binding terms>
-- Modifying the data type of a column
ALTER TABLE <tableName> MODIFY <colname> <dataType>
-- Change the column name
ALTER TABLE <tableName> CHANGE <old_name_colname> <new_name_colname> <dataType>
-- Delete a column from a table
ALTER TABLE <tableName> DROP COLUMN <colname>
```

| Binding terms             | Explanation    |
| ------------------------- | -------------- |
| `NOT NULL`                | **非空约束**   |
| `UNIQUE`                  | **唯一性约束** |
| `DEFAULT` <value>         | **默认值约束** |
| `PRIMARY KEY` (<colname>) | **主键约束**   |
| `FOREIGN KEY` (<colname>) | **外键约束**   |

***
### DQL
#### Query Data

```sql
-- query all data from a table
SELECT * FROM <tableName>;
-- query specified data from a table
SELECT <colName1>, <colName1>, <colName3>, ..., FROM <tableName>;
-- query specified data from a table and rename it
SELECT <old_colName> AS <new_colName> FROM <tableName>;
-- query specified data from a table and show unique values
SELECT DISTINCT <colName> FROM <tableName>;
```

* Commonly conditional expression

```sql
-- query data that meets conditions from a table
SELECT * FROM <tableName> WHERE <conditional expression>;
-- subquery
SELECT * FROM <tableName> WHERE <colName> = (SELECT * FROM <tableName> WHERE <conditional expression>);
```

|    条件    | 表达式举例1 |  表达式举例2  |                       说明                        |
| :--------: | :---------: | :-----------: | :-----------------------------------------------: |
|    相等    | score = 80  | name = 'abc'  |            字符串需要用单/双引号括起来            |
|    大于    | score > 80  | name > 'abc'  | 字符串比较根据ASCII码，中文字符比较根据数据库设置 |
| 大于或等于 | score >= 80 | name >= 'abc' |                                                   |
|    小于    | score < 80  | name <= 'abc' |                                                   |
| 小于或等于 | score <= 80 | name <= 'abc' |                                                   |
|   不相等   | score <> 80 | name <> 'abc' |                                                   |
|   不相等   | score != 80 | name != 'abc' |                                                   |

* 按照NOT、AND、OR的优先级进行，即NOT优先级最高，其次是AND，最后是OR。加上括号 " ( ) " 可以改变优先级。

```sql
-- query data that meets multiple conditions from a table
SELECT * FROM <tableName> WHERE <conditional expression 1> AND <conditional expression 2>;
SELECT * FROM <tableName> WHERE <conditional expression 1> OR <conditional expression 2>;
SELECT * FROM <tableName> WHERE NOT <conditional expression>;
```

```sql
SELECT * FROM <tableName> WHERE <colName> = 'X1' OR <colName> = 'X2' OR <colName> = 'X3'
-- simplify
SELECT * FROM <tableName> WHERE <colName> IN ('X1', 'X2', 'X3');
SELECT * FROM <tableName> WHERE <colName> NOT IN ('X1', 'X2', 'X3');
-- subquery
SELECT * FROM <tableName> WHERE <colName> IN (SELECT <colName> FROM <tableName>);
```

```sql
SELECT * FROM <tableName> WHERE <colName> >= num1 AND <colName> <= num2;
-- simplify
SELECT * FROM <tableName> WHERE <colName> BETWEEN num1 AND num2;
```

```sql
-- match string (Outdated methods)
SELECT * FROM <tableName> WHERE <colName> LIKE 'a%'
```

| 符号 | 意义                    |
| ---- | ----------------------- |
| %    | any number of character |
| _    | any single of character |

```sql
-- match string by regular expression
SELECT * FROM <tableName> WHERE <colName> REGEXP '*'
```

```sql
-- find null values
SELECT * FROM <tableName> WHERE <colName> IS NULL
-- find non-null values
SELECT * FROM <tableName> WHERE <colName> IS NOT NULL
```

```mysql
-- order data from slow to high (ascending order, default)
SELECT <colName1>, ... FROM <tableName> ORDER BY <colName1> (ASC);
-- order data from high to slow (descending order)
SELECT <colName1>, ... FROM <tableName> ORDER BY <colName1> DESC;
-- 
SELECT <colName1>, ... FROM <tableName> ORDER BY <colName1>, <colName2>;
SELECT <colName1>, ... FROM <tableName> ORDER BY <colName1> DESC, <colName2> DESC;
```

```sql
-- Only show the top num records
SELECT * FROM <tableName> LIMIT num
-- Skip the first num1 records and then display the top num2 records
SELECT * FROM <tableName> LIMIT num1, num2
```

```sql
SELECT * FROM <tableName> 
	WHERE <conditional expression> 
	ORDER BY <colName> 
	LIMIT pageSize 
	OFFSET pageSize*(pageIndex-1);
```

***

#### Joins Table

* Inner joins: JOIN只返回同时存在于两张表的行数据

```sql
SELECT * FROM <tableName1> 
	(INNER) JOIN <tableName2> ON <tableName1.colName> = <tableName2.colName>;
-- simplify
SELECT * FROM <tableName1> t1 
	JOIN <tableName2> t2 ON <t1.colName> = <t2.colName>;
-- simplify, the same colname
SELECT * FROM <tableName1> t1 
	JOIN <tableName2> t2 USING (colName);

-- Implpicit join syntax (Not recommended and can be ignored)
SELECT * FROM <tableName1> t1, <tableName2> t2 
	WHERE <t1.colName> = <t2.colName>;
```

* Outer joins

```sql
-- LEFT JOIN则返回左表(主表)都存在的行。
SELECT * FROM <tableName1> t1 
	LEFT (OUTER) JOIN <tableName2> t2 ON <t1.colName> = <t2.colName>;
-- RIGHT JOIN返回右(次表)表都存在的行。
SELECT * FROM <tableName1> t1 
	RIGHT (OUTER) JOIN <tableName2> t2 ON <t1.colName> = <t2.colName>;
-- 两张表的所有记录全部选择出来，并且，自动把对方不存在的列填充为NULL：
SELECT * FROM <tableName1> t1 
	FULL (OUTER) JOIN <tableName2> t2 ON <t1.colName> = <t2.colName>;
```

* Joining across databases

```sql
SELECT * FROM <tableName1> t1 
	JOIN <dataName2>.<tableName2> t2 ON <t1.colName> = <t2.colName>;
```

* Self joins and Self outer joins

```sql
SELECT * FROM <tableName> t1 
	JOIN <tableName> t2 ON <t1.colName> = <t2.colName>;
SELECT * FROM <tableName> t1 
	LEFT JOIN <tableName> t2 ON <t1.colName> = <t2.colName>;
```

* Joining multiple tables

```sql
SELECT * FROM <tableName1> t1 
	JOIN <tableName2> t2 ON <t1.colName1> = <t2.colName1> 
	JOIN <tableName3> t3 ON <t1.colName2> = <t3.colName1>
	LEFT JOIN <tableName4> t4 ON <t1.colName3> = <t4.colName1>;
```

* Compound join conditions （复合主键）

```sql
SELECT * FROM <tableName1> t1 
	JOIN <tableName2> t2 ON <t1.colName1> = <t2.colName1> AND <t1.colName2> = <t2.colName2>
-- simplify, the same colname
SELECT * FROM <tableName1> t1 
	JOIN <tableName2> t2 USING (colName1, colName2)
```

* Nature joins: (Not recommended and can be ignored)

```sql
SELECT * FROM <tableName1> t1 NATURAL JOIN <tableName2> t2
```

* Cross joins: 得到所有组合

```sql
SELECT <t1.colName>, <t2.colName> FROM <tableName1> t1 CROSS JOIN <tableName2> t2
-- Implpicit join syntax
SELECT <t1.colName>, <t2.colName> FROM <tableName1> t1, <tableName2> t2
```

* Unions: 追加合并（相同数量的列）

```sql
SELECT * FROM <tableName> WHERE <conditional expression 1> 
	UNION
	SELECT * FROM <tableName> WHERE <conditional expression 2>
```

***

### DML

#### Modify Data

* Data Format

|       名称       |      类型      |                            说明                            |
| :--------------: | :------------: | :--------------------------------------------------------: |
|       INT        |      整型      |                     4 bytes, [-2B, 2B]                     |
|     TINYINT      |      整型      |                    1 bytes, [-128, 127]                    |
| UNSIGNED TINYINT |      整型      |                     1 bytes, [0, 225]                      |
|     SMALLINT     |      整型      |                    2 bytes, [-32K, 32K]                    |
|    MEDIUMINT     |      整型      |                     3 bytes, [-8M, 8M]                     |
|      BIGINT      |      整型      |                     8 bytes, [-9Z, 9Z]                     |
|  REAL/FLOAT(24)  |     浮点型     |                   4 bytes, 范围约+/-1038                   |
|      DOUBLE      |     浮点型     |                  8 bytes, 范围约+/-10308                   |
|   DECIMAL(M,N)   |   高精度小数   |          由用户指定精度的小数，M位数，N小数点位数          |
|     CHAR(N)      |   定长字符串   |                    存储指定长度的字符串                    |
|    VARCHAR(N)    |   变长字符串   | 存储可变长度的字符串（**常用**），最长65,535个字符，~64 KB |
|     TINYTEXT     |     微文本     |                         255 bytes                          |
|       TEXT       |      文本      |                           64 KB                            |
|    MEDIUMTEXT    |     文本串     |                           16 MB                            |
|     LONGTEXT     |    长文本串    |                            4 GB                            |
|  BOOL / BOOLEAN  |    布尔类型    |                     TRUE(1) / FALSE(0)                     |
|       ENUM       |      枚举      |                                                            |
|       SET        |      集合      |                                                            |
|       DATE       |    日期类型    |                 存储日期，例如，2018-06-22                 |
|       TIME       |    时间类型    |                  存储时间，例如，12:20:59                  |
|     DATETIME     | 日期和时间类型 |     8 bytes, 存储日期+时间，例如，2018-06-22 12:20:59      |
|    TIMESTAMP     |    时间类型    |                    4 bytes, up to 2038                     |
|       YEAR       |    时间类型    |                                                            |
|     TINYBLOB     |   二进制数据   |                         255 bytes                          |
|       BLOB       |   二进制数据   |                           65 KB                            |
|    MEDIUMBLOB    |   二进制数据   |                           16 MB                            |
|     LOHGBLOB     |   二进制数据   |                            4 GB                            |
|       JOSN       |                |                         多个键值对                         |

* Inserting Data

```sql
INSERT INTO <tableName> VALUES (DEFAULT, value1, value2, ...);
INSERT INTO <tableName> (<colName1>, <colName2>, ...) VALUES (value1, value2, ...);
-- Inserting multiple row record
INSERT INTO <tableName> (<colName1>, <colName2>, ...) VALUES (value1, value2, ...), (value3, value4, ...);
-- Inserting Hierarchical row record ()
INSERT INTO <tableName1> (<colName1>, <colName2>, ...) VALUES (value1, value2, ...);
INSERT INTO <tableName2> VALUES (LAST_INSERT_ID(), value1, ...);
```

* Updating Data

```sql
-- Updating single/multiple row record
UPDATE <tableName> SET <colName>=<val1> WHERE <conditional expression>;
-- Updating all record
UPDATE <tableName> SET <colName>=<val>;
-- 
UPDATE <tableName> SET <colName>=<val> 
	WHERE <colName> = 
		(SELECT <colName> FROM <tableName> WHERE <conditional expression>);
```

* Deleting Data

```sql
DELETE FROM <tableName> WHERE <conditional expression>;
DELETE FROM <tableName> 
	WHERE <colName> = 
		(SELECT <colName> FROM <tableName> WHERE <conditional expression>);
-- Deleting all record
DELETE FROM <tableName>;
```

* Copy Table

```sql
-- create a new table and copy all records from an old table
CREATE TABLE <new_tableName> AS
	SELECT * FROM <old_tableName>;
-- create a new table and copy a part of records from an old table
CREATE TABLE <new_tableName> AS
INSERT INTO <new_tableName>
	SELECT * FROM <old_tableName> 
	WHERE <conditional expression>;
```

***

#### Aggregate Data

```sql
SELECT
	MAX(<colName>) AS highest,
	MIN(<colName>) AS lowest,
	SUM(<colName>) AS average,
	AVG(<colName>) AS total,
	COUNT(<colName>) AS 'number of records'
	COUNT(DISTINCT <colName>) AS 'number of unique records'
	-- FLOOR(SUM(<colName>)) -- 向上取整
	-- CEILING(SUM(<colName>)) -- 向下取整
FROM <tableName>
WHERE <conditional expression>;
```

```sql
-- Grouping
SELECT
	<colName1>,
	COUNT(<colName2>) AS 'number of records'
FROM <tableName>
JOIN <tableName2> USING <colName>
WHERE <conditional expression>
GROUP BY <colName1>, <colName3>
ORDER BY <colName2> DESC;
```

```sql
-- Filter data after grouping
SELECT
	<colName1>,
	COUNT(<colName2>) AS 'number of records'
FROM <tableName>
GROUP BY <colName1>
HAVING <conditional expression>;
```

```sql
-- Subtotals (MySQL specific function)
SELECT
	<colName1>,
	COUNT(<colName2>) AS 'number of records'
FROM <tableName>
GROUP BY <colName1> WITH ROLLUP;
```

```sql
-- 
SELECT * FROM <tableName> WHERE <colName> > ALL (num1, num2, ...);
-- 
SELECT * FROM <tableName> WHERE <colName> = ANY (num1, num2, ...);
SELECT * FROM <tableName> WHERE <colName> = SOME (num1, num2, ...);
```

***

### MySQL Specific Function

* Numeric Function

```sql
ROUND()
TRUNCATE()
CEILING()
FLOOT()
ABS()
RAND()
```

* String Function

```sql
LENGTH()
UPPER()
LOWER()
LTRIM()
RTRIM()
TRIM()
LEFT()
RIGHT()
SUBSTRING()
LOCATE()
REPLACE()
CONCAT()
```

* Date Function

```sql
NOW()
CURDATE()
CURTIME()
YEAR()
MONTH()
DAY()
HOUR()
MINUTE()
SECOND()
DAYNAME()
MONTHNAME()
EXTRACT(DAY FROM NOW())
```

```sql
DATE_FORMAT(NOW(), '%Y %m %d')
TIME_FORMAT(NOW(), '%H:%i %p')
```

```sql
DATE_ADD(NOW(), INTERVAL 1 DAY)
DATE_SUB(NOW(), INTERVAL 1 DAY)
DATEDIFF()
TIME_TO_SEC()
```

* Others Function

```sql
IFNULL(<colName>, "Not assigned")
COALESCE(<colName1>, <colName2>, "Not assigned")
```

```sql
IF(<conditional expression>, <trueValue>, <falseValue>)
```

```sql
CASE 
	WHEN <conditional expression1> THEN <trueValue1>
	WHEN <conditional expression2> THEN <trueValue2>
	ELSE <falseValue>
END
```

* https://dev.mysql.com/doc/refman/8.0/en/

***

### View Data

```sql
-- Create temporary virtual table
CREATE VIEW <viewName> AS 
	SELECT * FROM <tableName>;
-- Delete temporary virtual table
DROP VIEW <viewName>;
-- Change temporary virtual table
REPLACE VIEW <viewBame> AS
-- Create or Change (recommend)
CREATE OR REPLACE VIEW <viewBame> AS
```

* Updatable view
  * `DISTINCT`, `GROUP BY`, `HAVING`, `UNION`, Aggregate function were not used when creating the view
  * When we do not have permission to change the original table, we can insert new records, change records, and delete records into the view
  * `WITH CHECK OPTION`: Prevent records from being lost from view when changing them

```sql
CREATE OR REPLACE VIEW <viewBame> AS
SELECT * FROM <tableName>
WHERE <conditional expression>
WITH CHECK OPTION;
```

***

### Stored Procedure

```sql
DELIMITER $$ -- Change default delimiter
-- Create a procedure
CREATE PROCEDURE <procedureName>(
    <parameterName1> INT, 
    OUT <parameterName2> CHAR(2), -- Output parameters
    ...)
BEGIN
	-- Default parameters
	IF <parameterName> IS NULL THEN
		SET <parameterName> = 'X';
	END IF;
	-- Parameter validation, report an error and return code
	IF <parameterName> <= 0 THEN
		SIGNAL SQLSTATE '22003' 
			SET MESSAGE_TEXT = 'A numeric value is out of range.';
	END IF;
	SELECT * 
		INTO <parameterName2> -- Output parameters
		FROM <tableName>;
END$$
DELIMITER ; -- reset
--
DELIMITER $$ -- Change default delimiter
-- Create a procedure
CREATE PROCEDURE <procedureName>(<parameterName> INT, <parameterName> CHAR(2), ...)
BEGIN
	IF <parameterName> IS NULL THEN
		SELECT * FROM <tableName>;
	ELSE
		SELECT * FROM <tableName> WHERE <colName> = <parameterName>;
	END IF;
END$$
DELIMITER ; -- reset
--
DELIMITER $$ -- Change default delimiter
-- Create a procedure
CREATE PROCEDURE <procedureName>(<parameterName> INT)
BEGIN
	SELECT * FROM <tableName> WHERE <colName> = IFNULL(<parameterName>, <colName>);
END$$
DELIMITER ; -- reset
```

```sql
-- Other programming languages call SQL procedure
CALL <procedureName>(<parameterValue>)
-- Delete procedure
DROP PROCEDURE <procedureName>;
DROP PROCEDURE IF EXISTS <procedureName>; -- more safer
```

```sql
-- Set user or session variables
SET @<variableName> = <variableValue>;
-- Declare local variables
DECLARE <variableName> INT
DECLARE <variableName> INT DEFAULT 0;
SET <variableName> = <variableValue>;
SELECT <variableName>
-- Show all variables
SHOW VARIABLES;
SHOW VARIABLES LIKE 'XXX%';
```

```sql
-- Create function
CREATE FUNCTION <functionName>(<parameterName> INT)
RETURNS INTEGER -- INTEGER is return value type
-- DETERMINISTIC 
READS SQL DATA 
MODIFIES SQL DATA
BEGIN
	RETURN <returnValue>;
END
-- Delete function
DROP FUNCTION IF EXISTS <functionName>;
```

* [SQLSTATE values and common error codes](https://www.ibm.com/docs/en/db2-for-zos/11?topic=codes-sqlstate-values-common-error)

***

### Triggers & Events

Triggers: A block of SQL code that automatically gets executed before or after an insert, update or delete statement.

```sql
DELIMITER $$
CREATE TRIGGER <triggerName_after_insert>
	AFTER INSERT ON <tableName1>
	FOR EACH ROW
BEGIN
	UPDATE <tableName2> SET <colValue> = <colValue> + NEW.amount;
	-- Documentation program audit or logging
	INSERT INTO <option_audit> VALUES (NEW.date, ...);
END$$
DELIMITER ;
```

```sql
-- Show all triggers
SHOW TRIGGERS;
SHOW TRIGGERS LIKE 'XXX%';
-- Delete triggers
DROP TRIGGERS IF EXISTS <triggerName>;
```

Events: A task (block of SQL code) that gets executed according to a schedule.

```sql
DELIMITER $$
CREATE EVENT <eventName>
ON SCHEDULE
	-- Disposable
	AT '2020-01-01'
	-- Regular
	EVERY 1 MONTH STARTS '2020-01-01' ENDS '2050-01-01'
DO BEGIN
	DELETE FROM <tableName>
	WHERE <action_date> < NOW() - INTERVAL 1 MONTH;
END $$
DELIMITER ;
```

```sql
SET GLOBAL <eventName> = ON;
SHOW EVENTS;
DROP EVENT IF EXISTS <eventName>;
-- Change event, like CREATE EVENT
ALTER EVENT <eventName>
-- 暂时禁用event
ALTER EVENT <eventName> DISABLE
-- 暂时启用event
ALTER EVENT <eventName> ENABLE
```

***

### Transactions

A group of SQL statements that represent a single unit of work.

```sql
-- Create a transaction
START TRANSACTION;
	<Operation statement>;
COMMIT;
START TRANSACTION;
	<Operation statement>;
ROLLBACK;
```

### Concurrency

```sql

```

***

### Index

***

### Design Database

***

### Database Permission Management

***

## MySQL

### Install MySQL
```shell
# Linux
apt-get install mysql-server
sudo mysql_secure_installation
systemctl status mysql.service
# Windows
net start mysql80
net stop mysql80
mysql [-h 127.0.0.1] [-P 3306] -u root -p
```
### Primary Key
1. 自增整数类型：数据库会在插入数据时自动为每一条记录分配一个自增整数，这样我们就完全不用担心主键重复，也不用自己预先生成主键；
2. 全局唯一**GUID**类型：使用一种全局唯一的字符串作为主键，类似**8f55d96b-8acc-4636-8cb8-76bf8abc2f57**。GUID算法通过网卡MAC地址、时间戳和随机数保证任意计算机在任意时间生成的字符串都是不同的，大部分编程语言都内置了GUID算法，可以自己预算出主键。

### Foreign Key
```mysql
-- add a foreign key
ALTER TABLE students
ADD CONSTRAINT fk_class_id
FOREIGN KEY (class_id)
REFERENCES classes (id);

-- delete a foreign key
ALTER TABLE students
DROP FOREIGN KEY fk_class_id;
```

* 外键约束的名称 fk_class_id 可以任意，FOREIGN KEY (class_id) 指定了 class_id 作为外键，REFERENCES classes (id) 指定了这个外键将关联到 classes 表的 id 列。

### Index
```mysql
-- create index
ALTER TABLE students
ADD INDEX idx_score (score);
-- create unique index
ALTER TABLE students
ADD UNIQUE INDEX uni_name (name);
-- create unique index for a col
ALTER TABLE students
ADD CONSTRAINT uni_name UNIQUE (name);
```
#### Multi-table query
```mysql
-- Cartesian query(笛卡尔查询)
SELECT * FROM tableName1, tableName2;
```

#### Replace exit data
```mysql
REPLACE INTO tableName (colName1, colName2, ...) VALUES (value1, value2, ...);
```
#### Insert or update data
```mysql
-- if data exit, will update this sql comLine
INSERT INTO tableName (colName1, colName2, ...) VALUES (value1, value2, ...) ON DUPLICATE KEY UPDATE colName1=value1, colName2=value2;
```
#### Insert or ignore data
```mysql
-- if data exit, will ignore this sql comLine
INSERT IGNORE INTO tableName (colName1, colName2, ...) VALUES (value1, value2, ...);
```
#### Write query result set
```mysql
-- eg:
CREATE TABLE statistics (
    id BIGINT NOT NULL AUTO_INCREMENT,
    class_id BIGINT NOT NULL,
    average DOUBLE NOT NULL,
    PRIMARY KEY (id)
);
INSERT INTO statistics (class_id, average) SELECT class_id, AVG(score) FROM students GROUP BY class_id;
```
#### Force the specified index
```mysql
-- idx_colName_id is exit
SELECT * FROM tableName FORCE INDEX (idx_colName_id) WHERE colName_id = 1 ORDER BY id DESC;
```
## MySQL Usage
MySQL Client的可执行程序是mysql
MySQL Server的可执行程序是mysqld

```shell
# open mysql server
mysql -u root -p
```
```mysql
-- query all databases in a SQL server
SHOW DATABASES;
-- information_schema, mysql, preformance_schema, sys is system library

-- create a new database
CREATE DATABASE databaseName;
-- delete database
DROP DATABASE databaseName;
-- switch database
USE databaseName;

-- query all table in a database
SHOW TABLE;
-- query a table information
DESC tableName;
-- query commandLine of table when it was created
SHOW CREATE TABLE tableName;
-- create a new table
CREATE TABLE
-- eg:
CREATE TABLE 'students'(
	'id' bigint(20) NOT NULL AUTO_INCREMENT,
	'class_id' bigint(20) NOT NULL,
	'name' varchar(100) NOT NULL,
	'gender' varchar(1) NOT NULL,
	'score' int(11) NOT NULL,
	PRIMARY KEY('id')
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8

-- delete table
DROP TABLE

-- add a col
ALTER TABLE tableName CHANGE COLUMN newColName VARCHAR(20) NOT NULL;
-- delete a col
ALTER TABLE tableName DROP COLUMN colName;

-- quit mysql
EXIT
```

***

# 数据库事务

## 数据库事务具有ACID这4个特性：
A：Atomic，原子性，将所有SQL作为原子工作单元执行，要么全部执行，要么全部不执行；
C：Consistent，一致性，事务完成后，所有数据的状态都是一致的，即A账户只要减去了100，B账户则必定加上了100；
I：Isolation，隔离性，如果有多个事务并发执行，每个事务作出的修改必须与其他事务隔离；
D：Duration，持久性，即事务完成后，对数据库数据的修改被持久化存储。

```mysql
BEGIN;
SQL command line 1;
SQL command line 2;
COMMIT;

BEGIN;
SQL command line 1;
SQL command line 2;
ROLLBACK;
```
## 隔离级别(sorry, I understanding)
SQL标准定义了4种隔离级别，分别对应可能出现的数据不一致的情况：
Isolation Level | 脏读（Dirty Read） | 不可重复读（Non Repeatable Read） | 幻读（Phantom Read）
-|-|-|-
Read Uncommitted | Yes | Yes | Yes
Read Committed | - | Yes | Yes
Repeatable Read | - | - | Yes
Serializable | - | - | -
* Read Uncommitted是隔离级别最低的一种事务级别。在这种隔离级别下，一个事务会读到另一个事务更新后但未提交的数据，如果另一个事务回滚，那么当前事务读到的数据就是脏数据，这就是脏读（Dirty Read）
* 在Read Committed隔离级别下，一个事务可能会遇到不可重复读（Non Repeatable Read）的问题。不可重复读是指，在一个事务内，多次读同一数据，在这个事务还没有结束时，如果另一个事务恰好修改了这个数据，那么，在第一个事务中，两次读取的数据就可能不一致。
* 在Repeatable Read隔离级别下，一个事务可能会遇到幻读（Phantom Read）的问题。幻读是指，在一个事务中，第一次查询某条记录，发现没有，但是，当试图更新这条不存在的记录时，竟然能成功，并且，再次读取同一条记录，它就神奇地出现了。
* Serializable是最严格的隔离级别。在Serializable隔离级别下，所有事务按照次序依次执行，因此，脏读、不可重复读、幻读都不会出现。虽然Serializable隔离级别下的事务具有最高的安全性，但是，由于事务是串行执行，所以效率会大大下降，应用程序的性能会急剧降低。如果没有特别重要的情景，一般都不会使用Serializable隔离级别。

***

# Test Code

```mysql
-- 如果test数据库不存在，就创建test数据库：
CREATE DATABASE IF NOT EXISTS test;

-- 切换到test数据库
USE test;

-- 删除classes表和students表（如果存在）：
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS students;

-- 创建classes表：
CREATE TABLE classes (
id BIGINT NOT NULL AUTO_INCREMENT,
name VARCHAR(100) NOT NULL,
PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 创建students表：
CREATE TABLE students (
id BIGINT NOT NULL AUTO_INCREMENT,
class_id BIGINT NOT NULL,
name VARCHAR(100) NOT NULL,
gender VARCHAR(1) NOT NULL,
score INT NOT NULL,
PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 插入classes记录：
INSERT INTO classes(id, name) VALUES (1, '一班');
INSERT INTO classes(id, name) VALUES (2, '二班');
INSERT INTO classes(id, name) VALUES (3, '三班');
INSERT INTO classes(id, name) VALUES (4, '四班');

-- 插入students记录：
INSERT INTO students (id, class_id, name, gender, score) VALUES (1, 1, '小明', 'M', 90);
INSERT INTO students (id, class_id, name, gender, score) VALUES (2, 1, '小红', 'F', 95);
INSERT INTO students (id, class_id, name, gender, score) VALUES (3, 1, '小军', 'M', 88);
INSERT INTO students (id, class_id, name, gender, score) VALUES (4, 1, '小米', 'F', 73);
INSERT INTO students (id, class_id, name, gender, score) VALUES (5, 2, '小白', 'F', 81);
INSERT INTO students (id, class_id, name, gender, score) VALUES (6, 2, '小兵', 'M', 55);
INSERT INTO students (id, class_id, name, gender, score) VALUES (7, 2, '小林', 'M', 85);
INSERT INTO students (id, class_id, name, gender, score) VALUES (8, 3, '小新', 'F', 91);
INSERT INTO students (id, class_id, name, gender, score) VALUES (9, 3, '小王', 'M', 89);
INSERT INTO students (id, class_id, name, gender, score) VALUES (10, 3, '小丽', 'F', 85);

-- OK:
SELECT 'ok' as 'result:';
```

***

# Reference

1. https://www.bilibili.com/video/BV1UE41147KC
2. https://dev.mysql.com/doc/refman/8.0/en/
3. https://www.liaoxuefeng.com/wiki/1177760294764384

