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