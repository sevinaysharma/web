---
title: Cocoapods 管理三方静态库
date: 2020-09-10 19:44:07
tags:
 - cocoapods
categories:
 - iOS
---

使用 cocoapods 管理三方静态库，主要分为： specs 仓库创建、静态库仓库创建、创建 `podspec` 文件。

cocoapods 使用 `podspec` 文件来描述 Pod 的描述信息、源码地址、构建参数、依赖。然后根据这些信息生成 Pod 的 Xcode 工程。所以，cocoapods 的描述文件和源代码可以放在两个地方。

# 项目结构

specs 仓库用于存放所有的描述文件，静态库仓库用于存放静态库。

为了方便我把 `podspec` 描述文件和三方库都放在了一个仓库中。`master` 分支用于存放 `podspec` 充当类似官方仓库的角色。然后每个三方库对应一个分支。

```
// 仓库结构示意图
|master
|__a
|_____version
|_______a.podspec
|__b
|_____version
|_______b.podspec
|qq-share-sdk
|__sdk-files
```

为了冗余错误操作，理清三方库的版本，对于私有库的三方库版本的版本号采用 `version+build` 的方式生成。比如 QQ 开放联盟的 SDK 版本号为 3.3.9，则对应 Pod 的版本号就为 3.3.9.0。这样既能和官方版本对应，又能冗余制作过程中的操作错误

# 流程

## 上传 SDK 到仓库对应分支

上传仓库后，需要对对应的提交按照上面讲的版本号规则对这个提交打 tag。

还以 QQ 分享为例。私有库版本号为 *3.3.9.0* ，则需要 `git tag -a "3.3.9.0" -m "custom message" commitID`

打 tag 的目的是为了在 spec 中，通过 branch+tag 的方式定位到 “使用哪个仓库的哪个版本”

## 制作 `podspec`

对于 `podspec` 文件的详细参数请参照 [podspec](https://guides.cocoapods.org/syntax/podspec.html)

生成 spec 后，通过 `pod spec lint a.podspec` 来检查生成的文件是否合规，是否有效。

## 上传 `podspec`

上传 spec 之前需要将私有仓库添加的本地的 repo 中 `pod repo add local_repo_name repo_url`

然后执行 `pod repo push local_repo_name podspec_path`。这样就可以把 spec 文件上传到仓库。

## 注意事项

1. 官方工具建议使用 https，如果要使用 ssh，在 `lint` 和 `push` 时需要添加 `--allow-warnings` 参数。
2. 不需要自己把 spec 用 git 推到远程仓库。使用 `pod repo push` 后，工具会自动推送到远程仓库，同时自动完成版本管理，不需要额外操作