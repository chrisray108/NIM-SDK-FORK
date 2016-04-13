//
//  NIMUserRequestValidator.m
//  NIMLib
//
//  Created by chris on 15/11/4.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMUserRequestValidator.h"
#import "NIMUser.h"

@implementation NIMUserRequestValidator

- (BOOL)isValid
{
    NIMUserRequest *request = [self.object nim_asObject:[NIMUserRequest class]];
    return request &&
    [request.userId isKindOfClass:[NSString class]] &&
    ([request.message isKindOfClass:[NSString class]] ||
     request.message == nil);
}


@end
