//
//  NIMChatroomHistoryMessageCallback.m
//  NIMLib
//
//  Created by chrisRay on 16/1/5.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomHistoryMessageCallback.h"
#import "chatroom_protocol.h"
#import "NIMModelConverter.h"
#import "NIMMessage_Private.h"

@implementation NIMChatroomHistoryMessageCallback

- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBChatroomHistoryMsgParam *msgParam = dynamic_cast<nimbiz::CBChatroomHistoryMsgParam *>(param);
    if (msgParam)
    {
        result.error = NIMRemoteError(msgParam->code_);
        if (!result.error) {
            std::list<nimbiz::Property> msgs = msgParam->msgs_;
            NSMutableArray *messages = [NSMutableArray array];
            nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
            if (core)
            {
                for (auto it = msgs.begin(); it!= msgs.end(); it++)
                {
                    nimbiz::Property messageProperty = *it;
                    NIMMessage *message = [NIMModelConverter chatroomMessageFromProperty:messageProperty];
                    
                    if (![messages containsObject:message])
                    {
                        //因为网络原因可能有下发重复消息数据，需要去重
                        [messages addObject:message];
                    }
                }
            }
            result.resultObject = messages;
        }
    }
}

- (void)run:(NIMCallbackResult *)result
{
    NSArray *msgs = (NSArray *)result.resultObject;
    NSError *error= result.error;
    
    if (_block) {
        _block(error,msgs);
    }
}

@end
