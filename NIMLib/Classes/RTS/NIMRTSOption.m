//
//  NIMRTSOption.m
//  NIMLib
//
//  Created by 高峰 on 15/7/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMRTSOption.h"

@implementation NIMRTSOption

- (instancetype)init
{
    if (self = [super init]) {
        _apnsInuse = YES;
        _apnsBadge = YES;
        _apnsWithPrefix = YES;
    }
    return self;
}

@end
