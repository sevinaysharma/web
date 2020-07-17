---
title: iOS 脚手架
date: 2020-07-08 10:12:51
tags:
- APNS
- PEM
categories:
- APNS Pem 证书
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