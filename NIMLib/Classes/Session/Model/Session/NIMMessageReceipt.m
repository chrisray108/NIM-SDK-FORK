//
//  NIMMessageReceipt.m
//  NIMLib
//
//  Created by amao on 2/29/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMMessageReceipt_Private.h"
#import "NIMMessage_Private.h"

@implementation NIMMessageReceipt

- (instancetype)initWithMessage:(NIMMessage *)message
{
    if (self = [super init]) {
        
        _session = [[message session] copy];
        _timestamp = [message timestamp];
        _messageId = [message messageId];
    }
    return self;
}
@end
