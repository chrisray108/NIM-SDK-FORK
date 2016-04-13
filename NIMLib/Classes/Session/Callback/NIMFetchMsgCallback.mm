//
//  NIMFetchMsgCallback.m
//  NIMLib
//
//  Created by amao on 9/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMFetchMsgCallback.h"
#import "NIMConversationManager.h"
#import "NIMDispatch.h"
#import "NIMMessage_Private.h"
#import "session_protocol.h"
#import "NIMMessage_Private.h"
#import "NIMModelConverter.h"
#import "auth_protocol.h"

@implementation NIMFetchMsgCallback


- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBHistoryMsgParam *msgParam = dynamic_cast<nimbiz::CBHistoryMsgParam *>(param);
    if (msgParam)
    {
        result.error = NIMRemoteError(msgParam->code_);
        
        std::list<nimbiz::Property> msgs = msgParam->msgs_;
        NSMutableArray *messages = [NSMutableArray array];
        nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
        if (core)
        {
            NSString *account = NSUTF8(core->GetUid());
            for (auto it = msgs.begin(); it!= msgs.end(); it++)
            {
                nimbiz::Property messageProperty = *it;
                NIMMessage *message = [NIMModelConverter imMessageFromProperty:messageProperty];
                
                if (![messages containsObject:message])
                {
                    //因为网络原因可能有下发重复消息数据，需要去重
                    if ([message.session.sessionId isEqualToString:account])
                    {
                        //自己与自己说话的历史记录，isReceivedMsg根据客户端类型判断
                        message.isReceivedMsg = message.clientType != nimbiz::NIMClientTypeIOS;
                        if (!message.isReceivedMsg)
                        {
                            message.isDeliveried = YES;
                        }
                    }
                    [messages addObject:message];
                }
            }
        }
        result.resultObject = messages;
    }
}

- (void)run:(NIMCallbackResult *)result
{
    NSArray *msgs = (NSArray *)result.resultObject;
    NSError *error= result.error;
    
    if (_fetchBlock) {
        _fetchBlock(error,msgs);
    }
    
    if (error == nil && msgs && self.sync)
    {
        nim_io_async(^{
            NIMConversationManager *manager = [NIMConversationManager sharedManager];
            NSMutableArray *messages = [NSMutableArray array];
            for (NIMMessage *message in msgs)
            {
                if (![manager isMessageReceived:[message messageId]
                                     forSession:self.session])
                {
                    [message setStatus:NIMMessageStatusRead];   //设置为已读消息
                    [messages addObject:message];
                }
            }
            
            if ([messages count])
            {
                [manager saveMessages:messages];
            }
            
        });
    }

}
@end
