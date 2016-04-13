//
//  NIMFileInfo.m
//  NIMLib
//
//  Created by amao on 5/4/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMFileInfo.h"

#pragma mark - NIMFileCallback
@implementation NIMFileCallback
@end

#pragma mark - NIMFileCenterInfo

@interface NIMFileInfo ()
{
    NSMutableArray  *_callbacks;
}
@end


@implementation NIMFileInfo
- (instancetype)init
{
    if (self = [super init])
    {
        _callbacks = [NSMutableArray array];
        _retryTimes = 3;
    }
    return self;
}

- (void)addCallback:(NIMFileCallback *)callback
{
    if (callback)
    {
        [_callbacks addObject:callback];
    }
}


- (NSArray *)callbacks
{
    return _callbacks;
}

@end