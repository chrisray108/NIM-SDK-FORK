 //
//  NIMRTSManager.m
//  NIMLib
//
//  Created by fenric on 15/4/29.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMRTSManager.h"
#import "NIMRTSManagerProtocol.h"
#import "NIMSDK.h"
#import "NIMNetCallManager.h"
#import "NTSClient.h"
#import "NIMNTSManager.h"
#import "NIMDispatch.h"
#import "NIMRTSObject.h"
#import "NIMNVSManager.h"
#import "NVSDefine.h"
#import "rts_protocol.h"
#import "bind.h"
#import "NIMProtocolUtil.h"
#import "NIMTimer.h"
#import "NVSDelegate.h"
#import "NVSSessionManager.h"
#import "NIMDelegateCenter.h"
#import "NIMRTSRecordingInfo_Private.h"

#define NIMRTSCodeKey (@"code")
#define NIMRTSSessionIDKey (@"sessionid")
#define NIMRTSChannelIDKey (@"channelid")
#define NIMRTSAcceptedKey (@"accepted")
#define NIMRTSUserKey (@"user")
#define NIMRTSUsersKey (@"users")
#define NIMRTSObjectKey (@"rts_object")
#define NIMRTSControlKey (@"control")

#define NIMRTSKeepNotifyIntervalSeconds (1)
#define NIMRTSMaxDataLength (50 * 1024)

@interface NIMRTSManager()<NTSClientDelegate, NVSSessionDelegate, NIMTimerDelegate>
{
}
@property(nonatomic, strong) NSMutableDictionary *rtsObjects;
@property(nonatomic, weak)   NIMNVSManager *nvsManager;
@property(nonatomic, weak)   NIMNTSManager *ntsManager;

@property(nonatomic, strong) NIMTimer *keepNotifyTimer;
@property(nonatomic, strong) NSMutableArray *keeyNotifySessions;

@property(nonatomic, strong) NSMutableArray *incomingRtsCallIDs;

@end

@implementation NIMRTSManager
- (instancetype)init
{
    if (self = [super init])
    {
        _rtsObjects = [[NSMutableDictionary alloc] init];
        _nvsManager = [NIMNVSManager sharedManager];
        _ntsManager = [NIMNTSManager sharedManager];
        _keepNotifyTimer = [[NIMTimer alloc] init];
        _keeyNotifySessions = [[NSMutableArray alloc] init];
        _incomingRtsCallIDs = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - public - NIMRTSManager delegate

//主叫发起通话
- (NSString *)requestRTS:(NSArray *)callees
                services:(NSUInteger)types
                  option:(NIMRTSOption *)option
              completion:(NIMRTSRequestHandler)completion
{
    NIMRTSObject *rtsObject = [[NIMRTSObject alloc] initWithServices:types];
    rtsObject.option = option;
    NIMLogApp(@"User request RTS:%@", rtsObject.sessionID);
    
    //nvs busy handling
    if ((types & NIMRTSServiceAudio) && [[NIMNVSManager sharedManager] isBusy]) {
        NIMLogErr(@"start rts error: nvs busy working on channel %llu", [[NIMNVSManager sharedManager] currentChannelID]);
        if (completion) {
            __block NSString *sessionID = rtsObject.sessionID;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSError *error = NIMLocalError(NIMLocalErrorCodeNetCallBusy);
                completion(error, sessionID);
            });
        }
        return rtsObject.sessionID;
    }
    
    [rtsObject setBlockHandler:completion isCaller:YES];
    [_rtsObjects setObject:rtsObject forKey:rtsObject.sessionID];

    [self invokeRequestNewTun:callees services:types option:option uuid:rtsObject.sessionID];
    
    rtsObject.state = NIMRTSSessionStateCallerRequestSent;
    return rtsObject.sessionID;
}

//被叫响应实时会话请求
- (void)responseRTS:(NSString *)sessionID
             accept:(BOOL)accept
             option:(NIMRTSOption *)option
         completion:(NIMRTSResponseHandler)completion
{
    NIMLogApp(@"User response RTS:%@", sessionID);
    
    NIMRTSObject *rtsObject = [self rtsObjectByKey:sessionID];
    if (rtsObject) {
        
        if (rtsObject.state == NIMRTSSessionStateCalleeResponseSent) {
            NIMLogApp(@"user already responsed the RTS request:%@, ignore it.", sessionID);
            return;
        }
        
        if (accept && (rtsObject.services & NIMRTSServiceAudio) && [_nvsManager isBusy]) {
            if (completion) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeNetCallBusy);
                completion(error, sessionID);
            }
            NIMLogErr(@"RTS not responsed: NVS is busy!");
            return;
        }
        
        rtsObject.state = NIMRTSSessionStateCalleeResponseSent;
        [rtsObject setBlockHandler:completion isCaller:NO];
        
        if (option) {
            if (nil == rtsObject.option) {
                rtsObject.option = [[NIMRTSOption alloc] init];
            }
            rtsObject.option.disableRecord = option.disableRecord;
            if (rtsObject.nvsObject) {
                rtsObject.nvsObject.serverRecordAudio = !(option.disableRecord);
                rtsObject.nvsObject.serverRecordVideo = !(option.disableRecord);
            }
            if (rtsObject.ntsObject) {
                rtsObject.ntsObject.disableRecord = option.disableRecord;
            }
        }
        else {
            rtsObject.nvsObject.serverRecordAudio = YES;
            rtsObject.nvsObject.serverRecordVideo = YES;
        }
        
        [self invokeResponseTun:rtsObject.serviceID accept:accept];
    }
    else {
        if (completion) {
            NSError *error = NIMLocalError(NIMLocalErrorCodeInvalidParam);
            completion(error, sessionID);
        }
        NIMLogErr(@"RTS not responsed: object not found :@!", sessionID);
    }
}

//挂断实时会话
- (void)terminateRTS:(NSString *)sessionID
{
    NIMLogApp(@"User terminate RTS:%@", sessionID);
    
    NIMRTSObject *rtsObject = [self rtsObjectByKey:sessionID];

    if (rtsObject) {
        if (rtsObject.state != NIMRTSSessionStateTermimate) {
            rtsObject.state = NIMRTSSessionStateTermimate;
            [_keeyNotifySessions removeObject:sessionID];
            if (rtsObject.serviceID) {
                [self invokeCloseTun:rtsObject.serviceID];
            }
        }
        else {
            NIMLogApp(@"RTS terminate message not sent not handled: already terminated");
        }
        [self stopRTS:rtsObject];
    }
    else {
        NIMLogErr(@"RTS terminate not handled: object not found! %@", sessionID);
    }
}

- (BOOL)sendRTSData:(NSData *)data
               from:(NSString *)sessionID
                 to:(NSString *)userID
               with:(NIMRTSService)service
{
    if (service != NIMRTSServiceReliableTransfer) {
        return NO;
    }
    
    //    NSLog(@"======= sendRTSData length:%zd =======", data.length);

    if (data.length > NIMRTSMaxDataLength) {
        NIMLogErr(@"Error: RTS send data exceeds max length: %zd > %zd", data.length, NIMRTSMaxDataLength);
        return NO;
    }
    
    NIMRTSObject *rtsObject = [self rtsObjectByKey:sessionID];
    
    if (rtsObject) {
        UInt64 clientID;
        if (userID) {
            clientID = [[rtsObject.usersInfo objectForKey:userID] unsignedLongLongValue];
            if (0 == clientID) {
                NIMLogErr(@"Send RTS data error: user %@ not found!", userID);
                return NO;
            }
        }
        else {
            clientID = 0;
        }
        return [[NIMNTSManager sharedManager] sendNTSData:data
                                                     from:rtsObject.ntsObject
                                                       to:clientID];
    }
    return NO;
}

- (void)sendRTSControl:(NSString *)controlInfo
            forSession:(NSString *)sessionID
{
    NIMLogApp(@"User send RTS control:%@-%@", sessionID, controlInfo);
    
    NIMRTSObject *rtsObject = [self rtsObjectByKey:sessionID];
    if (rtsObject && rtsObject.serviceID) {
        [self invokeSendRtsControl:rtsObject.serviceID command:controlInfo];
    }
    else {
        NIMLogErr(@"RTS control not sent: object not found %@", sessionID);
    }
    
}



//设置当前实时会话静音模式
- (void)setMute:(BOOL)mute
{
    if (_nvsManager.session) {
        [_nvsManager.session setMute:mute];
    }
}

//设置当前实时会话扬声器模式
- (void)setSpeaker:(BOOL)useSpeaker
{
    if (_nvsManager.session) {
        [_nvsManager.session setSpeake:useSpeaker];
    }
}

- (UInt64)serviceID:(NSString *)sessionID
{
    NIMRTSObject *rtsObject = [self rtsObjectByKey:sessionID];
    return rtsObject.serviceID;
}

- (NSString *)sessionID:(UInt64)serviceID
{
    NIMRTSObject *rtsObject = [self rtsObjectByKey:@(serviceID)];
    return rtsObject.sessionID;
}


#pragma mark - NVSSessionDelegate
- (void)onSessionStatus:(NVSVideoChatSessionStatus)status
{
    dispatch_block_t mainBlock = ^(){
        
        uint64_t channelID = [_nvsManager currentChannelID];
        NIMRTSObject *rtsObject = [self rtsObjectByKey:@(channelID)];
        
        if (rtsObject == nil) {
            NIMLogErr(@"nvs session status error: object not found, %llu", channelID);
            return;
        }
        
        NIMRTSStatus rtsStatus = (status == NVSVideoChatSessionStatusJoined) ? NIMRTSStatusConnect : NIMRTSStatusDisconnect;
        
        if (rtsStatus == NIMRTSStatusConnect) {
            [self setSpeaker:YES];
            
            NVSSessionRecordInfo *nvsInfo = [_nvsManager getRecordInfo];
            if ([[nvsInfo recordFile] length] > 0) {
                NIMRTSRecordingInfo *recordInfo = [[NIMRTSRecordingInfo alloc] initWithService:NIMRTSServiceAudio
                                                                                       address:nvsInfo.recordAddr
                                                                                          file:nvsInfo.recordFile];
                [[NIMDelegateCenter rtsDelegate] onRTSRecordingInfo:recordInfo forSession:rtsObject.sessionID];
            }
        }
        
        [[NIMDelegateCenter rtsDelegate] onRTS:rtsObject.sessionID
                                       service:NIMRTSServiceAudio
                                        status:rtsStatus
                                         error:nil];
    };
    
    nim_main_async_safe(mainBlock);
}

- (void)onNetstatBad:(NVSVideoChatSessionNetStat)stat
{
    
}

- (void)onNetstatChanged:(NVSVideoChatSessionNetStat)stat
{
    
}

- (void)onLoginError:(NVSLoginErrorCode)code
{
    dispatch_block_t mainBlock = ^(){

        uint64_t channelID = [_nvsManager currentChannelID];
        NIMRTSObject *rtsObject = [self rtsObjectByKey:@(channelID)];
        
        if (rtsObject == nil) {
            NIMLogErr(@"nvs session error not handled: object not found, %llu", channelID);
            return;
        }
        
        NIMLogErr(@"RTS: nvs login error:%d!", code);
        
        [[NIMDelegateCenter rtsDelegate] onRTS:rtsObject.sessionID
                                       service:NIMRTSServiceAudio
                                        status:NIMRTSStatusDisconnect
                                         error:NIMRemoteError(code)];
    };
    
    nim_main_async_safe(mainBlock);
}
- (void)onAudioDeviceError:(NVSAudioErrorCategory)category
{
    dispatch_block_t mainBlock = ^(){

        uint64_t channelID = [_nvsManager currentChannelID];
        NIMRTSObject *rtsObject = [self rtsObjectByKey:@(channelID)];
        
        if ((rtsObject == nil) || (rtsObject.nvsObject == nil)) {
            NIMLogErr(@"nvs session error not handled: object not found, %llu", channelID);
            return;
        }
        NIMLogErr(@"rts: nvs session disconnected for audio error, %llu", channelID);

        [[NIMDelegateCenter rtsDelegate] onRTS:rtsObject.sessionID
                                       service:NIMRTSServiceAudio
                                        status:NIMRTSStatusDisconnect
                                         error:NIMLocalError(NIMLocalErrorCodeAudioDeviceInitFailed)];
    };
    
    nim_main_async_safe(mainBlock);
}
- (void)onSessionReport:(NVSSessionReport *)report
{
    NIMLogApp(@"session report: channel=%llu, description=%@, tx=%llu, rx=%llu",
              report.channelID, report.errorDescription, report.totalTxBytes, report.totalRxBytes);
}

#pragma mark - NTSClientDelegate
- (void)onNTSConnectResult:(NTSConnectResultInfo *)info
                 sessionID:(NSString *)sessionID
{
    NIMLogApp(@"onNTSConnectResult:%d, session:%@", info.status, sessionID);

    dispatch_block_t mainBlock = ^(){

        NIMRTSObject *rtsObject = [self rtsObjectByKey:sessionID];
        if (rtsObject && rtsObject.ntsObject) {
            rtsObject.ntsObject.info = info;
            
            if (info.status == NTSNetErrorServerConnect) {
                if ([_ntsManager tryNextServer:rtsObject.ntsObject]) {
                    //这里不用通知上层直接换服务器重试
                    return;
                };
            }
        }
        
        if (info.status != NTSNetNoError) {
            [[NIMDelegateCenter rtsDelegate] onRTS:sessionID
                                           service:NIMRTSServiceReliableTransfer
                                            status:NIMRTSStatusDisconnect
                                             error:NIMRemoteError(info.status)];
        }
        else {
            if ([info.recordName length] > 0) {
                NIMRTSRecordingInfo *recordInfo = [[NIMRTSRecordingInfo alloc] initWithService:NIMRTSServiceReliableTransfer
                                                                                       address:info.recordAddress
                                                                                          file:info.recordName];
                [[NIMDelegateCenter rtsDelegate] onRTSRecordingInfo:recordInfo forSession:sessionID];
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
}
-(void) onNTSDisconnect:(NSString *)sessionID
{
    NIMLogPro(@"onNTSServerDisconnect, session:%@", sessionID);

    nim_main_async_safe(^{
        [[NIMDelegateCenter rtsDelegate] onRTS:sessionID
                                       service:NIMRTSServiceReliableTransfer
                                        status:NIMRTSStatusDisconnect
                                         error:nil];
    });

}

-(void) onNTSClientJoin:(NTSClientInfo *)info sessionID:(NSString *)sessionID
{
    nim_main_async_safe(^{
        [[NIMDelegateCenter rtsDelegate] onRTS:sessionID
                                       service:NIMRTSServiceReliableTransfer
                                        status:NIMRTSStatusConnect
                                         error:nil];
    });
    NIMLogPro(@"onNTSClientJoin:%llu, session:%@", info.clientID, sessionID);
}

-(void) onNTSClientLeave:(uint64_t)clientID forReason:(NTSLeaveReason)reason sessionID:(NSString *)sessionID
{
    nim_main_async_safe(^{
        [[NIMDelegateCenter rtsDelegate] onRTS:sessionID
                                       service:NIMRTSServiceReliableTransfer
                                        status:NIMRTSStatusDisconnect
                                         error:nil];
    });
    NIMLogPro(@"onNTSClientLeave:%llu for reason:%d, session:%@", clientID, reason, sessionID);
}

-(void) onNTSReceiveData:(NSData *)data from:(uint64_t)clientID sessionID:(NSString *)sessionID
{
    dispatch_block_t mainBlock = ^(){
        
        NIMRTSObject *rtsObject = [self rtsObjectByKey:sessionID];
        NSString *sender = [rtsObject.usersInfo objectForKey:@(clientID)];

        [[NIMDelegateCenter rtsDelegate] onRTSReceive:sessionID
                                                 data:data
                                                 from:sender
                                               withIn:NIMRTSServiceReliableTransfer];
    };
    
    nim_main_async_safe(mainBlock);
}
-(void) onNTSError:(uint32_t)error sessionID:(NSString *)sessionID
{
    NIMLogErr(@"onNTSError:%d, session:%@", error, sessionID);
    
    dispatch_block_t mainBlock = ^(){

        NIMRTSObject *rtsObject = [self rtsObjectByKey:sessionID];
        
        if (rtsObject == nil) {
            NIMLogErr(@"NTS error not handled: object not found %@", sessionID);
            return;
        }
        
        BOOL disconnected = NO;
        if (error == NTSNetErrorServerConnect) {
            if (rtsObject.ntsObject && ![_ntsManager tryNextServer:rtsObject.ntsObject]) {
                NIMLogErr(@"rts: nts terminated due to server connection error!");
                disconnected = YES;
            }
        }
        else {
            NIMLogErr(@"rts: nts login error:%d!", error);
            disconnected = YES;
        }
        if (disconnected) {
            [[NIMDelegateCenter rtsDelegate] onRTS:rtsObject.sessionID
                                           service:NIMRTSServiceReliableTransfer
                                            status:NIMRTSStatusDisconnect
                                             error:NIMRemoteError(error)];
        }
    };
    
    nim_main_async_safe(mainBlock);
}

#pragma mark - NIMTimerDelegate
- (void)onNIMTimerFired:(NIMTimer *)timer
{
    if (timer == _keepNotifyTimer) {
        
        dispatch_block_t mainBlock = ^(){

            NSArray *keeyNotifySessions;
            keeyNotifySessions = [NSArray arrayWithArray:_keeyNotifySessions];
            [_keeyNotifySessions removeAllObjects];

            for (NSString *sessionID in keeyNotifySessions) {
                NIMRTSObject *rtsObject = [self rtsObjectByKey:sessionID];
                if (rtsObject && rtsObject.keepNotifyUsers.count > 0) {
                    [self invokeKeepNotify:rtsObject.serviceID uuid:rtsObject.sessionID callees:rtsObject.keepNotifyUsers];
                }
            }
        };
        
        nim_main_async_safe(mainBlock);
    }
}

#pragma mark - private methods
- (void)startRTS:(NIMRTSObject *)rtsObject
{
    if ((rtsObject.services & NIMRTSServiceAudio) && [_nvsManager isBusy]){
        NIMLogErr(@"RTS has audio channel, but nvs is busy, stop nvs firstly...");
        [[NIMNetCallManager sharedManager] internalHangup];
        [_nvsManager stop:0];
    }
    
    if (rtsObject.nvsObject) {
        [_nvsManager start:rtsObject.nvsObject delegate:self];
    }
    
    if (rtsObject.ntsObject) {
        rtsObject.ntsObject.delegate = self;
        [_ntsManager startNTS:rtsObject.ntsObject];
    }
}

- (void)stopRTS:(NIMRTSObject *)rtsObject
{
    if (rtsObject.nvsObject) {
        [_nvsManager stop:rtsObject.nvsObject.channelId];
        rtsObject.nvsObject = nil;
    }
    if (rtsObject.ntsObject) {
        [_ntsManager stopNTS:rtsObject.ntsObject];
        rtsObject.ntsObject = nil;
    }
}

- (NSArray *)serverStringToArray:(NSString *)addrString
{
    NSArray *addrs = [addrString componentsSeparatedByString:@";"];
    NSMutableArray *mutableArray;
    
    for (NSString *addr in addrs) {
        if ([addr length] > 0) {
            if (mutableArray == nil) {
                mutableArray = [NSMutableArray arrayWithObject:addr];
            }
            else {
                [mutableArray addObject:addr];
            }
        }
    }
    
    return mutableArray;
}

- (NSDictionary *)parseUsersInfo:(std::map<uint64_t, nimbiz::UTF8String> &)info
{
    NSMutableDictionary *usersInfo = [[NSMutableDictionary alloc] init];
    std::map<uint64_t, nimbiz::UTF8String>::iterator i = info.begin();
    for (; i != info.end(); ++i) {
        [usersInfo setObject:NSUTF8(i->second) forKey:@(i->first)];
        [usersInfo setObject:@(i->first) forKey:NSUTF8(i->second)];
    }
    return usersInfo;
}

- (NIMRTSObject *)rtsObjectByKey:(id)key
{
    NIMRTSObject *rtsObject = nil;
    if (key) {
        rtsObject = [_rtsObjects objectForKey:key];
    }
    return rtsObject;
}

#pragma mark - 协议
#pragma mark 发起实时会话
- (void)invokeRequestNewTun:(NSArray *)calleeUsers
                   services:(NSInteger)services
                     option:(NIMRTSOption *)option
                       uuid:(NSString *)uuid
{
    nimbiz::IRtsService *rtsService = (nimbiz::IRtsService*)GetServiceFromCore(nimbiz::SVID_NIM_RTS);
    if (rtsService)
    {
        nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackRtsNewTunResponse);
        
        NSArray *servicesArray = [self servicesToStringArray:services];
        std::list<nimbiz::UTF8String> services_list =  [NIMProtocolUtil arrayToStringList:servicesArray];
        std::list<nimbiz::UTF8String> users_list = [NIMProtocolUtil arrayToStringList:calleeUsers];
        
        
        nimbiz::Property notify;
        notify.put_uint32(nimbiz::NIMRtsNotifyOptionTagApnsEnable, (uint32_t)(option.apnsInuse));
        notify.put_uint32(nimbiz::NIMRtsNotifyOptionTagApnsCountBadge, (uint32_t)(option.apnsBadge));
        notify.put_uint32(nimbiz::NIMRtsNotifyOptionTagApnsWithNick, (uint32_t)(option.apnsWithPrefix));
        
        if ([option.apnsContent length]) {
            notify.put_string(nimbiz::NIMRtsNotifyOptionTagApnsContent, UTF8(option.apnsContent));
        }
        
        if ([option.extendMessage length]) {
            notify.put_string(nimbiz::NIMRtsNotifyOptionTagNotifyAttach, UTF8(option.extendMessage));
        }
        
        nimbiz::UTF8String payload = [NIMProtocolUtil stringByJsonDictionary:option.apnsPayload];
        if (!payload.empty()) {
            notify.put_string(nimbiz::NIMRtsNotifyOptionTagApnsPayload, payload);
        }
        
        if ([option.apnsSound length]) {
            notify.put_string(nimbiz::NIMRtsNotifyOptionTagApnsSound, UTF8(option.apnsSound));
        }
        
        rtsService->Invoke_RtsNewTun(services_list, users_list, UTF8(uuid), notify, callback);
    }
}

#pragma mark 发起实时会话的服务器响应
- (void)onNewTunRsponse:(NSDictionary *)info
{
    NSInteger code = [[info objectForKey:NIMRTSCodeKey] integerValue];
    NSString *sessionID = [info objectForKey:NIMRTSSessionIDKey];
    NIMRTSObject *rtsObject = [self rtsObjectByKey:sessionID];
    
    NSError *error = nil;
    if (code == nimbiz::NIMResSuccess) {
        if (rtsObject == nil) {
            NIMLogErr(@"Handle new tun response failed: RTS object not found.");
            return;
        }
        
        if ([self handlePendingTerminate:rtsObject]) {
            NIMLogApp(@"Handle new tun response ignored: pending hangup.");
            return;
        }
        [_rtsObjects setObject:rtsObject forKey:@(rtsObject.serviceID)];
        
        if (rtsObject.keepNotifyUsers) {
            [_keeyNotifySessions addObject:[rtsObject sessionID]];
            [_keepNotifyTimer startTimer:NIMRTSKeepNotifyIntervalSeconds delegate:self repeats:NO];
            
        }
    }
    else {
        error = NIMRemoteError(code);
    }
    
    if (rtsObject) {
        rtsObject.state = NIMRTSSessionStateCallerServerResponse;
        if (rtsObject.requestBlock) {
            rtsObject.requestBlock(error, sessionID);
        }
    }
}

- (BOOL)handlePendingTerminate:(NIMRTSObject *)rtsObject
{
    if (rtsObject && rtsObject.state == NIMRTSSessionStateTermimate) {
        nimbiz::IRtsService *rtsService = (nimbiz::IRtsService*)GetServiceFromCore(nimbiz::SVID_NIM_RTS);
        if (rtsService)
        {
            rtsService->Invoke_RtsCloseTun(rtsObject.serviceID);
        }
        return YES;
    }
    return NO;
}


-(NSArray *)servicesToStringArray:(NSUInteger)services
{
    NSMutableArray *stringArray = [[NSMutableArray alloc] init];
    int serviceTypes[] = {NIMRTSServiceAudio, NIMRTSServiceReliableTransfer,};
    int serviceTagValue[] = {nimbiz::NIMRtsServiceTypeAudio, nimbiz::NIMRtsServiceTypeTcp, };
    for (int i = 0; i < sizeof(serviceTypes) / sizeof(int); i ++) {
        if (services & serviceTypes[i]) {
            NSString *service = [NSString stringWithFormat:@"%d", serviceTagValue[i]];
            [stringArray addObject:service];
        }
    }
    return stringArray;
}

- (void)fillCallerParam:(nimbiz::CBRtsNewTunParam *)param
{
    NIMRTSObject *rtsObject = [self rtsObjectByKey:NSUTF8(param->uuid)];
    if (rtsObject) {
        rtsObject.serviceID = param->channel_id_;
        rtsObject.state = NIMRTSSessionStateCallerServerResponse;
        rtsObject.keepNotifyUsers = [NIMProtocolUtil stringListToArray:param->keep_calling_users_];
        rtsObject.usersInfo = [[NIMRTSManager sharedManager] parseUsersInfo:param->users_info_];
        
        for (size_t i = 0; i < param->services_info_.size(); i++) {
            nimbiz::Property &serviceInfo = (param->services_info_)[i];
            nimbiz::NIMRtsServiceType serviceType = (nimbiz::NIMRtsServiceType)[NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagServiceType)) integerValue];
            if (serviceType == nimbiz::NIMRtsServiceTypeTcp) {
                NIMNTSObject *ntsObject = [[NIMNTSObject alloc] init];
                ntsObject.sessionID = NSUTF8(param->uuid);
                ntsObject.channelId = serviceInfo.get_uint64(nimbiz::NIMRtsTunInfoTagChannelId);
                ntsObject.myUid = param->my_uid_;
                ntsObject.turnAddrs = [self serverStringToArray:NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagTurnAddrs))];
                ntsObject.proxyAddrs = [self serverStringToArray:NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagProxyAddrs))];
                
                if (rtsObject.option) {
                    ntsObject.disableRecord = rtsObject.option.disableRecord;
                }
                rtsObject.ntsObject = ntsObject;
            }
            else if (serviceType == nimbiz::NIMRtsServiceTypeAudio) {
                NIMNVSObject *nvsObject = [[NIMNVSObject alloc] init];
                nvsObject.callType = NIMNetCallTypeAudio;
                nvsObject.myUid = param->my_uid_;
                nvsObject.channelId = serviceInfo.get_uint64(nimbiz::NIMRtsTunInfoTagChannelId);
                nvsObject.turnAddrs = [self serverStringToArray:NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagTurnAddrs))];
                nvsObject.stunAddrs = [self serverStringToArray:NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagStunAddrs))];
                nvsObject.proxyAddrs = [self serverStringToArray:NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagProxyAddrs))];
                if (rtsObject.option) {
                    nvsObject.serverRecordAudio = !(rtsObject.option.disableRecord);
                    nvsObject.serverRecordVideo = !(rtsObject.option.disableRecord);
                }
                else {
                    nvsObject.serverRecordAudio = YES;
                    nvsObject.serverRecordVideo = YES;
                }
                nvsObject.disableP2P = !(param->enable_p2p_);
                nvsObject.callConfig = NSUTF8(param->call_config_);
                rtsObject.nvsObject = nvsObject;
            }
        }
    }
    else {
        NIMLogErr(@"RTS object not found, id:%@", NSUTF8(param->uuid));
    }
}

#pragma mark 持续呼叫
- (void)invokeKeepNotify:(uint64_t)channelID
                    uuid:(NSString *)uuid
                 callees:(NSArray *)callees
{
    nimbiz::IRtsService *rtsService = (nimbiz::IRtsService *)GetServiceFromCore(nimbiz::SVID_NIM_RTS);
    if (rtsService) {
        nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackRtsKeepNotifyResponse);
        rtsService->Invoke_RtsKeepNotify([NIMProtocolUtil arrayToStringList:callees], channelID, UTF8(uuid), callback);
    }
}

- (void)onKeepNotifyResponse:(NSDictionary *)info
{
    NIMRTSObject *rtsObject = [self rtsObjectByKey:[info objectForKey:NIMRTSSessionIDKey]];
    if (rtsObject) {
        rtsObject.keepNotifyUsers = [info objectForKey:NIMRTSUsersKey];
        if (rtsObject.keepNotifyUsers.count > 0) {
            [_keeyNotifySessions addObject:rtsObject.sessionID];
            [_keepNotifyTimer startTimer:NIMRTSKeepNotifyIntervalSeconds delegate:self repeats:NO];
        }
    }
}

#pragma mark 被叫收到请求
- (void)onRtsTunReceivedNotify:(NSDictionary *)info
{
    NIMRTSObject *rtsObject = [info objectForKey:NIMRTSObjectKey];
    
    //bug NIM-3208同款: 允许多个ios设备登录同一帐号时，一边在线，一边离线，在线的一边会收到两次呼入请求，这里去一下重
    if ([_incomingRtsCallIDs containsObject:@(rtsObject.serviceID)]) {
        NIMLogApp(@"Duplicated incoming RTS request %llu, drop it.", rtsObject.serviceID);
        return;
    }

    NIMRTSObject *currentRtsObject = [self rtsObjectByKey:rtsObject.sessionID];
    if (currentRtsObject) {
        NIMLogErr(@"Handle RTS tun received error: having existing session %@, terminate internally!", currentRtsObject.sessionID);
        [self stopRTS:currentRtsObject];
    }
    [_rtsObjects setObject:rtsObject forKey:rtsObject.sessionID];
    [_rtsObjects setObject:rtsObject forKey:@(rtsObject.serviceID)];

    [_incomingRtsCallIDs addObject:@(rtsObject.serviceID)];
    
    [[NIMDelegateCenter rtsDelegate] onRTSRequest:rtsObject.sessionID from:rtsObject.caller services:rtsObject.services message:rtsObject.option.extendMessage];
}

- (NIMRTSObject *)rtsObjectFromReceivedParam:(nimbiz::CBRtsTunReceivedParam *)param
{
    NIMRTSObject *rtsObject = [[NIMRTSObject alloc] initWithServices:0];
    rtsObject.serviceID = param->channel_id_;
    rtsObject.caller = NSUTF8(param->caller_);
    rtsObject.usersInfo = [[NIMRTSManager sharedManager] parseUsersInfo:param->users_info_];

    rtsObject.state = NIMRTSSessionStateCalleeRequestReceived;
    NSString *extendMessage = NSUTF8(param->extend_message_);
    if(extendMessage) {
        NIMRTSOption *option = [[NIMRTSOption alloc] init];
        option.extendMessage = extendMessage;
        rtsObject.option = option;
    }
    
    for (size_t i = 0; i < param->services_info_.size(); i++) {
        nimbiz::Property &serviceInfo = (param->services_info_)[i];
        nimbiz::NIMRtsServiceType serviceType = (nimbiz::NIMRtsServiceType)[NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagServiceType)) integerValue];
        if (serviceType == nimbiz::NIMRtsServiceTypeTcp) {
            rtsObject.services |= NIMRTSServiceReliableTransfer;
            NIMNTSObject *ntsObject = [[NIMNTSObject alloc] init];
            ntsObject.sessionID = rtsObject.sessionID;
            ntsObject.channelId = serviceInfo.get_uint64(nimbiz::NIMRtsTunInfoTagChannelId);
            ntsObject.myUid = param->my_uid_;
            ntsObject.turnAddrs = [self serverStringToArray:NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagTurnAddrs))];
            ntsObject.proxyAddrs = [self serverStringToArray:NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagProxyAddrs))];
            rtsObject.ntsObject = ntsObject;
        }
        else if (serviceType == nimbiz::NIMRtsServiceTypeAudio) {
            NIMNVSObject *nvsObject = [[NIMNVSObject alloc] init];
            nvsObject.callType = NIMNetCallTypeAudio;
            nvsObject.myUid = param->my_uid_;
            nvsObject.channelId = serviceInfo.get_uint64(nimbiz::NIMRtsTunInfoTagChannelId);
            nvsObject.turnAddrs = [self serverStringToArray:NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagTurnAddrs))];
            nvsObject.stunAddrs = [self serverStringToArray:NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagStunAddrs))];
            nvsObject.proxyAddrs = [self serverStringToArray:NSUTF8(serviceInfo.get_string(nimbiz::NIMRtsTunInfoTagProxyAddrs))];
            nvsObject.disableP2P = !(param->enable_p2p_);
            nvsObject.callConfig = NSUTF8(param->call_config_);
            rtsObject.services |= NIMRTSServiceAudio;
            rtsObject.nvsObject = nvsObject;
        }
    }
    return rtsObject;
}

#pragma mark 被叫响应请求
- (void)invokeResponseTun:(uint64_t)channelID
                   accept:(BOOL)accept
{
    nimbiz::IRtsService *rtsService = (nimbiz::IRtsService *)GetServiceFromCore(nimbiz::SVID_NIM_RTS);
    if (rtsService) {
        nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackRtsResponseTunResponse);
        rtsService->Invoke_RtsResponseTun(channelID, accept, callback);
    }
}

- (void)onResponseTunResponse:(NSDictionary *)info
{
    NSError *error = nil;
    uint64_t channelID = [[info objectForKey:NIMRTSChannelIDKey] unsignedLongLongValue];
    NIMRTSObject *rtsObject = [self rtsObjectByKey:@(channelID)];
    
    NSInteger code = [[info objectForKey:NIMRTSCodeKey] integerValue];

    if (code == nimbiz::NIMResSuccess) {
        if (rtsObject) {
            if ([[info objectForKey:NIMRTSAcceptedKey] boolValue]) {
                [self startRTS:rtsObject];
            }
        }
    }
    else {
        
        if (code == nimbiz::NIMResNetCallOtherHandled) {
            error = NIMLocalError(NIMLocalErrorCodeNetCallOtherHandled);
        }
        else {
            error = NIMRemoteError(code);
        }
    }
    
    if (rtsObject && rtsObject.responseBlock) {
        rtsObject.responseBlock(error, rtsObject.sessionID);
    }
}

#pragma mark 主叫收到被叫响应
- (void)onRtsTunResponsedNotify:(NSDictionary *)info pendingStartResponse:(BOOL)pending
{
    uint64_t channel = [[info objectForKey:NIMRTSChannelIDKey] unsignedLongLongValue];
    NSString *callee = [info objectForKey:NIMRTSUserKey];
    BOOL accepted = [[info objectForKey:NIMRTSAcceptedKey] boolValue];
    
    NIMRTSObject *rtsObject = [self rtsObjectByKey:@(channel)];
    
    if (!rtsObject) {
        if (!pending) {
            NIMLogErr(@"On RTS responsed: object not found for channel %llu, pending...", channel);
            __weak typeof(self) wself = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wself onRtsTunResponsedNotify:info pendingStartResponse:YES];
            });
        }
        else {
            NIMLogErr(@"On RTS responsed error: object not found! %llu", channel);
        }
        return;
    }
    
    [[NIMDelegateCenter rtsDelegate] onRTSResponse:rtsObject.sessionID
                                              from:callee
                                          accepted:accepted];
    rtsObject.state = NIMRTSSessionStateCallerCalleeResponse;
    
    if (accepted && rtsObject) {
        [self startRTS:rtsObject];
    }
}

#pragma mark 多端响应通知
- (void)onRtsOtherResponsedNotify:(NSDictionary *)info
{
    uint64_t channelID = [[info objectForKey:NIMRTSChannelIDKey] unsignedLongLongValue];
    BOOL accepted = [[info objectForKey:NIMRTSAcceptedKey] boolValue];
    NIMRTSObject *rtsObject = [self rtsObjectByKey:@(channelID)];
    
    if (rtsObject) {
        [[NIMDelegateCenter rtsDelegate] onRTSResponsedByOther:rtsObject.sessionID
                                                      accepted:accepted];
    }
    else {
        NIMLogErr(@"RTS other response not handled : object not found! %llu", channelID);
    }
}

#pragma mark 结束实时会话
- (void)invokeCloseTun:(uint64_t)channelID
{
    nimbiz::IRtsService *rtsService = (nimbiz::IRtsService *)GetServiceFromCore(nimbiz::SVID_NIM_RTS);
    if (rtsService) {
        rtsService->Invoke_RtsCloseTun(channelID);
    }
}

#pragma mark 收到结束实时会话通知
- (void)onRtsTunClosedNotify:(NSDictionary *)info
{
    uint64_t channel = [[info objectForKey:NIMRTSChannelIDKey] unsignedLongLongValue];
    NSString *user = [info objectForKey:NIMRTSUserKey];
    NIMRTSObject *rtsObject = [self rtsObjectByKey:@(channel)];
    if (rtsObject) {
        rtsObject.state = NIMRTSSessionStateTermimate;
        [[NIMDelegateCenter rtsDelegate] onRTSTerminate:rtsObject.sessionID by:user];
    }
}

#pragma mark 发送控制指令
- (void)invokeSendRtsControl:(uint64_t)channelID command:(NSString *)command
{
    nimbiz::IRtsService *rtsService = (nimbiz::IRtsService *)GetServiceFromCore(nimbiz::SVID_NIM_RTS);
    if (rtsService) {
        rtsService->Invoke_RtsControl(channelID, UTF8(command));
    }
}

#pragma mark 收到控制指令
- (void)onRtsControlNotify:(NSDictionary *)info
{
    uint64_t channel = [[info objectForKey:NIMRTSChannelIDKey] unsignedLongLongValue];
    NSString *user = [info objectForKey:NIMRTSUserKey];
    NSString *control = [info objectForKey:NIMRTSControlKey];
    NIMRTSObject *rtsObject = [self rtsObjectByKey:@(channel)];
    if (rtsObject) {
        [[NIMDelegateCenter rtsDelegate] onRTSControl:control from:user forSession:rtsObject.sessionID];
    }
}

@end

namespace nimbiz
{
#pragma mark - 协议回调
void CallbackRtsNewTunResponse(IAsynCallbackParam *param)
{
    @autoreleasepool {
        CBRtsNewTunParam *aparam = (CBRtsNewTunParam *)param;
        if (aparam->code_ == nimbiz::NIMResSuccess) {
            [[NIMRTSManager sharedManager] fillCallerParam:aparam];
        }
        NSDictionary *info = @{NIMRTSCodeKey : @(aparam->code_),
                               NIMRTSSessionIDKey : NSUTF8(aparam->uuid),
                               };
        nim_main_async_safe(^{
            [[NIMRTSManager sharedManager] onNewTunRsponse:info];
        });
    }

}

void CallbackRtsKeepNotifyResponse(IAsynCallbackParam *param)
{
    @autoreleasepool
    {
        CBRtsKeepNotifyParam *aparam = (CBRtsKeepNotifyParam *)param;
        NSArray *keepNotifyUsers = [NIMProtocolUtil stringListToArray:aparam->callee_users_];
        
        NSDictionary *info = @{NIMRTSSessionIDKey : NSUTF8(aparam->uuid),
                               NIMRTSUsersKey : keepNotifyUsers,
                               };
        nim_main_async_safe(^{
            [[NIMRTSManager sharedManager] onKeepNotifyResponse:info];
        });
    }
    
}

void CallbackRtsResponseTunResponse(IAsynCallbackParam *param)
{
    @autoreleasepool
    {
        CBRtsResponseTunParam *aparam = (CBRtsResponseTunParam *)param;
        
        NSDictionary *info = @{NIMRTSCodeKey : @(aparam->code_),
                               NIMRTSChannelIDKey : @(aparam->channel_id_),
                               NIMRTSAcceptedKey : @(aparam->accept_),
                               };
        
        nim_main_async_safe(^{
            [[NIMRTSManager sharedManager] onResponseTunResponse:info];
        });
    }
}



void CallbackRtsTunReceivedNotify(IAsynCallbackParam *param)
{
    @autoreleasepool {
        CBRtsTunReceivedParam *aparam = (CBRtsTunReceivedParam *)param;
        NIMRTSObject *rtsObject = [[NIMRTSManager sharedManager] rtsObjectFromReceivedParam:aparam];
        NSDictionary *info = @{NIMRTSObjectKey : rtsObject,
                               };
        nim_main_async_safe(^{
            [[NIMRTSManager sharedManager] onRtsTunReceivedNotify:info];
        });
    }

}
void CallbackRtsTunResponsedNotify(IAsynCallbackParam *param)
{
    @autoreleasepool {
        CBRtsTunResponsedNotifyParam *aparam = (CBRtsTunResponsedNotifyParam *)param;
        NSDictionary *info = @{NIMRTSChannelIDKey : @(aparam->channel_id_),
                               NIMRTSUserKey : NSUTF8(aparam->callee_),
                               NIMRTSAcceptedKey : @(aparam->accepted_),
                               };
        nim_main_async_safe(^{
            [[NIMRTSManager sharedManager] onRtsTunResponsedNotify:info pendingStartResponse:NO];
        });
    }
}

void CallbackRtsOtherResponsedNotify(IAsynCallbackParam *param)
{
    @autoreleasepool {
        CBRtsOtherResponsedNotifyParam *aparam = (CBRtsOtherResponsedNotifyParam *)param;
        NSDictionary *info = @{NIMRTSChannelIDKey : @(aparam->channel_id_),
                               NIMRTSAcceptedKey : @(aparam->accepted_),
                               };
        nim_main_async_safe(^{
            [[NIMRTSManager sharedManager] onRtsOtherResponsedNotify:info];
        });
    }
}

void CallbackRtsTunClosedNotify(IAsynCallbackParam *param)
{
    @autoreleasepool {
        CBRtsTunClosedNotifyParam *aparam = (CBRtsTunClosedNotifyParam *)param;
        NSDictionary *info = @{NIMRTSChannelIDKey : @(aparam->channel_id_),
                               NIMRTSUserKey : NSUTF8(aparam->peer_),
                               };
        nim_main_async_safe(^{
            [[NIMRTSManager sharedManager] onRtsTunClosedNotify:info];
        });
    }

}
void CallbackRtsControlNotify(IAsynCallbackParam *param)
{
    @autoreleasepool {
        CBRtsControlNotifyParam *aparam = (CBRtsControlNotifyParam *)param;
        NSDictionary *info = @{NIMRTSChannelIDKey : @(aparam->channel_id_),
                               NIMRTSUserKey : NSUTF8(aparam->peer_),
                               NIMRTSControlKey : NSUTF8(aparam->control_),
                               };
        nim_main_async_safe(^{
            [[NIMRTSManager sharedManager] onRtsControlNotify:info];
        });
    }

}
void CallbackRtsTunSummaryNotify(IAsynCallbackParam *param)
{
    @autoreleasepool {
        NIMLogPro(@"RTS tun summary received");
    }
}
}
