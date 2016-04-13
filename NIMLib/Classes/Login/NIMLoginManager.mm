//
//  NIMLoginManager.m
//  NIMLib
//
//  Created by amao on 1/20/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMLoginManager.h"
#import "auth_protocol.h"
#import "user_protocol.h"
#import "bind.h"
#import "service.h"
#import "sync_protocol.h"
#import "NIMGlobalDefs.h"
#import "NIMLinkListener.h"
#import "NIMCoreCenter.h"
#import "NIMManager.h"
#import "NIMTimer.h"
#import "NIMNOSTokenManager.h"
#import "NIMSDK_Private.h"
#import "NIMClientManager.h"
#import "NIMLoginClient_Private.h"
#import "NIMNetCallManager.h"
#import "NIMProtocolUtil.h"
#import "NIMDispatch.h"
#import "NIMDelegateCenter.h"
#import "NIMLoginOperation.h"
#import "NIMLoginHelper.h"
#import "NIMKickClientCallback.h"
#import "NIMLoginClientValidator.h"
#import "NIMNonEmptyStringValidator.h"
#import "NIMAutoLoginDataValidator.h"

@interface NIMLoginManager ()<NIMLinkProtocol,NIMTimerDelegate>
@property (nonatomic,strong)  NIMTimer            *loginTimer;
@property (nonatomic,copy)    NIMLoginHandler      logoutHandler;
@property (nonatomic,strong)  NIMClientManager     *clientManager;
@property (nonatomic,assign)  NSInteger            loginTaskID;
@property (nonatomic,assign)  BOOL                 stopConnectingServer;
@end

@implementation NIMLoginManager
+ (instancetype)sharedManager
{
    static NIMLoginManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMLoginManager alloc] init];
    });
    return instance;
}


- (instancetype)init
{
    if (self = [super init])
    {
        _loginTimer                 = [[NIMTimer alloc] init];
        _clientManager              = [[NIMClientManager alloc] init];
    }
    return self;
}

- (void)login:(NSString *)account
        token:(NSString *)token
   completion:(NIMLoginHandler)completion;
{
    NIMAPITrace();
    
    NIMLogApp(@"app raise login");
    NSParameterAssert(completion);
    NSParameterAssert(account);
    NSParameterAssert(token);
    
    //检查AppKey
    NSString *appKey = [[NIMSDK sharedSDK] appKey];
    if (![[NIMNonEmptyStringValidator validator:appKey] isValid])
    {
        if (completion)
        {
            nim_main_async_safe(^{
                completion(NIMLocalError(NIMLocalErrorCodeAppKeyNeed));
            });
        }
        return;
    }
    
    //检查参数
    if (![[NIMAndValidator validator:@[[NIMNonEmptyStringValidator validator:account],
                                      [NIMNonEmptyStringValidator validator:token]]] isValid])
    {
        NIMLogErr(@"login failed because of invalid account %@ token %@",account,token);
        if (completion)
        {
            nim_main_async_safe(^{
                completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
            });
        }
        return;
    }
    
    
    dispatch_block_t mainBlock = ^(){
        [self reset];
        
        NIMLoginOperation *operation    =  [[NIMLoginOperation alloc] init];
        operation.account               = account;
        operation.accountToken          = token;
        operation.handler               = completion;
        operation.mode                  = NIMLoginModeManual;
        
        self.currentOperation = operation;
        
        [_loginTimer startTimer:60
                       delegate:self
                        repeats:NO];
    };
    
    nim_main_async_safe(mainBlock);
}

- (void)autoLogin:(NSString *)account
            token:(NSString *)token
{
    NIMAutoLoginData *data = [[NIMAutoLoginData alloc] init];
    data.account = account;
    data.token = token;
    
    [self autoLogin:data];
}

- (void)autoLogin:(NIMAutoLoginData *)loginData
{
    NIMAPITrace();
    NSParameterAssert(loginData);
    NIMLogApp(@"app raise auto login %@",loginData);

    //检查AppKey
    NSString *appKey = [[NIMSDK sharedSDK] appKey];
    if (![[NIMNonEmptyStringValidator validator:appKey] isValid])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = NIMLocalError(NIMLocalErrorCodeAppKeyNeed);
            [[NIMDelegateCenter loginDelegate] onAutoLoginFailed:error];
        });
        return;
    }
    
    //检查参数
    if (![[NIMAutoLoginDataValidator validator:loginData] isValid])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = NIMLocalError(NIMLocalErrorCodeInvalidParam);
            [[NIMDelegateCenter loginDelegate] onAutoLoginFailed:error];
        });
        NIMLogErr(@"auto login failed because of invalid login data %@",loginData);
        return;
    }
    
    NSString *account = [loginData account];
    NSString *token = [loginData token];
    
    dispatch_block_t mainBlock = ^(){
        [self reset];
        
        NIMLoginOperation *operation    = [[NIMLoginOperation alloc] init];
        operation.account               = account;
        operation.accountToken          = token;
        operation.mode                  = NIMLoginModeAuto;
        operation.forcedMode            = loginData.forcedMode;
        
        self.currentOperation = operation;
        
        [[NIMCoreCenter sharedCenter] setup:operation.account];
    };
    
    
    nim_main_async_safe(mainBlock);
    
}


- (void)logout:(NIMLoginHandler)completion
{
    NIMAPITrace();
    
    NIMLogApp(@"logout begin");
    
    dispatch_block_t mainBlock = ^(){
        
        [[[NIMSDK sharedSDK] lbsManager] setStopReportLink:YES];
        [[NIMNetCallManager sharedManager] internalHangup];
        self.logoutHandler = completion;
        nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
        if (core && core->IsKicked())
        {
            [self closeAndLogout:nil];
        }
        else
        {
            nimbiz::IAuthService *service = (nimbiz::IAuthService *)GetServiceFromCore(nimbiz::SVID_NIM_AUTH);
            if (service)
            {
                nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackLogout);
                service->Invoke_Logout(callback);
            }
        }
    };
    nim_main_async_safe(mainBlock);
}

- (void)kickOtherClient:(NIMLoginClient *)client
             completion:(NIMLoginHandler)completion
{
    NIMAPITrace();
    
    if (![[NIMLoginClientValidator validator:client] isValid]) {
        if (completion) {
            nim_main_async_safe(^{
                completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
            });
        }
        return;
    }
    
    dispatch_block_t mainBlock = ^(){
        nimbiz::IAuthService *service = (nimbiz::IAuthService *)GetServiceFromCore(nimbiz::SVID_NIM_AUTH);
        if (service)
        {
            NIMKickClientCallback *callback = [[NIMKickClientCallback alloc] init];
            callback.handler = ^(NSError *error,NSArray *deviceIds) {
                
                if ([deviceIds count])
                {
                    [_clientManager removeClientsByDeviceId:deviceIds];
                }
                
                if (completion) {
                    completion(error);
                }
            };
            
            
            NSInteger taskId = (NSInteger)service->Invoke_Kick(UTF8(client.deviceId),nimbiz::GetNIMCallback());
            [[NIMCallbackManager sharedManager] setCallback:callback
                                                    forTask:taskId];
        }
    };
    nim_main_async_safe(mainBlock);
}

- (NSString *)currentAccount
{
    return [[NIMCoreCenter sharedCenter] currentUserID];
}

- (BOOL)isLogined
{
    nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
    return core && core->IsLogin();
}

- (NSArray *)currentLoginClients
{
    __block NSArray *clients = nil;
    nim_main_sync_safe(^{
        clients = [_clientManager currentClients];
    });
    return clients;
}


- (void)addDelegate:(id<NIMLoginManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] addDelegate:delegate
                                          forType:NIMDelegateTypeLogin];
}

- (void)removeDelegate:(id<NIMLoginManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] removeDelegate:delegate
                                             forType:NIMDelegateTypeLogin];
}

#pragma mark - 重置
- (void)reset
{
    NIMLogApp(@"reset begin");
    _stopConnectingServer = NO;
    [[NIMCoreCenter sharedCenter] close];
    [[NIMManagerCenter sharedCenter] destroyCenter];
    
    [[NIMCoreCenter sharedCenter] start];
    [[NIMLinkListener sharedListener] setDelegate:self];
    [[NIMLinkListener sharedListener] checkState];
    
    self.currentOperation = nil;

    [_loginTimer stopTimer];
    NIMLogApp(@"reset end");
}

- (void)closeAndLogout:(NSError *)error
{
    NIMLogApp(@"close and logout begin");
    [[NIMCoreCenter sharedCenter] close];
    [[NIMManagerCenter sharedCenter] destroyCenter];
    
    if (self.logoutHandler)
    {
        self.logoutHandler(error);
        self.logoutHandler = nil;
    }
    [[[NIMSDK sharedSDK] lbsManager] setStopReportLink:NO];
    NIMLogApp(@"close and logout end");
}

#pragma mark - LinkProtocol
- (void)onConnectionBegin:(NIMLinkListener *)listener
{
    [self setLoginStep:NIMLoginStepLinking];
}

- (void)onConnectSuccess:(NIMLinkListener *)listener
{
    [self setLoginStep:NIMLoginStepLinkOK];
    //如果当前有登录操作,则使用登录操作
    if (self.currentOperation)
    {
        [self doLogin];
    }
    else
    {
        NIMLogApp(@"link success while no operation");
    }
}

- (void)onConnectFailed:(NIMLinkListener *)listener
{
    [self setLoginStep:NIMLoginStepLinkFailed];
}

- (void)onDisconnect:(NIMLinkListener *)listener
{
    [self setLoginStep:NIMLoginStepLinkFailed];
}

- (void)onNetChanged:(NIMLinkListener *)listener
{
    [self setLoginStep:NIMLoginStepNetChanged];
}

- (BOOL)shouldConnectServer:(NIMLinkListener *)listener
{
    BOOL should = YES;
    nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
    if (core && core->IsKicked())
    {
        should = NO;
    }
    if (_stopConnectingServer) {
        should = NO;
    }
    return should;
}

#pragma mark - NIMTimer
- (void)onNIMTimerFired:(NIMTimer *)timer
{
    NIMLogApp(@"login timerout");
    [self rasieLoginCallback:nimbiz::NIMResTimeoutError
                      taskID:self.loginTaskID];
}

#pragma mark - misc
- (void)doLogin
{

    nimbiz::Property loginReq = [NIMLoginHelper loginTags:self.currentOperation];
    
    nimbiz::IAuthService *service = (nimbiz::IAuthService *)GetServiceFromCore(nimbiz::SVID_NIM_AUTH);
    nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackLogin);
    self.loginTaskID =  service->Invoke_Login(loginReq, callback);
    [self setLoginStep:NIMLoginStepLogining];
    NIMLogApp(@"raise login task id %zd",self.loginTaskID);
}



- (void)rasieLoginCallback:(NSInteger)code
                    taskID:(NSInteger)taskID
{
    NIMLogApp(@"receive login callback: operation %@ code %zd",self.currentOperation,code);
    if (self.loginTaskID != taskID) //如果id不匹配,直接返回
    {
        NIMLogApp(@"task id not matched %zd vs %zd",self.loginTaskID,taskID);
        return;
    }
    self.loginTaskID = 0;
    
   
    
    if (self.currentOperation)
    {
        if (code == nimbiz::NIMResSuccess)
        {
            
            NSString *userID = [[NIMCoreCenter sharedCenter] currentUserID];
            [[NIMCoreCenter sharedCenter] setup:userID];
            
            NIMLoginHandler handler = self.currentOperation.handler;
            if (handler)
            {
                handler(nil);
                self.currentOperation.handler = nil;
            }
            
            //切换成自动模式
            self.currentOperation.mode = NIMLoginModeAuto;

            [_loginTimer stopTimer];
            [self loginAfter];
            NIMLogApp(@"login ok");
        }
        else
        {
            NIMLogErr(@"login fail %zd",code);
            if (self.currentOperation.mode == NIMLoginModeManual) //手动登录
            {
                NSError *error = NIMRemoteError(code);
                NIMLoginHandler handler = self.currentOperation.handler;
                if (handler)
                {
                    handler(error);
                }
                self.currentOperation = nil;
                [_loginTimer stopTimer];
                NIMLogErr(@"cancel operation");
            }
            else
            {
                if([NIMLoginHelper isNoretryCode:code])
                {
                    _stopConnectingServer = YES;
                    NIMLogWar(@"stop connecting server for code %zd",code);
                }
                
                NSError *error = NIMRemoteError(code);
                [[NIMDelegateCenter loginDelegate] onAutoLoginFailed:error];
                NIMLogErr(@"auto login failed");
            }
        }
        [self setLoginStep:code == nimbiz::NIMResSuccess ? NIMLoginStepLoginOK : NIMLoginStepLoginFailed];
    }
}

- (void)loginAfter
{
    [_clientManager onLoginOK];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [[NIMNOSTokenManager sharedManager] tryToRefreshToken];
    });
}

- (void)onKick:(NIMKickReason)reason clientType:(NIMLoginClientType)clientType
{
    [[NIMDelegateCenter loginDelegate] onKick:reason clientType:clientType];
}

- (void)setLoginStep:(NIMLoginStep)step
{
    [[NIMDelegateCenter loginDelegate] onLogin:step];
}

#pragma mark - 多端登录状态
- (void)onClientsChanged:(NSArray *)clients
                    type:(NSInteger)type
{
    [_clientManager onClientsChanged:clients
                                type:type];
}
@end


#pragma mark - Callbacks

namespace nimbiz
{
void    CallbackLogin(IAsynCallbackParam *loginParam)
{
    @autoreleasepool {
        CBLoginParam *param = (CBLoginParam *)loginParam;
        
        NSInteger code = (NSInteger)param->code_;
        NSInteger taskID = (NSInteger)param->task_id_;
        
        
        //这里本来需要同步执行,因为需要注册完毕所有的回调后才进行后续的同步和包处理
        //当时如果同步执行,在刚好close core的时会有死锁的问题,所以采用异步且最多等待n秒的机制来做
        __block BOOL callbackFired = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NIMLoginManager sharedManager] rasieLoginCallback:code
                                                         taskID:taskID];
            callbackFired = YES;
        });
        
        NSDate *start = [NSDate date];
        while (!callbackFired) {
            sleep(0);
            NSDate *end = [NSDate date];
            if ([end timeIntervalSinceDate:start] > 8) {
                NIMLogErr(@"main thread be blocked by core");
                break;
            }
        }
        NSDate *end = [NSDate date];
        NIMLogApp(@"login callback start %@ end %@",start,end);
    }
    
}


void    CallbackLogout(IAsynCallbackParam *logoutParam)
{
    @autoreleasepool {
        NSInteger code = (NSInteger)((CBLogoutParam *)logoutParam)->code_;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NIMLoginManager sharedManager] closeAndLogout:NIMRemoteError(code)];
        });
    }
}


void    CallbackKickout(struct IAsynCallbackParam *kickParam)
{
    @autoreleasepool {
        CBKickoutParam *param = (CBKickoutParam *)kickParam;
        NSInteger reason = (NSInteger)param->reason_;
        NSInteger clientType = (NSInteger)param->client_type_;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NIMLoginManager sharedManager] onKick:reason clientType:clientType];
        });
        
    }
}

void    CallbackSync(struct IAsynCallbackParam *syncParam)
{
    @autoreleasepool
    {
        CBSyncParam *param = (CBSyncParam *)syncParam;
        int32_t step = (int32_t)param->step_;
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (step) {
                case NIMSyncStepBegin:
                    [[NIMLoginManager sharedManager] setLoginStep:NIMLoginStepSyncing];
                    break;
                case NIMSyncStepEnd:
                    [[NIMLoginManager sharedManager] setLoginStep:NIMLoginStepSyncOK];
                    break;
                default:
                    break;
            }
        });
    }
}


void    CallbackMultiLogin(struct IAsynCallbackParam *multiParam)
{
    @autoreleasepool
    {
        CBMultiLoginParam *param = (CBMultiLoginParam *)multiParam;
        NSInteger type = (NSInteger)param->type_;
        NSMutableArray *array = [NSMutableArray array];
        for (auto it = param->clients_.list_.begin(); it != param->clients_.list_.end(); it++)
        {
            NIMLoginClient *client = [[NIMLoginClient alloc] initWithProperty:*it];
            [array addObject:client];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NIMLoginManager sharedManager] onClientsChanged:array
                                                         type:type];
        });
    }
}
    
}