---
title: Git 查看变更历史
date: 2020-09-11 14:10:14
tags:
categories:
 - git
---

# git blame

这个命令用于向前追溯，查看文件当前版本的每一行是哪个版本修改得到的。

有一个文件 A，起初始内容如下，commit 为 “c1”

```
I am content.
perfect
```

修改后的版本如下，commit 为“c2”

```
He is clever.
perfect
```

使用 `git blame a`

```
c2 (author time 1) He is clever.
c1 (author time 2) perfect
```

使用 `--reverse` 可以追溯文件在指定的提交范围内最初的模样。所以 `git blame c1..c2 a` 的结果为

```
c1 (author time 1) I am content.
c2 (author time 2) perfect
```

说明第 2 行从 c1 到 c2 都没有变。第 1 行 从 c1 之后改变，改变前的内容为 `I am content`

# git diff

查看不同提交间修改了哪些内容

# git show

显示指定提交修改了哪些内容

# git log

查看提交记录。这是关于提交历史最强大的命令。最厉害的是对于已经删除的文件一样起作用。

`git log -- [file_path]` 这个命令可以查看某个文件的修改记录，如果这个文件已经被删除了（即当前工作区没有这个文件了），也可以查看。这样也就可以产看到这个文件具体是在哪个提交删除的

## git shortlog

可以提取提交相关的信息形成 summary。

`git shortlog -sn` 可以看到每个作者有多少个提交