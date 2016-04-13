//
//  NIMNetCallManagerWrapper.m
//  NIMLib
//
//  Created by 高峰 on 15/8/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMNetCallManagerWrapper.h"
#import "NIMNetCallManager.h"
#import "NIMDispatch.h"
#import "NIMDelegateCenter.h"

@implementation NIMNetCallManagerWrapper

+ (instancetype)sharedWrapper
{
    static NIMNetCallManagerWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMNetCallManagerWrapper alloc] init];
    });
    return instance;
}

- (void)start:(NSArray *)callees
         type:(NIMNetCallType)type
       option:(NIMNetCallOption *)option
   completion:(NIMNetCallStartHandler)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
    
        NIMNetCallManager *manager = [NIMNetCallManager sharedManager];
        if (manager)
        {
            [manager start:callees
                      type:type
                    option:option
                completion:completion];
        }
        else
        {
            if (completion)
            {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                completion(error, 0);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
    
}

- (void)response:(UInt64)callID
          accept:(BOOL)accept
          option:(NIMNetCallOption *)option
      completion:(NIMNetCallResponseHandler)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock =^(){
        
        NIMNetCallManager *manager = [NIMNetCallManager sharedManager];
        if (manager)
        {
            [manager response:callID
                       accept:accept
                       option:option
                   completion:completion];
        }
        else
        {
            if (completion)
            {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                completion(error, callID);;
            }
        }
        
    };
    
    nim_main_async_safe(mainBlock);
    
    
}


- (void)hangup:(UInt64)callID
{
    NIMAPITrace();
    
    nim_main_async_safe(^{
        [[NIMNetCallManager sharedManager] hangup:callID];
    });
}

- (void)control:(UInt64)callID
           type:(NIMNetCallControlType)type
{
    NIMAPITrace();
    
    nim_main_async_safe(^{
        [[NIMNetCallManager sharedManager] control:callID type:type];
    });
    
}

- (BOOL)setMute:(BOOL)mute
{
    NIMAPITrace();
    
    __block BOOL result = NO;
    
    nim_main_sync_safe(^{
        result = [[NIMNetCallManager sharedManager] setMute:mute];
    });
    return result;
}

- (BOOL)setSpeaker:(BOOL)useSpeaker
{
    NIMAPITrace();
    
    __block BOOL result = NO;
    
    nim_main_sync_safe(^{
        result = [[NIMNetCallManager sharedManager] setSpeaker:useSpeaker];
    });
    return result;
}

- (void)switchCamera:(NIMNetCallCamera)camera
{
    NIMAPITrace();
    
    nim_main_async_safe(^{
        [[NIMNetCallManager sharedManager] switchCamera:camera];
    });
    
}

- (BOOL)setCameraDisable:(BOOL)disable
{
    NIMAPITrace();
    
    __block BOOL result = NO;
    
    nim_main_sync_safe(^{
        result =  [[NIMNetCallManager sharedManager] setCameraDisable:disable];
    });
    return result;
}

- (void)switchType:(NIMNetCallType)type
{
    NIMAPITrace();
    
    nim_main_async_safe(^{
        [[NIMNetCallManager sharedManager] switchType:type];
    });
    
}

- (CALayer *)localPreviewLayer
{
    __block CALayer *layer = nil;
    
    nim_main_sync_safe(^{
        layer = [[NIMNetCallManager sharedManager] localPreviewLayer];
    });
    return layer;

}

- (UInt64)currentCallID
{
    __block UInt64 callId = 0;
    
    nim_main_sync_safe(^{
        callId = [[NIMNetCallManager sharedManager] currentCallID];
    });
    return callId;
}

- (NIMNetCallNetStatus)netStatus
{
    __block NIMNetCallNetStatus status = NIMNetCallNetStatusGood;
    
    nim_main_sync_safe(^{
        status = [[NIMNetCallManager sharedManager] netStatus];
    });
    return status;
}

- (BOOL)startLocalRecording:(NSURL *)filePath
               videoBitrate:(UInt32)videoBitrate
{
    __block BOOL result = NO;
    
    nim_main_sync_safe(^{
        result =  [[NIMNetCallManager sharedManager] startLocalRecording:filePath
                                                            videoBitrate:videoBitrate];
    });
    return result;
}

- (BOOL)stopLocalRecording
{
    __block BOOL result = NO;
    
    nim_main_sync_safe(^{
        result = [[NIMNetCallManager sharedManager] stopLocalRecording];
    });
    return result;
}


- (void)addDelegate:(id<NIMNetCallManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] addDelegate:delegate
                                          forType:NIMDelegateTypeNetCall];
    
}

- (void)removeDelegate:(id<NIMNetCallManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] removeDelegate:delegate
                                             forType:NIMDelegateTypeNetCall];
}



@end
