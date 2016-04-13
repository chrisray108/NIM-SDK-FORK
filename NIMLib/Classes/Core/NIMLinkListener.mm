//
//  NIMLinkListener.m
//  YixinCall
//
//  Created by amao on 10/8/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import "NIMLinkListener.h"
#import "NIMReachability.h"
#import "response_code.h"
#import "auth_protocol.h"
#import "NIMCoreCenter.h"
#import "NIMTimer.h"

NIMNotification(NIMConnectNotification);
NIMNotification(NIMDisconnectNotification);
NIMNotification(NIMRespCode);
NIMNotification(NIMConnectStep);


@interface NIMLinkListener ()<NIMTimerDelegate>
@property (nonatomic,strong)    NIMReachability    *networkListener;   //网络时间监听
@property (nonatomic,strong)    NIMTimer           *reconnectTimer;    //重连Timer(重链需要delay一段时间)
@property (nonatomic,assign)    BOOL               connectOnce;        //是否尝试过至少一次连接
@end

@implementation NIMLinkListener

+ (instancetype)sharedListener
{
    static NIMLinkListener *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMLinkListener alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self addListenEvents];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkListener stopNotifier];
}

- (void)checkState
{
    [self beginToConnect];
}

- (void)addListenEvents
{
    
    //连接到服务器通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onConnectNotify:)
                                                 name:NIMConnectNotification
                                               object:nil];
    
    //网络切换通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetChanged:)
                                                 name:NIMReachabilityChangedNotification
                                               object:nil];
    
    //与服务器断开连接通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDisconnect:)
                                                 name:NIMDisconnectNotification
                                               object:nil];
    
    self.networkListener = [NIMReachability reachabilityForInternetConnection];
    [_networkListener startNotifier];
}

#pragma mark - 事件处理
- (void)onConnectNotify:(NSNotification *)aNotification
{
    NSDictionary *dict = aNotification.userInfo;
    NSInteger code = [dict[NIMRespCode] integerValue];
    NSInteger step = [dict[NIMConnectStep] integerValue];
    NIMLogApp(@"get connection notification: %@",dict);
    if (code == nimbiz::NIMResSuccess)
    {
        if (step == nimbiz::NIMConnectStepLinked)
        {
            _state = NIMConnectStateConnected;
            if (_delegate && [_delegate respondsToSelector:@selector(onConnectSuccess:)])
            {
                [_delegate onConnectSuccess:self];
            }
        }
    }
    else
    {
        _state = NIMConnectStateInit;
        if (_delegate && [_delegate respondsToSelector:@selector(onConnectFailed:)])
        {
            [_delegate onConnectFailed:self];
        }
        [self reconnect:1];
    }
}

- (void)onNetChanged:(NSNotification *)aNotification
{
    NIMLogApp(@"net device changed: %@",[_networkListener currentReachabilityString]);
    //网络切换后,修改登录状态为非登录
    nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
    if (core)
    {
        core->SetLogin(false);
    }
    
    if (_state == NIMConnectStateConnected)
    {
        _state = NIMConnectStateInit;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(onNetChanged:)])
    {
        [_delegate onNetChanged:self];
    }
    [self reconnect:1];
}

- (void)onDisconnect:(NSNotification *)aNotification
{
    NIMLogApp(@"on disconnect from server");
    if (_state == NIMConnectStateConnected)
    {
        _state = NIMConnectStateInit;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(onDisconnect:)])
    {
        [_delegate onDisconnect:self];
    }
    [self reconnect:1];
}

#pragma mark - misc
- (void)onNIMTimerFired:(NIMTimer *)holder
{
    [self beginToConnect];
}

#pragma mark - 重连
- (void)reconnect:(NSTimeInterval)delay
{
    NIMLogApp(@"set timer for reconnecting %zd",(int)delay);
    if (delay)
    {
        if (_reconnectTimer == nil)
        {
            _reconnectTimer = [[NIMTimer alloc]init];
        }
        [_reconnectTimer startTimer:delay
                           delegate:self
                            repeats:NO];
    }
    else
    {
        [self beginToConnect];
    }
}


- (void)beginToConnect
{
    NIMLogApp(@"try to connect link");
    if (![_networkListener isReachable])
    {
        NIMLogApp(@"bad connection state %@ with %d",[_networkListener currentReachabilityString],_connectOnce);
        if (_connectOnce)
        {
            return;
        }
    }
    if (_state == NIMConnectStateConnecting ||
        _state == NIMConnectStateConnected)
    {
        NIMLogApp(@"connect cancelled because of in %d state",_state);
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(shouldConnectServer:)])
    {
        if (![_delegate shouldConnectServer:self])
        {
            NIMLogApp(@"connect cancelled by delegate");
            return;
        }
    }
    _state = NIMConnectStateConnecting;
    [[NIMCoreCenter sharedCenter] beginToConnect];
    if (_delegate && [_delegate respondsToSelector:@selector(onConnectionBegin:)])
    {
        [_delegate onConnectionBegin:self];
    }
    _connectOnce = YES;
}



@end

namespace nimbiz
{

void    CallbackConnectLink(IAsynCallbackParam *connectParam)
{
    @autoreleasepool
    {
        CBConnectStepParam *param = (CBConnectStepParam *)connectParam;
        NSDictionary *dict = @{NIMConnectStep:@(param->step_),
                               NIMRespCode:@(param->code_)};
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NIMConnectNotification
                                                                object:nil
                                                              userInfo:dict];
        });
    }

}
void    CallbackDisconnectLink(IAsynCallbackParam *disconnectParam)
{
    @autoreleasepool
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NIMDisconnectNotification
                                                                object:nil];
        });
    }

}
}



