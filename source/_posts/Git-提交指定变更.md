---
title: Git 提交指定变更
date: 2021-02-05 22:53:05
tags:
categories:
 - git
---

# 方式一

```
// 将指定的文件放到暂存区
git add filePath
// 将工作区所有变更放到暂存区
git add .
```

# 方式二

```
git add -p filePath
```

上面的命令用于将某个文件变更的一部分放到暂存区。该命令会触发一个交互界面。通过交互的方式可以将 hunk 放到暂存区或者变为更小范围的 hunk

![](1.png)

对应的命令含义如下

|参数|含义|
|:--:|:--|
|y|将这个 hunk 放到暂存区|
|n|不将这个 hunk 放到暂存区，并跳到下一个 hunk|
|q|退出交互模式|
|a|将这个 hunk 及后续所有 hunk 放到暂存区|
|d|这个 hunk 及后续所有 hunk 都不放到暂存区|
|g|跳转到指定的 hunk|
|/|搜索符合条件（正则）的 hunk|
|j|将当前 hunk 标记为 undecided，并跳到下一个状态为 undecided 的 hunk|
|J|将当前 hunk 标记为 undecided，并跳到下一个 hunk|
|k|将当前 hunk 标记为 undecided，并跳到上一个状态为 undecided 的 hunk|
|K|当前 hunk 标记为 undecided，并跳到上一个 hunk|
|s|将当前 hunk 拆分为更小的 hunk|
|e|编辑当前 hunk|
|？|输出帮助信息|

其大致流程如下图所示

![](2.jpg)

# 状态操作

```
// 输出暂存区和工作区的 diff
git diff --staged

// 将指定的变更从暂存区移到工作区
git reset -p
```