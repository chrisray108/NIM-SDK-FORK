//
//  NIMApnsManagerWrapper.m
//  NIMLib
//
//  Created by amao on 8/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMApnsManagerWrapper.h"
#import "NIMApnsManager.h"
#import "NIMDispatch.h"
#import "NIMGlobalDefs.h"
#import "NIMSDK_Private.h"

@implementation NIMApnsManagerWrapper

+ (instancetype)sharedWrapper
{
    static NIMApnsManagerWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMApnsManagerWrapper alloc] init];
    });
    return instance;
}

- (NIMPushNotificationSetting *)currentSetting
{
    return [[NIMApnsManager sharedManager] currentSetting];
}

- (void)updateApnsSetting:(NIMPushNotificationSetting *)setting
               completion:(NIMApnsHandler)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMApnsManager *manager = [NIMApnsManager sharedManager];
        if (manager) {
            [manager updateApnsSetting:setting
                            completion:completion];
        }
        else{
            if (completion) {
                completion(NIMLocalError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
    
}

- (void)registerBadgeCountHandler:(NIMBadgeHandler)handler
{
    nim_main_async_safe(^{
        [[[NIMSDK sharedSDK] appTokenManager] setBadgeHandler:handler];
    });
}
@end
