//
//  NIMLbsManager.h
//  NIMLib
//
//  Created by amao on 3/23/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    NIMLbsTypeLink = 0,
    NIMLbsTypeNOS  = 1,
} NIMLbsType;

@interface NIMLinkAddress : NSObject
@property (nonatomic,copy)      NSString *address;
@property (nonatomic,assign)    NSInteger port;
@end

@interface NIMLbsManager : NSObject
@property (atomic,assign)    BOOL    stopReportLink;    //有两种情况下需要暂时屏蔽Link地址的汇报 1.登出 2.第一次汇报后的1秒内

- (void)queryLbs;

- (NSString *)nosURL;

- (NIMLinkAddress *)link;

- (NSString *)nosAccURL;

- (void)reportError:(NIMLbsType)type
              fatal:(BOOL)fatal;

@end
