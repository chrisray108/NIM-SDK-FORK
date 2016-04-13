//
//  NIMChatManager.h
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMManager.h"
#import "NIMChatManagerProtocol.h"



@interface NIMChatManager : NIMManager

#pragma mark - 对外接口
- (BOOL)sendMessage:(NIMMessage *)message
          toSession:(NIMSession *)session
              error:(NSError **)error;
- (BOOL)resendMessage:(NIMMessage *)message
                error:(NSError **)error;
- (void)sendMessageReceipt:(NIMMessageReceipt *)receipt
                completion:(NIMSendMessageReceiptBlock)completion;
- (BOOL)fetchMessageAttachment:(NIMMessage *)message
                         error:(NSError **)error;
- (BOOL)messageInTransport:(NIMMessage *)message;
- (CGFloat)messageTransportProgress:(NIMMessage *)message;


#pragma mark - SDK内部接口
- (void)onRecvMessages:(NSArray *)messages;

- (void)onRoomMsgAck:(NSString *)roomId
           messageId:(NSString *)messageId
                info:(NSDictionary *)info;

- (NSTimeInterval)receiptTimestamp:(NSString *)userId;
@end


namespace nimbiz
{
    struct IAsynCallbackParam;
    void    CallbackSendMsg(struct IAsynCallbackParam *msgParam);               //消息ACK
    void    CallbackRecvMsgs(struct IAsynCallbackParam *msgParam);              //收到消息
    void    CallbackRecvReceipt(struct IAsynCallbackParam *msgParam);           //收到已读回执
}



