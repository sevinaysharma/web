---
title: GitHub 常用库分类汇总
date: 2020-06-07 01:34:27
tags:
categories:
- GitHub
---

这篇文章作为 Github Star 列表的备份。

本人作为一个伪全栈，开发过程中用到了大量的优秀三方库。苦于 GitHub 没有分类功能，写了这篇备份文供日常使用

# 知识汇总

|名称|用途|
|:--:|:---|
|[computer-science](https://github.com/ossu/computer-science)|汇总了计算机科学相关的资料。从入门，算法，操作系统等等。相当全面|
|[architecture.of.internet-product](https://github.com/davideuler/architecture.of.internet-product)|各大公司架构汇总|
|[hello-vim](https://github.com/vim-china/hello-vim)|vim 手册|
|[The Art of Command Line](https://github.com/jlevy/the-art-of-command-line)|Bash 极简使用手册|
|[learn-regex](https://github.com/ziishaned/learn-regex)|正则表达式|
|[chinese-poetry](https://github.com/chinese-poetry/chinese-poetry)|古诗仓库|
|[interviews](https://github.com/kdn251/interviews)|面试相关|
|[TensorFlow 2.0深度学习开源书](https://github.com/dragen1860/Deep-Learning-with-TensorFlow-book)||
|[前端9册 2019](https://www.yuque.com/fe9/basic)||
# Android

## UI
|名称|用途|
|:--:|:---|
|[uCrop](https://github.com/Yalantis/uCrop "uCrop")|图片选择和剪裁库。现在常用的方式是调用系统的剪裁库。调用系统库的好处是防止剪裁过程出现 OOM，毕竟现在图片像素很高|
|[SmartSwipe](https://github.com/luckybilly/SmartSwipe)|一个完美抽象了滑动检测，刷新的库。可以方便实现侧滑返回，刷新|
|[StatusBarUtil](https://github.com/laobie/StatusBarUtil)|自定义状态栏颜色。如果 APP 最低兼容 5.0 以上，这个工具用处不大|
|[Markwon](https://github.com/noties/Markwon)|MarkDown 解析器。会解析成 Spannables。没有用到 Webview。速度快|

## 业务

|名称|用途|
|:--:|:---|
|[FileDownloader](https://github.com/lingochamp/FileDownloader)|文件下载库。自动支持断点下载|
|[MMKV](https://github.com/Tencent/MMKV)|腾讯出品键值存储库。支持多进程，支持基于 ID 的键值分组，支持自定义存储位置|
|[logger](https://github.com/orhanobut/logger)|日志框架，支持存储到本地、XML 和 JSON|
|[xLog](https://github.com/elvishew/xLog)|日志框架，支持存储到本地，XML 和 JSON。个人感觉比较好用。拥有和系统日志相同的方法名，方便迁移|
|[微信 xLog](https://github.com/Tencent/mars)|简单说就是牛。xLog 是微信开源的跨平台跨业务的终端基础组件 Mars 的一部分|
|[Logan](https://github.com/Meituan-Dianping/Logan)|美团出品日志框架。和 xLog 类似，支持日志上传机制（需自己实现上传的网络逻辑）|
|[RxJava](https://github.com/ReactiveX/RxJava)||
|[RxAndroid](https://github.com/ReactiveX/RxAndroid)||

## 知识

|名称|用途|
|:--:|:---|
|[AndroidProguard](https://github.com/HurTeng/AndroidProguard)|Proguard 语法|

## 深入
|名称|用途|
|:--:|:---|
|smali2java|将 smali 转为 java 的工具|
|apktool|反解 apk 程序和重新打包 apk。包括资源、manifest、代码（smali 语法）|
|jdgui|生成 jar、读取 jar、打包成 jar|

# iOS

## 业务

|名称|用途|
|:--:|:---|
|[SwiftGuide](https://github.com/ipader/SwiftGuide)|基于 Swift 的应用/工具集合|
|[youku-sdk-tool-woodpecker](https://github.com/alibaba/youku-sdk-tool-woodpecker)|优酷啄木鸟团队出的超厉害调试库。支持测试版和线上版本。涉及到 UI、网络、Crash、存储等|
|[DoraemonKit](https://github.com/didi/DoraemonKit)|滴滴出品调试工具|
|[Mantle](https://github.com/Mantle/Mantle)|OC Model 层框架|
|[ZipArchive](https://github.com/ZipArchive/ZipArchive)|iOS 端 ZIP 工具|
|[libphonenumber](https://github.com/google/libphonenumber)|全球电话号码格式化工具|
|[R.swift](https://github.com/mac-cain13/R.swift)|像 Android 一样通过 R 类访问应用内的资源。例如：`R.image.imageName()`|
|[RxSwift](https://github.com/ReactiveX/RxSwift)|Swift 异步框架|
|[SQLite.swift](https://github.com/stephencelis/SQLite.swift)|SQLite Wrapper|
|[SnapKit](https://github.com/SnapKit/SnapKit)|AutoLayout DSL|
|[Alamofire](https://github.com/Alamofire/Alamofire)|Swift 网络框架|
|[Axe](https://github.com/axe-org/axe)|业务组件化框架|
|[mailcore2](https://github.com/MailCore/mailcore2)|支持 iOS 和 MAC 的邮件库|
|[Hedwig](https://github.com/onevcat/Hedwig)|基于 Swift 的邮件框架|
|[ios-cmake](https://github.com/leetal/ios-cmake)|iOS 基于 CMake 的编译工具链|
|[IOSSecuritySuite](https://github.com/securing/IOSSecuritySuite)|华为开源的纯 Swift 写的安全库。可以检测是否越狱，恶意调试等|

## UI
|名称|用途|
|:--:|:---|
|[DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet)|列表空白页|
|[AAChartKit](https://github.com/AAChartModel/AAChartKit)|iOS 端图表工具|
|[Charts](https://github.com/danielgindi/Charts)|支持苹果全平台的图表工具|
|[Chameleon](https://github.com/viccalexander/Chameleon)|颜色工具。支持渐变色、主题、十六进制颜色等|

# Node & JS

## 业务 & 工具

|名称|用途|
|:--:|:---|
|[number-precision](https://github.com/nefe/number-precision)|浮点数字四舍五入到指定的位数。目前 JS 官方已有 toFixex 方法支持|
|[node-tenpay](https://github.com/befinal/node-tenpay)|微信支付脚手架|
|[ip2region](https://github.com/lionsoul2014/ip2region)|基于 IP 的定位工具|
|[axios](https://github.com/axios/axios)|支持 Promise 的 HTTP 框架|
|[koa](https://github.com/koajs/koa)|node 中间件框架|
|[nvm](https://github.com/nvm-sh/nvm)|node 版本管理工具|
|nrm|node 镜像源管理工具|
|moongoose|node 连接和操作 moongo 数据模块|

## UI

|名称|用途|
|:--:|:---|
|[strapi](https://github.com/strapi/strapi)|新一代 CMS 系统。|
|[omi](https://github.com/Tencent/omi)|腾讯出品前端工具集合。包括小程序端中心化存储框架、小程序 setData 优化框架等|
|[pasition](https://github.com/dntzhang/pasition)|轻量级过度动画库。基于路径（SVG Path）|
|[Cavas 动画绘制案例集合](https://github.com/Aaaaaaaty/blog)|各种基于 Cavas 实现的动画效果。包括粒子效果|

# 运维

|名称|用途|
|[postwoman](https://github.com/liyasthomas/postwoman)|api 管理工具。对应 postman|

# 数据库

|名称|用途|
|:--:|:---|
|[mysql-tutorial](https://github.com/jaywcjlove/mysql-tutorial)|MySQL 教程|

# 网络

|名称|用途|
|:--:|:---|
|[lanproxy](https://github.com/ffay/lanproxy)|将局域网个人电脑、服务器代理到公网的内网穿透工具。支持所有基于 tcp 的流量|
|[frp](https://github.com/fatedier/frp)|内网穿透工具|
|[n2n](https://github.com/ntop/n2n)|基于中心节点的端到端通信工具|
|[annie](https://github.com/iawia002/annie)|视频下载工具。支持 youtube 等|