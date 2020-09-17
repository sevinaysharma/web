---
title: 【转】从 LayoutGuide 到Safe Area
date: 2020-09-17 14:03:40
tags:
 - LayoutGuide
 - SafeArea
categories:
 - iOS
---

> 本文转载自[iOS开发-LayoutGuide（从top/bottom LayoutGuide到Safe Area）](https://www.cnblogs.com/lurenq/p/7849813.html)。版权归作者所有

# iOS7 topLayoutGuide/bottomLayoutGuide

创建一个叫做LayoutGuideStudy的工程，我们打开看一下Main.storyboard：

![1](1.png)

可以看到 View Controller 下面出现 `topLayoutGuide/bottomLayoutGuide` 这两个东西，并且和 Controller 的 View 处于同一层级。并且在 `UIViewController` 头文件里面,这两个属性是 id 类型遵守一个 `UILayoutSupport` 协议并且是只读的属性

```
// These objects may be used as layout items in the NSLayoutConstraint API
@property(nonatomic,readonly,strong) id<UILayoutSupport> topLayoutGuide NS_AVAILABLE_IOS(7_0);
@property(nonatomic,readonly,strong) id<UILayoutSupport> bottomLayoutGuide NS_AVAILABLE_IOS(7_0);
```

这就说明了这两个 LayoutGuide 是系统自动创建并管理的，这也解释了刚刚我们创建的工程里面 `Main.storyboard` 为什么会自动出现 `topLayoutGuide/bottomLayoutGuide`。

## Demo&探索

我们拖拽一个红色的 `UIView` 到 Controller 的 view 里，添加约束的时候，注意到是右下角的约束设定框，关于顶部约束的基准 view 下拉选择，XCode 默认勾选了 `Top Layout Guide`

![2](2.png)

添加完宽高约束，最后约束如下所示

![3](3.png)

运行结果如下

![4](4.png)

可以看出 top 约束基于系统提供的 topLayoutGuide，系统会自动为这个 view 避开顶部状态栏。我们在 ViewController 里面打印红色 view

```
<UIView: 0x7ff10860fa90; frame = (0 20; 240 128); autoresize = RM+BM; layer = <CALayer: 0x60000003b5c0>>
```

看到红色 view 的 y 值就是 20。刚好是状态栏的高度。由此看出 Top Layout Guide 的作用就是在进行自动布局的时候，帮助开发者隔离出状态栏的空间。那么我们再看看导航控制器（顶部出现导航栏）的情况

![5](5.png)

运行结果如下

![6](6.png)

Top Layout Guide 同样自动帮助隔离出状态栏 + 导航栏。
在ViewController里面打印黄色view

```
<UIView: 0x7fb04fe08040; frame = (0 64; 240 128); autoresize = RM+BM; layer = <CALayer: 0x61800003ef60>>
```

看到黄色 view 的 y 值就是 64。刚好是状态栏 + 导航栏的高度。

同理，`bottomLayoutGuide` 就是用于在 TabbarController 里面隔离底部的 tabbar

![7](7.png)

## 扒一扒 topLayoutGuide/bottomLayoutGuide 对象

在UIViewController的viewDidLayoutSubviews方法打印

```
- (void)viewDidLayoutSubviews
 {
    [super viewDidLayoutSubviews];
    NSLog(@"topLayoutGuide-%@",self.topLayoutGuide);
    NSLog(@"bottomLayoutGuide-%@",self.bottomLayoutGuide);
}
```

打印结果如下

```
topLayoutGuide-
<_UILayoutGuide: 0x7fd7cce0c350; frame = (0 0; 0 64); hidden = YES; layer = <CALayer: 0x61000003f2c0>>

bottomLayoutGuide-
<_UILayoutGuide: 0x7fd7cce0d6b0; frame = (0 667; 0 0); hidden = YES; layer = <CALayer: 0x610000221620>>
```

这个是 `_UILayoutGuide` 类型的私有对象，看起来里面有 frame，hidden，layer 属性，感觉十分像 `UIView` 啊，那我们就验证一下

```
if ([self.topLayoutGuide isKindOfClass:[UIView class]]) {
    NSLog(@"topLayoutGuide is an UIView");
}
 if ([self.bottomLayoutGuide isKindOfClass:[UIView class]]) {
    NSLog(@"bottomLayoutGuide is an UIView");
}

// 打印结果
topLayoutGuide is an UIView
bottomLayoutGuide is an UIView
```

得到结论就是 topLayoutGuide/bottomLayoutGuide 其实是一个 `UIView` 类型的对象。
我们再打印一下 `UIViewController` 的 view 的 subviews

```
- (void)viewDidLayoutSubviews
 {
    [super viewDidLayoutSubviews];
     NSLog(@"viewController view subViews %@",self.view.subviews);
}

// 结果如下

viewController view subViews (
    "<UIView: 0x7ffc774035b0; frame = (0 64; 240 128); autoresize = RM+BM; layer = <CALayer: 0x60800002c720>>",
    "<_UILayoutGuide: 0x7ffc7740ae10; frame = (0 0; 0 64); hidden = YES; layer = <CALayer: 0x60800002c480>>",
    "<_UILayoutGuide: 0x7ffc7740b1e0; frame = (0 667; 0 0); hidden = YES; layer = <CALayer: 0x60800002b820>>"
)
```

## 总结

topLayoutGuide/bottomLayoutGuide 其实是作为虚拟的占坑 view，用于在自动布局的时候帮助开发者避开顶部的状态栏，导航栏以及底部的 tabbar 等。

# iOS9 UILayoutGuide

iOS9开始，苹果新增加了一个UILayoutGuide的类，看看苹果官方对它的解释

>The UILayoutGuide class defines a rectangular area that can interact with Auto Layout. 
>Use layout guides to replace the dummy views you may have created to represent
>inter-view spaces or encapsulation in your user interface

大概意思是 `UILayoutGuide` 用于提供一个矩形区域可以用 Auto Layout 来定制一些约束特性，作为一个虚拟的 view 使用。
我想大概是苹果的工程师觉得以前的 topLayoutGuide/bottomLayoutGuide 提供虚拟占坑 view，隔离导航栏/tabber的思想不错，进而有了启发，能不能让整个 LayoutGuide 变得更灵活，让开发者能够自由定制，于是这个 `UILayoutGuide 类就设计出来了

那么如何自由定制一个 UILayoutGuide，我们看看这个类的几个属性

```
@property(readonly, strong) NSLayoutXAxisAnchor *leadingAnchor;
@property(readonly, strong) NSLayoutXAxisAnchor *trailingAnchor;
@property(readonly, strong) NSLayoutXAxisAnchor *leftAnchor;
@property(readonly, strong) NSLayoutXAxisAnchor *rightAnchor;
@property(readonly, strong) NSLayoutYAxisAnchor *topAnchor;
@property(readonly, strong) NSLayoutYAxisAnchor *bottomAnchor;
@property(readonly, strong) NSLayoutDimension *widthAnchor;
@property(readonly, strong) NSLayoutDimension *heightAnchor;
@property(readonly, strong) NSLayoutXAxisAnchor *centerXAnchor;
@property(readonly, strong) NSLayoutYAxisAnchor *centerYAnchor;
```

`NSLayoutXAxisAnchor`，`NSLayoutYAxisAnchor`，`NSLayoutDimension` 这几个类也是跟随 `UILayoutGuide` 在 iOS9 以后新增的，即便很陌生，但我们看上面 `UILayoutGuide` 的几个属性里面leading，trailing，top，bottom，center 等熟悉的字眼，就能明白这些属性就是用于给 `UILayoutGuide` 对象增加布局约束的。

我们在看UIView里面新增的一个分类

```
@interface UIView (UIViewLayoutConstraintCreation)

@property(readonly, strong) NSLayoutXAxisAnchor *leadingAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutXAxisAnchor *trailingAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutXAxisAnchor *leftAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutXAxisAnchor *rightAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutYAxisAnchor *topAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutYAxisAnchor *bottomAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutDimension *widthAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutDimension *heightAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutXAxisAnchor *centerXAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutYAxisAnchor *centerYAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutYAxisAnchor *firstBaselineAnchor NS_AVAILABLE_IOS(9_0);
@property(readonly, strong) NSLayoutYAxisAnchor *lastBaselineAnchor NS_AVAILABLE_IOS(9_0);

@end
```

也是跟 `UILayoutGuide` 一样的提供了一致的属性。这就说明了 `UILayoutGuide` 是可以跟 `UIView` 进行 Auto Layout 的约束交互的。

## Demo&探索

创建一个 `UILayoutGuide`，约束它距离控制器view的顶部 64，左边 0，宽 250，高 200，于是在 viewDidLoad 方法里面的代码

```
// 创建
UILayoutGuide *layoutGuide = [[UILayoutGuide alloc] init];
// 需要使用UIView的addLayoutGuide方法添加新建的layoutGuide
[self.view addLayoutGuide:layoutGuide];
// 正式的约束代码
[layoutGuide.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:64].active = YES;
[layoutGuide.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
[layoutGuide.widthAnchor constraintEqualToConstant:250].active = YES;
[layoutGuide.heightAnchor constraintEqualToConstant:200].active = YES;
```

这样约束代码明显比使用 NSLayoutConstraint 简洁多了。

接着，我们再创建一个紫色 view，基于这个创建的 layoutGuide 进行约束，紫色 view 顶部距离上述 layoutGuide 底部 20，和 layoutGuide 左对齐，宽和高和 layoutGuide 保持一致

```
UIView *viewBaseLayoutGuide = [[UIView alloc] init];
viewBaseLayoutGuide.translatesAutoresizingMaskIntoConstraints = NO;
viewBaseLayoutGuide.backgroundColor = [UIColor purpleColor];
[self.view addSubview:viewBaseLayoutGuide];

[viewBaseLayoutGuide.topAnchor constraintEqualToAnchor:layoutGuide.bottomAnchor constant:20].active = YES;
[viewBaseLayoutGuide.leadingAnchor constraintEqualToAnchor:layoutGuide.leadingAnchor].active = YES;
[viewBaseLayoutGuide.widthAnchor constraintEqualToAnchor:layoutGuide.widthAnchor].active = YES;
[viewBaseLayoutGuide.heightAnchor constraintEqualToAnchor:layoutGuide.heightAnchor].active = YES;
```

运行结果如下

![8](8.png)

# iOS11 Safe Area / safeAreaLayoutGuide

iOS11 又引入了一个 Safe Area（安全区域）的概念，苹果建议在这个安全区域内放置 UI 控件。这个安全区域的范围其实就是整个屏幕隔离出状态栏，导航栏，tabar，以及 iPhone X 顶部刘海，底部虚拟 home 手势区域的范围。

从这个介绍可以看得出，所谓的 Safe Area 其实也就是升级版本的 topLayoutGuide/bottomLayoutGuide，以前只能限制 top/bottom 的 Layout，现在更加强大了。

再看一下 `UIViewController` 头文件：（用 XCode 9 以上版本打开）

```
@property(nonatomic,readonly,strong) id<UILayoutSupport> topLayoutGuide API_DEPRECATED_WITH_REPLACEMENT("-[UIView safeAreaLayoutGuide]", ios(7.0,11.0), tvos(7.0,11.0));
@property(nonatomic,readonly,strong) id<UILayoutSupport> bottomLayoutGuide API_DEPRECATED_WITH_REPLACEMENT("-[UIView safeAreaLayoutGuide]", ios(7.0,11.0), tvos(7.0,11.0));
```

苹果提示 topLayoutGuide/bottomLayoutGuide 这两个属性在 iOS11 已经过期，推荐使用 UIView 的 safeAreaLayoutGuide 属性（safeAreaLayoutGuide 稍后会介绍）。

另外用 XCode9 以上版本创建工程的时候，Main.storyboard 会默认选择 `Use Safe Area Layout Guides`，控制器 view 下面会出现 safe area

![9](9.png)

## Demo&探索

如上图所示，我们基于 storyboard 提供的控制器 view 的 safeArea 区域对红色的 view 进行约束：顶部距离安全区域 0，左边距离安全区域 0，宽 240，高 180

![10](10.png)

运行结果如下

![11](11.png)

为了验证 Safe Area 在竖屏 iPhone X 底部起到的隔离作用，又增加了一个棕色的 view：左边距离安全区域 0，底部距离安全区域 0，宽 240，高 180

![12](12.png)

运行结果如下

![13](13.png)

利用安全区域进行 Auto Layout 布局，分别在 iPhone 8，iPhone X 上以及避开了状态栏/刘海/底部的 home 虚拟手势区域，使得开发者不用关心状态栏以及适配 iPhone X 避开刘海的高度，只需要安安心心的苹果指定的这个安全区域放置子控件，布局就可以了。

## UIView 的safeAreaLayoutGuide属性

查看 UIView 在 iOS11 上关于 Safe Area 新增的两个属性

```
@property (nonatomic,readonly) UIEdgeInsets safeAreaInsets API_AVAILABLE(ios(11.0),tvos(11.0));
@property(nonatomic,readonly,strong) UILayoutGuide *safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));
```

很明显这个只读的 safeAreaLayoutGuide 属性是系统自动创建的，可以让开发者用代码进行基于安全区域进行自动布局。
点击控制器的 view 触发 touchesBegan 进行打印验证：

```
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"safeAreaInsets %@",NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    NSLog(@"safeAreaGuide %@",self.view.safeAreaLayoutGuide);
}
```

打印结果

```
safeAreaInsets {44, 0, 34, 0}
safeAreaGuide <UILayoutGuide: 0x6080009a3c60 - "UIViewSafeAreaLayoutGuide",
layoutFrame = {{0, 44}, {375, 734}}, owningView = <UIView: 0x7f888240c3b0; frame = (0 0; 375 812); 
autoresize = W+H; layer = <CALayer: 0x608000431ec0>>>
```

根据打印结果 safeAreaInsets.top=44，刚好是苹果规定的适配 iPhone X 要避开的刘海的距离，safeAreaInsets.bottom=34，刚好是底部的 home 虚拟手势区域的高度。

进行横屏切换后

![14](14.png)

再次点击控制器的 view 触发 touchesBegan 进行打印验证，打印结果：

```
safeAreaInsets {0, 44, 21, 44}
safeAreaGuide <UILayoutGuide: 0x6080009a3c60 - "UIViewSafeAreaLayoutGuide", layoutFrame =
{{44, 0}, {724, 354}}, owningView = <UIView: 0x7f888240c3b0; frame = (0 0; 812 375); autoresize =
W+H; layer = <CALayer: 0x608000431ec0>>>
```

旋转之后，safeAreaInsets.left 距离刘海隔离区域依然是 44，底部的 home 虚拟手势区域变成了 21。由此证明，系统也把屏幕旋转的情况也自动计算好了。

![15](15.png)

## iOS 11.0 之后系统新增安全区域变化方法

UIViewController中新增：

```
- (void)viewSafeAreaInsetsDidChange;
```

UIView中新增：

```
- (void)viewSafeAreaInsetsDidChange；
```

如果屏幕旋转，相应的安全区域也会变化，所以不比担心。

```
- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
     
    NSLog(@"viewSafeAreaInsetsDidChange-%@",NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
     
    [self updateOrientation];
}

/**
 更新屏幕safearea frame
 */
- (void)updateOrientation {
    if (@available(iOS 11.0, *)) {
        CGRect frame = self.customerView.frame;
        frame.origin.x = self.view.safeAreaInsets.left;
        frame.size.width = self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right;
        frame.size.height = self.view.frame.size.height - self.view.safeAreaInsets.bottom;
        self.customerView.frame = frame;
    } else {
        // Fallback on earlier versions
    }
}
```

![16](16.gif)

## UIScrollView/UICollectionView

在 iOS11 上所有 UIScrollView 及其子类默认会把内容放到 Safe Area 范围内，导致顶部会有空白区域或者 Cell 不能顶到屏幕最上面。为此，iOS 新增了方法来约束在 `UIScrollView` 上如何适配 Safe Area

```
@property(nonatomic) UIScrollViewContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior API_AVAILABLE(ios(11.0),tvos(11.0));
```

```
typedef NS_ENUM(NSInteger, UIScrollViewContentInsetAdjustmentBehavior) {
    UIScrollViewContentInsetAdjustmentAutomatic, // Similar to .scrollableAxes, but for backward compatibility will also adjust the top & bottom contentInset when the scroll view is owned by a view controller with automaticallyAdjustsScrollViewInsets = YES inside a navigation controller, regardless of whether the scroll view is scrollable
    UIScrollViewContentInsetAdjustmentScrollableAxes, // Edges for scrollable axes are adjusted (i.e., contentSize.width/height > frame.size.width/height or alwaysBounceHorizontal/Vertical = YES)
    UIScrollViewContentInsetAdjustmentNever, // contentInset is not adjusted
    UIScrollViewContentInsetAdjustmentAlways, // contentInset is always adjusted by the scroll view's safeAreaInsets
} API_AVAILABLE(ios(11.0),tvos(11.0));
```

# 总结

这次为了适配 iPhone X，个人从一开始看到 iOS11 的 Safe Area 这个概念，追溯到 iOS7 topLayoutGuide/bottomLayoutGuide，从头开始学习，受益匪浅。也体会到了苹果工程师针对 UI 适配，面向开发者进行的一系列探索，以及优化的心路历程。也看到了他们如何将一个好的思路，面对当前的需求变化，进行合理的扩展，设计出的灵活可扩展的 API：

1.iOS7: topLayoutGuide/bottomLayoutGuide，利用一个虚拟的 view 初步解决导航栏，tabbar 的隔离问题。

2.iOS9:有了虚拟 view 的思路,又考虑能不能去除 top/bottom 概念的局限性，让开发者都可以灵活自定义这个隔离区域，又提供一些更方便简洁易懂的API方便进行代码自动布局，于是有了 UILayoutGuide 这个类。

3.两年后的 iOS11，有了 iPhone X，苹果工程师顺理成章的将他们在 iOS9 的探索成果利用起来，他们自定义了一个 UILayoutGuide，给开发者提供了一个只读属性的 safeAreaLayoutGuide，并且提出安全区域的概念。