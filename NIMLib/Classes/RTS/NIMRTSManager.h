//
//  NIMRTSManager.h
//  NIMLib
//
//  Created by fenric on 15/6/26.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMManager.h"
#import "NIMRTSManagerProtocol.h"
#import "rts_protocol.h"

namespace nimbiz
{
struct IAsynCallbackParam;

void CallbackRtsNewTunResponse(IAsynCallbackParam *param);
void CallbackRtsKeepNotifyResponse(IAsynCallbackParam *param);
void CallbackRtsResponseTunResponse(IAsynCallbackParam *param);

void CallbackRtsTunReceivedNotify(IAsynCallbackParam *param);
void CallbackRtsTunResponsedNotify(IAsynCallbackParam *param);
void CallbackRtsTunClosedNotify(IAsynCallbackParam *param);
void CallbackRtsControlNotify(IAsynCallbackParam *param);
void CallbackRtsTunSummaryNotify(IAsynCallbackParam *param);
void CallbackRtsOtherResponsedNotify(IAsynCallbackParam *param);
}

@interface NIMRTSManager : NIMManager

- (NSString *)requestRTS:(NSArray *)callees
                services:(NSUInteger)types
                  option:(NIMRTSOption *)option
              completion:(NIMRTSRequestHandler)completion;

- (void)responseRTS:(NSString *)sessionID
             accept:(BOOL)accept
             option:(NIMRTSOption *)option
         completion:(NIMRTSResponseHandler)completion;

- (void)terminateRTS:(NSString *)sessionID;

- (BOOL)sendRTSData:(NSData *)data
               from:(NSString *)sessionID
                 to:(NSString *)userID
               with:(NIMRTSService)service;

- (void)sendRTSControl:(NSString *)controlInfo
            forSession:(NSString *)sessionID;

- (void)setMute:(BOOL)mute;

- (void)setSpeaker:(BOOL)useSpeaker;

- (UInt64)serviceID:(NSString *)sessionID;

- (NSString *)sessionID:(UInt64)serviceID;


@end


