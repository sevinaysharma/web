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
* OC 中所有非公开的属性放到 **.m** 文件中，并已 "_" 开头命名
* 私有方法、公有方法和不同协议使用 `#pragma mark - ` 标记。Swift 使用 `// MARK: - `
* 赋值语句中 “=” 两边要有空格（`a = b`）
* OC 中使用数组时，必须指定成员的类型（`NSArray<NSString *> *classNameArray;`）
* 当一个类（A）的作为总入口，其实现逻辑按照功能模块拆分到不同类(B、C)中时，这些类作为 A 的专用类，命名应为（_B、_C），并且 A、_B、_C 要放到以 A 命名的文件夹（Group）中

# 发版

* 上线版本 Commit 命名为 **Version:x.x.x Build:buildCode**
* 上线后 feature 分支必须合并到主分支，feature 分支是否保留看情况