//
//  NIMRTSManagerTest.m
//  NIMLib
//
//  Created by fenric on 16/3/29.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMTestConfig.h"
#import "NIMRTSManager.h"
#import "NIMMacros.h"
#include "rts_protocol.h"


@interface NIMRTSManagerTest : NIMBaseTest<NIMRTSManagerDelegate>

@property(nonatomic, strong) NSString *lastRTSManagerDelegateKey;

@property(nonatomic, strong) NSString *existingCallee;

@property(nonatomic, assign) UInt64 randomCallID;


@end

@implementation NIMRTSManagerTest

- (void)setUp {
    [super setUp];
    
    NSArray *callees = [self existingCallees];
    
    if (callees.count > 0) {
        _existingCallee = [callees firstObject];
    }
    else {
        _existingCallee = @"gaofeng1";
    }

    _randomCallID = arc4random();

    [[NIMSDK sharedSDK].rtsManager addDelegate:self];
}

- (void)tearDown {
    _lastRTSManagerDelegateKey = nil;

    [[NIMSDK sharedSDK].rtsManager removeDelegate:self];
    [super tearDown];
}

#pragma mark - request RTS
- (void)testRequestRTS_NormalCase_WithoutOption {
    [self requestRTS:nil withAudio:YES];
}

- (void)testRequestRTS_NormalCase_WithOption {
    
    NIMRTSOption *option = [[NIMRTSOption alloc] init];
    option.extendMessage = @"unit test extend message";
    [self requestRTS:option withAudio:YES];
}

- (void)testRequestRTS_NormalCase_MultipleCallees {
    
    __block BOOL completed = NO;
    __block NSString *blockSessionID = nil;
    NSString *returnID =  [[NIMSDK sharedSDK].rtsManager requestRTS:[self existingCallees]
                                                           services:NIMRTSServiceAudio
                                                             option:nil
                                                         completion:^(NSError *error, NSString *sessionID)
   {
       completed = YES;
       XCTAssertNil(error);
       XCTAssertNotNil(sessionID);
       blockSessionID = sessionID;
       NIM_TEST_NOTIFY;
   }];
    
    NIM_TEST_WAIT;
    XCTAssertTrue(completed);
    XCTAssertNotNil(returnID);
    XCTAssertTrue([returnID isEqualToString:blockSessionID]);
}


- (void)testRequestRTS_ErrorCase_NoneExistingCallee {
    
    __block BOOL completed = NO;
    __block NSString *blockSessionID = nil;
    NSString *returnID =  [[NIMSDK sharedSDK].rtsManager requestRTS:@[[self noneExistingCallee]]
                                                           services:NIMRTSServiceReliableTransfer
                                                             option:nil
                                                         completion:^(NSError *error, NSString *sessionID)
     {
         completed = YES;
         //这里应该是404的，等小可爱修 NIM-3719
         XCTAssertEqual(error.code, NIMRemoteErrorCodeCalleeOffline);
         XCTAssertNotNil(sessionID);
         blockSessionID = sessionID;
         NIM_TEST_NOTIFY;
     }];
    NIM_TEST_WAIT;
    XCTAssertTrue(completed);
    XCTAssertNotNil(returnID);
    XCTAssertTrue([returnID isEqualToString:blockSessionID]);
}

#pragma mark - response RTS
- (void)testResponseRTS_ErrorCase_SessionIDNoneExist {
    
    __block BOOL completed = NO;
    NSString *noneExistSessionID = [self noneExistSessionID];
    [[NIMSDK sharedSDK].rtsManager responseRTS:noneExistSessionID
                                        accept:YES
                                        option:nil
                                    completion:^(NSError *error, NSString *sessionID)
    {
        completed = YES;
        XCTAssertTrue([sessionID isEqualToString:noneExistSessionID]);
        XCTAssertEqual(error.code, NIMLocalErrorCodeInvalidParam);
    }];
    XCTAssertTrue(completed);
}

#pragma mark - terminate RTS
- (void)testTerminateRTS_NormalCase_RequestAndTerminate {
    
    NSString  *sessionID = [self requestRTS:nil withAudio:YES];
    
    [[NIMSDK sharedSDK].rtsManager terminateRTS:sessionID];
}

- (void)testTerminateRTS_ErrorCase_NoneExistSessionID {
    
    [[NIMSDK sharedSDK].rtsManager terminateRTS:[self noneExistSessionID]];
    
    [[NIMSDK sharedSDK].rtsManager terminateRTS:nil];
}

#pragma mark - send RTS data
- (void)testSendRTSData_NormalCase {
    
    NSString  *sessionID = [self requestRTS:nil withAudio:YES];
    
    BOOL success = [[NIMSDK sharedSDK].rtsManager sendRTSData:[NSData data]
                                                         from:sessionID
                                                           to:_existingCallee
                                                         with:NIMRTSServiceReliableTransfer];
    XCTAssertFalse(success);
}

- (void)testSendRTSData_ErrorCase_InvalidParams {
    
    NSString  *sessionID = [self requestRTS:nil withAudio:YES];
    
    BOOL result = [[NIMSDK sharedSDK].rtsManager sendRTSData:[NSData data]
                                                        from:[self noneExistSessionID]
                                                          to:_existingCallee
                                                        with:NIMRTSServiceReliableTransfer];
    XCTAssertFalse(result);
    
    result = [[NIMSDK sharedSDK].rtsManager sendRTSData:[NSData data]
                                                   from:sessionID
                                                     to:[self noneExistingCallee]
                                                   with:NIMRTSServiceReliableTransfer];
    XCTAssertFalse(result);
    
    result = [[NIMSDK sharedSDK].rtsManager sendRTSData:[NSData data]
                                                   from:sessionID
                                                     to:_existingCallee
                                                   with:NIMRTSServiceAudio];
    XCTAssertFalse(result);
}


#pragma mark - control RTS
- (void)testSendRTSControl_NormalCase {
    
    NSString  *sessionID = [self requestRTS:nil withAudio:YES];
    
    [[NIMSDK sharedSDK].rtsManager sendRTSControl:@"controlxxx" forSession:sessionID];
}

- (void)testSendRTSControl_ErrorCase_InvalidParam {
        
    [[NIMSDK sharedSDK].rtsManager sendRTSControl:@"controlxxx" forSession:[self noneExistSessionID]];
}


#pragma mark - device control
- (void)testControlDeviceRTS_NormalCase {
    
    [[NIMSDK sharedSDK].rtsManager setMute:YES];
    
    [[NIMSDK sharedSDK].rtsManager setSpeaker:NO];
}

#pragma mark - on keep notify
- (void)testOnKeepNotifyRTS_NormalCase {
    NSString  *sessionID = [self requestRTS:nil withAudio:YES];
    
    nimbiz::CBRtsKeepNotifyParam keepNotifyParam;
    keepNotifyParam.callee_users_.push_back(UTF8(_existingCallee));
    keepNotifyParam.uuid = UTF8(sessionID);
    nimbiz::CallbackRtsKeepNotifyResponse(&keepNotifyParam);
    //no checkpoint yet
}

#pragma mark - on control
- (void)testOnControlRTS_NormalCase {
    NSString  *sessionID = [self requestRTS:nil withAudio:YES];
    nimbiz::CBRtsControlNotifyParam controlParam;
    controlParam.peer_ = [_existingCallee UTF8String];
    controlParam.channel_id_ = [[NIMRTSManager sharedManager] serviceID:sessionID];
    controlParam.control_ = "test_control_message";
    nimbiz::CallbackRtsControlNotify(&controlParam);
    
    NSString *expectedKey = [self controlKey:_existingCallee info:NSUTF8(controlParam.control_) sessionID:sessionID];
    XCTAssertTrue([_lastRTSManagerDelegateKey isEqualToString:expectedKey]);
}

#pragma mark - on callee responsed
- (void)testOnTunResponsedRTS_NormalCase_Accepted {
    NSString *sessionID = [self onTunResponsedRTSTest:YES];
    [[NIMSDK sharedSDK].rtsManager terminateRTS:sessionID];
}

- (void)testOnTunResponsedRTS_NormalCase_Rejected {
    NSString *sessionID = [self onTunResponsedRTSTest:NO];
    [[NIMSDK sharedSDK].rtsManager terminateRTS:sessionID];
}

- (void)testOnTunResponsedRTS_NormalCase_MultipleRTS {
    NSString *sessionID1 = [self onTunResponsedRTSTest:YES];
    NSString *sessionID2 = [self onTunResponsedRTSTest:NO];
    NSString *sessionID3 = [self onTunResponsedRTSTest:NO];

    [[NIMSDK sharedSDK].rtsManager terminateRTS:sessionID1];
    [[NIMSDK sharedSDK].rtsManager terminateRTS:sessionID2];
    [[NIMSDK sharedSDK].rtsManager terminateRTS:sessionID3];
}

- (void)testOnTunResponsedRTS_ErrorCase_ChannelNotFound {
    
    nimbiz::CBRtsTunResponsedNotifyParam callbackParam;
    callbackParam.callee_ = [_existingCallee UTF8String];
    callbackParam.channel_id_ = 123;
    callbackParam.accepted_ = true;
    nimbiz::CallbackRtsTunResponsedNotify(&callbackParam);
}


#pragma mark - on receive rts request
- (void) testOnTunReceivedRTS_NormalCase {
    [self onTunReceivedTest];
}

#pragma mark - on rts response result
- (void)testOnResponseTunResultRTS_NormalCase {
    NSString *sessionID = [self onTunReceivedTest];
    
    [[NIMSDK sharedSDK].rtsManager responseRTS:sessionID
                                        accept:YES
                                        option:nil
                                    completion:^(NSError *error, NSString *sessionID)
    {
        NIM_TEST_NOTIFY;
    }];
    NIM_TEST_WAIT;
}

#pragma mark - on other side handled
- (void) testOnOtherSideHandledRTS_NormalCase {
    NSString *sessionID = [self onTunReceivedTest];
    nimbiz::CBRtsOtherResponsedNotifyParam param;
    param.channel_id_ = _randomCallID;
    param.accepted_ = true;
    nimbiz::CallbackRtsOtherResponsedNotify(&param);
    
    NSString *expectedKey = [self otherResponsedKey:sessionID accepted:param.accepted_];
    XCTAssertTrue([_lastRTSManagerDelegateKey isEqualToString:expectedKey]);
}

#pragma mark - on tun closed
- (void)testOnTunClosedRTS_NormalCase {
    NSString *sessionID = [self onTunResponsedRTSTest:YES];
    nimbiz::CBRtsTunClosedNotifyParam param;
    param.peer_ = UTF8(_existingCallee);
    param.channel_id_ = [[NIMRTSManager sharedManager] serviceID:sessionID];
    nimbiz::CallbackRtsTunClosedNotify(&param);
    
    NSString *expectedKey = [self tunClosedKey:_existingCallee sessionID:sessionID];
    XCTAssertTrue([_lastRTSManagerDelegateKey isEqualToString:expectedKey]);
    
    [[NIMSDK sharedSDK].rtsManager terminateRTS:sessionID];
}


#pragma mark - misc

- (NSString *)requestRTS:(NIMRTSOption *)option withAudio:(BOOL)withAudio{
    
    __block BOOL completed = NO;
    __block NSString *blockSessionID = nil;
    NSUInteger services = withAudio ? (NIMRTSServiceReliableTransfer | NIMRTSServiceAudio) : NIMRTSServiceReliableTransfer;
    NSString *returnID = [[NIMSDK sharedSDK].rtsManager requestRTS:@[_existingCallee]
                                                          services:services
                                                            option:option
                                                          completion:^(NSError *error, NSString *sessionID)
    {
        completed = YES;
        XCTAssertNil(error);
        XCTAssertNotNil(sessionID);
        blockSessionID = sessionID;
        NIM_TEST_NOTIFY;
    }];
    
    NIM_TEST_WAIT;
    XCTAssertTrue(completed);
    XCTAssertNotNil(returnID);
    XCTAssertTrue([returnID isEqualToString:blockSessionID]);
    return returnID;
}

-(NSString *)onTunResponsedRTSTest:(BOOL)accepted
{
    NSString  *sessionID = [self requestRTS:nil withAudio:accepted];
    nimbiz::CBRtsTunResponsedNotifyParam callbackParam;
    callbackParam.callee_ = [_existingCallee UTF8String];
    callbackParam.channel_id_ = [[NIMRTSManager sharedManager] serviceID:sessionID];
    callbackParam.accepted_ = accepted ? true :false;
    nimbiz::CallbackRtsTunResponsedNotify(&callbackParam);
    
    NSString *expectedKey = [self tunResponsedKey:_existingCallee accepted:accepted sessionID:sessionID];
    XCTAssertTrue([_lastRTSManagerDelegateKey isEqualToString:expectedKey]);
    
    return sessionID;
}

- (NSString *) onTunReceivedTest {
    nimbiz::CBRtsTunReceivedParam param;
    param.channel_id_ = _randomCallID;
    param.caller_ = "gaofeng";
    param.extend_message_ = "assdd112";
    nimbiz::CallbackRtsTunReceivedNotify(&param);
    NSString *expectedKey = [self tunRequestKey:NSUTF8(param.caller_) message:NSUTF8(param.extend_message_)];
    XCTAssertTrue([_lastRTSManagerDelegateKey isEqualToString:expectedKey]);
    
    return [[NIMRTSManager sharedManager] sessionID:_randomCallID];
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

- (NSString *)noneExistSessionID
{
    return @"noneexistrts";
}

- (NSString *)controlKey:(NSString *)user info:(NSString *)control sessionID:(NSString *)sessionID
{
    return [NSString stringWithFormat:@"rts_control_%@_from_%@_in_%@", control, user, sessionID];
}

- (NSString *)tunResponsedKey:(NSString *)callee accepted:(BOOL)accepted sessionID:(NSString *)sessionID
{
    return [NSString stringWithFormat:@"%@_%@_rts_request_%@", callee, accepted ? @"accepted" : @"rejected", sessionID];
}

- (NSString *)tunRequestKey:(NSString *)caller message:(NSString *)extendMessage
{
    return [NSString stringWithFormat:@"rts_received_from_%@_with_message_%@", caller, extendMessage];
}

- (NSString *)otherResponsedKey:(NSString *)sessionID accepted:(BOOL)accepted
{
    return [NSString stringWithFormat:@"other_%@_rts_request_%@", accepted ? @"accepted" : @"rejected", sessionID];
}

- (NSString *)tunClosedKey:(NSString *)user sessionID:(NSString *)sessionID
{
    return [NSString stringWithFormat:@"%@_closed_rts_%@", user, sessionID];
}

#pragma mark - NIMRTSManagerDelegate
- (void)onRTSControl:(NSString *)controlInfo
                from:(NSString *)user
          forSession:(NSString *)sessionID
{
    _lastRTSManagerDelegateKey = [self controlKey:user info:controlInfo sessionID:sessionID];
}

- (void)onRTSResponse:(NSString *)sessionID
                 from:(NSString *)callee
             accepted:(BOOL)accepted
{
    _lastRTSManagerDelegateKey = [self tunResponsedKey:callee accepted:accepted sessionID:sessionID];
}

- (void)onRTSRequest:(NSString *)sessionID
                from:(NSString *)caller
            services:(NSUInteger)types
             message:(NSString *)extendMessage
{
    _lastRTSManagerDelegateKey = [self tunRequestKey:caller message:extendMessage];
}

- (void)onRTSResponsedByOther:(NSString *)sessionID
                     accepted:(BOOL)accepted
{
    _lastRTSManagerDelegateKey = [self otherResponsedKey:sessionID accepted:accepted];
}

- (void)onRTSTerminate:(NSString *)sessionID
                    by:(NSString *)user
{
    _lastRTSManagerDelegateKey = [self tunClosedKey:user sessionID:sessionID];
}


@end
