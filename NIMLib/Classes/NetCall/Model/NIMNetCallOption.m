//
//  NIMNetCallOption.m
//  NIMLib
//
//  Created by fenric on 16/1/4.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMNetCallOption.h"

@implementation NIMNetCallOption

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
