---
title: Android 获取 APK 信息
date: 2020-07-20 19:26:43
tags:
- Android
- APK
categories:
- Android
---


## 获取设备已安装软件的包名

```
adb shell pm list packages
```

## 根据包名获取安装路径

```
adb shell pm path ${packageName}
```

## 从设备下载文件

```
adb shell pull ${filePath}
```

## 查看 APK 的 Manifest

```
aapt dump xmltree apkName.apk AndroidManifest.xml
```

## aapt 解析包信息

```
aapt d badging apkName.apk
```

## dumpsys

```
// 支持的服务列表。常用的为 activity
adb shell dumpsys -l

// 使用方法可以搜索或者查看帮助文档
adb shell dumpsys ${serviceName} -h
// 比如
adb shell dumpsys activity -h
```

## apktool

解完包就没有秘密了，怎么用自己去搜索。