//
//  NIMMessageValidator.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMMessageValidator.h"
#import "NIMMessage_Private.h"
#import "NIMNonEmptyStringValidator.h"

@implementation NIMMessageValidator
- (BOOL)isValid
{
    NIMMessage *message = (NIMMessage *)[self.object nim_asObject:[NIMMessage class]];
    return message &&
           [[NIMNonEmptyStringValidator validator:message.messageId] isValid] &&
           ([message.from isKindOfClass:[NSString class]] || !message.from);
}
@end
