//
//  NIMNTSManager.m
//  NIMLib
//
//  Created by 高峰 on 15/7/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMNTSManager.h"
#import "NVSDefine.h"
#import "NIMPathManager.h"
#import "log.h"

@implementation NIMNTSManager

- (void)startNTS:(NIMNTSObject *)object
{
    if (object.client) {
        [object.client stopNTSClient];
        object.client = nil;
    }
    
    NTSClientParam *param = [[NTSClientParam alloc] init];
    
    param.clientName = [self logFileName:object.channelId];
    param.clientID = object.myUid;
    param.channelID = object.channelId;
    param.sessionID = object.sessionID;
    param.turnAddr = object.turnAddrs[object.turnAddrIndex];
//    param.turnAddr = @"223.252.198.240:9090";
    if ([object.proxyAddrs count] > 1) {
        param.proxyPolicy = 1;
        param.proxyAddr = [object.proxyAddrs objectAtIndex:object.proxyAddrIndex];
    }
    else {
        param.proxyPolicy = 0;
        param.proxyAddr = param.turnAddr;
    }
    param.encryptType = NVSEncryptTypeNone;
    param.encryptToken = [NSString stringWithFormat:@"%llu", param.channelID];
    //网络库不支持多log文件,与nvs共用log
    param.logPath = [[NIMPathManager sharedManager] sdkNvsLogPath];
    nbase::LogInterface *log = nbase::Log_Creater();
    uint32_t levelLevel = log->GetLevel();
    param.logLevel = (levelLevel == nbase::LogInterface::LV_PRO) ? 7 : 6;
    param.clientType = NTSClientTypeNIM;
    param.disableRecord = object.disableRecord;
    
    NTSClient *ntsClient = [[NTSClient alloc] init];
    BOOL success = [ntsClient startNTSClient:param delegate:object.delegate];
    
    if (success) {
        NIMLogPro(@"nts start ok, channel:%llu, myuid:%d", param.channelID, param.clientID);
        object.client = ntsClient;
    }
}

- (BOOL)tryNextServer:(NIMNTSObject *)object
{
    BOOL tryNext = NO;
    if ((object.proxyAddrIndex + 1 )< [object.proxyAddrs count]) {
        object.proxyAddrIndex ++;//先换proxy
        NIMLogApp(@"nts: change proxy ip %d!", object.proxyAddrIndex);
        tryNext = YES;
    }else if ((object.turnAddrIndex + 1) < [object.turnAddrs count]){
        object.turnAddrIndex ++; //再换turn
        NIMLogApp(@"nts: change turn ip %d!", object.turnAddrIndex);
        tryNext = YES;
    }
    
    if (tryNext) {
        __weak NIMNTSObject *weakObject = object;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startNTS:weakObject];
        });
    }
    return tryNext;

}

- (void)stopNTS:(NIMNTSObject *)object
{
    if (object && object.client) {
        [object.client stopNTSClient];
    }
}

- (BOOL)sendNTSData:(NSData *)data from:(NIMNTSObject *)object to:(uint64_t)clientID
{
    if (object && object.client) {
        return [object.client sendNTSData:data to:clientID];
    }
    else {
        return NO;
    }
}

- (NSString *)logFileName: (UInt64)channelID
{
    //网络库不支持多log文件,与nvs共用log
    return @"nim_nvs";
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyMMddHHmmss"];
//    NSString *timestampStr = [formatter stringFromDate:[NSDate date]];
//    return [NSString stringWithFormat:@"nim_nts_%@_%llu",timestampStr, channelID];
}

@end
