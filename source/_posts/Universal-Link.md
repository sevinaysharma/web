---
title: Universal Link (iOS9 - iOS13)
date: 2020-09-03 15:03:25
tags:
  - "Universal Link"
  - "Deep Link"
categories:
  - iOS
---

# 概述

*Universal Link* 是 iOS9 推出的新功能。目的是为了实现更友好的应用间跳转。以前使用 **Schemes** 方式跳转存在两个主要问题：1. Scheme 冲突；2. 未安装目标应用时，此次跳转无效

使用了 *Universal Link* 后，如果用户没有安装目标 APP，我们可以在跳转用的网页中加入产品介绍等引导内容，吸引用户下载。这样既提供了完整不被打断的跳转体验，又提升了应用的下载量。

*Universal Link* 目前苹果进行了四个迭代。iOS9 - iOS9.1 为第一个版本，iOS9.2 - iOS12 为第二个版本，iOS13 为第三个版本，即将到来的 iOS14 为第四个版本。

第二版相对于第一版，跳转逻辑更加严苛。当前页和 *Universal Link* 页必须不同域（跨域）才能触发打开应用操作，否则就是正常的 Web 页面跳转。比如 *Universal Link* 配置的域名为 `u.universal.com`，跳转匹配规则为 `/share/*`。则从 `https://u.universal.com/content` 跳转到 `https://u.universal.com/share/share.html` 不会打开应用，只会打开 `https://u.universal.com/share/share.html` 对应的 Web 页。而从 `https://u.content.com/content` 跳转到 `https://u.universal.com/share/share.html` 系统会打开 APP 并且拦截此次的 Web 跳转

第三版和第二版的区别在于 *apple-app-site-association* 格式不同，新版的路径匹配更灵活。

```
// 旧版
{
    "applinks": {
        "apps": [],
        "details": [{
            "appID": "D3KQX62K1A.com.example.photoapp",
            "paths": ["/albums"]
            },
            {
            "appID": "D3KQX62K1A.com.example.videoapp",
            "paths": ["/videos"]
        }]
    }
}
```

```
// 第三版
{
  "applinks": {
      "details": [
           {
             "appIDs": [ "ABCDE12345.com.example.app", "ABCDE12345.com.example.app2" ],
             "components": [
               {
                  "#": "no_universal_links",
                  "exclude": true,
                  "comment": "Matches any URL whose fragment equals no_universal_links and instructs the system not to open it as a universal link"
               },
               {
                  "/": "/buy/*",
                  "comment": "Matches any URL whose path starts with /buy/"
               },
               {
                  "/": "/help/website/*",
                  "exclude": true,
                  "comment": "Matches any URL whose path starts with /help/website/ and instructs the system not to open it as a universal link"
               }
               {
                  "/": "/help/*",
                  "?": { "articleNumber": "????" },
                  "comment": "Matches any URL whose path starts with /help/ and which has a query item with name 'articleNumber' and a value of exactly 4 characters"
               }
             ]
           }
       ]
   },
   "webcredentials": {
      "apps": [ "ABCDE12345.com.example.app" ]
   }
}
```

第四版相对于第三版却别在于，第四版加入了 CDN 的支持。之前的版本每次安装，系统都会直接访问 **Associated Domains** 中设置的域名获取配置文件。iOS14 后，系统不会直接访问开发者的服务器，而是向苹果的 CDN 网络请求数据，苹果 CDN 负责向开发者网站获取配置并更新配置信息。

## 配置

使用 *Universal Link* 需要使用如下几步：1. 添加 Domain（必须支持 https）；2. 在服务器特定位置添加配置文件；3. 开发分享页

### 添加 Associated Domains。

*Associated Domains* 格式为 `<service>:<fully qualified domain>`。

详见[Associated Domains Entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_associated-domains?language=objc)

### apple-app-site-association

*apple-app-site-association* 经历了两个版本的迭代，为了适配不同版本，需要把两个版本的配置放到一个文件中。因为 `details` 字段为数组，所以可以直接将不同版本的配置放到里面

```
{
    "applinks": {
        "apps": [],
        "details": [
            {
            "appID": "D3KQX62K1A.com.example.photoapp",
            "paths": ["/albums"]
            },
            {
            "appID": "D3KQX62K1A.com.example.videoapp",
            "paths": ["/videos"]
            },
            {
             "appIDs": [ "D3KQX62K1A.com.example.photoapp"],
             "components": [
               {
                  "/": "/albums/*",
                  "comment": "Matches any URL whose path starts with /albums/"
               }
             ]
           },
           {
             "appIDs": [ "D3KQX62K1A.com.example.videoapp"],
             "components": [
               {
                  "/": "/videos/*",
                  "comment": "Matches any URL whose path starts with /videos/"
               }
             ]
           }
        ]
    }
}
```

上面的样例就兼顾了新老版本。

需要注意的是，文件名必须为 `apple-app-site-association`，不能带任何其他字符和拓展名。文件编码为 `UTF-8`

其他事项请参考 [Supporting Associated Domains](https://developer.apple.com/documentation/safariservices/supporting_associated_domains?language=objc)


|符号|含义|
|:-:|:---|
|/|The pattern to match with the URL path component. The default is *, which matches everything.
|?|The pattern or dictionary to match with the URL query component. The default is *, which matches everything.Possible types: string, applinks.Details.Components.Query|
|#|The pattern to match with the URL fragment component. The default is *, which matches everything.|
|exclude|A Boolean value that indicates whether to stop pattern matching and prevent the universal link from opening if the URL matches the associated pattern. The default is false.|
|comment||Text that the system ignores. Use this to provide information about the URLs a pattern matches.|
|caseSensitive|A Boolean value that indicates whether pattern matching is case-sensitive. The default is true.|
|percentEncoded|A Boolean value that indicates whether URLs are percent-encoded. The default is true.|

[applinks.Details.Components](https://developer.apple.com/documentation/bundleresources/applinks/details/components?language=objc)


### Universal Link 页面

这里需要注意的是跨域问题。iOS9.2 以后需要跨域访问指定的 domain 才能触发打开 APP 操作。详见**概述**

目前微信 7.0.15 放开了 Universal Link（具体从哪个版本开始没有考究）。

对于 Safari 浏览器来说，还有一种方式可以跳转应用或者商店，那就是使用 Safari 定制版 meta `<meta charset="UTF-8" name="apple-itunes-app" content="app-id=yourAppId, affiliate-data=yourAffiliateData, app-argument=yourScheme://aa.com">`。使用了上面的代码后，用 Safari 浏览器打开时顶部会有 APP 信息栏。如果用户已经安装了应用，点击就跳转应用；如果用户没有安装，则点击跳转商店。

![](safari_meta.png)

目前头条新闻分享的 Universal Link 实现是本人最喜欢的。当应用安装了时可以触发跳应用，没安装时跳商店（非 meta 方式）。流程是，先尝试 Universal Link，如果不能跳转，就打开 APP STORE。具体代码实现还没有理清楚（代码经过了压缩和混淆，打码量大，还没有定位到）

```
{
    unfoldArticle: "https://article.zlink.toutiao.com/hM19",
    comment: "https://article.zlink.toutiao.com/FwDH",
    hotBoard: "https://article.zlink.toutiao.com/UH4x",
    recommended: "https://article.zlink.toutiao.com/8tdJ",
    searchWords: "https://article.zlink.toutiao.com/SUSd",
    bottomBanner: "https://article.zlink.toutiao.com/6Rbe",
    endcard: "https://article.zlink.toutiao.com/Vyb",
    weitoutiao: "https://article.zlink.toutiao.com/Mrqp",
    video: "https://article.zlink.toutiao.com/LEeg",
    default: "https://article.zlink.toutiao.com/PqER"
}

https://article.zlink.toutiao.com/hM19?scheme=sslocal%3A%2F%2Fdetail%3Fgroupid%3D6867708694365209101%26gd_label%3Dclick_wap_test_unfoldArticle%26needlaunchlog%3D1%26zlink%3Dhttps%253A%252F%252Farticle.zlink.toutiao.com%252FhM19%26zlink_click_time%3D1599125754759%26zlink_data%3D%257B%2522position%2522%253A%2522unfoldArticle%2522%252C%2522gid%2522%253A%25226867708694365209101%2522%252C%2522vid%2522%253A%2522%2522%252C%2522utm_source%2522%253A%2522weixin%2522%257D
```