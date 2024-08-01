---
title: PSQL 按时间分组查询
date: 2024-07-31T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [PostgreSQL, SQL, json, row_number, date_trunc]
---

```sql
SELECT 
  year,
  json_agg(json_build_object('id', id, 'thumbUrl', thumb_url, 'createTime', create_time)) AS items 
FROM (
  SELECT
    id,
    thumb_url,
    create_time,
    DATE_TRUNC('year', create_time) AS year,
    ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC('year', create_time) ORDER BY create_time DESC) AS row_num
  FROM
    "Image"
) AS subquery
WHERE row_num <= 3
GROUP BY year
ORDER BY year desc
```

> 需求：写一个查询语句，根据 create_time 字段，按时间分组（例如年），以 json 数组形式返回，每个分组下最多返回三条数据，返回示例如下

```json
[
  {
    "year": "2025-01-01T00:00:00.000Z",
    "items": [
      { "id": 1, "create_time": "2025-07-30T02:56:43.739" },
      { "id": 2, "create_time": "2025-07-29T02:56:43.739" },
      { "id": 3, "create_time": "2025-07-31T02:56:43.739" }
    ]
  },
  {
    "year": "2024-01-01T00:00:00.000Z",
    "items": [
      { "id": 4, "create_time": "2024-07-30T02:56:43.739" },
      { "id": 5, "create_time": "2024-07-31T02:56:43.739" }
    ]
  }
]
```

我们根据功能点一步一步实现这个需求

### 1 处理时间分类字段

Image 表中没有 year 或 month 字段，只有 Datetime 类型的 create_time

所以我们需要造出这个用于分组的字段

用 `DATE_TRUNC` 处理 Datetime 类型的数据，截取 create_time 字段对应的年份或月份作为要分类的字段

```sql
SELECT
    id,
    create_time,
    DATE_TRUNC('year', create_time) AS year
FROM
  "Image"
```

> DATE_TRUNC 方法用于将日期时间戳截断到指定的精度。它接受两个参数：
>
> - 截断精度: 指定要截断的日期时间部分。例如：year、month、day、hour、minute、second。
> - 日期时间戳: 要截断的日期时间值。
>
> DATE_TRUNC 方法返回一个截断后的日期时间戳。
>
> ```sql
> -- 截断到年
> SELECT DATE_TRUNC('year', '2023-10-26 12:34:56'); -- 返回 2023-01-01 00:00:00
> 
> -- 截断到月
> SELECT DATE_TRUNC('month', '2023-10-26 12:34:56'); -- 返回 2023-10-01 00:00:00
> 
> -- 截断到日
> SELECT DATE_TRUNC('day', '2023-10-26 12:34:56'); -- 返回 2023-10-26 00:00:00
> 
> -- 截断到小时
> SELECT DATE_TRUNC('hour', '2023-10-26 12:34:56'); -- 返回 2023-10-26 12:00:00
> 
> -- 截断到分钟
> SELECT DATE_TRUNC('minute', '2023-10-26 12:34:56'); -- 返回 2023-10-26 12:34:00
> 
> -- 截断到秒
> SELECT DATE_TRUNC('second', '2023-10-26 12:34:56'); -- 返回 2023-10-26 12:34:56
> ```
>

### 2 分组

```sql
SELECT
    id,
    create_time,
    DATE_TRUNC('year', create_time) AS year
FROM
    "Image"
GROUP BY
    year, id, create_time;
```

这里不做任何聚合，只是展示如何按年份分组

> 为啥不能直接 `GROUP BY year`？
>
> 根据 SQL 标准，如果在 SELECT 子句中使用了一个字段，那么这个字段要么应该是聚合函数的一部分（比如 COUNT, SUM, AVG），要么应该出现在 GROUP BY 子句中。否则，SQL 语句将无法执行，因为数据库无法确定如何处理这些字段
>
> 例如仅按 year 分组，数据库无法知道在 2024 年这一组中应如何处理 id 和 create_time 字段，因为每一组内可能有多个不同的 id 和 create_time 值

### 3 聚合为 JSON 数组

为了将分组后的记录聚合为 JSON 数组，我们需要先构建 JSON 对象，然后将这些对象聚合成数组。

这时使用子查询是为了在聚合之前完成分组和所需的数据处理。

子查询的作用：

预处理数据：在进行聚合操作之前，可以在子查询中预处理数据，确保我们在最终聚合时有一个干净的数据集。

逻辑隔离：将复杂的逻辑隔离在子查询中，使主查询更简洁和易读。

通过子查询，我们先进行年份分组，然后在外层查询中进行聚合

```sql
SELECT 
    year,
    json_agg(json_build_object('id', id, 'createTime', create_time)) AS items 
FROM (
    SELECT
        id,
        create_time,
        DATE_TRUNC('year', create_time) AS year
    FROM
        "Image"
) AS subquery
# 由于将 id、create_time 字段聚合成了 json 数组作为 items 字段，此时就可以只根据 year 来分组了
GROUP BY year;
```
> - `json_agg` 是 PostgreSQL 提供的一个聚合函数，用于将一组行聚合成一个 JSON 数组。每一行将作为 JSON 数组的一个元素。
> - `json_build_object` 是 PostgreSQL 提供的一个函数，用于创建一个 JSON 对象。它接受成对的键值参数，并返回一个 JSON 对象。

此时查询结果如下

| year                | items                                                        |
| ------------------- | ------------------------------------------------------------ |
| 2024-01-01 00:00:00 | [{"id" : "6ccd24be-5797-4a69-8193-da5fd24d5291", "createTime" : "2024-07-31T01:13:33.806"}, {"id" ... |
| 2025-01-01 00:00:00 | [{"id" : "51e4db24-0166-4b3d-81dc-0d11f35c7440", "createTime" : "2025-07-30T02:56:43.739"}, {"id" ... |

### 4 限制每组返回条数

增加 ROW_NUMBER 窗口函数：为每条记录分配行号，按年份分区，并按创建时间降序排序。

使用子查询过滤行号：

> - `ROW_NUMBER` 
>
> 是一种窗口函数（window function），用于为结果集中的每一行分配一个唯一的行号（从1开始）。它通常与 `OVER` 子句一起使用，以定义如何计算行号的窗口
>
> 语法：`ROW_NUMBER() OVER (window_specification)`
>
> 示例：`SELECT id, name, ROW_NUMBER() OVER (ORDER BY id) AS row_num FROM employees;`
>
> 在这个示例中，`ROW_NUMBER` 为每一行分配一个行号，按照 `id` 列排序
>
> - `OVER` 
>
> 用于定义窗口函数的窗口（即行集分组的方式）。它可以包含一个 `PARTITION BY` 子句用于定义分区，以及一个 `ORDER BY` 子句用于定义行的排序顺序。
>
> 语法：`window_function() OVER (window_specification)`
>
> `window_specification` 可以包含：`PARTITION BY` 子句：将数据分区；`ORDER BY` 子句：定义行的排序顺序；`ROWS` 或 `RANGE` 子句：进一步定义窗口范围（可选）。
>
> 示例：
>
> ```sql
> SELECT id, department, ROW_NUMBER() OVER (PARTITION BY department ORDER BY id) AS row_num
> FROM employees;
> ```
>
> 在这个示例中，`OVER` 子句定义了一个窗口，按 `department` 分区，并按 `id` 列排序，为每个部门内的每一行分配一个行号。
>
> - `PARTITION BY` 
>
> 子句用于将结果集划分为多个分区（子集），每个分区独立地应用窗口函数。分区中的每一行都分配一个行号，并且行号在每个分区内从1开始。
>
> 语法：`PARTITION BY expression`，其中 `expression` 可以是一个或多个列。
>
> 示例：
>
> ```sql
> SELECT id, department, salary, ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rank
> FROM employees;
> ```
>
> 在这个示例中，`PARTITION BY` 按 `department` 列分区，并按 `salary` 列降序排序，为每个分区内的每一行分配一个行号（排名）。

因此我们可以在子查询中在新增 row_num 行号列，根据 year 进行分区，使用 WHERE 筛选出不超过 3 的即可

```sql
SELECT 
  year,
  json_agg(json_build_object('id', id, 'thumbUrl', thumb_url, 'createTime', create_time)) AS items 
FROM (
  SELECT
    id,
    thumb_url,
    create_time,
    DATE_TRUNC('year', create_time) AS year,
    ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC('year', create_time) ORDER BY create_time DESC) AS row_num
  FROM
    "Image"
) AS subquery
WHERE row_num <= 3
GROUP BY year;
```

