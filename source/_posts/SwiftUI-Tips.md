---
title: SwiftUI Tips
date: 2020-12-18 14:36:33
tags:
 - SwiftUI
categories:
 - iOS
toc: true
---

# Debug

## 打印调试信息

```
func debug() -> Self {
    print(Mirror(reflecting: self).subjectType)
    return self
}
```

需要注意的是，在使用 SWiftUI 开发小组件的时候，因为运行环境的限制，`Mirror` 和 `\(self)` 这种语法不能输出任何信息。`\()` 语法对应的字符串拼接可以正常执行。

在调试 iOS 14 小组件的时候，直接运行小组件对应的 Scheme，如果要打印出有效信息，需要做如下配置：(涂红的部分选择 extension 所在的主应用)

![第一步](01.jpg)
![第二步](02.jpg)

# UI

## LiberyContentProvider

可以构建自己的组件库，像系统控件一样被 XCode 识别，并预览

![](03.webp)
![](04.webp)

