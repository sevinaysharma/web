---
title: iOS 脚手架
date: 2020-07-08 10:12:51
tags:
 - APNS
categories:
 - iOS
---


## 生成推送需要的 PEM 证书

```
// app_pushnotification.cer 为 Apple 服务器后台下载的证书
openssl x509 -in app_pushnotification.cer -inform der -out app_pushnotificationpass.pem
// apns_dev.p12 为包含了公私钥的证书
openssl pkcs12 -in apns_dev.p12 -nodes -nocerts -out app_pushnotification.pem
cat app_pushnotificationpass.pem app_pushnotification.pem > app_pushnotification_end.pem

// 或者使用
openssl pkcs12 -in MyApnsCert.p12 -out MyApnsCert.pem -nodes
```

## 不同版本注册推送

```
// iOS10 下需要使用新的 API
if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  // Enable or disable features based on authorization.
                                  if (granted) {
                                      [application registerForRemoteNotifications];
                                  }
                              }];
#endif
}
else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
    UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}else {
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
}
```

## 获取网络类型

```
+ (const NSString *)connectionType {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return @"";
    }
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        return @"wifi";
    }
    if (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0) {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            return @"wifi";
        }
    }
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
        if (info) {
            NSString *currentStatus = nil;
            if ([UIDevice currentDevice].systemVersion.floatValue >= 12.1) {
                if ([info respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsupported-availability-guard"
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
                    NSDictionary *dict = [info serviceCurrentRadioAccessTechnology];
#pragma clang diagnostic pop
                    if (dict.count) {
                        currentStatus = [dict objectForKey:dict.allKeys[0]];
                    }
                }
            } else {
                if ([info respondsToSelector:@selector(currentRadioAccessTechnology)]) {
                    currentStatus = [info currentRadioAccessTechnology];
                }
            }
            NSArray *network2G = @[CTRadioAccessTechnologyEdge,
                                   CTRadioAccessTechnologyGPRS,
                                   CTRadioAccessTechnologyCDMA1x];
            NSArray *network3G = @[CTRadioAccessTechnologyWCDMA,
                                   CTRadioAccessTechnologyHSDPA,
                                   CTRadioAccessTechnologyHSUPA,
                                   CTRadioAccessTechnologyCDMAEVDORev0,
                                   CTRadioAccessTechnologyCDMAEVDORevA,
                                   CTRadioAccessTechnologyCDMAEVDORevB,
                                   CTRadioAccessTechnologyeHRPD];
            NSArray *network4G = @[CTRadioAccessTechnologyLTE];
            if ([network2G containsObject:currentStatus]) {
                return @"2g";
            }
            if ([network3G containsObject:currentStatus]) {
                return @"3g";
            }
            if ([network4G containsObject:currentStatus]){
                return @"4g";
            }
            return @"cell_unknown";
        }
    }
    return @"";
}
```

## 程序主动到后台

```
// 进入后台
UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
// 结束应用
DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
  UIApplication.shared.perform(Selector(("terminateWithSuccess")))
}
```

# UI

## 引导用户评论

**跳转appStore评价页**

```
NSString  *nsStringToOpen = [NSString  stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@?action=write-review",@"APPID"];  //替换为对应的APPID
 
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:nsStringToOpen]];
```

这种方式的好处是，会直接打开商店的评论页面，可以一次性完成打星和评论两个功能

**APP 内部展示产品页评价**

```
// 1 . 引入
#import <StoreKit/StoreKit.h>

// 2 . 遵循 SKStoreProductViewControllerDelegate

// 3 . 引入方法
SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
    storeProductViewContorller.delegate = self;
    //加载App Store视图展示
    [storeProductViewContorller loadProductWithParameters:

      @{SKStoreProductParameterITunesItemIdentifier : @"APPID"} completionBlock:^(BOOL result, NSError *error) {

     if(error) {

     } else {

     //模态弹出appstore

     [self presentViewController:storeProductViewContorller animated:YES completion:^{
      }];
      }
}];

// 4.实现SKStoreProductViewControllerDelegate代理方法
(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
```

**应用内星级评价**

```
// 1. 引入
#import <StoreKit/StoreKit.h>

// 2. 实现方法
[SKStoreReviewController requestReview];
```

这种方式的缺点是，整个流程由系统接管，不保证每次都能正常弹出

## 计算壁纸的主色调是深色还是浅色

```
BOOL isDarkImage(UIImage* inputImage){
    
    BOOL isDark = FALSE;
    
    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(inputImage.CGImage));
    const UInt8 *pixels = CFDataGetBytePtr(imageData);
    
    int darkPixels = 0;
    
    int length = CFDataGetLength(imageData);
    int const darkPixelThreshold = (inputImage.size.width*inputImage.size.height)*.45;
    
    for(int i=0; i<length; i+=4)
    {
        int r = pixels[i];
        int g = pixels[i+1];
        int b = pixels[i+2];
        
        //luminance calculation gives more weight to r and b for human eyes
        float luminance = (0.299*r + 0.587*g + 0.114*b);
        if (luminance<150) darkPixels ++;
    }
    
    if (darkPixels >= darkPixelThreshold)
        isDark = YES;

    CFRelease(imageData);
    
    return isDark;
    
}
```