---
title: SQLite 随笔
date: 2020-10-12 21:32:43
tags:
 - SQLite
categories:
 - SQLite
---

# Demo 语句

## 删除超过指定数量（10）的数据

数据库名为 *SearchHistory* 拥有两个字段分别为 `keyword` 和 `updateDate`，其中 `keyword` 是不重复的主键。

需要注意的是 `in` 后面跟的是个集合，如果这个集合也是一个 query 语句，则一定要保证这个 query 返回的数据只有一个 column。所以 query 指定了 column 为 `keyword` 而不是用 `*`

```
delete from SearchHistory where (select count(*) from SearchHistory) > 10 and keyword in (select keyword from SearchHistory order by updateDate desc limit (select count(*) from SearchHistory) offset 10 )
```

下面的语句会报错，原因就是上面说的

```
delete from SearchHistory where (select count(*) from SearchHistory) > 10 and keyword in (select * from SearchHistory order by updateDate desc limit (select count(*) from SearchHistory) offset 10 )
```
