//
//  NIMRTSManagerWrapper.m
//  NIMLib
//
//  Created by 高峰 on 15/8/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMRTSManagerWrapper.h"
#import "NIMRTSManager.h"
#import "NIMDispatch.h"
#import "NIMDelegateCenter.h"
#import "NIMUtil.h"

@implementation NIMRTSManagerWrapper

+ (instancetype)sharedWrapper
{
    static NIMRTSManagerWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMRTSManagerWrapper alloc] init];
    });
    return instance;
}


- (NSString *)requestRTS:(NSArray *)callees
                services:(NSUInteger)types
                  option:(NIMRTSOption *)option
              completion:(NIMRTSRequestHandler)completion
{
    NIMAPITrace();
    
    __block NSString *sessionID = nil;
    
    dispatch_block_t mainBlock = ^(){
        
        NIMRTSManager *manager = [NIMRTSManager sharedManager];
        if (manager) {
            sessionID = [manager requestRTS:callees services:types option:option completion:completion];
        }else{
            sessionID = [NIMUtil uuid];
            if (completion) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion(error, sessionID);
                });
            }
        }
    };
    
    nim_main_sync_safe(mainBlock);
    
    return sessionID;
}

- (void)responseRTS:(NSString *)sessionID
             accept:(BOOL)accept
             option:(NIMRTSOption *)option
         completion:(NIMRTSResponseHandler)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMRTSManager *manager = [NIMRTSManager sharedManager];
        if (manager) {
            [manager responseRTS:sessionID accept:accept option:option completion:completion];
        }else{
            if (completion) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                completion(error, sessionID);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);

}

- (void)terminateRTS:(NSString *)sessionID
{
    NIMAPITrace();
    
    nim_main_async_safe(^{
        [[NIMRTSManager sharedManager] terminateRTS:sessionID];
    });
}

- (BOOL)sendRTSData:(NSData *)data
               from:(NSString *)sessionID
                 to:(NSString *)userID
               with:(NIMRTSService)service
{
    
    __block BOOL result = NO;

    nim_main_sync_safe(^{
        result = [[NIMRTSManager sharedManager] sendRTSData:data
                                                       from:sessionID
                                                         to:userID
                                                       with:service];
    });
    
    return result;
}

- (void)sendRTSControl:(NSString *)controlInfo
            forSession:(NSString *)sessionID
{
    NIMAPITrace();
    
    nim_main_async_safe(^{
        [[NIMRTSManager sharedManager] sendRTSControl:controlInfo forSession:sessionID];
    });
}

- (void)setMute:(BOOL)mute
{
    NIMAPITrace();
    
    nim_main_async_safe(^{
        [[NIMRTSManager sharedManager] setMute:mute];
    });
}

- (void)setSpeaker:(BOOL)useSpeaker
{
    NIMAPITrace();
    
    nim_main_async_safe(^{
        [[NIMRTSManager sharedManager] setSpeaker:useSpeaker];
    });

}

//添加实时会话委托
- (void)addDelegate:(id<NIMRTSManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] addDelegate:delegate
                                          forType:NIMDelegateTypeRTS];
}

//移除实时会话委托
- (void)removeDelegate:(id<NIMRTSManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] removeDelegate:delegate
                                             forType:NIMDelegateTypeRTS];
}

@end
