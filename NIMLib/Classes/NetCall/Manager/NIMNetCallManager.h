//
//  NIMNetCallManager.h
//  NIMLib
//
//  Created by fenric on 15/4/29.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMManager.h"
#import "NIMNetCallManagerProtocol.h"
#import "NIMNotificationObject_Private.h"
#import "NIMNetCallRecord_Private.h"


namespace nimbiz
{
struct IAsynCallbackParam;

#pragma mark - 响应
//主叫发起
void CallbackNetcallStart(IAsynCallbackParam *param);
//持续呼叫
void CallbackNetcallKeepCalling(IAsynCallbackParam *param);
//被叫接听结果
void CallbackNetcallCalleeAck(IAsynCallbackParam *param);

#pragma mark - 通知
//被叫收到聊天请求
void CallbackNetcallStartNotify(IAsynCallbackParam *param);
//主叫收到被叫发起呼叫的响应
void CallbackNetcallCalleeAckNotify(IAsynCallbackParam *param);
//收到挂断通知
void CallbackNetcallHangupNotify(IAsynCallbackParam *param);
//控制协议通知
void CallbackNetcallControlNotify(IAsynCallbackParam *param);

//回单、未接通知
void CallbackReceiveNotify(IAsynCallbackParam *param);

//被叫应答多端同步通知
void CallbackReceiveOtherAckNotify(IAsynCallbackParam *param);
}


@interface NIMNetCallManager : NIMManager

- (void)start:(NSArray *)callees
         type:(NIMNetCallType)type
       option:(NIMNetCallOption *)option
   completion:(NIMNetCallStartHandler)completion;

- (void)response:(UInt64)callID
          accept:(BOOL)accept
          option:(NIMNetCallOption *)option
      completion:(NIMNetCallResponseHandler)completion;

- (void)hangup:(UInt64)callID;

- (void)control:(UInt64)callID
           type:(NIMNetCallControlType)type;

- (BOOL)setMute:(BOOL)mute;

- (BOOL)setSpeaker:(BOOL)useSpeaker;

- (void)switchCamera:(NIMNetCallCamera)camera;

- (BOOL)setCameraDisable:(BOOL)disable;

- (void)switchType:(NIMNetCallType)type;

- (CALayer *)localPreviewLayer;

- (UInt64)currentCallID;

- (NIMNetCallNetStatus)netStatus;

- (BOOL)startLocalRecording:(NSURL *)filePath
               videoBitrate:(UInt32)videoBitrate;

- (BOOL)stopLocalRecording;


//收到远程话单记录
- (void)onReceiveRemoteCallRecords:(NSArray *)records;

//生成话单记录以及话单消息
- (void)generateNetcallMsgAndRecord:(NIMNetCallRecord *)record isReceived:(BOOL)isReceived;

//用户SDK自己在某些情况下需要直接结束通话的场景，例如被踢
- (void)internalHangup;

@end


@interface NIMNetCallManager(DB)

- (BOOL)saveCallRecord:(NIMNetCallRecord *)record;

- (void)deleteCallRecord:(NIMNetCallRecord *)record;

- (void)deleteAllRerords;

- (NSArray*)reordsWithLastRecord:(NIMNetCallRecord *)lastRecord
                           limit:(NSInteger)limit;

- (void)openDatabase;

- (void)queryUnreadCount;

@end


