---
title: iOS 踩坑实录
date: 2020-09-08 18:49:43
tags:
categories:
 - iOS
---

> 谨以此文致敬测试小哥哥小姐姐们的极限操作

# UI

## UIScrollView/UICollectionView

---
`- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView`

**场景描述**

在一个视频项目中用这个代理方法监测是否开始进行滑动，用 `- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView` 监测滑动停止。当开始滑动时视频停止，并显示预览图；停止滑动时自动播放，并显示播放画面。每个 Cell 均全屏显示，双击屏幕“暂停/播放”。所有 Cell 公用一个 `AVPlayer`，每个 Cell 保留自己的 `AVPlayerItem`。当停止滑动时给 Player 设置 `AVPlayerLayer` 和 `AVPlayerItem` 完成播放，当开始滑动时暂停播放，并置空（`nil`） `AVPlayerLayer` 的 `AVPlayer` 。

测试发现，当滑动到下一个 Cell 时立即多次点击屏幕有一定概率出现只播放声音没有画面的问题。经过分析日志发现并定位问题

**问题分析** 

`- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView` 表示视图将要滑动，但是此时还没有进行滑动。所以当系统觉得 *will* 这个行为消失，也没有进行实际滑动时，此时没有任何回调上报。即按照滑动做了准备，后续没有回调告诉你滑动停止了。这个情形就像 `UITouch` 没有了 cancel 回调

**问题修复**

在 delegate 中增加一个 `isScrolling` 属性。然后实现如下逻辑

```
// WP 开头的方法是因为对 delegate 进行了封装和再分发。场景中使用的是 WP 开头的方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.isDragging && !scrollView.decelerating && !scrollView.tracking) {
        // 刚初始化，没有进行任何滑动
        return;
    }
    if (self.isScrolling) {
        // 过滤连续的回调
        return;
    }
    self.isScrolling = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(WPScrollViewDidBeginDragging:)]) {
        [self.delegate WPScrollViewDidBeginMoving:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isScrolling = NO;
    if(self.delegate && [self.delegate respondsToSelector:@selector(WPScrollViewDidEndDecelerating:)]){
        [self.delegate WPScrollViewDidEndMoving:scrollView];
    }
}
```

## 同时支持 iPhone、iPad 设置了仅支持 portrait 但在 iPad 上依然会根据屏幕旋转

**问题描述**

应用同时支持 iPhone、iPad。在设置中仅勾选了支持 Portrait。实际发现在 iPad 上依然会随屏幕旋转。

**问题探索**

刚开始是怀疑苹果新增了控制参数或 API，通过设置 UIViewController 和 Application 的 orientation 参数发现，页面不会旋转了，但是启动页依然会随屏幕旋转。

经过一番查找资料，受一篇文章的启发，可能是漏设置了 iPad 上的参数。

![1.png](1.png)

上图是默认看到的设置界面。当把 iPhone 取消后，你会发现下图的样子

![2](2.png)

所以这是一个障眼法。通过修改配置会发现下图的修改

![3.png](3.png)

**问题回顾**

本质还是忽略了每个设备需要单独配置，这些配置包括但不限于国际化文件（string、xib等）、plist。不同设备以文件名区分。比如用于 iPad 的配置文件名格式为 `name~iPad.ext`。具体描述参考官方文档

## XIB

**问题描述**

有两个 XIB 布局 A 和 B，在对应的 XIB 中指定根节点 View 的类分别为 A、B，然后在 A 的 XIB 添加一个子 View（a），并指定其类型为 B。并在 A 类中设置 a 的 IBOutlet。使用如下代码加载 XIB

```
@interface A

@property(nonatomic, weak) IBOutlet B *aSubview;

@end

@implementation A
@end

@interface B

@property(nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation B
@end
```

```
A *view = (A *)[[[UINib nibWithNibName:@"A" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
// 或者
[[NSBundle mainBundle] loadNibNamed:@"A" owner:nil options:nil];
```

然后 发现 view 的 aSubview 实例自身的属性(titleLabel)为空（nil）。

**问题探索**

系统在加载 XIB 的时候会按照类型依次初始化其 subview，调用对应的 `- (instancetype)initWithCoder:(NSCoder *)coder` 方法。这里需要注意的是，此时如果，该 subview 也是通过 XIB 布局的（比如 B），就会导致 B 仅仅是把对应的类初始化，当不会加载其对应的 XIB 布局。所以需要正确处理 `- (instancetype)initWithCoder:(NSCoder *)coder` 方法。

这里就需要用到 XIB 中 *Placeholders* 中的 *File's Owner* 属性。在 B 的 XIB 中，将这个属性对应的类指定为 B。然后重写 B 对应的 `- (instancetype)initWithCoder:(NSCoder *)coder` 方法

```
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        UIView *view = (UIView *)[[[UINib nibWithNibName:@"A" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
        [self addSubview:view];
        // 设置 view 的 frame 或者 约束
    }
}
```