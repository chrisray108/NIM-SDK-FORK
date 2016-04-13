//
//  ios_util.m
//  NIM
//
//  Created by amao on 13-3-27.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "ios_util.h"
#import "NIMReachability.h"
#import "base/encrypt/encrypt_impl.h"
#import "biz/core/yixin_core.h"
#import "NIMUtil.h"
#import "NIMPathManager.h"
#import "NIMSDK_Private.h"
#import "NIMGlobalDefs.h"
#import "NIMSDKConfig_Private.h"
#import "NIMLoginManager.h"
#import "NSString+NIM.h"
#import "NIMChatroomManager.h"
#import "NIMConversationManager.h"
#import "NIMNetworkConfig.h"

namespace nimbiz {

NIMConfigTag(NIMConfigTagDeviceID);

UTF8String GetAPNSToken()
{
    @autoreleasepool
    {
        return UTF8([[NIMSDK sharedSDK] apnsToken]);
    }
}

UTF8String  GetAPNSCerName()
{
    @autoreleasepool
    {
        return UTF8([[NIMSDK sharedSDK] apnsCerName]);
    }
}


UTF8String  GetDeviceID()
{
    @autoreleasepool
    {
        static NSString *deviceID = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            deviceID = [[NSUserDefaults standardUserDefaults] objectForKey:NIMConfigTagDeviceID];
            if (deviceID == nil)
            {
                deviceID = [[NSUUID UUID] UUIDString];
                [[NSUserDefaults standardUserDefaults] setObject:deviceID
                                                          forKey:NIMConfigTagDeviceID];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        });
        return  UTF8(deviceID);
    }
}



UTF8String  GetUserDirectory()
{
    @autoreleasepool
    {
        NSString *dir = [NSString stringWithFormat:@"%@/",[[NIMPathManager sharedManager] sdkCurrentUserDir]];
        return UTF8(dir);
    }
}


bool CanConnectInternet()
{
    @autoreleasepool
    {
        NIMReachability *reachability = [NIMReachability reachabilityForInternetConnection];
        return [reachability currentReachabilityStatus] != NIMNotReachable;

    }
}



void SetShouldSwitchLinkHost(bool fatal)
{
    @autoreleasepool
    {
        [[[NIMSDK sharedSDK] lbsManager] reportError:NIMLbsTypeLink
                                               fatal:fatal];
        
        [[[NIMSDK sharedSDK] lbsManager] setStopReportLink:YES];
        
        //避免短时间内有太多的汇报
        CGFloat duration = fatal ? 1 : 0.3;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[[NIMSDK sharedSDK] lbsManager] setStopReportLink:NO];
        });
    }
}
    
void  SetShouldSwitchChatroomHost(std::string &room_id,bool fatal)
{
    @autoreleasepool
    {
        static CFAbsoluteTime lastReportTime = 0;
        CFAbsoluteTime thisFired = CFAbsoluteTimeGetCurrent();
        if (fabs(thisFired - lastReportTime) > 0.3)
        {
            lastReportTime = thisFired;
            
            NIMLogErr(@"switch host for %s %d",room_id.c_str(),fatal);
            NSString *roomId = NSUTF8(room_id);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NIMChatroomManager sharedManager] reportHostError:roomId
                                                              fatal:fatal];
            });
        }
    }
}
    

void GetLinkAddress(std::string &addr, uint16_t &port)
{
    @autoreleasepool
    {
        NIMLinkAddress *address = [[[NIMSDK sharedSDK] lbsManager] link];
        addr = UTF8(address.address);
        port = (uint16_t)address.port;
    }
}

bool        HostUserInfos()
{
    return [[NIMSDKConfig sharedConfig] hostUserInfos];
}
    
uint64_t    GetP2PTimetagByDB(const UTF8String &uid,const UTF8String &messageId)
{
    @autoreleasepool {
        uint64_t timetag = 0;
        if (!uid.empty() && !messageId.empty()) {
            
            NIMSession *session = [NIMSession session:NSUTF8(uid) type:NIMSessionTypeP2P];
            NSArray *messageIds = @[NSUTF8(messageId)];
            
            NSArray *messages =  [[NIMConversationManager sharedManager] messagesInSession:session
                                                                                messageIds:messageIds];
            timetag = NIMTimeDoubleToLong([[messages lastObject] timestamp]);
        }
        return timetag;
        
        
    }
}

    
int32_t     GetLoginTimeout()
{
    @autoreleasepool
    {
        int32_t timeout = 30;
        NIMNetworkType type = [[NIMNetworkConfig sharedConfig] currentNetworkType];
        if (type == NIMNetworkTypeWifi ||
            type == NIMNetworkType4G)
        {
            timeout = 15;
        }
        return timeout;
    }
}
}



