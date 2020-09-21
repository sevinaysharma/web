---
title: '[转载] iOS开发之 Autolayout 详解'
date: 2020-09-20 15:54:45
tags:
 - AutoLayout
categories:
 - iOS
---

> 原文地址为[iOS开发之 Autolayout 详解](https://juejin.im/post/6844903612972269575)，版权及所有权归原作者所有。本文对排版做了适当修改



# 1. 概述

`Autolayout` 是 Apple 自 iOS6 开始引入的旨在解决不同屏幕之间布局适配的技术。苹果官方推荐开发者使用 Autolayout 进行 UI 界面的布局。

Autolayout 有两个核心概念：1. 参照。 2. 约束

使用 Autolayout 的注意点：

1. 添加约束之前需要保证控件已被添加到父控件中
2. 不需要再给 View 设置 frame
3. 禁止 autoresizing 功能。

# 2. 代码实现 Autolayout

## 2.1 实现步骤概述


**把 View 添加到父控件上**


**添加约束到相应的 View 上**

```
- (void)addConstraint:(NSLayoutConstraint *)constraint;
- (void)addConstraints:(NSArray<__kindof NSLayoutConstraint *> *)constraints;
```

**自动布局核心公式**

```
obj1.property1 =（obj2.property2 * multiplier）+ constantValue
```

## 2.2 Demo

添加一个左间距 100 上间距 200，宽 150 高 64 的红视图

```
- (void)testAutolayout1 {
    UIView *redV = [[UIView alloc] init];
    redV.backgroundColor = [UIColor redColor];
    redV.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:redV];
    /**
     view1 ：要约束的控件
     attr1 ：约束的类型（做怎样的约束）
     relation ：与参照控件之间的关系
     view2 ：参照的控件
     attr2 ：约束的类型（做怎样的约束）
     multiplier ：乘数
     c ：常量
     */
    /// 左间距100:
    NSLayoutConstraint *consLeft = [NSLayoutConstraint constraintWithItem:redV attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:100];
    [self.view addConstraint:consLeft];
    
    /// 上间距200:
    NSLayoutConstraint *consTop = [NSLayoutConstraint constraintWithItem:redV attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:200];
    [self.view addConstraint:consTop];
    
    /// 宽150:
    NSLayoutConstraint *consWidth = [NSLayoutConstraint constraintWithItem:redV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:150];
    [redV addConstraint:consWidth];
    
    /// 高64:
    NSLayoutConstraint *consHeight = [NSLayoutConstraint constraintWithItem:redV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:64];
    [redV addConstraint:consHeight];
}
```

复制代码在上视图基础上添加一个与红视图右间距相同，高度相同，顶部距离红色视图间距 20，宽度为红色视图一半的蓝色 View

```
UIView *blueV = [[UIView alloc] init];
blueV.backgroundColor = [UIColor blueColor];
blueV.translatesAutoresizingMaskIntoConstraints = NO;
[self.view addSubview:blueV];
    
/// 和 redV 右间距为0
NSLayoutConstraint *b_consRight = [NSLayoutConstraint constraintWithItem:blueV attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:redV attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
[self.view addConstraint:b_consRight];
    
/// 和 redV 等高
NSLayoutConstraint *b_consHeight = [NSLayoutConstraint constraintWithItem:blueV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:redV attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
[self.view addConstraint:b_consHeight];
    
/// 宽度是 redV 的一半
NSLayoutConstraint *b_consWidth = [NSLayoutConstraint constraintWithItem:blueV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:redV attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0];
[self.view addConstraint:b_consWidth];
    
/// 顶部距离 redV 20
NSLayoutConstraint *b_consTop = [NSLayoutConstraint constraintWithItem:blueV attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:redV attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20.0];
[self.view addConstraint:b_consTop];
```

复制代码最终效果：

![1](1.png)

## 2.3 添加约束的规则

在创建约束之后，需要将其添加到作用的 view上。在添加时要注意目标view需要遵循以下规则：

1. 对于两个同层级 view 之间的约束关系，添加到它们的父 view 上
2. 对于两个不同层级 view 之间的约束关系，添加到他们最近的共同父 view 上
3. 对于有层次关系的两个 view 之间的约束关系，添加到层次较高的父 view 上
4. 通过设置 `NSLayoutConstraint` 的 `active` 为 `YES` 系统会自动将该约束添加到合适的 View；设置为 `NO`，系统会自动从对应的 View 上移除该约束

# VFL

VFL 全称是 *Visual Format Language*，翻译过来是“可视化格式语言”，是苹果公司为了简化 Autolayout 的编码而推出的抽象语言。

```
    /*
     format ：VFL语句
     opts ：约束类型
     metrics ：VFL语句中用到的具体数值
     views ：VFL语句中用到的控件
     */
+ (NSArray<__kindof NSLayoutConstraint *> *)constraintsWithVisualFormat:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *,id> *)views;
```

`@{@"redV" : redV}` 等价于 `NSDictionaryOfVariableBindings(redV)`

```
NSDictionary *views = NSDictionaryOfVariableBindings(blueView, redView);

NSArray *conts2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[blueView(==blueHeight)]-margin-|" options:0 metrics:@{@"blueHeight" : @40, @"margin" : @20} views:views];
```

复制代码约束格式说明：

|||
|:-:|:--|
|方向|H:/V:|
|Views|[view]|
|SuperView|\||
|关系|>=,==,<=|
|空间,间隙|-|
|优先级|@value|

## 3.1 VFL 部分语法：

**H:|-100-[redV(200)]-|**
水平方向距离左边距 100，宽度 200

**V:|-200-[redV(64)]-|**
垂直方向距离顶部 200，高度 64

**H:[redV(72)]-12-[blueV(50)]**
水平方向 redV 宽度 72，blueV 宽度 50，他们之间间距 12

**H:[redV(>=60@700)]**
水平方向 redV 宽度大于等于 60，优先级为 700 （优先级最大 1000）

**V:[redBox]-[yellowBox(==redBox)]**
竖直方向上，先有一个 redBox，其下方紧接一个高度等于 redBox 高度的 yellowBox

**H:|-10-[Find]-[FindNext]-[FindField(>=20)]-|**
水平方向上，Find 距离父 view 左边缘 10，之后是 FindNext 距离 Find 间隔默认宽度；再之后是宽度不小于 20 的 FindField，它和 FindNext 以及父 view 右边缘的间距都是默认宽度。（竖线“|” 表示 superview 的边缘）

## 3.2 VFL的语法

标准间隔：[button]-[textField]

宽约束：[button(>=50)]

与父视图的关系：|-50-[purpleBox]-50-|

垂直布局：V:[topField]-10-[bottomField]

Flush Views：[maroonView][buleView]

权重：[button(100@20)]

等宽：[button(==button2)]

Multiple Predicates：[flexibleButton(>=70,<=100)]

### 注意事项

创建这种字符串时需要注意一下几点：

1. H: 和 V:每次都使用一个。
2. 视图变量名出现在方括号中，例如 `[view]`。
3. 字符串中顺序是按照从顶到底，从左到右
3. 视图间隔以数字常量出现，例如-10-。
4. `|` 表示父视图

## 3.3 使用 Auto Layout 时需要注意的点

1. 注意禁用 Autoresizing Masks。对于每个需要使用 Auto Layout 的视图需要调用 `setTranslatesAutoresizingMaskIntoConstraints:NO`
2. VFL 语句里不能包含空格和 `>`，`<` 这样的约束
3. 布局原理是由外向里布局，最先屏幕尺寸，再一层一层往里决定各个元素大小。
4. 删除视图时直接使用 removeConstraint 和 removeConstraints 时需要注意这样删除是没法删除视图不支持的约束导致 view 中还包含着那个约束（使用第三方库时需要特别注意下）。解决这个的办法就是添加约束时用一个局部变量保存下，删除时进行比较删掉和先前那个，还有个办法就是设置标记，`constraint.identifier = @“What you want to call”`。

## 3.4 View 的改变会调用哪些方法

改变 frame.origin 不会掉用 layoutSubviews

改变 frame.size 会使 superVIew 的 layoutSubviews 调用和自己 view 的 layoutSubviews 方法

改变 bounds.origin 和 bounds.size 都会调用 superView 和自己 view 的 layoutSubviews 方法

## 3.5 VFL Demo：

```
- (void)testVFL {
    UIView *redV = [[UIView alloc] init];
    redV.backgroundColor = [UIColor redColor];
    redV.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:redV];
    
    UIView *blueV = [[UIView alloc] init];
    blueV.backgroundColor = [UIColor blueColor];
    blueV.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:blueV];
    /*
     format ：VFL语句
     opts ：约束类型
     metrics ：VFL语句中用到的具体数值
     views ：VFL语句中用到的控件
     */
    //水平方向 redV 左右间距为20
    NSArray *cons1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[redV]-20-|" options:0 metrics:nil views:@{@"redV":redV}];
    [self.view addConstraints:cons1];
    
    //垂直方法redV距离顶部 100, redV 高度为64, blueV顶部距离redV 100 像素, blueV的高度等于redV
    NSArray *cons2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[redV(64)]-margin-[blueV(==redV)]" options:NSLayoutFormatAlignAllRight metrics:@{@"margin" : @100} views:NSDictionaryOfVariableBindings(redV,blueV)];
    [self.view addConstraints:cons2];
    
    NSLayoutConstraint *cons = [NSLayoutConstraint constraintWithItem:blueV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:redV attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0];
    [self.view addConstraint:cons];
}
```

运行结果：

![2](2.png)