---
title: Git 常见错误
date: 2020-06-07 01:30:53
tags:
categories:
- Git
---

## 常见错误

### The remote end hung up unexpectedly

```
// 解决缓存控件不够导致的问题
git config http.postBuffer 524288000
// 或
git config --global http.postBuffer 524288000
// 或
git config ssh.postBuffer 524288000

// 解决因为网速慢导致的错误
git config --global http.lowSpeedTime 999999
```