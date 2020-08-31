---
title: iMessage (iOS 11 - iOS 13)
date: 2020-08-24 14:59:07
tags:
 - iMessage
categories:
 - iOS
---

# 消息

从类上分，消息一共分为 `MSMessage`、`MSSticker`、`NSString`、`NSURL`。

`NSString` 是直接把一段文本放到输入框发送。

`NSURL` 用于发送附件。所以这个 url 一定要是 *file URL*

`MSSticker` 和附件消息类似。用于把一张图片发送给对方，并且 iMessage 会直接呈现图片内容。只支持本地图片（file URL）

## MSMessage

`MSMessage` 是所有消息类型里面最强大的。之所以这么说，是因为，基于 `MSMessage` 可以开发有交互功能的消息。比如官方 demo [IceCreamBuilder: Building an iMessage Extension](https://developer.apple.com/documentation/messages/icecreambuilder_building_an_imessage_extension?language=objc)。

`MSMessage` 主要由三部分组成。`MSMessageLayout`、`NSURL *URL`、`NSString *summaryText`。*summaryText* 参照文档说明。`MSMessageLayout` 用于消息内容的布局。比如常用的 `MSMessageTemplateLayout` 支持图文模式展示消息。

对于可交互的 Message 来说，核心是如何保存数据和状态。`MSMessage` 的 *URL* 属性就是用来完成这个任务。每次发送消息时，可以通过自定义 URL 的 query 来携带必要的参数，通过定义 URL 的 path 来区分不同功能（当然也可以将这些信息都放到 query 中）。

使用 `MSMessage` 时，可以通过指定相同的 *session* 可以实现用新的消息内容替换旧的消息。需要注意的是：1. 新老消息都存在，只是 Messages.app 从视觉上处理成了替换效果；2. 只能替换自己发送的消息，对于收到的消息不能替换（一个是接收，一个是发送，方向不同）

## iOS 11

在 iOS 11 上，支持新的 layout `MSMessageLiveLayout`。这种新的 layout 支持让用户直接在消息体上操作而无需通过点击消息来触发新的操作。详见下面的视频(IceCreamBuilder为例)

<!-- {% asset_img iMessage_normal.mp4 %} -->

{% raw %}
<video src='/web/2020/08/24/iMessage-iOS-11-iOS-13/iMessage_normal.mp4' type='video/mp4' controls='controls' autoplay muted  width='30%' height='30%'>
</video>
<p>normal</p>
<video src='/web/2020/08/24/iMessage-iOS-11-iOS-13/iMessage_live_layout.mov' type='video/mov' controls='controls' autoplay muted  width='30%' height='30%'>
</video>
<p>live layout</p>
{% endraw %}

<!-- [MSMessageTemplateLayout](iMessage_normal.mp4)

[MSMessageLiveLayout](iMessage_live_layout.mov) -->


# 场景

在 iOS 11 上 iMessage App 只能出现在 iMessage 中。上下文为 `MSMessagesAppPresentationContextMessages`。从 iOS 12 开始，iMessage App 支持 FaceTime。如果要支持 FaceTime 需要在配置 infoPlist 中添加 `MSSupportedPresentationContexts` key。其值为数组 `MSMessagesAppPresentationContextMessages` 和 `MSMessagesAppPresentationContextMedia`。

Sticker Pack 默认全部支持上述场景，不需要特殊配置

详细的使用方法见 [Adding Sticker Packs and iMessage Apps to Effects in Messages and FaceTime](https://developer.apple.com/documentation/messages/adding_sticker_packs_and_imessage_apps_to_effects_in_messages_and_facetime?language=objc)

