//
//  NIMChatroomCallback.m
//  NIMLib
//
//  Created by amao on 12/16/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMChatroomCallback.h"
#import "chatroom_protocol.h"
#import "NIMSessionManager.h"
#import "NIMChatManager.h"
#import "NIMModelConverter.h"
#import "NIMChatroomManager.h"


namespace nimbiz
{
    
#pragma mark - 全局回调函数
    void CallbackChatroomSendMsg(struct IAsynCallbackParam *msgParam)
    {
        @autoreleasepool {
            CBChatroomSendMsgParam *param = (CBChatroomSendMsgParam *)msgParam;
            NSInteger code      = (NSInteger)param->code_;
            NSString *messageId = NSUTF8(param->client_id_);
            NSString *roomId    = NSUTF8(param->room_id_);
            
            NSDictionary *info = @{NIMACKCode       : @(code)};
            
            NIMLogApp(@"on room %@ msg ack %@ \n %@",roomId,messageId,info);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{

                [[NIMChatManager sharedManager] onRoomMsgAck:roomId
                                                   messageId:messageId
                                                        info:info];
            });
        }
    }

    void CallbackChatroomRecvMsg(struct IAsynCallbackParam *msgParam)
    {
        @autoreleasepool {
            
            CBChatroomReceiveMsgParam *param = (CBChatroomReceiveMsgParam *)msgParam;
            NIMMessage *message = [NIMModelConverter chatroomMessageFromProperty:param->cb_msg_];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NIMChatroomManager sharedManager] onRecvMsg:message];
            });
        }
    }
    
    
    void CallbackChatroomBeKicked(struct IAsynCallbackParam *kickedParam)
    {
        @autoreleasepool {
            CBChatroomBeKickedParam *param = (CBChatroomBeKickedParam *)kickedParam;
            NSString *roomId = NSUTF8(param->room_id_);
            NIMChatroomKickReason reason = (NIMChatroomKickReason)param->reason_;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NIMChatroomManager sharedManager] onKicked:roomId
                                                      reason:reason];
            });
        }
    }

}