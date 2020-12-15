---
title: Swift 知识备忘
date: 2020-12-15 10:00:44
tags:
 - Swift
categories:
 - iOS
---

# 集合

## 弱引用数组

```
NSPointerArray(Array)
NSMapTable(Dic)
NSHashTable(Set)
```

# 注解

`@discardableResult`

修饰函数时，该函数的返回结果可以忽略

```
func test() -> String {
    return "A"
}

@discardableResult
func testA() -> String {
    return "B"
}

test()  // Result of call to 'test()' is unused

testA()
```

# 条件编译

```
#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endifs
```