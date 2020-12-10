---
title: iOS Widget 开发记录
date: 2020-12-03 10:42:53
tags:
 - iOS14 Widget
categories:
 - iOS
---

关于 Widget 开发的具体技术细节可以参考官方资料 [WidgetKit](https://developer.apple.com/documentation/widgetkit/)。里面有详细的图文资料和视频教程。

特别是视频教程，涵盖了 Widget 开发需要的几乎所有技术细节。点赞

本文仅记录开发过程中遇到的问题和解决方案

# 项目概述

一句话概括为 **基于 Widget 的主题美化**。

因为 iOS 系统的天然限制，不能像 Android 一样通过代码直接应用到桌面。所以，这里的主题美化分为两部分。一是壁纸，二是基于 Widget 实现应用图标的个性化和图标排列的个性化。

现阶段完成效果如下图所示

![完成图](1.jpeg)

理想状态如下图所示

![理想图](2.jpg)


## 项目结构

*Widget 支持两种模式，静态模式（StaticConfiguration）和动态模式（IntentConfiguration）。静态模式下，界面是固定的，用户不可配置。这里主要描述的是 IntentConfiguration。*

项目由主应用（Host APP）、WidgetExtension Target、IntentExtension Target 三部分组成。三部分的交互流程如下图所示。

![主流程](Widget主流程.jpg)


这三者的关系可以概括为：Host 负责生成配置和需要的资源；IntentHandler 负责将主应用生成的信息加工后生成 Widget 可以直接使用的数据列表，让用户选择；Widget 根据 IntentHandler 生成的数据产生自己的 timeline 通过 UI 展示，并在用户点击时唤起 Host；Host 被 Widget 唤起后，通过 Widget 传递的信息执行对应的逻辑（功能）

# 注意点

## intentdefinition 文件

intentdefinition 文件定义了 Intent 属性和自定义参数。在自定义参数类型时，仅支持有限的基础数据类型。所以，为了把 app 列表、位置、名称等复杂的数据结构正常在不同 target 直接传递，采用了两层结构。

第一层为载体类（`LayoutInfoWrapperI`），第二层为具体配置信息（`Layout`）。具体配置信息作为载体类的属性存在。具体如下：

![载体类](载体类结构.jpg)

具体工作流为 

  Host 将 `Layout` 序列化后保存到共享空间
    IntentHandler 读取配置文件后生成 `LayoutInfoWrapperI` 实例，该实例携带 `Layout` 的 json 字符串
      用户选择某个配置后生成 Intent，该 Intent 携带 `LayoutInfoWrapperI` 实例
        Widget 在 `getTimeline` 方法中将 `Layout` json 字符串反序列化为 Layout 实例，并生成携带该实例的 `TimelineEntry` 数据载体
          Widget 根据 `TimelineEntry` 中的 Layout 信息构建 UI 并展示

`LayoutInfoWrapperI` 定义在 *intentdefinition* 文件中，由系统生成具体的类文件。


## 状态判断

Widget 可能处于以下几个状态：预览状态（01）、添加到屏幕但没有选择配置（02）、添加到屏幕并已选择配置（03）。

01 状态可以通过 Widget 生命周期函数中的 `Context` 参数判断。02 和 03 通过是否携带布局参数来判断

## 跳转 Host APP

* 当没有配置任何 scheme 时，用户点击 Widget 跳转 Host 不会触发 `- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options`

* 当 Widget 为 `systemSmall` 时，仅能通过控件的 `widgetURL` API 设置跳转的 Scheme 链接

* 当 Widget 不是 `systemSmall` 时，可以通过 `Link` 组件指定某个区域的 Scheme 跳转链接


## 多 Intent 支持

当默认使用 `SwiftUI.Widget` 作为主入口时，Widget Extension 所有类型 Widget 只能共用一个 Intent 类型。

如果想实现 `systemSmall` 使用 IntentA，`systemMedium` 使用 IntentB，`systemLarge` 使用 IntentC，可以使用 `SwiftUI.WidgetBundle` 作为主入口

# 探索

## Widget 进程问题

Widget 有自己的进程。并且定义的全局变量会被保留，不会在 `getTimeline` 方法执行完成后回收。

假设现在有两个配置可以选择，分别为 A 和 B。当时间线没有耗尽时，切换不同配置不会触发 `getTimeline` 的频繁回调