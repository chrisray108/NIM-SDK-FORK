//
//  NIMChatroomStateManager.m
//  NIMLib
//
//  Created by amao on 12/11/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMChatroomStateManager.h"
#import "NIMUtil.h"
#import "chatroom_protocol.h"
#import "NIMDispatch.h"
#import "NIMGlobalDefs.h"
#import "bind.h"
#import "NIMChatroomManager.h"
#import "NIMTimer.h"
#import "NIMReachability.h"
#import "NIMLoginManager.h"
#import "NIMLoginHelper.h"
#import "NIMDelegateCenter.h"
#import "NIMChatroomStateEmitter.h"



@interface NIMChatroomStateManager ()<NIMTimerDelegate>
@property (nonatomic,strong)    NIMChatroomLoginOperation           *loginOperation;
@property (nonatomic,strong)    NIMTimer                            *reconnectTimer;
@property (nonatomic,assign)    NSInteger                           reconnectDelay;
@property (nonatomic,strong)    NIMChatroomStateEmitter             *stateEmitter;
@end

@implementation NIMChatroomStateManager

- (instancetype)init
{
    if (self = [super init])
    {
        _reconnectTimer  = [[NIMTimer alloc] init];
        _reconnectDelay = 1;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNetChanged:)
                                                     name:NIMReachabilityChangedNotification
                                                   object:nil];
        
        
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)login:(NIMChatroomLoginOperation *)operation
{
    NIMLogApp(@"begin to login room with data %@ state %@",operation,[self stateDescription:_state]);
    [self loginBy:operation];
}

#pragma mark - 登录
- (void)loginBy:(NIMChatroomLoginOperation *)operation
{
    self.loginOperation = operation;
    self.stateEmitter = [NIMChatroomStateEmitter emitterByRoomId:operation.roomId];
    
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    if (service)
    {
        nimbiz::LinkChatroomData data;
        
        data.link_id_       = UTF8(_loginOperation.linkId);
        data.room_id_       = UTF8(_loginOperation.roomId);
        
        NIMChatroomAddress *address = [_loginOperation address];
        data.room_ip_       = UTF8([address ip]);
        data.room_port_     = (int32_t)[address port];
        
        
        nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackConnectChatroom);
        service->Invoke_ConnectRoom(data, callback);
        
        [self updateState:NIMChatroomStateConnecting
                    error:nil];

    }
}


#pragma mark - 状态回调
- (void)chatroomConnect:(NSString *)linkId
                connect:(BOOL)connected
{
    if ([linkId isEqualToString:_loginOperation.linkId])
    {
        if (connected)
        {
            [self updateState:NIMChatroomStateConnected
                        error:nil];
        }
        else
        {
            [self updateState:NIMChatroomStateConnectFailed
                        error:NIMRemoteError(NIMRemoteErrorCodeConnectionError)];
        }
    }
    else
    {
        NIMLogWar(@"room %@ connect link id %@ not matched",_loginOperation,linkId);
    }
}

- (void)chatroomDisconnected:(NSString *)linkId
{
    if ([linkId isEqualToString:_loginOperation.linkId])
    {
        [self updateState:NIMChatroomStateDisconnected
                    error:nil];
    }
    else
    {
        NIMLogWar(@"room %@ disconnect link id %@ not matched",_loginOperation,linkId);
    }
}

- (void)chatroomEnter:(NSInteger)taskId
                error:(NSError *)error
             roomInfo:(NIMChatroom *)room
               meInfo:(NIMChatroomMember *)me
{
    if (taskId == _loginOperation.loginTaskId)
    {
        if (error)
        {
            [self updateState:NIMChatroomStateLoginFailed
                        error:error];
        }
        else
        {
            _roomInfo = room;
            _me = me;
            [self updateState:NIMChatroomStateLogined
                        error:error];
        }
    }
    else
    {
        NIMLogWar(@"room %@ enter task id %zd not matched",_loginOperation,taskId);
    }
}

- (void)chatroomHostError:(BOOL)force
{
    [_loginOperation reportHostError:force];
}


#pragma mark - 状态变化
- (void)updateState:(NIMChatroomState)state
              error:(NSError *)error
{
    NIMLogApp(@"state change from %@ to %@\n%@\n",
              [self stateDescription:_state],[self stateDescription:state],_loginOperation);
    _state = state;
    switch (_state)
    {
        case NIMChatroomStateInit:
            break;
        case NIMChatroomStateConnecting:
            break;
        case NIMChatroomStateConnected:
            [self onConnected];
            break;
        case NIMChatroomStateConnectFailed:
            [self onConnectFailed:error];
            break;
        case NIMChatroomStateLogining:
            break;
        case NIMChatroomStateLogined:
            [self onLoginSuccess];
            break;
        case NIMChatroomStateLoginFailed:
            [self onLoginFailed:error];
            break;
        case NIMChatroomStateDisconnected:
            [self onDisconnected];
            break;
        default:
            break;
    }
    [_stateEmitter commit:_state
                    error:error];
}


- (NSString *)stateDescription:(NIMChatroomState)state
{
    static NSDictionary *descriptions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptions = @{@(NIMChatroomStateInit) : @"init",
                         @(NIMChatroomStateConnecting) : @"connecting",
                         @(NIMChatroomStateConnected) : @"connected",
                         @(NIMChatroomStateConnectFailed) : @"connect failed",
                         @(NIMChatroomStateLogining) : @"logining",
                         @(NIMChatroomStateLogined) : @"logined",
                         @(NIMChatroomStateLoginFailed) : @"login failed",
                         @(NIMChatroomStateDisconnected) : @"disconnected"};
    });
    return [descriptions objectForKey:@(state)];
}

- (void)onConnected
{
    _reconnectDelay = 1;
    
    nimbiz::IChatroomService *service = (nimbiz::IChatroomService *)nimbiz::GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    if (service)
    {
        NIMLoginOperation *operation = [[NIMLoginManager sharedManager] currentOperation];
        
        nimbiz::EnterChatroomRequest request;
        request.im_request_ = [NIMLoginHelper loginTags:operation];
        request.chatroom_request_ = [NIMLoginHelper chatroomTags:operation
                                                         request:_loginOperation.request];


        nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackEnterChatroom);
        _loginOperation.loginTaskId = (NSInteger)service->Invoke_EnterRoom(request, callback);
        
        [self updateState:NIMChatroomStateLogining
                    error:nil];
    }
}

- (void)onConnectFailed:(NSError *)error
{
    [self raiseCallback:error];
    [self tryAgain];
}

- (void)onLoginSuccess
{
    [self raiseCallback:nil];
    
    //切换成自动重连模式
    _loginOperation.mode = NIMLoginModeAuto;
}

- (void)onLoginFailed:(NSError *)error
{
   [self raiseCallback:error];
    
    NSInteger code = [error code];
    NIMLogApp(@"login failed code %zd data %@",code,_loginOperation);
    
    if ([NIMLoginHelper isNoretryCode:code]) {
        return;
    }
    
    [self tryAgain];
}

- (void)onDisconnected
{
    [self tryAgain];
}

- (void)raiseCallback:(NSError *)error
{
    //尝试发起回调
    NIMChatroomEnterHandler handler = _loginOperation.loginHandler;
    if (handler)
    {
        NIMChatroom *room = error ? nil : self.roomInfo;
        NIMChatroomMember *me = error ? nil : self.me;
        handler(error,room,me);
        _loginOperation.loginHandler = nil;
    }
}

- (void)tryAgain
{
    if (_loginOperation.mode == NIMLoginModeAuto)
    {
        [self reconnect];
    }
    else
    {
        NIMLogWar(@"failed in manual mode, no retry");
    }
}


#pragma mark - 重连
- (void)reconnect
{
    NIMLogApp(@"try to reconnect after %zds %@ state %@",_reconnectDelay,_loginOperation,[self stateDescription:_state]);
    
    [_reconnectTimer startTimer:_reconnectDelay
                       delegate:self
                        repeats:NO];
    
    _reconnectDelay = _reconnectDelay < 8 ? _reconnectDelay + 1 : 1;
}

- (void)onNIMTimerFired:(NIMTimer *)timer
{
    //如果处于 连接中/已连接/登录中/已登录 状态,不进行重连
    if (_state == NIMChatroomStateConnecting ||
        _state == NIMChatroomStateConnected ||
        _state == NIMChatroomStateLogining ||
        _state == NIMChatroomStateLogined) {
        
        NIMLogApp(@"reconnect cancelled for %@ state %@",_loginOperation,[self stateDescription:_state]);
        return;
    }
    
    if (_state == NIMChatroomStateDisconnected)
    {
        NIMChatroomLoginOperation *operation = _loginOperation;
        operation.linkId = [NIMUtil uuid];
        
        [self loginBy:operation];
    }
    else
    {
        
    }
}

- (void)onNetChanged:(NSNotification *)aNotification
{
    NIMLogApp(@"net device changed for room %@",_loginOperation);
    [self updateState:NIMChatroomStateDisconnected
                error:nil];
    
}
@end
