 //
//  NIMNetCallManager.m
//  NIMLib
//
//  Created by fenric on 15/4/29.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMNetCallManager.h"
#import "NIMSessionManager.h"
#import "NIMDispatch.h"
#import "NVSSessionManager.h"
#import "NIMNetCallSessionData.h"
#import "NIMNetCallModel.h"
#import "NIMNetCallManagerProtocol.h"
#import "NIMGlobalDefs.h"
#import "NIMTimer.h"
#import "netcall_protocol.h"
#import "bind.h"
#import "NIMProtocolUtil.h"
#import "NSDictionary+NIMJson.h"
#import "NIMPathManager.h"
#import "NIMUtil.h"
#import "NIMModelConverter.h"
#import "NIMRecvMessageHandler.h"
#import "NIMMessage_Private.h"
#import "NSString+NIM.h"
#import "NIMNVSManager.h"
#import "NIMDelegateCenter.h"
#import "NVSI420Frame.h"
#import "NIMMulticastDelegate.h"
#import "NIMNetCallRecordManager.h"

#define NIMNetCallSessionDataKey @"vc_session_data"
#define NIMNetCallUserKey @"user"
#define NIMNetCallChannelKey @"channel"
#define NIMNetCallControlKey @"control"
#define NIMNetCallAcceptKey @"accept"
#define NIMNetCallTimetagKey @"timetag"
#define NIMNetCallUUidKey @"uuid"
#define NIMNetCallOtherClientTypeKey @"client"


#define NIMNetCallKeepCallingIntervalSeconds 2


@interface NIMNetCallManager()<NVSVideoPlayerDelegate, NVSSessionDelegate, NIMTimerDelegate, NVSRecordingDelegate>
{
}


@property(nonatomic, weak)   NIMNVSManager *nvsManager;
@property(nonatomic, copy)   NIMNetCallStartHandler startHandler;
@property(nonatomic, copy)   NIMNetCallResponseHandler responseHandler;
@property(nonatomic, strong) NSMutableDictionary *netCallsInfo;
@property(nonatomic, copy)   NSString *currentSessionUUid;
@property(nonatomic, strong) NIMTimer *keepCallingTimer;
@property(nonatomic, strong) NIMNetCallRecordManager *recordManager;
@property(nonatomic, strong) NSMutableArray *incomingCallIDs;

@end

@implementation NIMNetCallManager
- (instancetype)init
{
    if (self = [super init])
    {
        _nvsManager = [NIMNVSManager sharedManager];
        _keepCallingTimer = [[NIMTimer alloc] init];
        _netCallsInfo = [[NSMutableDictionary alloc] init];
        _incomingCallIDs = [[NSMutableArray alloc] init];
        _recordManager = [[NIMNetCallRecordManager alloc] init];
        NIMLogApp(@"NVS version %u_%u", [NVSSessionManager nvsVersion], [NVSSessionManager netVersion]);
    }
    return self;
}




#pragma mark - public - NIMNetCallManager delegate

//主叫发起通话
- (void)start:(NSArray *)callees
         type:(NIMNetCallType)type
       option:(NIMNetCallOption *)option
   completion:(NIMNetCallStartHandler)completion
{
    NIMLogApp(@"User start net call to %@, type:%d", callees, type);
    
    if (_startHandler)
    {
        [self raiseStartHandler:NIMLocalError(NIMLocalErrorCodeOperationIncomplete)
                         callID:0];
        NIMLogApp(@"Previous start operation incomplete.");
    }
    
    _startHandler = [completion copy];
    if ([self isBusy])
    {
        [self raiseStartHandler:NIMLocalError(NIMLocalErrorCodeNetCallBusy)
                         callID:0];
        NIMLogErr(@"Net call not started: BUSY!");
        return;
    }
    
    if (callees.count != 1)
    {
        NIMLogErr(@"Net call not started: support one callee only, callee count is %zd!", callees.count);
        [self raiseStartHandler:NIMLocalError(NIMLocalErrorCodeInvalidParam)
                         callID:nil];
        return;
    }
    
    NVSSessionMode sessionMode = (type == NIMNetCallTypeAudio) ? NVSSessionModeAudio : NVSSessionModeVideo;
    
    NIMNetCallModel *newCall = [[NIMNetCallModel alloc] initCallerWithCallees:callees type:type];
    newCall.option = option;
    
    [_netCallsInfo setObject:newCall forKey:newCall.uuid];
    [_netCallsInfo setObject:newCall forKey:@(0)]; //此时还没拿到channelid，可以通过0索引
    
    NIMLogApp(@"net calls info in mem: %lu", _netCallsInfo.count);
    
    [newCall setStatus:NIMNetCallSessionStatusCallerWatingStartAck];
    [self invokeInitCall:callees
                chatType:sessionMode
                    uuid:newCall.uuid
                  option:option];
}

- (void)raiseStartHandler:(NSError *)error
                   callID:(UInt64)callID
{
    if (_startHandler)
    {
        _startHandler(error,callID);
        _startHandler = nil;
    }
}

//被叫响应呼叫
- (void)response:(UInt64)callID
          accept:(BOOL)accept
          option:(NIMNetCallOption *)option
      completion:(NIMNetCallResponseHandler)completion;
{
    NIMLogApp(@"User response to net call request %llu, accept: %d", callID, accept);
    if (_responseHandler)
    {
        [self raiseResponeHandler:NIMLocalError(NIMLocalErrorCodeOperationIncomplete)
                           callID:callID];
        NIMLogApp(@"Previous response operation incomplete.");
    }
    
    _responseHandler = [completion copy];
    
    NIMNetCallModel *callInfo = [self callInfo:callID];
    
    if (callInfo)
    {
        callInfo.option = option;
        if (callInfo.status == NIMNetCallSessionStatusCalleeResponsed)
        {
            NIMLogApp(@"user already responsed the call:%llu, ignore it.", callID);
            return;
        }
        else
        {
            callInfo.status = NIMNetCallSessionStatusCalleeResponsed;
        }
    }
    else {
        NIMLogErr(@"Error response a netcall, callID %llu not exist!.", callID);

        [self raiseResponeHandler:NIMLocalError(NIMLocalErrorCodeInvalidParam)
                           callID:callID];
        return;
    }
    
    if (accept && [self isBusy])
    {
        [self raiseResponeHandler:NIMLocalError(NIMLocalErrorCodeNetCallBusy)
                           callID:callID];
        NIMLogErr(@"Net call not responsed: BUSY!");
        return;
    }
    if (!accept) {
        [self generateLocalNetcallRecord:callID eventType:NIMNetCallEventTypeReject];
    }
    nimbiz::INetcallService *service = (nimbiz::INetcallService*)GetServiceFromCore(nimbiz::SVID_NIM_NETCALL);
    if (service && callInfo)
    {
        nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackNetcallCalleeAck);
        service->Invoke_CalleeAck(callInfo.type, UTF8(callInfo.caller), callID, accept, callback);
    }
}

- (void)raiseResponeHandler:(NSError *)error
                     callID:(UInt64)callID
{
    if (_responseHandler)
    {
        _responseHandler(error,callID);
        _responseHandler = nil;
    }
}


//挂断通话
- (void)hangup:(UInt64)callID
{
    NIMLogApp(@"User hangup netcall %llu", callID);
    NIMNetCallModel *callInfo = [self netCallInfoByKey:@(callID)];
    if (!callInfo) {
        if ([_nvsManager stop:callID]) {
            NIMLogErr(@"No call info found, stop the netcall only");
            return;
        }
    }
    
    if (callInfo.status == NIMNetCallSessionStatusCallerWatingStartAck) {
        NIMLogApp(@"Netcall pending hangup %@...", callInfo.uuid);
        [callInfo setStatus:NIMNetCallSessionStatusCallerPendingHangup];
    }
    
    [_keepCallingTimer stopTimer];

    //挂断后主叫可能话单可能对方未接，被叫一定是话单
    NIMNetCallEventType eventType = (callInfo.status == NIMNetCallSessionStatusConnected || !callInfo.isCaller) ? NIMNetCallEventTypeBill : NIMNetCallEventTypeNoResponse;
    [self stopNetCallWithHangup:callID];
    //生成通话记录的时候会删除call相关信息, 放在最后做
    [self generateLocalNetcallRecord:callID eventType:eventType];
}

//发送控制指令
- (void)control:(UInt64)callID
           type:(NIMNetCallControlType)type
{
    NIMLogApp(@"User control net call %llu, type:%d", callID, type);
    nimbiz::INetcallService *service = (nimbiz::INetcallService*)GetServiceFromCore(nimbiz::SVID_NIM_NETCALL);
    if (service && callID) {
        service->Invoke_Control(callID, type);
    }
}

//设置静音
- (BOOL)setMute:(BOOL)mute
{
    NIMLogApp(@"User set mute:%d", mute);
    NIMNetCallModel *currentCall = [self netCallInfoByKey:_currentSessionUUid];
    if (currentCall) {
        [currentCall setIsMute:mute];
    }
    return [_nvsManager.session setMute:mute];
}

//设置扬声器
- (BOOL)setSpeaker:(BOOL)useSpeaker
{
    NIMLogApp(@"User set speaker:%d", useSpeaker);
    NIMNetCallModel *currentCall = [self netCallInfoByKey:_currentSessionUUid];
    if (currentCall) {
        [currentCall setUseSpeaker:useSpeaker];
    }
    return [_nvsManager.session setSpeake:useSpeaker];
}

//切换摄像头
- (void)switchCamera:(NIMNetCallCamera)camera
{
    NIMLogApp(@"User switch camera:%d", camera);
    [_nvsManager.session switchVideoDevice:(camera == NIMNetCallCameraBack) ? 1 : 2];
}

//关闭摄像头
- (BOOL)setCameraDisable:(BOOL)disable
{
    NIMLogApp(@"User set camera disable:%d", disable);
    return [_nvsManager.session setCamera:disable];
}

//切换音视频模式
- (void)switchType:(NIMNetCallType)type
{
    NIMLogApp(@"User switch type:%d", type);
    NVSSessionMode mode = ((type == NIMNetCallTypeAudio) ? NVSSessionModeAudio : NVSSessionModeVideo);
    [_nvsManager.session switchChatMode:mode
                           keepSettings:NO];

}

//获取本地预览层
- (CALayer *)localPreviewLayer {
    NIMNetCallModel *currentCall = [self netCallInfoByKey:_currentSessionUUid];
    if (currentCall) {
        NIMLogApp(@"User get local preview layer success");
        return currentCall.localPreveiwLayer;
    }
    NIMLogApp(@"User get local preview layer failed.");
    return nil;
}

//获取正在进行中的网络通话call id
- (UInt64)currentCallID
{
    if(_currentSessionUUid) {
        NIMNetCallModel *currentCall = [self netCallInfoByKey:_currentSessionUUid];
        return currentCall.channelID;
    }
    return 0;
}

- (NIMNetCallNetStatus)netStatus
{
    NIMNetCallNetStatus status = NIMNetCallNetStatusGood;
    if(_currentSessionUUid) {
        NIMNetCallModel *currentCall = [self netCallInfoByKey:_currentSessionUUid];
        status = currentCall.netStatus;
    }
    else {
        NIMLogErr(@"Get netstat but no ongiong call.");
    }
    return status;
}



- (BOOL)startLocalRecording:(NSURL *)filePath
               videoBitrate:(UInt32)videoBitrate
{
    NIMLogApp(@"User start recording:%@, video bitrate:%u", filePath, videoBitrate);

    if (_nvsManager.session && [_nvsManager.session readyToRecord]) {
        NVSRecordingError error = [_nvsManager.session startRecording:filePath videoBitrate:videoBitrate delegate:self];
        if (error != NVSRecordingErrorNoError) {
            NIMLocalErrorCode code = (error == NVSRecordingErrorInvalidFilePath) ? NIMLocalErrorCodeRecordInvalidFilePath : NIMLocalErrorCodeRecordStartFailed;
            [[NIMDelegateCenter netCallDelegate] onLocalRecordError:NIMLocalError(code)
                                                             callID:[self currentCallID]];
        }
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)stopLocalRecording
{
    NIMLogApp(@"User stop recording");
    if (_nvsManager.session) {
        NVSRecordingError error = [_nvsManager.session stopRecording];
        if (error != NVSRecordingErrorNoError) {
            [[NIMDelegateCenter netCallDelegate] onLocalRecordError:NIMLocalError(NIMLocalErrorCodeRecordStopFailed)
                                                             callID:[self currentCallID]];
        }

        return YES;
    }
    else {
        return NO;
    }
}


#pragma mark - private methods
- (void)internalHangup
{
    nim_main_sync_safe(^{
        
        //挂掉当前通话
        if (_currentSessionUUid) {
            [self stopNetCall];
        }
        
        //通知上层所有还没挂掉的通话已经都该挂了
        for (NIMNetCallModel *call in [_netCallsInfo allValues]) {
            if (call.status != NIMNetCallSessionStatusDisconnected) {
                [call setStatus:NIMNetCallSessionStatusDisconnected];
                [self recordNetCall:call.channelID AndNotifyStatus:NIMNetCallStatusDisconnect];
            }
        }
    });
    
    
}

#pragma mark - msg requests
- (void)invokeInitCall:(NSArray *)calleeUsers
              chatType:(NSInteger)chatType
                  uuid:(NSString *)uuid
                option:(NIMNetCallOption *)option
{
    nimbiz::INetcallService *service = (nimbiz::INetcallService*)GetServiceFromCore(nimbiz::SVID_NIM_NETCALL);
    if (service)
    {
        nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackNetcallStart);
        std::list<nimbiz::UTF8String> users_list = [NIMProtocolUtil arrayToStringList:calleeUsers];
        
        nimbiz::Property notify;
        notify.put_uint32(nimbiz::NIMNetcallNotifyOptionTagApnsEnable, (uint32_t)(option.apnsInuse));
        notify.put_uint32(nimbiz::NIMNetcallNotifyOptionTagApnsCountBadge, (uint32_t)(option.apnsBadge));
        notify.put_uint32(nimbiz::NIMNetcallNotifyOptionTagApnsWithNick, (uint32_t)(option.apnsWithPrefix));
        
        if ([option.apnsContent length]) {
            notify.put_string(nimbiz::NIMNetcallNotifyOptionTagApnsContent, UTF8(option.apnsContent));
        }
        
        if ([option.extendMessage length]) {
            notify.put_string(nimbiz::NIMNetcallNotifyOptionTagNotifyAttach, UTF8(option.extendMessage));
        }

        nimbiz::UTF8String payload = [NIMProtocolUtil stringByJsonDictionary:option.apnsPayload];
        if (!payload.empty()) {
            notify.put_string(nimbiz::NIMNetcallNotifyOptionTagApnsPayload, payload);
        }
        
        if ([option.apnsSound length]) {
            notify.put_string(nimbiz::NIMNetcallNotifyOptionTagApnsSound, UTF8(option.apnsSound));
        }
        
        service->Invoke_InitCall(chatType, users_list, UTF8(uuid), notify, callback);
    }
}

- (void)sendKeepCalling
{
    if (_currentSessionUUid) {
        NIMNetCallModel *currentCall = [self netCallInfoByKey:_currentSessionUUid];
        if (currentCall.sessionData) {
            if ( 0 == currentCall.sessionData.keepCallingCallees.count) {
                return;
            }
            nimbiz::INetcallService *service = (nimbiz::INetcallService*)GetServiceFromCore(nimbiz::SVID_NIM_NETCALL);
            if (service)
            {
                nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackNetcallKeepCalling);
                service->Invoke_KeepCalling(currentCall.type,
                                            [NIMProtocolUtil arrayToStringList:currentCall.sessionData.keepCallingCallees],
                                            currentCall.channelID,
                                            callback);
            }
        }
    }
}

#pragma mark - msg responses
- (void)onStartAck:(NSDictionary *)info
{
    NSInteger code = [[info objectForKey:NIMACKCode] integerValue];
    NSError *error = nil;
    UInt64 callID = 0;
    if (code == nimbiz::NIMResSuccess) {

        [_nvsManager stop:0];
        
        NIMNetCallSessionData *startData = [info objectForKey:NIMNetCallSessionDataKey];
        
        if (startData) {
            NIMNetCallModel *currentCall = [self netCallInfoByKey:[info objectForKey:NIMNetCallUUidKey]];
            if (currentCall) {
                currentCall.channelID = startData.channelId;
                
                
                [_netCallsInfo setObject:currentCall forKey:@(currentCall.channelID)];
                [_netCallsInfo removeObjectForKey:@(0)];//已经拿到channel id了，去掉0的索引
                
                if ([self handlePendingHangup:startData.channelId]) {
                    _startHandler = nil;
                    return;
                }
                currentCall.sessionData = startData;
                currentCall.sessionData.option = currentCall.option;
                callID = currentCall.channelID;
                _currentSessionUUid = currentCall.uuid;
                if (currentCall.sessionData.keepCallingCallees.count > 0) {
                    [_keepCallingTimer startTimer:NIMNetCallKeepCallingIntervalSeconds
                                         delegate:self
                                          repeats:NO];
                }
            }
        }
    }
    else {
        error = NIMRemoteError(code);
    }
    
    [self raiseStartHandler:error
                     callID:callID];
}

- (void)onKeepCallingAck:(NSArray *)callees
{
    if (_currentSessionUUid) {
        NIMNetCallModel *currentCall = [self netCallInfoByKey:_currentSessionUUid];
        currentCall.sessionData.keepCallingCallees = callees;
        [_keepCallingTimer startTimer:NIMNetCallKeepCallingIntervalSeconds
                             delegate:self
                              repeats:NO];
    }
}

//被叫响应的结果
- (void)onCalleeAck:(NSDictionary *)info
{
    NSError *error = nil;
    uint64_t channelID = [[info objectForKey:NIMNetCallChannelKey] unsignedLongLongValue];
    NIMNetCallModel *callInfo = [self netCallInfoByKey:@(channelID)];
    NSInteger code = [[info objectForKey:NIMACKCode] integerValue];
    if (code == nimbiz::NIMResSuccess) {
        if (callInfo) {
            if ([[info objectForKey:NIMNetCallAcceptKey] boolValue]) {
                [_nvsManager stop:0];
                _currentSessionUUid = callInfo.uuid;
                callInfo.sessionData.option = callInfo.option;
                [self startNetCall];
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
    
    [self raiseResponeHandler:error
                       callID:channelID];

}

#pragma mark - msg notifications
//被叫收到呼叫请求
- (void)onBeCalled:(NIMNetCallSessionData *)sessionData
{
    //bug NIM-3208: 允许多个ios设备登录同一帐号时，一边在线，一边离线，在线的一边会收到两次呼入请求，这里去一下重
    if ([_incomingCallIDs containsObject:@(sessionData.channelId)]) {
        NIMLogApp(@"Duplicated incoming call request %llu, drop it.", sessionData.channelId);
        return;
    }

    NIMNetCallType type = (sessionData.callType == NVSSessionModeAudio) ? NIMNetCallTypeAudio : NIMNetCallTypeVideo;
    
    NIMNetCallModel *incomingCall = [[NIMNetCallModel alloc] initCalleeWithCaller:sessionData.caller
                                                                            type:sessionData.callType
                                                                       channelID:sessionData.channelId];
    incomingCall.sessionData = sessionData;
    
    //需要支持通过channelid和uuid两种方式查找通话信息
    [_netCallsInfo setObject:incomingCall forKey:@(incomingCall.channelID)];
    [_netCallsInfo setObject:incomingCall forKey:incomingCall.uuid];
    
    [_incomingCallIDs addObject:@(incomingCall.channelID)];
    
    NSString *extendMessage = sessionData.extendMessage.length ? sessionData.extendMessage : nil;
    NIMLogApp(@"Receive call from %@, channel:%llu, extend message:%@", sessionData.caller, sessionData.channelId, extendMessage);
    //如果现在正在通话中： 直接回调上层，上层来决定是挂掉当前通话还是拒绝新的呼叫
    [[NIMDelegateCenter netCallDelegate] onReceive:sessionData.channelId
                                              from:sessionData.caller
                                              type:type
                                           message:extendMessage];
}

//主叫收到被叫响应
- (void)onReceiveCalleeAck:(NSDictionary *)info
{
    uint64_t channel = [info nim_jsonUnsignedLongLong:NIMNetCallChannelKey];
    NSString *callee = [info nim_jsonString:NIMNetCallUserKey];
    BOOL accepted = [info nim_jsonBool:NIMNetCallAcceptKey];
    [[NIMDelegateCenter netCallDelegate]onResponse:channel
                                              from:callee
                                          accepted:accepted];

    NIMNetCallModel *callInfo = [self netCallInfoByKey:@(channel)];
    if (!callInfo) {
        NIMLogErr(@"Receive unrecognized callee ack of %llu.", channel);
        return;
    }
    
    if (callInfo.status == NIMNetCallSessionStatusDisconnected) {
        NIMLogErr(@"Receive callee ack of %llu, but netcall already terminated.", channel);
        return;
    }
    
    if (!(accepted)) {
        //对方拒绝接听这通电话
        if (_currentSessionUUid) {
            NIMNetCallModel *currentCallInfo = [self netCallInfoByKey:_currentSessionUUid];
            if (channel == currentCallInfo.channelID) {
                [self stopNetCall];
            }
        }
        [self generateLocalNetcallRecord:channel eventType:NIMNetCallEventTypeReject];
    }
    else {
        [self startNetCall];
    }
}

//收到挂断通知
- (void)onReceiveHangupNotify:(NSDictionary *)info
{
    uint64_t channel = [info nim_jsonUnsignedLongLong:NIMNetCallChannelKey];
    NSString *user = [info nim_jsonString:NIMNetCallUserKey];
    [[NIMDelegateCenter netCallDelegate] onHangup:channel
                                               by:user];
    if ([_nvsManager stop:channel]) {
        _currentSessionUUid = nil;
    };
    
    NIMNetCallModel *call = [self callInfo:channel];
    [call setStatus:NIMNetCallSessionStatusDisconnected];
}

//收到通用通知
- (void)onReceiveRemoteCallRecords:(NSArray *)records
{
    for (NIMNetCallRecord *record in records) {
        [self generateNetcallMsgAndRecord:record isReceived:YES];
    }
}

//收到控制协议通知
- (void)onReceiveControl:(NSDictionary *)info
{
    [[NIMDelegateCenter netCallDelegate] onControl:[info nim_jsonUnsignedLongLong:NIMNetCallChannelKey]
                                              from:[info nim_jsonString:NIMNetCallUserKey]
                                              type:[info nim_jsonInteger:NIMNetCallControlKey]];
}

//被叫应答多端同步: 该通话已经被其他端处理了
- (void)onReceiveOtherAckSyncNotify:(NSDictionary *)info
{
    UInt64 channelID = [[info objectForKey:NIMNetCallChannelKey] unsignedLongLongValue];
    BOOL accepted = [[info objectForKey:NIMNetCallAcceptKey] boolValue];
    if (channelID) {
        if (!accepted) {
            //如果在其他端拒绝，我们这里也要生成一条拒绝消息
            [self generateLocalNetcallRecord:channelID eventType:NIMNetCallEventTypeReject];
        }
        if ([self isCurrentCall:channelID]) {
            //以防万一
            [self stopNetCall];
        }
        [[NIMDelegateCenter netCallDelegate] onResponsedByOther:channelID
                                                       accepted:accepted];
    }
}

#pragma mark - private functions
//生成本地通话记录
- (void)generateLocalNetcallRecord:(uint64_t)callID eventType:(NIMNetCallEventType)eventType{
    NIMNetCallModel *callInfo = [self netCallInfoByKey:@(callID)];
    if (callInfo) {
        NIMNetCallRecord *localRecord = [NIMNetCallRecord genCallRecord:callInfo eventType:eventType];
        [self generateNetcallMsgAndRecord:localRecord isReceived:YES];
    }
}

//存储话单记录以及话单消息
- (void)generateNetcallMsgAndRecord:(NIMNetCallRecord *)record isReceived:(BOOL)isReceived
{    
    NIMNetCallModel *callInfo;
    if ([record.recordId nim_isPureInteger]) {
        callInfo = [self netCallInfoByKey:@(record.recordId.longLongValue)];
    }else{
        callInfo = [self netCallInfoByKey:record.recordId];
    }

    if (callInfo.channelID) {
        [self removeNetCallInfo:@(callInfo.channelID)];
        NIMLogApp(@"remove net calls info, remaining %lu", _netCallsInfo.count);
    }
    if (!callInfo.channelID && callInfo.isCallRecorded) {
        return;
    }
    //存储Record
    [_recordManager saveCallRecord:record];
    
    callInfo.isCallRecorded = YES;
    NIMMessage *message   = [NIMModelConverter netCallMessageFromRercord:record];
    if (message)
    {
        message.isReceivedMsg = isReceived;
        NIMRecvMessageHandler *handler = [NIMRecvMessageHandler handler:0];
        [handler recvMessages:@[message]];
    }
}

-(void)startNetCall
{
    if (!_currentSessionUUid) {
        NIMLogErr(@"Net call session not started: no current session id");
        return;
    }
    
    NIMNetCallModel *currentCallInfo = [self netCallInfoByKey:_currentSessionUUid];
    if (currentCallInfo && currentCallInfo.sessionData) {
        [_nvsManager start:currentCallInfo.sessionData delegate:self];
    }
    else {
        NIMLogErr(@"Net call session not started: no call info found");
    }
}

-(void)stopNetCall
{
    _currentSessionUUid = nil;
    [_nvsManager stop:0];
}

- (void)stopNetCallWithHangup:(UInt64)channelID
{
    [self invokeHangup:channelID];
    NIMNetCallModel *call = [self callInfo:channelID];
    if (channelID) {
        [call setStatus:NIMNetCallSessionStatusDisconnected];
    }
    if (_currentSessionUUid) {
        NIMNetCallModel *currentCall = [self netCallInfoByKey:_currentSessionUUid];
        if (channelID == currentCall.channelID) {
            [self stopNetCall];
        }
    }
}

- (BOOL)handlePendingHangup:(uint64_t)channelID
{
    NIMNetCallModel *callInfo = [self netCallInfoByKey:@(channelID)];
    if (callInfo.status == NIMNetCallSessionStatusCallerPendingHangup) {
        NIMLogApp(@"netcall pending hangup handled %llu %@", channelID, callInfo.uuid);
        callInfo.status = NIMNetCallSessionStatusDisconnected;
        nimbiz::INetcallService *service = (nimbiz::INetcallService*)GetServiceFromCore(nimbiz::SVID_NIM_NETCALL);
        if (service)
        {
            service->Invoke_Hangup(channelID);
        }
        return YES;
    }
    return NO;
}

- (void)invokeHangup:(UInt64)channelID
{
    nimbiz::INetcallService *service = (nimbiz::INetcallService*)GetServiceFromCore(nimbiz::SVID_NIM_NETCALL);
    if (service && (channelID != 0))
    {
        service->Invoke_Hangup(channelID);
    }
}

- (BOOL)removeNetCallInfo:(id)key
{
    NIMNetCallModel *callInfo = [self netCallInfoByKey:key];
    if (callInfo) {
        [_netCallsInfo removeObjectForKey:callInfo.uuid];
        [_netCallsInfo removeObjectForKey:@(callInfo.channelID)];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isCurrentCall:(UInt64)channelID
{
    if (_currentSessionUUid) {
        NIMNetCallModel *currentCall = [self netCallInfoByKey:_currentSessionUUid];
        if (channelID == currentCall.channelID) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isBusy
{
    if (_currentSessionUUid) {
        uint64_t channelID = [_nvsManager currentChannelID];
        if (channelID && [self isCurrentCall:channelID]) {
            return YES;
        }
    }
    _currentSessionUUid = nil;
    return NO;
}

- (NIMNetCallModel *)callInfo:(uint64_t)channelID
{
    return [self netCallInfoByKey:@(channelID)];
}

- (void)recordNetCall:(UInt64)callID AndNotifyStatus:(NIMNetCallStatus)status
{
    NIMNetCallModel *callInfo = [self netCallInfoByKey:@(callID)];
    if (status == NIMNetCallStatusDisconnect && callInfo.connectTimetag) {
        //插入本地话单消息
        [self generateLocalNetcallRecord:callID eventType:NIMNetCallEventTypeBill];
    }
    [[NIMDelegateCenter netCallDelegate] onCall:callID status:status];
}


-(NIMLocalErrorCode)recordErrorCode:(NVSRecordingError)nvsError
{
    NIMLocalErrorCode nimError = 0;
    switch (nvsError) {
        case NVSRecordingErrorNotReady:
            nimError = NIMLocalErrorCodeRecordStartFailed;
            break;
        case NVSRecordingErrorNotRecording:
            nimError = NIMLocalErrorCodeRecordStopFailed;
            break;
            
        case NVSRecordingErrorCreateFile:
            nimError = NIMLocalErrorCodeRecordCreateFileFailed;
            break;
            
        case NVSRecordingErrorInitVideo:
            nimError = NIMLocalErrorCodeRecordInitVideoFailed;
            break;
            
        case NVSRecordingErrorInitAudio:
            nimError = NIMLocalErrorCodeRecordInitAudioFailed;
            break;
            
        case NVSRecordingErrorStartWriting:
            nimError = NIMLocalErrorCodeRecordStartWritingFailed;
            break;
            
        case NVSRecordingErrorWritingInterrupted:
            nimError = NIMLocalErrorCodeRecordWritingFileFailed;
            break;
        
        case NVSRecordingErrorWillStopForLackSpace:
            nimError = NIMLocalErrorCodeRecordWillStopForLackSpace;
            break;
            
        default:
            break;
    }
    
    return nimError;

}

- (NIMNetCallModel *)netCallInfoByKey:(id)key
{
    NIMNetCallModel *netCallInfo;
    if (key) {
        netCallInfo = [_netCallsInfo objectForKey:key];
    }
    return netCallInfo;
}

#pragma mark - NVSSessionDelegate
- (void)onSessionStatus:(NVSVideoChatSessionStatus)status
{
    nim_main_async_safe(^{
        
        if (!_currentSessionUUid) {
            NIMLogErr(@"Error: no current session id on status update");
            return;
        }
        
        NIMNetCallModel *currentCall = [self netCallInfoByKey:_currentSessionUUid];
        
        __block UInt64 callID = currentCall.sessionData.channelId;
        NIMNetCallStatus nimCallStatus;
        switch (status) {
            case NVSVideoChatSessionStatusJoined:
            {
                if (currentCall) {
                    [_nvsManager.session setMute:currentCall.isMute];
                    [_nvsManager.session setSpeake:currentCall.useSpeaker];
                    [currentCall setStatus:NIMNetCallSessionStatusConnected];
                    [currentCall setConnectTimetag:[[NSDate date] timeIntervalSince1970]];
                }
                nimCallStatus = NIMNetCallStatusConnect;
                break;
            }
            default:
            {
                if (currentCall) {
                    NIMLogErr(@"Net call terminated due to error:%d!", status);
                    [self stopNetCallWithHangup:currentCall.channelID];
                    [currentCall setStatus:NIMNetCallSessionStatusDisconnected];
                }
                nimCallStatus = NIMNetCallStatusDisconnect;
                break;
            }
        }
        
        [self recordNetCall:callID AndNotifyStatus:nimCallStatus];
    });
    
    
}
- (void)onNetstatBad:(NVSVideoChatSessionNetStat)stat
{
    
}
- (void)onNetstatChanged:(NVSVideoChatSessionNetStat)stat
{
    
    nim_main_async_safe(^{
        
        UInt64 callID = [_nvsManager currentChannelID];
        NIMNetCallModel *theCall = [self netCallInfoByKey:@(callID)];
        if (theCall) {
            [theCall setNetStatus:(NIMNetCallNetStatus)stat];
        }
        
        [[NIMDelegateCenter netCallDelegate] onCall:callID netStatus:stat];
    });
}
- (void)onLoginError:(NVSLoginErrorCode)code
{
    nim_main_async_safe(^{
        
        NIMLogErr(@"Net call login error:%d!", code);
        [self onSessionStatus:NVSVideoChatSessionStatusDisconnected];
    });

}
- (void)onAudioDeviceError
{
    nim_main_async_safe(^{
        
        NIMLogErr(@"Net call termimated due to audio device error!");
        [self onSessionStatus:NVSVideoChatSessionStatusDisconnected];
    });

}

- (void)onSessionReport:(NVSSessionReport *)report
{
    NIMLogApp(@"session report: channel=%llu, description=%@, tx=%llu, rx=%llu",
              report.channelID, report.errorDescription, report.totalTxBytes, report.totalRxBytes);
}

#pragma mark - NVSVideoPlayerDelegate
- (void)displayLocalPreviewLayer:(CALayer *)previewLayer;
{
    nim_main_async_safe(^{
        
        NIMLogApp(@"Net call: displayLocalPreviewLayer");
        uint64_t channelID = [_nvsManager currentChannelID];
        NIMNetCallModel *callInfo = [self netCallInfoByKey:@(channelID)];
        [callInfo setLocalPreveiwLayer:previewLayer];
        [[NIMDelegateCenter netCallDelegate] onLocalPreviewReady:callInfo.localPreveiwLayer];
    });

}

// 远程渲染接口，提供更上层进行显示
- (void)displayRemoteI420:(NVSI420Frame *)frame
{
    nim_main_async_safe(^{
        
        if (frame && frame.data && frame.dataLength) {
            NSData *yuvData = [NSData dataWithBytes:frame.data length:frame.dataLength];
            [[NIMDelegateCenter netCallDelegate] onRemoteYUVReady:yuvData
                                                            width:frame.width
                                                           height:frame.height];
        }
        
        if ([(NIMMulticastDelegate *)[NIMDelegateCenter netCallDelegate] hasDelegateThatRespondsToSelector:@selector(onRemoteImageReady:)]) {
            [[NIMDelegateCenter netCallDelegate] onRemoteImageReady:[NVSSessionManager i420FrameToImage:frame].CGImage];
        }
    });
    
    
}

// 没有获取到本地camera
- (void)cameraNotAvalible
{
    
}

#pragma mark - NVSRecordingDelegate

- (void) recordingStart:(UInt64)channelID
                 result:(NVSRecordingError)error
                fileURL:(NSURL *)fileURL
{
    NIMLogApp(@"Recording start callback, channel = %llu, code = %d", channelID, error);
    nim_main_async_safe(^{
        if (error == NVSRecordingErrorNoError) {
            [[NIMDelegateCenter netCallDelegate] onLocalRecordStarted:channelID fileURL:fileURL];
        }
        else {
            NIMLocalErrorCode nimError = [self recordErrorCode:error];
            [[NIMDelegateCenter netCallDelegate] onLocalRecordError:NIMLocalError(nimError) callID:channelID];
        }
    });
}

- (void) recordingError:(NVSRecordingError)error
                channel:(UInt64)channelID
{
    nim_main_async_safe(^{
        [_nvsManager.session stopRecording];
        NIMLocalErrorCode nimError = [self recordErrorCode:error];
        [[NIMDelegateCenter netCallDelegate] onLocalRecordError:NIMLocalError(nimError) callID:channelID];
    });
}

- (void) recordingStopped:(UInt64)channelID
                  fileURL:(NSURL *)fileURL
{
    NIMLogApp(@"Recording stop callback, channel = %llu", channelID);
    nim_main_async_safe(^{
        [[NIMDelegateCenter netCallDelegate] onLocalRecordStopped:channelID fileURL:fileURL];
    });
}

#pragma mark - NIMTimeDelegate

- (void)onNIMTimerFired:(NIMTimer *)timer
{
    if (timer == _keepCallingTimer) {
        [self sendKeepCalling];
    }
}
@end

namespace nimbiz
{
#pragma mark - callbacks
void CallbackNetcallStart(IAsynCallbackParam *param)
{
    @autoreleasepool
    {
        CBNetcallInitParam *initParam = (CBNetcallInitParam *)param;
        NIMNetCallSessionData *sessionData = [[NIMNetCallSessionData alloc] initWithNetcallInitParam:initParam];
        NSDictionary *info = @{NIMACKCode               : @(initParam->code_),
                               NIMNetCallSessionDataKey : sessionData,
                               NIMNetCallUUidKey        : NSUTF8(initParam->uuid),
                              };
        
        nim_main_async_safe(^{
            [[NIMNetCallManager sharedManager] onStartAck:info];
        });
    }
}

void CallbackNetcallKeepCalling(IAsynCallbackParam *param)
{
    @autoreleasepool
    {
        CBNetcallKeepCallingParam *keepCallingParam = (CBNetcallKeepCallingParam *)param;
        NSArray *keepCallingCallees = [NIMProtocolUtil stringListToArray:keepCallingParam->keep_calling_users_];
        nim_main_async_safe(^{
            [[NIMNetCallManager sharedManager] onKeepCallingAck:keepCallingCallees];
        });
    }

}

void CallbackNetcallCalleeAck(IAsynCallbackParam *param)
{
    @autoreleasepool
    {
        CBNetcallCalleeAckParam *calleeAckParam = (CBNetcallCalleeAckParam *)param;
        
        NSDictionary *info = @{ NIMACKCode           : @(calleeAckParam->code_),
                                NIMNetCallChannelKey : @(calleeAckParam->channel_id_),
                                NIMNetCallAcceptKey  : @(calleeAckParam->accept_),
                                };
        
        nim_main_async_safe(^{
            [[NIMNetCallManager sharedManager] onCalleeAck:info];
        });
    }
}


//notifications
void CallbackNetcallStartNotify(IAsynCallbackParam *param)
{
    @autoreleasepool
    {
        CBNetcallBeCalledParam *beCalledParam = (CBNetcallBeCalledParam *)param;
        NIMNetCallSessionData *sessionData = [[NIMNetCallSessionData alloc] initWithNetcallBeCalledParam:beCalledParam];
        nim_main_async_safe(^{
            [[NIMNetCallManager sharedManager] onBeCalled:sessionData];
        });
    }

}
void CallbackNetcallCalleeAckNotify(IAsynCallbackParam *param)
{
    @autoreleasepool
    {
        CBNetcallRcvCalledAckParam *rcvCalleeAckParam = (CBNetcallRcvCalledAckParam *)param;
        
        NSDictionary *info = @{ NIMACKCode           : @(rcvCalleeAckParam->code_),
                                NIMNetCallUserKey    : NSUTF8(rcvCalleeAckParam->callee_),
                                NIMNetCallChannelKey : @(rcvCalleeAckParam->channel_id_),
                                NIMNetCallAcceptKey : @(rcvCalleeAckParam->accepted_),
                                };
        nim_main_async_safe(^{
            [[NIMNetCallManager sharedManager] onReceiveCalleeAck:info];
        });
    }
}

void CallbackNetcallHangupNotify(IAsynCallbackParam *param)
{
    @autoreleasepool
    {
        CBNetcallHangupNotifyParam *rcvHangupNotifyParam = (CBNetcallHangupNotifyParam *)param;
        
        NSDictionary *info =
                @{ NIMNetCallChannelKey : @(rcvHangupNotifyParam->channel_id_),
                   NIMNetCallUserKey    : NSUTF8(rcvHangupNotifyParam->peer_),
                   NIMNetCallTimetagKey : @(rcvHangupNotifyParam->timetag_),
                   };
        
        nim_main_async_safe(^{
            [[NIMNetCallManager sharedManager] onReceiveHangupNotify:info];
        });
    }
}

void CallbackNetcallControlNotify(IAsynCallbackParam *param)
{
    @autoreleasepool
    {
        CBNetCallControlParam *controlParam = (CBNetCallControlParam *)param;
        NSDictionary *info = @{ NIMNetCallUserKey    : NSUTF8(controlParam->peer_),
                                NIMNetCallChannelKey : @(controlParam->channel_id_),
                                NIMNetCallControlKey : @(controlParam->control_),
                                };
        nim_main_async_safe(^{
            [[NIMNetCallManager sharedManager] onReceiveControl:info];
        });
    }
}

void CallbackReceiveNotify(IAsynCallbackParam *param){
    @autoreleasepool
    {
        CBNetCallRcvNotifyParam *notifyParam = (CBNetCallRcvNotifyParam *)param;
        NSMutableArray *netcalls = [NSMutableArray array];
        for (size_t i = 0; i < notifyParam->netcalls_.size(); i++) {
            nimbiz::Property &property = notifyParam->netcalls_[i];
            NIMNetCallRecord *record = [[NIMNetCallRecord alloc] initWithPorperty:property];
            [netcalls addObject:record];
        }
        nim_main_async_safe(^{
            [[NIMNetCallManager sharedManager] onReceiveRemoteCallRecords:netcalls];
        });
    }
}

void CallbackReceiveOtherAckNotify(IAsynCallbackParam *param){
    @autoreleasepool
    {
        CBNetCallOtherAckParam *otherAckParam = (CBNetCallOtherAckParam *)param;
        NSDictionary *info = @{ NIMNetCallChannelKey : @(otherAckParam->channel_id_),
                                NIMNetCallAcceptKey : @(otherAckParam->accepted_),
                                NIMNetCallOtherClientTypeKey : @(otherAckParam->client_type_),
                              };
        nim_main_async_safe(^{
            [[NIMNetCallManager sharedManager] onReceiveOtherAckSyncNotify:info];
        });
    }
}
}


