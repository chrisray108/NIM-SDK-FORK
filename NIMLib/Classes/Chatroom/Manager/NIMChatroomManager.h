//
//  NIMChatroomManager.h
//  NIMLib
//
//  Created by amao on 12/14/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMManager.h"
#import "NIMChatroomManagerProtocol.h"
#import "NIMChatroomTokenCallback.h"

@class NIMMessage;

@interface NIMChatroomManager : NIMManager
- (void)requestToken:(NSString *)roomId
          completion:(NIMRequestChatroomTokenHandler)completion;

- (void)enterChatroom:(NIMChatroomEnterRequest *)request
           completion:(NIMChatroomEnterHandler)completion;

- (void)exitChatroom:(NSString *)roomId
          completion:(NIMChatroomHandler)completion;

- (void)fetchChatroomMembers:(NIMChatroomMemberRequest *)request
                  completion:(NIMChatroomMembersHandler)completion;

- (void)markMemberManager:(NIMChatroomMemberUpdateRequest *)request
               completion:(NIMChatroomHandler)completion;


- (void)markNormalMember:(NIMChatroomMemberUpdateRequest *)request
              completion:(NIMChatroomHandler)completion;

- (void)updateMemberBlack:(NIMChatroomMemberUpdateRequest *)request
               completion:(NIMChatroomHandler)completion;


- (void)updateMemberMute:(NIMChatroomMemberUpdateRequest *)request
              completion:(NIMChatroomHandler)completion;

- (void)closeChatroom:(NSString *)roomId
            notifyExt:(NSDictionary *)ext
           completion:(NIMChatroomHandler)completion;

- (void)fetchMessageHistory:(NSString *)roomId
                     option:(NIMHistoryMessageSearchOption *)option
                     result:(NIMFetchChatroomHistoryBlock)block;

- (void)fetchChatroomInfo:(NSString *)roomId
               completion:(NIMChatroomInfoHandler)completion;

- (void)fetchChatroomMembersByIds:(NIMChatroomMembersByIdsRequest *)request
                       completion:(NIMChatroomMembersHandler)completion;

- (void)kickMember:(NIMChatroomMemberKickRequest *)request
        completion:(NIMChatroomHandler)completion;


#pragma mark - 对内接口
- (void)onRecvMsg:(NIMMessage *)message;

- (void)reportHostError:(NSString *)roomId
                  fatal:(BOOL)fatal;

- (void)onKicked:(NSString*)roomId
          reason:(NIMChatroomKickReason)reason;

@end



//登录登出由于其特殊性,需要保证11对应，所以不使用CallbackManager里的机制
namespace nimbiz
{
    struct IAsynCallbackParam;
    void   CallbackConnectChatroom(IAsynCallbackParam *param);
    void   CallbackEnterChatroom(IAsynCallbackParam *param);
    void   CallbackDisconnectChatroom(IAsynCallbackParam *param);
    void   CallbackExitChatroom(IAsynCallbackParam *param);
    void   CallbackCloseChatroom(IAsynCallbackParam *param);
}