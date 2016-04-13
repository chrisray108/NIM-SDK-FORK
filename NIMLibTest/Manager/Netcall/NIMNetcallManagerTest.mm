//
//  NIMNetcallManagerTest.m
//  NIMLib
//
//  Created by fenric on 16/3/29.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMTestConfig.h"
#import "NIMNetCallManager.h"
#import "NIMMacros.h"
#include "netcall_protocol.h"

@interface NIMNetcallManagerTest : NIMBaseTest<NIMNetCallManagerDelegate>

@property(nonatomic, strong) NSString *lastNetCallManagerDelegateKey;

@property(nonatomic, strong) NSString *existingCallee;

@property(nonatomic, assign) UInt64 randomCallID;

@end

@implementation NIMNetcallManagerTest

- (void)setUp{
    [super setUp];
    
    NSArray *callees = [self existingCallees];
    
    if (callees.count > 0) {
        _existingCallee = [callees firstObject];
    }
    else {
        _existingCallee = @"gaofeng1";
    }

    _randomCallID = arc4random();
    
    [[NIMSDK sharedSDK].netCallManager addDelegate:self];
}

- (void)tearDown{
    _lastNetCallManagerDelegateKey = nil;
    [[NIMSDK sharedSDK].netCallManager removeDelegate:self];
    [super tearDown];
}


#pragma mark - start netcall
- (void)testStartNetcall_NormalCase_WithoutOption {
    [self requestCall:nil];
}

- (void)testStartNetcall_NormalCase_WithOption {
    
    NIMNetCallOption *option = [[NIMNetCallOption alloc] init];
    option.extendMessage = @"unit test extend message";
    [self requestCall:option];
}

- (void)testStartNetcall_ErrorCase_NoneExistingCallee {
    
    __block BOOL completed = NO;
    [[NIMSDK sharedSDK].netCallManager start:@[[self noneExistingCallee]]
                                        type:NIMNetCallTypeAudio
                                      option:nil
                                  completion:^(NSError *error, UInt64 callID)
     {
         completed = YES;
         XCTAssertEqual(error.code, NIMRemoteErrorCodeNotExist);
         XCTAssertEqual(callID, 0);
         NIM_TEST_NOTIFY;
     }];
    NIM_TEST_WAIT;
    XCTAssertTrue(completed);
}

- (void)testStartNetcall_ErrorCase_MultipleCallees {
    
    __block BOOL completed = NO;
    [[NIMSDK sharedSDK].netCallManager start:[self existingCallees]
                                        type:NIMNetCallTypeVideo
                                      option:nil
                                  completion:^(NSError *error, UInt64 callID)
     {
         completed = YES;
         XCTAssertEqual(error.code, NIMLocalErrorCodeInvalidParam);
     }];
    XCTAssertTrue(completed);
}

#pragma mark - response a netcall

- (void)testResponseNetcall_ErrorCase_CallIDNoneExist {
    
    __block BOOL completed = NO;

    [[NIMSDK sharedSDK].netCallManager response:1
                                         accept:YES
                                         option:nil
                                     completion:^(NSError *error, UInt64 callID)
    {
        XCTAssertEqual(error.code, NIMLocalErrorCodeInvalidParam);
        completed = YES;
    }];
    XCTAssertTrue(completed);
}

#pragma mark - hangup a netcall

- (void)testHangupNetcall_NormalCase_RequestAndHangup {
    
    //发邀请
    UInt64 requestCallID = [self requestCall:nil];
    
    //挂断
    [[NIMSDK sharedSDK].netCallManager hangup:requestCallID];
}

- (void)testHangupNetcall_NormalCase_NoCallID {
    
    [[NIMSDK sharedSDK].netCallManager hangup:0];
}

#pragma mark - control a netcall
- (void)testControlNetcall_NormalCase {
    
    UInt64 requestCallID = [self requestCall:nil];
    
    [[NIMSDK sharedSDK].netCallManager control:requestCallID type:NIMNetCallControlTypeOpenVideo];
}

#pragma mark - device control
- (void)testControlDeviceNetcall_NormalCase {
    
    UInt64 callID = [self requestCall:nil];
    
    id<NIMNetCallManager> manager = [NIMSDK sharedSDK].netCallManager;
    
    XCTAssertFalse([manager setMute:YES]);
    
    XCTAssertFalse([manager setSpeaker:YES]);
    
    [manager switchCamera:NIMNetCallCameraFront];

    XCTAssertFalse([manager setCameraDisable:YES]);
    
    [manager switchType:NIMNetCallTypeAudio];

    XCTAssertNil([manager localPreviewLayer]);
    
    XCTAssertEqual([manager currentCallID], callID);
    
    XCTAssertEqual([manager netStatus], NIMNetCallNetStatusGood);
}

#pragma mark - local recording

- (void)testLocalRecordingNetcall_NormalCase {
    
    [self requestCall:nil];
    
    XCTAssertFalse([[NIMSDK sharedSDK].netCallManager startLocalRecording:[NSURL URLWithString:@"/a/file/path/file/name"]
                                                             videoBitrate:0]);
    
    XCTAssertFalse([[NIMSDK sharedSDK].netCallManager stopLocalRecording]);
}

#pragma mark - on keepcalling
- (void)testOnKeepCallingNetcall_NormalCase {
    [self requestCall:nil];
    nimbiz::CBNetcallKeepCallingParam keepCallingParam;
    keepCallingParam.keep_calling_users_.push_back([_existingCallee UTF8String]);
    nimbiz::CallbackNetcallKeepCalling(&keepCallingParam);
    //no checkpoint yet
}

#pragma mark - on control
- (void)testOnControlNetcall_NormalCase {
    UInt64 callID = [self requestCall:nil];
    nimbiz::CBNetCallControlParam controlParam;
    controlParam.peer_ = [_existingCallee UTF8String];
    controlParam.channel_id_ = callID;
    controlParam.control_ = NIMNetCallControlTypeBusyLine;
    nimbiz::CallbackNetcallControlNotify(&controlParam);
    
    NSString *expectedKey = [self controlKey:_existingCallee type:controlParam.control_ callID:callID];
    XCTAssertTrue([_lastNetCallManagerDelegateKey isEqualToString:expectedKey]);
    
}


#pragma mark - on receive callee ack
- (void)testOnReceiveCalleeAckNetcall_NormalCase_Accepted {
    
    UInt64 callID = [self requestCall:nil];
    
    nimbiz::CBNetcallRcvCalledAckParam rcvCalleeAckParam;
    rcvCalleeAckParam.code_ = nimbiz::NIMResSuccess;
    rcvCalleeAckParam.channel_id_ = callID;
    rcvCalleeAckParam.callee_ = [_existingCallee UTF8String];
    rcvCalleeAckParam.accepted_ = true;
    nimbiz::CallbackNetcallCalleeAckNotify(&rcvCalleeAckParam);
    
    NSString *expectedKey = [self calleeResponseKey:_existingCallee accepted:YES callID:callID];
    XCTAssertTrue([_lastNetCallManagerDelegateKey isEqualToString:expectedKey]);
    
    [[NIMNetCallManager sharedManager] internalHangup];
}

- (void)testOnReceiveCalleeAckNetcall_NormalCase_Rejected {
    
    UInt64 callID = [self requestCall:nil];
    
    nimbiz::CBNetcallRcvCalledAckParam rcvCalleeAckParam;
    rcvCalleeAckParam.code_ = nimbiz::NIMResSuccess;
    rcvCalleeAckParam.channel_id_ = callID;
    rcvCalleeAckParam.callee_ = [_existingCallee UTF8String];
    rcvCalleeAckParam.accepted_ = false;
    nimbiz::CallbackNetcallCalleeAckNotify(&rcvCalleeAckParam);
    
    NSString *expectedKey = [self calleeResponseKey:_existingCallee accepted:NO callID:callID];
    XCTAssertTrue([_lastNetCallManagerDelegateKey isEqualToString:expectedKey]);
}

#pragma mark - on receive incoming call
- (void) testOnReceiveStartNotifyNetcall_NormalCase {
    nimbiz::CBNetcallBeCalledParam param;
    NSString *expectedKey = [self fillStartNotifyParam:&param];
    nimbiz::CallbackNetcallStartNotify(&param);
    
    XCTAssertTrue([_lastNetCallManagerDelegateKey isEqualToString:expectedKey]);
}

#pragma mark - on callee ack result
- (void) testOnCalleeAckResultNetcall_NormalCase_Accept {
    
    nimbiz::CBNetcallBeCalledParam param;
    NSString *expectedKey = [self fillStartNotifyParam:&param];
    nimbiz::CallbackNetcallStartNotify(&param);
    
    XCTAssertTrue([_lastNetCallManagerDelegateKey isEqualToString:expectedKey]);
    
    [[NIMSDK sharedSDK].netCallManager response:_randomCallID
                                         accept:YES
                                         option:nil
                                     completion:^(NSError *error, UInt64 callID)
    {
        NIM_TEST_NOTIFY;
    }];
    NIM_TEST_WAIT;
    [[NIMSDK sharedSDK].netCallManager hangup:_randomCallID];
}

- (void) testOnCalleeAckResultNetcall_NormalCase_Reject {
    
    nimbiz::CBNetcallBeCalledParam param;
    NSString *expectedKey = [self fillStartNotifyParam:&param];
    nimbiz::CallbackNetcallStartNotify(&param);
    
    XCTAssertTrue([_lastNetCallManagerDelegateKey isEqualToString:expectedKey]);
    
    [[NIMSDK sharedSDK].netCallManager response:_randomCallID
                                         accept:NO
                                         option:nil
                                     completion:^(NSError *error, UInt64 callID)
     {
         NIM_TEST_NOTIFY;
     }];
    NIM_TEST_WAIT;
}

#pragma mark - on other side handled
- (void) testOnOtherSideHandledNetcall_NormalCase {
    
    nimbiz::CBNetcallBeCalledParam param;
    NSString *expectedKey = [self fillStartNotifyParam:&param];
    nimbiz::CallbackNetcallStartNotify(&param);
    
    XCTAssertTrue([_lastNetCallManagerDelegateKey isEqualToString:expectedKey]);
    
    nimbiz::CBNetCallOtherAckParam otherAckParam;
    otherAckParam.channel_id_ = _randomCallID;
    otherAckParam.accepted_ = false;
    nimbiz::CallbackReceiveOtherAckNotify(&otherAckParam);
    
    expectedKey = [self responsedByOtherKey:_randomCallID accepted:otherAckParam.accepted_];
    XCTAssertTrue([_lastNetCallManagerDelegateKey isEqualToString:expectedKey]);

}


#pragma mark - misc

- (UInt64)requestCall:(NIMNetCallOption *)option {
    
    __block UInt64 requestCallID = 0;
    __block BOOL completed = NO;
    [[NIMSDK sharedSDK].netCallManager start:@[_existingCallee]
                                        type:NIMNetCallTypeAudio
                                      option:option
                                  completion:^(NSError *error, UInt64 callID)
     {
         completed = YES;
         XCTAssertNil(error);
         XCTAssertGreaterThan(callID, 0);
         requestCallID = callID;
         NIM_TEST_NOTIFY;
     }];
    NIM_TEST_WAIT;
    XCTAssertTrue(completed);
    XCTAssertGreaterThan(requestCallID, 0);
    XCTAssertEqual(requestCallID, [[NIMSDK sharedSDK].netCallManager currentCallID]);
    return requestCallID;
    
}

- (NSArray *)existingCallees
{
    NSArray *imSessions = [NIMTestConfig sharedConfig].imSessions;
    NSMutableArray *existingCallees = [NSMutableArray array];
    for (NIMSession *session in imSessions) {
        if (session.sessionType == NIMSessionTypeP2P) {
            [existingCallees addObject:session.sessionId];
        }
    }
    return existingCallees;
}


- (NSString *)noneExistingCallee
{
    return @"biu~biu~biu~";
}

- (NSString *)fillStartNotifyParam:(nimbiz::CBNetcallBeCalledParam *)param
{
    param->call_type_ = nimbiz::NIMNetcallTypeVideo;
    param->channel_id_ = _randomCallID;
    param->caller_ = "gaofeng";
    param->my_uid_ = 84721;
    param->turn_addrs_.push_back("223.252.198.177:30000");
    param->turn_addrs_.push_back("223.252.198.177:35000");
    param->turn_addrs_.push_back("223.252.198.177:23432");
    param->sturn_addrs_.push_back("223.252.198.177:3478");
    param->sturn_addrs_.push_back("223.252.198.177:3479");
    param->extend_message_ = "test_extend_message";
    
    return [self receiveCallKey:param->channel_id_
                           from:NSUTF8(param->caller_)
                           type:param->call_type_
                        message:NSUTF8(param->extend_message_)];
}

- (NSString *)calleeResponseKey:(NSString *)callee accepted:(BOOL)accepted callID:(UInt64)callID
{
    return [NSString stringWithFormat:@"%@_%@_netcall_%llu", callee, accepted ? @"accepted" : @"rejected", callID];
}

- (NSString *)controlKey:(NSString *)user type:(NIMNetCallControlType)control callID:(UInt64)callID
{
    return [NSString stringWithFormat:@"%@_control%ld_netcall_%llu", user, (long)control, callID];
}

- (NSString *)receiveCallKey:(UInt64)callID from:(NSString *)caller type:(NIMNetCallType)type message:(NSString *)extendMessage
{
    return [NSString stringWithFormat:@"receive_netcall_%llu_from_%@_type_%ld_withmessage_%@", callID, caller, (long)type, extendMessage];
}

- (NSString *)responsedByOtherKey:(UInt64)callID accepted:(BOOL)accepted
{
    return [NSString stringWithFormat:@"netcall_%llu_%@_by_other", callID, accepted ? @"accepted" : @"rejected"];

}

#pragma mark - NIMNetCallManagerDelegate

- (void)onResponse:(UInt64)callID
              from:(NSString *)callee
          accepted:(BOOL)accepted
{
    _lastNetCallManagerDelegateKey = [self calleeResponseKey:callee accepted:accepted callID:callID];
}

- (void)onControl:(UInt64)callID
             from:(NSString *)user
             type:(NIMNetCallControlType)control
{
    _lastNetCallManagerDelegateKey = [self controlKey:user type:control callID:callID];
}

- (void)onReceive:(UInt64)callID
             from:(NSString *)caller
             type:(NIMNetCallType)type
          message:(NSString *)extendMessage
{
    _lastNetCallManagerDelegateKey = [self receiveCallKey:callID from:caller type:type message:extendMessage];
}

- (void)onResponsedByOther:(UInt64)callID
                  accepted:(BOOL)accepted
{
    _lastNetCallManagerDelegateKey = [self responsedByOtherKey:callID accepted:accepted];
}


@end
