//
//  NIMNVSManager.m
//  NIMLib
//
//  Created by 高峰 on 15/7/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMNVSManager.h"
#import "log.h"
#import "NIMPathManager.h"
#import "NIMDispatch.h"
#import "NIMNVSObject.h"
#import "NVSSessionManager.h"
#import "NIMGlobalDefs.h"
#import "NIMNetCallOption.h"

static NSString *NIMNVSClientName = @"nim_nvs";

@interface NIMNVSManager()<NVSLogDelegate>

@property (nonatomic, strong) NIMNVSObject *sessionData;
@property (nonatomic, weak)   id<NVSSessionDelegate, NVSVideoPlayerDelegate> delegate;
@end

@implementation NIMNVSManager

- (void)start:(NIMNVSObject *)object delegate:(id)delegate;
{
    nim_main_async_safe(^{
        if (_session) {
            NIMLogErr(@"Execute Start Net Call: Having ongoing mute call, stop it first...");
            [_session stopChat];
            _session = nil;
        }
        _sessionData = object;
        _delegate = delegate;
        
        NVSSessionParam *param = [NVSSessionParam new];
        
        param.myClientType = NVSClientTypeNIM;
        param.peerClientType = NVSClientTypeNIM;
        param.clientName = NIMNVSClientName;
        
        param.clientID = _sessionData.myUid;
        param.channelID = _sessionData.channelId;
        
        param.encryptType = NVSEncryptTypeNone;
        param.encryptToken = [NSString stringWithFormat:@"%llu", param.channelID];
        
        param.turnAddrArrays = [NSArray arrayWithObjects:_sessionData.turnAddrs, nil];
        
        param.stunAddr1 = [[_sessionData stunAddrs] objectAtIndex:0];
        if ([[_sessionData stunAddrs] count] > 1) {
            param.stunAddr2 = [[_sessionData stunAddrs] objectAtIndex:1];
        }
        else {
            param.stunAddr2 = param.stunAddr1;
        }
        param.proxyAddrs = _sessionData.proxyAddrs;

        nbase::LogInterface *log = nbase::Log_Creater();
        uint32_t levelLevel = log->GetLevel();
        param.logLevel = (levelLevel == nbase::LogInterface::LV_PRO) ? 7 : 6;
        
        param.logPath = [self logFileDir];
        param.mode = (NVSSessionMode)_sessionData.callType;
        param.disableP2P = _sessionData.disableP2P;
        param.serverRecordAudio = _sessionData.serverRecordAudio;
        param.serverRecordVideo = _sessionData.serverRecordVideo;

        param.callConfig = _sessionData.callConfig;
        
        if (_sessionData.option) {
            param.preferredVideoQuality = [self nvsVideoQuality:_sessionData.option.preferredVideoQuality];
            param.noCropping = _sessionData.option.disableVideoCropping;
            param.serverRecordAudio = _sessionData.option.serverRecordAudio;
            param.serverRecordVideo = _sessionData.option.serverRecordVideo;
            NIMLogApp(@"NVS option: video quality :%d, no cropping:%d", param.preferredVideoQuality, param.noCropping);
        }
    
        _session = [[NVSSessionManager alloc] initWithLocalPlayerDelegate:delegate];
        [_session setSessionDelegate:delegate];
        [_session setLogDelegate:self];
        [_session startChat:param];
    });
}

- (BOOL)stop:(uint64_t)channelID
{
    if ((channelID == 0) || ([self currentChannelID] == channelID)) {
        nim_main_async_safe(^{
            if (_session) {
                [_session stopChat];
                _session = nil;
                _sessionData = nil;
                _delegate = nil;
            }
        });
        return YES;
    }
    return NO;
}

- (uint64_t)currentChannelID
{
    return _sessionData ? _sessionData.channelId : 0;
}

- (BOOL)isBusy
{
    return ([self currentChannelID] != 0);
}

- (NSString *)logFilePath
{
    return [NSString stringWithFormat:@"%@/%@.log", [self logFileDir], NIMNVSClientName];
}

- (NSString *)logFileDir
{
    return [[NIMPathManager sharedManager] sdkNvsLogPath];
}

- (NVSSessionRecordInfo *)getRecordInfo
{
    if (_session) {
        return [_session recordInfo];
    }
    else {
        return nil;
    }
}

#pragma mark - NVSLogDelegate
- (void)log:(NVSLogLevel)level
       file:(NSString *)file
       line:(NSUInteger)line
       text:(NSString *)text
{
    uint32_t logLevel;
    switch (level) {
        case NVSLogLevelErr:
            logLevel = 6;
            break;
        case NVSLogLevelWar:
            logLevel = 8;
            break;
        case NVSLogLevelApp:
            logLevel = 12;
            break;
        case NVSLogLevelPro:
            logLevel = 14;
            break;
        default:
            logLevel = 14;
            break;
    }
    NIMLOG_OBJC(logLevel, UTF8(file), (uint32_t)line, text);
}

- (NVSVideoQuality)nvsVideoQuality:(NIMNetCallVideoQuality)nimVideoQuality {
    switch (nimVideoQuality) {
        case NIMNetCallVideoQualityLow:
            return NVSVideoQualityLow;
        case NIMNetCallVideoQualityMedium:
            return NVSVideoQualityMedium;
        case NIMNetCallVideoQualityHigh:
            return NVSVideoQualityHigh;
        default:
            return NVSVideoQualityDefault;
    }
}

@end
