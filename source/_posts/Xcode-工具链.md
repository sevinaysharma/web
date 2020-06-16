---
title: Xcode 工具链
date: 2020-06-17 01:21:16
tags:
- xcode
categories:
- xcode
---

Xcode 除了 GUI 用于日常开发外，还提供了大量的命令行工具。这些工具对于 CI 和理解 iOS 的细节有很大帮助（如：clang 重写 OC 文件为 CPP）

## Xcode Tools

### xcode-select

当有多个 Xcode 版本同时存在时，可以通过这个工具选择命令行使用的 Xcode 版本。这种选择是通过指定开发工具文件夹位置实现的。

详见 `xcode-select --help`

### xcrun

xcrun 可以执行其他 Xcode 相关命令，并为这个命令提供基于当前 Xcode 版本的环境信息。

例如，使用 `clang` 重写 OC 文件时，如果引用了 `<UIKit/UIKit.h>` 会提示 `fatal error: 'UIKit/UIKit.h' file not found`。

这是因为没有提供系统库路径，这个时候可以通过执行下面的命令解决这个问题 `xcrun -sdk iphonesimulator clang -rewrite-objc main.m`


xcrun 还可以实现应用上传商店和应用验证。详见 `xcrun altool --help`

### xcodebuild

这个工具用于构建 Xcode 项目。下面的简单脚本可以实现 AdHoc 版本的打包。使用脚本打包并上传商店和这里的类似。

```
#! /bin/sh

xcodebuild clean
pod install
xcodebuild -workspace Runner.xcworkspace -scheme Runner -archivePath $archivePath -allowProvisioningUpdates -allowProvisioningDeviceRegistration archive
xcodebuild -exportArchive -archivePath $archivePath -exportPath $ipaPath -exportOptionsPlist $exportOptionsPath
```

exportOptionsPath 是导出 ipa 的 plist 配置信息。具体支持的参数可以通过 `xcodebuild --help` 查看


## 编译 & 汇编

* clang: 编译 C、C++、Objective-C和 Objective-C 源文件。
* lldb: 调试C、C++、Objective-C 和 Objective-C 程序
* nasm: 汇编文件
* ndisasm: 反汇编文件
* symbols: 显示一个文件或者进程的符号信息。
* dwarfdump: 可以通过 dSYM 的信息。（如 dSYM 对应的指令集）
* strip: 删除或修改符号表附加到汇编器和链接编辑器的输出。
* atos: 将数字内存地址转换为二进制映像或进程的符号。

## 库

* ld: 将目标文件和库合并成一个文件。
* otool: 显示目标文件或库的指定部分。
* lipo: 创建、编辑、查看静态库
* ar: 创建和维护库文档。
* libtool: 使用链接器 ld 创建库。
* ranlib: 更新归档库的目录。
* mksdk: 创建和更新 SDK。
* lorder: 列出目标文件的依赖。