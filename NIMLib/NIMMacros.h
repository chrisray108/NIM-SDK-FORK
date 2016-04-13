//
//  NIMMacros.h
//  NIMLib
//
//  Created by amao on 1/20/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef NIMLib_NIMMacros_h
#define NIMLib_NIMMacros_h

#if defined(__cplusplus)
#define NIM_EXTERN extern "C"
#else
#define NIM_EXTERN extern
#endif

#define NIMNotification(x)          NSString *x = @#x
#define NIMConfigTag(x)             NSString *x = @#x
#define UTF8(str)                   [(str) isKindOfClass:[NSString class]] ? ([(str) UTF8String] ? : "") : "" //NSString转std::string使用这个方法，避免用NULL去初始化std::string引起崩溃
#define NSUTF8(str)                 ((str).c_str() ? [NSString stringWithUTF8String:(str).c_str()] : @"")
#define NIMAssert()                 NSAssert(NO,@"invalid code path"); NIMLogErr(@"invalid code path");

#define NIMTimeLongToDouble(x)      (((double)(x)) / 1000.0)
#define NIMTimeDoubleToLong(x)      ((uint64_t)((x) * 1000))


#define NIMLocalError(x)            [NSError errorWithDomain:NIMLocalErrorDomain \
                                                        code:(x) \
                                                    userInfo:nil]

#define NIMRemoteError(x)           (x) == nimbiz::NIMResSuccess ? nil :  \
                                    [NSError errorWithDomain:NIMRemoteErrorDomain \
                                                        code:(x) \
                                                    userInfo:nil]


#define NIMIOS7            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)



//使用这个而不在工程配置里面设置,避免一些错误写法导致的方法不存在且不被发现
#define NIMSuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


#if defined(__LP64__) && __LP64__
#define NIMTry  @try
#define NIMCatch @catch
#else
#define NIMTry try
#define NIMCatch catch
#endif

#endif
