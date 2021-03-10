---
title: iOS 开发规范
date: 2021-03-10 00:54:34
tags:
 - iOS
categories:
 - 开发规范
---

# 类

* OC 私有方法名使用 “_” 开头
* OC 中所有非公开的属性放到 **.m** 文件中
* 私有方法、公有方法和不同协议使用 `#pragma mark - ` 标记。Swift 使用 `// MARK: - `
* 赋值语句中 “=” 两边要有空格（`a = b`）

# 发版

* 上线版本 Commit 命名为 **Version:x.x.x Build:buildCode**
* 上线后 feature 分支必须合并到主分支，feature 分支是否保留看情况