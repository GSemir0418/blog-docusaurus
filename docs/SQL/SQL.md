---
title: SQL
date: 2023-04-02T15:19:00+08:00
tags: ["SQL"]
sidebar-position: 1
authors: gsemir
---

## 基础

### 概念

SQL（**S**tructured **Q**uery **L**anguage）是一种操作和管理关系型数据库的编程语言

- 关系型数据库是将信息组织到一个或多个表中的数据库
- 表是将数据组织为行和列的数据集合

### 基础语句

- CREATE DATABASE someDataBase;

- DROP DATABASE someDataBase;

- SHOW DATABASES;

- USE someDataBase;

- CREATE TABLE

  - ```sql
    CREATE TABLE celebs (
       id INTEGER PRIMARY KEY, 
       name TEXT UNIQUE,
       date_of_birth TEXT NOT NULL,
       date_of_death TEXT DEFAULT 'Not Applicable'
    );
    ```

- INSERT INTO (VALUE)

  - ```sql
    INSERT INTO celebs (id, name, age) 
    VALUES (1, 'Justin Bieber', 22);
    ```

- SELECT

  - ```sql
    SELECT name, age FROM users;
    ```

- ALTER TABLE

  - ```sql
    ALTER TABLE users 
    ADD COLUMN address TEXT;
    ```

- UPDATE

  - ```sql
    UPDATE users 
    SET address = '@taylorswift13' 
    WHERE id = 4; 
    ```

- DELETE FROM

  - ```sql
    DELETE FROM users 
    WHERE address IS NULL;
    ```

## 查询

- SELECT

  - ```sql l
    SELECT column1, column2 
    FROM table_name;
    ```

- AS

  - ```sql
    # 别名
    SELECT name AS 'Titles'
    FROM movies;
    ```

- DISTINCT

  - ```sql
    # 去重
    SELECT DISTINCT tools 
    FROM inventory;
    ```

- WHERE

  - ```sql
    # =, !=, >, <, >=, <=, IS NULL, IS NOT NULL
    SELECT * 
    FROM movies 
    WHERE imdb_rating < 5;
    ```

- WHERE - LIKE

  - ```sql
    # 模糊匹配关键字 _字符占位符
    SELECT * 
    FROM movies
    WHERE name LIKE 'Se_en';
    # %任意字符占位符
    SELECT * 
    FROM movies
    WHERE name LIKE 'The %';
    ```

- WHERE - BETWEEN

  - ```sql
    # 90 年代电影
    SELECT *
    FROM movies
    WHERE year BETWEEN 1990 AND 1999;
    
    # 开头字母顺序 A 直到 J（不包含J开头的）的
    SELECT *
    FROM movies
    WHERE name BETWEEN 'A' AND 'J';
    ```

- WHERE - AND/OR

  - 交集/并集

- SELECT FROM - ORDER BY

  - ```sql
    SELECT name, year, imdb_rating
    FROM movies
    ORDER BY imdb_rating DESC/ASC;
    ```

- LIMIT

  - ```sql
    SELECT *
    FROM movies
    LIMIT 10;
    ```

- CASE

  - ```sql
    # 查询时对数据做条件判断，配合 AS 使用
    SELECT name,
     CASE
      WHEN genre = 'romance' THEN 'Chill'
      WHEN genre = 'comedy'  THEN 'Chill'
      ELSE 'Intense'
     END AS 'Mood'
    FROM movies;
    ```

## 合计函数

- COUNT

  - ```sql
    # 接受列名作为参数，返回该列中非空值的数量
    SELECT COUNT(*) 
    FROM fake_apps
    WHERE price = 0;
    ```

- SUM

  - ```sql
    # 接受列名作为参数，返回该列中所有值的总和
    SELECT SUM(downloads)
    FROM fake_apps;
    ```

- MAX / MIN

  - ```sql
    # 返回列中的最大值和最小值
    SELECT MAX(price)
    FROM fake_apps;
    ```

- AVG

  - ```sql
    # 平均值
    SELECT AVG(downloads)
    FROM fake_apps
    ```

- Round

  - ```sql
    # 按指定的小数位数进行舍入
    SELECT round(AVG(price), 2)
    FROM fake_apps;
    ```

- SELECT FROM - GROUP BY

  - ```sql
    # 分组
    SELECT year,
       AVG(imdb_rating)
    FROM movies
    GROUP BY year
    ORDER BY year;
    
    # 简写列名
    SELECT category, 
       price,
       AVG(downloads)
    FROM fake_apps
    GROUP BY 1, 2
    ORDER BY 2;
    ```

- HAVING

  - ```sql
    # 通常跟在 GROUP BY 后、 ORDER BY 和 LIMIT 前使用
    # 辅助组的筛选
    SELECT price, 
       ROUND(AVG(downloads)),
       COUNT(*)
    FROM fake_apps
    GROUP BY price
    having COUNT(*) > 10;
    ```

## 多表操作

- JOIN ON

  - ```sql
    SELECT *
    FROM orders
    JOIN subscriptions
      ON orders.subscription_id = subscriptions.subscription_id
    WHERE subscriptions.description = 'Fashion Magazine';
    # JOIN ON 默认为 INNER JOIN
    # 会自动排除匹配不到的数据行
    ```

- LEFT JOIN ON

  - ```sql
    # 会以左侧表为基准，保留左表匹配不到的数据作为一行
    SELECT COUNT(*)
    FROM online
    LEFT JOIN newspaper
      ON newspaper.id = online.id;
    ```

- PRIMARY KEY

  - ```
    主键不能为空
    值唯一
    每个表只能有一个
    ```

- FOREIGN KEY

  - ```
    当一个表的主键字段出现在其他表中，则称其为 外键
    外键的名称要语义化 order_id 
    ```

- CROSS JOIN

- UNION

  - ```sql
    # 将一个数据集堆叠在另一个数据集之上
    # 之所以叫数据集，是因为可能不是一个表，而是查询出来的数据
    # 两个数据集必须具有相同的列，且数据类型也一致
    select * from newspaper
    union
    select * from online;
    ```

- WITH

  - ```sql
    # 将查询数据集的逻辑抽离 或者提前查询
    # 例如先在 orders 表中统计每个 customer 的订阅数量
    # 再结合 customers 表数据将 customer_id 替换为 customer_name
    WITH previous_query AS (
       SELECT customer_id,
          COUNT(subscription_id) AS 'subscriptions'
       FROM orders
       GROUP BY customer_id
    )
    SELECT customers.customer_name, 
       previous_query.subscriptions
    FROM previous_query
    JOIN customers
      ON previous_query.customer_id = customers.customer_id;
    ```

    



