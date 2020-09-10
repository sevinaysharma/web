---
title: 基于 NSProxy 实现的简单 AOP
date: 2020-09-10 10:35:52
tags:
 - OC
categories:
 - iOS
---

```
#ifndef WPProxyInvokerDelegate_h
#define WPProxyInvokerDelegate_h
#import <Foundation/Foundation.h>

@protocol WPProxyInvokerDelegate <NSObject>

// 提供了对单个 instance 的方法转发能力。返回非空值时，消息将转发到这个对象。
- (id)consumerForInvocation:(NSInvocation *)invocation withTarget:(id)target;
// target 没有 selector 实现时调用这个方法。YES 说明 invoker 实例提供了 selector 的实现，消息会转发给 invoker
- (BOOL)invokerHasImpForDefaultImp:(NSInvocation *)invocation;

@optional

- (void)beforeInvoke:(NSInvocation *)invocation withTarget:(id)target;
- (void)afterInvoke:(NSInvocation *)invocation withTarget:(id)target;

@end

#endif /* WPProxyInvokerDelegate_h */
```

```
#import <Foundation/Foundation.h>
#import "WPProxyInvokerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPProxy : NSProxy

- (id)initWithObject:(id)object invoker:(id<WPProxyInvokerDelegate>)invoker weakType:(BOOL)weakReference;

- (void)registerSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
```

```
#import "WPProxy.h"

@implementation WPProxy
{
    __weak id _weakTarget;
    __strong id _strongTarget;
    
    id<WPProxyInvokerDelegate> _invoker;
    
    BOOL _isWeakType;
    
    NSMutableArray *_selectors;
}
- (id)initWithObject:(id)object invoker:(id<WPProxyInvokerDelegate>)invoker weakType:(BOOL)weakReference {
    if (weakReference) {
        _weakTarget = object;
    } else {
        _strongTarget = object;
    }
    _isWeakType = weakReference;
    _invoker = invoker;
    _selectors = [NSMutableArray array];
    return self;
}

- (void)registerSelector:(SEL)selector {
    NSValue *selValue = [NSValue valueWithPointer:selector];
    [_selectors addObject:selValue];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    if (_isWeakType) {
        if (_weakTarget) {
            __strong typeof(_weakTarget) temp = _weakTarget;
            return [temp methodSignatureForSelector:sel];
        }
        return nil;
    } else {
        return [_strongTarget methodSignatureForSelector:sel];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {    
    __strong id target = nil;
    if (_isWeakType) {
        if (_weakTarget) {
            target = _weakTarget;
        }
    } else {
        target = _strongTarget;
    }
    if (!target) {
        return;
    }
    
    if (_selectors.count > 0) {
        SEL targetSelector = invocation.selector;
        for (NSValue *selValue in _selectors) {
            if (targetSelector == [selValue pointerValue]) {
                if ([_invoker respondsToSelector:@selector(beforeInvoke:withTarget:)]) {
                    [_invoker beforeInvoke:invocation withTarget:target];
                }
            }
        }
    } else {
        if ([_invoker respondsToSelector:@selector(beforeInvoke:withTarget:)]) {
            [_invoker beforeInvoke:invocation withTarget:target];
        }
    }
    
    id consumer = [_invoker consumerForInvocation:invocation withTarget:target];
    if (!consumer) {
        consumer = target;
    }
    
    if ([consumer respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:consumer];
    } else {
        if ([_invoker invokerHasImpForDefaultImp:invocation]) {
            [invocation invokeWithTarget:_invoker];
        }
    }
    
    if (_selectors.count > 0) {
        SEL targetSelector = invocation.selector;
        for (NSValue *selValue in _selectors) {
            if (targetSelector == [selValue pointerValue]) {
                if ([_invoker respondsToSelector:@selector(afterInvoke:withTarget:)]) {
                    [_invoker afterInvoke:invocation withTarget:target];
                }
            }
        }
    } else {
        if ([_invoker respondsToSelector:@selector(afterInvoke:withTarget:)]) {
            [_invoker afterInvoke:invocation withTarget:target];
        }
    }
}

@end
```


```
@interface NSInvocation (arguments)

- (id)aspect_argumentAtIndex:(NSUInteger)index;

@end

@implementation NSInvocation (arguments)

- (id)aspect_argumentAtIndex:(NSUInteger)index {
    const char *argType = [self.methodSignature getArgumentTypeAtIndex:index];
    // Skip const type qualifier.
    if (argType[0] == _C_CONST) argType++;

#define WRAP_AND_RETURN(type) do { type val = 0; [self getArgument:&val atIndex:(NSInteger)index]; return @(val); } while (0)
    
    if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing id returnObj;
        [self getArgument:&returnObj atIndex:(NSInteger)index];
        return returnObj;
    } else if (strcmp(argType, @encode(SEL)) == 0) {
        SEL selector = 0;
        [self getArgument:&selector atIndex:(NSInteger)index];
        return NSStringFromSelector(selector);
    } else if (strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing Class theClass = Nil;
        [self getArgument:&theClass atIndex:(NSInteger)index];
        return theClass;
        // Using this list will box the number with the appropriate constructor, instead of the generic NSValue.
    } else if (strcmp(argType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(argType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(argType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(argType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(argType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(argType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(argType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(bool)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        __unsafe_unretained id block = nil;
        [self getArgument:&block atIndex:(NSInteger)index];
        return [block copy];
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(argType, &valueSize, NULL);
        unsigned char valueBytes[valueSize];
        [self getArgument:valueBytes atIndex:(NSInteger)index];
        return [NSValue valueWithBytes:valueBytes objCType:argType];
    }
    return nil;
#undef WRAP_AND_RETURN
}

/**
 * 作者：一缕殇流化隐半边冰霜
 * 链接：https://juejin.im/post/6844903447263707143
 * 来源：掘金
 * 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
*/
```