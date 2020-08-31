---
title: iMessage (iOS 11 - iOS 13)
date: 2020-08-24 14:59:07
tags:
 - iMessage
categories:
 - iOS
---

# 场景

在 iOS 11 上 iMessage App 只能出现在 iMessage 中。上下文为 `MSMessagesAppPresentationContextMessages`。从 iOS 12 开始，iMessage App 支持 FaceTime。如果要支持 FaceTime 需要在配置 infoPlist 中添加 `MSSupportedPresentationContexts` key。其值为数组 `MSMessagesAppPresentationContextMessages` 和 `MSMessagesAppPresentationContextMedia`。

Sticker Pack 默认全部支持上述场景，不需要特殊配置

详细的使用方法见 [Adding Sticker Packs and iMessage Apps to Effects in Messages and FaceTime](https://developer.apple.com/documentation/messages/adding_sticker_packs_and_imessage_apps_to_effects_in_messages_and_facetime?language=objc)

