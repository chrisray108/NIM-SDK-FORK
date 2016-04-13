//
//  NIMRTSObject.m
//  NIMLib
//
//  Created by 高峰 on 15/7/15.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMRTSObject.h"
#import "NIMUtil.h"

@implementation NIMRTSObject

- (id)initWithServices:(NSUInteger)types
{
    if (self = [super init]) {
        _sessionID = [NIMUtil uuid];
        _services = types;
    }
    return self;
}

- (void)setBlockHandler:(id)block isCaller:(BOOL)caller
{
    if (caller) {
        _requestBlock = [(NIMRTSRequestHandler)block copy];
    }
    else {
        _responseBlock = [(NIMRTSResponseHandler)block copy];
    }
}

@end
