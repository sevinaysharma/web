---
title: LivePhoto
date: 2020-08-11 10:01:22
tags:
 - LivePhoto
categories:
 - iOS
---

## 产品体验

1. 关于声音。LivePhoto 本身会记录声音。在相册查看时可以播放声音，在设置为动态壁纸时系统不会播放声音，此时只有画面
2. 主屏幕设定 LivePhoto 后只会显示 LivePhoto 中的静态图片
3. 手指结束按压后，视频停止播放，同时从当前视频帧的内容过度到 LivePhoto 中的静态图片

## 数据存储

LivePhoto 支持两种存储形式。默认使用容器格式 `HEIC`。容器中存储的是多张图片和对应的声音文件。另一种是兼容格式，将 LivePhoto 拆分为 `JPG` 文件和 `MOV` 视频文件。

***本文中实现 LivePhoto 效果是基于兼容格式实现***。


## 原理及实现

使用兼容模式实现 LivePhoto 效果主要分两步：1. 分别在图片和视频中添加相同的标识符，一般使用 `UUID`；2. 使用 `PHPhotoLibrary` 框架分别将视频和图片保存到相册

具体实现可以参照 [LivePhotoDemo](https://github.com/genadyo/LivePhotoDemo)

这里需要注意的是，生成 LivePhoto 预览数据 `PHLivePhoto` 时传入的参数是资源 URL。如果使用的视频和壁纸在服务器上，最好先将资源下载到本地，否则会导致预览无效果。