//
//  NIMChatroomManager.m
//  NIMLib
//
//  Created by amao on 12/14/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMChatroomManager.h"
#import "chatroom_protocol.h"
#import "NIMChatroom_Private.h"
#import "NIMChatroomStateManager.h"
#import "NIMGlobalDefs.h"
#import "bind.h"
#import "NIMDispatch.h"
#import "NIMChatroomFetchMembersCallback.h"
#import "NIMChatroomMsgRecvHandler.h"
#import "NIMChatroomMemberRequest_Private.h"
#import "NIMChatroomUpdateMemberCallback.h"
#import "NIMChatroomInfoCallback.h"
#import "NIMChatroomMember_Private.h"
#import "NIMDelegateCenter.h"
#import "NIMProtocolUtil.h"
#import "NIMChatroomKickCallback.h"
#import "NIMChatroomEnterRequest.h"
#import "NIMChatroomMemberRequestValidator.h"
#import "NIMChatroomMemberUpdateRequestValidator.h"
#import "NIMNonEmptyStringValidator.h"
#import "NIMChatroomMembersByIdsValidator.h"
#import "NIMChatroomEnterRequestValidator.h"
#import "NIMChatroomKickValidator.h"
#import "NIMSessionValidator.h"
#import "NIMMessageHistorySearchOptionValidator.h"
#import "NIMChatroomHistoryMessageCallback.h"
#import "NIMMessageSearchOption.h"

@interface NIMChatroomManager ()
@property (nonatomic,strong)    NSMutableDictionary *rooms;
@property (nonatomic,strong)    NIMChatroomMsgRecvHandler *msgHandler;
@end

@implementation NIMChatroomManager
- (instancetype)init
{
    if (self = [super init])
    {
        _rooms = [[NSMutableDictionary alloc] init];
        _msgHandler = [[NIMChatroomMsgRecvHandler alloc] init];
    }
    return self;
}

#pragma mark - 进入聊天室
- (void)enterChatroom:(NIMChatroomEnterRequest *)request
           completion:(NIMChatroomEnterHandler)completion
{
    if (![[NIMChatroomEnterRequestValidator validator:request] isValid])
    {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil,nil);
        }
        return;
    }
    
    
    NSString *roomId = request.roomId;
    __weak typeof(self) weakSelf = self;
    [self requestToken:roomId
            completion:^(NSError *error, NIMChatroomToken *token) {
                if (error)
                {
                    if (completion) {
                        completion(error,nil,nil);
                    }
                }
                else
                {
                    [weakSelf onGetToken:request
                                   token:token
                              completion:completion];
                }
            }];
}


#pragma mark - 获取聊天室成员
- (void)fetchChatroomMembers:(NIMChatroomMemberRequest *)request
                  completion:(NIMChatroomMembersHandler)completion{
    
    if (![[NIMChatroomMemberRequestValidator validator:request] isValid]) {
        
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
        }
        return;
    }
    
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    if (service) {
        nimbiz::ChatroomMembersRequest req;
        req.room_id_ = UTF8(request.roomId);
        req.type_    = (int32_t)request.type;
        //固定成员列表用updatetime,非固定成员列表用进入聊天室的时间
        NIMChatroomMember *lastMember = request.lastMember;
        req.end_     = lastMember.type == NIMChatroomMemberTypeGuest?
               NIMTimeDoubleToLong(lastMember.enterTimeInterval) : NIMTimeDoubleToLong(lastMember.updateTimeInterval);
        req.limit_   = (int32_t)request.limit;
        
        NSInteger taskId = service->Invoke_FetchRoomMember(req, nimbiz::GetNIMCallback());
        NIMChatroomFetchMembersCallback *callback = [[NIMChatroomFetchMembersCallback alloc] init];
        callback.block = completion;
        [[NIMCallbackManager sharedManager] setCallback:callback
                                                forTask:taskId];
    }
}


#pragma mark - 标记聊天室成员身份
- (void)markMemberManager:(NIMChatroomMemberUpdateRequest *)request
               completion:(NIMChatroomHandler)completion
{

    [self updateMember:request
                option:nimbiz::NIMChatroomMemberUpdateTagManager
            completion:completion];
}


- (void)markNormalMember:(NIMChatroomMemberUpdateRequest *)request
              completion:(NIMChatroomHandler)completion
{
    [self updateMember:request
                option:nimbiz::NIMChatroomMemberUpdateTagCommon
            completion:completion];
}

- (void)updateMemberBlack:(NIMChatroomMemberUpdateRequest *)request
               completion:(NIMChatroomHandler)completion
{
    [self updateMember:request
                option:nimbiz::NIMChatroomMemberUpdateTagBlacklist
            completion:completion];
}


- (void)updateMemberMute:(NIMChatroomMemberUpdateRequest *)request
              completion:(NIMChatroomHandler)completion
{
    [self updateMember:request
                option:nimbiz::NIMChatroomMemberUpdateTagMuted
            completion:completion];
}


- (void)updateMember:(NIMChatroomMemberUpdateRequest *)request
              option:(int32_t)option
          completion:(NIMChatroomHandler)completion{
    if (![[NIMChatroomMemberUpdateRequestValidator validator:request] isValid]) {
        
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    if (service) {
        nimbiz::ChatroomMemberUpdateRequest req;
        req.room_id_ = UTF8(request.roomId);
        req.user_id_ = UTF8(request.userId);
        req.valid_   = request.enable;
        req.option_  = option;
        req.level_   = 0;
        req.notifyExt_ = [NIMProtocolUtil stringByJsonDictionary:request.notifyExt];
        NSInteger taskId = service->Invoke_UpdateMember(req, nimbiz::GetNIMCallback());
        NIMChatroomUpdateMemberCallback *callback = [[NIMChatroomUpdateMemberCallback alloc] init];
        callback.block = completion;
        [[NIMCallbackManager sharedManager] setCallback:callback
                                                forTask:taskId];
    }
}

#pragma mark - 关闭聊天室
- (void)closeChatroom:(NSString *)roomId
            notifyExt:(NSDictionary *)ext
           completion:(NIMChatroomHandler)completion
{
    if (![[NIMNonEmptyStringValidator validator:roomId] isValid]) {
        
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    NIMChatroomStateManager *manager = _rooms[roomId];
    if (service && manager)
    {
        
        nimbiz::ChatroomCloseRoomRequest request;
        request.room_id_    = UTF8(roomId);
        request.notify_ext_ = [NIMProtocolUtil stringByJsonDictionary:ext];
        nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackCloseChatroom);
        manager.closeTaskId = (NSInteger)service->Invoke_CloseRoom(request,callback);
        manager.closeHandler= completion;
        
        NIMLogApp(@"close chatroom room id %@ task id %zd",roomId,[manager closeTaskId]);
    }
    else
    {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorChatroomNotExists));
        }
    }
}


#pragma mark - 查询聊天室历史消息
- (void)fetchMessageHistory:(NSString *)roomId
                     option:(NIMHistoryMessageSearchOption *)option
                     result:(NIMFetchChatroomHistoryBlock)block
{
    NIMAndValidator *validator = [NIMAndValidator validator:@[[NIMNonEmptyStringValidator validator:roomId],
                                             [NIMChatroomMessageHistorySearchOptionValidator validator:option]]];
    if (![validator isValid])
    {
        if (block) {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
        }
        return;
    }
    
    NIMChatroomHistoryMessageCallback *callback = [[NIMChatroomHistoryMessageCallback alloc] init];
    callback.block     = block;
    
    nimbiz::ChatroomHistoryMsgReqeust requestParam;
    requestParam.room_id_   = UTF8(roomId);
    requestParam.from_time_ = NIMTimeDoubleToLong(option.startTime);
    requestParam.limit_     = (int32_t)option.limit;
    
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService*)GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    int32_t taskId = service->Invoke_HistoryMsg(requestParam,nimbiz::GetNIMCallback());
    
    [[NIMCallbackManager sharedManager] setCallback:callback
                                            forTask:taskId];

}

#pragma mark - 获取聊天室信息
- (void)fetchChatroomInfo:(NSString *)roomId
               completion:(NIMChatroomInfoHandler)completion{
    
    if (![[NIMNonEmptyStringValidator validator:roomId] isValid]) {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
        }
        return;
    }
    
    
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    if (service) {        
        NSInteger taskId = service->Invoke_GetRoomInfo(UTF8(roomId), nimbiz::GetNIMCallback());
        NIMChatroomInfoCallback *callback = [[NIMChatroomInfoCallback alloc] init];
        callback.block = completion;
        [[NIMCallbackManager sharedManager] setCallback:callback
                                                forTask:taskId];
    }
}

- (void)fetchChatroomMembersByIds:(NIMChatroomMembersByIdsRequest *)request
                       completion:(NIMChatroomMembersHandler)completion
{
    if (![[NIMChatroomMembersByIdsValidator validator:request] isValid]) {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
        }
        return;
    }
    
    
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    if (service) {
        nimbiz::ChatroomMembersRequestByIds req;
        req.room_id_ = UTF8(request.roomId);
        req.uids_    = [NIMProtocolUtil arrayToStringList:request.userIds];

        NSInteger taskId = service->Invoke_FetchMembersByIds(req, nimbiz::GetNIMCallback());
        NIMChatroomFetchMembersCallback *callback = [[NIMChatroomFetchMembersCallback alloc] init];
        callback.block = completion;
        [[NIMCallbackManager sharedManager] setCallback:callback
                                                forTask:taskId];
    }
}

- (void)kickMember:(NIMChatroomMemberKickRequest *)request
        completion:(NIMChatroomHandler)completion
{
    if (![[NIMChatroomKickValidator validator:request] isValid]) {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    if (service) {
        nimbiz::ChatroomMemberKickRequest req;
        req.room_id_   = UTF8(request.roomId);
        req.target_id_ = UTF8(request.userId);
        NSDictionary *notifyExt = request.notifyExt;
        if (![NSJSONSerialization isValidJSONObject:notifyExt]) {
            notifyExt = [[NSDictionary alloc] init];
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:notifyExt options:0 error:nil];
        NSString *extString = @"";
        if (data) {
            extString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        req.notify_ext_ = UTF8(extString);
        
        NSInteger taskId = service->Invoke_KickMember(req, nimbiz::GetNIMCallback());
        NIMChatroomKickCallback *callback = [[NIMChatroomKickCallback alloc] init];
        callback.block = completion;
        [[NIMCallbackManager sharedManager] setCallback:callback
                                                forTask:taskId];
    }
}


- (void)requestToken:(NSString *)roomId
          completion:(NIMRequestChatroomTokenHandler)completion
{
    
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    if (service)
    {
        NSInteger taskId = service->Invoke_RequestChatroom(UTF8(roomId), nimbiz::GetNIMCallback());
        
        NIMChatroomTokenCallback *callback = [[NIMChatroomTokenCallback alloc] init];
        callback.block = completion;
        
        [[NIMCallbackManager sharedManager] setCallback:callback
                                                forTask:taskId];
    }
}


- (void)onGetToken:(NIMChatroomEnterRequest *)request
             token:(NIMChatroomToken *)token
        completion:(NIMChatroomEnterHandler)handler
{
    NSString *roomId = request.roomId;
    NIMChatroomStateManager *manager = [[NIMChatroomStateManager alloc] init];
    if (_rooms[roomId])
    {
        NIMLogApp(@"has same room in manager for %@",roomId);
    }
    _rooms[roomId] = manager;
    
    NIMChatroomLoginOperation *operation = [NIMChatroomLoginOperation operationByRequest:request token:token];
    operation.loginHandler = handler;
    
    [manager login:operation];
}



#pragma mark - 离开聊天室
- (void)exitChatroom:(NSString *)roomId
          completion:(NIMChatroomHandler)completion
{
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    NIMChatroomStateManager *manager = _rooms[roomId];
    if (service && manager)
    {
        nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackExitChatroom);
        manager.exitTaskId = (NSInteger)service->Invoke_ExitRoom(UTF8(roomId), callback);
        manager.exitHandler= completion;
        
        NIMLogApp(@"exit chatroom room id %@ task id %zd",roomId,[manager exitTaskId]);
    }
    else
    {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorChatroomNotExists));
        }
    }
}




#pragma mark - callback
- (void)chatroomConnect:(NSString *)roomId
                 linkId:(NSString *)linkId
                connect:(BOOL)connected
{
    NIMChatroomStateManager *manager = _rooms[roomId];
    [manager chatroomConnect:linkId
                     connect:connected];
}

- (void)chatroomDisconnected:(NSString *)roomId
                      linkId:(NSString *)linkId
{
    NIMChatroomStateManager *manager = _rooms[roomId];
    [manager chatroomDisconnected:linkId];
}


- (void)chatroomEnter:(NSString *)roomId
               taskId:(NSInteger)taskId
                error:(NSError *)error
                 room:(NIMChatroom *)room
                   me:(NIMChatroomMember *)me
{
    NIMChatroomStateManager *manager = _rooms[roomId];
    [manager chatroomEnter:taskId
                     error:error
                  roomInfo:room
                    meInfo:me];
     
}

- (void)chatroomExit:(NSString *)roomId
              taskId:(NSInteger)taskId
               error:(NSError *)error
{
    NIMChatroomStateManager *manager = _rooms[roomId];
    if (manager && taskId == [manager exitTaskId])
    {
        NIMChatroomHandler handler = [manager exitHandler];
        if (handler) {
            handler(error);
        }
        [_rooms removeObjectForKey:roomId];
    }
}


- (void)chatroomClose:(NSString *)roomId
               taskId:(NSInteger)taskId
                error:(NSError *)error
{
    NIMChatroomStateManager *manager = _rooms[roomId];
    if (manager && taskId == [manager closeTaskId])
    {
        NIMChatroomHandler handler = [manager closeHandler];
        if (handler) {
            handler(error);
        }
        if (!error) {
            [_rooms removeObjectForKey:roomId];
        }
    }
}


#pragma mark - 内部接口
- (void)onRecvMsg:(NIMMessage *)message
{
    [_msgHandler onRecvMsg:message];
}

- (void)reportHostError:(NSString *)roomId
                  fatal:(BOOL)fatal
{
    NIMChatroomStateManager *manager = _rooms[roomId];
    [manager chatroomHostError:fatal];
}

- (void)onKicked:(NSString*)roomId
          reason:(NIMChatroomKickReason)reason
{
    NIMLogApp(@"room %@ be kicked",roomId);
    [_rooms removeObjectForKey:roomId];
    [[NIMDelegateCenter chatroomDelegate] chatroom:roomId beKicked:reason];
}

@end



namespace nimbiz
{
    void   CallbackConnectChatroom(IAsynCallbackParam *param)
    {
        @autoreleasepool
        {
            CBLinkChatroomParam *linkParam = (CBLinkChatroomParam *)param;
            NSString *roomId = NSUTF8(linkParam->room_id_);
            NSString *linkId = NSUTF8(linkParam->link_id_);
            BOOL connected   = linkParam->connected;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NIMChatroomManager sharedManager] chatroomConnect:roomId
                                                             linkId:linkId
                                                            connect:connected];
            });
            
        }
    }
    
    
    
    void   CallbackEnterChatroom(IAsynCallbackParam *param)
    {
        @autoreleasepool
        {
            CBEnterChatroomParam *enterParam = (CBEnterChatroomParam *)param;
            NSString *roomId = NSUTF8(enterParam->room_id_);
            NSInteger code   = (NSInteger)enterParam->code_;
            NSInteger taskId = (NSInteger)enterParam->task_id_;
            NSError *error = NIMRemoteError(code);
            NIMChatroom *info = error ? nil : [[NIMChatroom alloc] initWithProperty:enterParam->room_];
            NIMChatroomMember *me = error ? nil : [[NIMChatroomMember alloc] initWithProperty:enterParam->me_];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NIMChatroomManager sharedManager] chatroomEnter:roomId
                                                           taskId:taskId
                                                            error:error
                                                             room:info
                                                               me:me];
                 
            });
        }
        
    }
    
    void   CallbackDisconnectChatroom(IAsynCallbackParam *param)
    {
        @autoreleasepool
        {
            CBDisconnectChatroomParam *disconnectParam = (CBDisconnectChatroomParam *)param;
            NSString *roomId = NSUTF8(disconnectParam->room_id_);
            NSString *linkId = NSUTF8(disconnectParam->link_id_);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NIMChatroomManager sharedManager] chatroomDisconnected:roomId
                                                                  linkId:linkId];
            });
        }
    }
    
    void   CallbackExitChatroom(IAsynCallbackParam *param)
    {
        @autoreleasepool {
            CBExitChatroomParam *exitParam = (CBExitChatroomParam *)param;
            NSString *roomId = NSUTF8(exitParam->room_id_);
            NSInteger code   = (NSInteger)exitParam->code_;
            NSInteger taskId = (NSInteger)exitParam->task_id_;
            NSError *error = NIMRemoteError(code);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NIMChatroomManager sharedManager] chatroomExit:roomId
                                                          taskId:taskId
                                                           error:error];
            });

        }
    }
    
    void   CallbackCloseChatroom(IAsynCallbackParam *param)
    {
        @autoreleasepool {
            CBCloseChatroomParam *exitParam = (CBCloseChatroomParam *)param;
            NSString *roomId = NSUTF8(exitParam->room_id_);
            NSInteger code   = (NSInteger)exitParam->code_;
            NSInteger taskId = (NSInteger)exitParam->task_id_;
            NSError *error = NIMRemoteError(code);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NIMChatroomManager sharedManager] chatroomClose:roomId
                                                           taskId:taskId
                                                            error:error];
            });
        }
    }
}