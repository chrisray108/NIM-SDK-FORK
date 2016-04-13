//
//  NIMMessageHistorySearchOptionValidator.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMMessageHistorySearchOptionValidator.h"
#import "NIMMessageSearchOption.h"
#import "NIMMessageValidator.h"

#define NIMHistorySearchLimit 100
@implementation NIMMessageHistorySearchOptionValidator
- (BOOL)isValid
{
    NIMHistoryMessageSearchOption *option = (NIMHistoryMessageSearchOption *)[self.object nim_asObject:[NIMHistoryMessageSearchOption class]];
    return option &&
           option.startTime >= 0 &&
           option.endTime >= option.startTime &&
           (option.currentMessage == nil || (option.currentMessage && [[NIMMessageValidator validator:option.currentMessage] isValid])) &&
          option.limit <= NIMHistorySearchLimit;
}
@end


@implementation NIMChatroomMessageHistorySearchOptionValidator

- (BOOL)isValid
{
    NIMHistoryMessageSearchOption *option = (NIMHistoryMessageSearchOption *)[self.object nim_asObject:[NIMHistoryMessageSearchOption class]];
    return option &&
           option.startTime >= 0 &&
           option.limit <= NIMHistorySearchLimit;
}

@end
