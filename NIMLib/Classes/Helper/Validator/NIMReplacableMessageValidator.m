//
//  NIMReplacableMessageValidator.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMReplacableMessageValidator.h"

@implementation NIMReplacableMessageValidator
- (BOOL)isValid
{
    NIMMessage *message = (NIMMessage *)[self.object nim_asObject:[NIMMessage class]];
    //消息是否可以被替换:大部分消息如果本地已经有一份了就不可以(也不用)被服务器消息替换
    //但是某些系统通知需要做替换:在收到通知后对本地的消息做一次替换
    return [message.messageObject isKindOfClass:[NIMNotificationObject class]]  &&
    [[(NIMNotificationObject *)(message.messageObject) content] isKindOfClass:[NIMNetCallNotificationContent class]];
}

- (BOOL)shouldLogError
{
    return NO;
}
@end
