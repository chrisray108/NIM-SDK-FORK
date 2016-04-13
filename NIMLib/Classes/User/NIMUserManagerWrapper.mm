//
//  NIMUserManagerWrapper.m
//  NIMLib
//
//  Created by amao on 8/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMUserManagerWrapper.h"
#import "response_code.h"
#import "NIMUserManager.h"
#import "NIMDispatch.h"
#import "NIMGlobalDefs.h"
#import "NIMMacros.h"
#import "NIMDelegateCenter.h"

@implementation NIMUserManagerWrapper
+ (instancetype)sharedWrapper
{
    static NIMUserManagerWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMUserManagerWrapper alloc] init];
    });
    return instance;
    
}

- (void)requestFriend:(NIMUserRequest *)request
           completion:(NIMUserBlock)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
    
        NIMUserManager *manager = [NIMUserManager sharedManager];
        if (manager) {
            return [manager requestFriend:request
                               completion:block];
        }
        else
        {
            if (block) {
                block(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
    
}

- (void)deleteFriend:(NSString *)userId
          completion:(NIMUserBlock)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMUserManager *manager = [NIMUserManager sharedManager];
        if (manager) {
            return [manager deleteFriend:userId
                              completion:block];
        }
        else
        {
            if (block) {
                block(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));;
            }
        }
        
    };
    nim_main_async_safe(mainBlock);

    
    }

- (NSArray *)myFriends
{
    return [[NIMUserManager sharedManager] myFriends];
}


- (void)addToBlackList:(NSString *)userId
            completion:(NIMUserBlock)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        NIMUserManager *manager = [NIMUserManager sharedManager];
        if (manager) {
            return [manager addToBlackList:userId
                                completion:block];
        }
        else
        {
            if (block) {
                block(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }

    };
    nim_main_async_safe(mainBlock);

}


- (void)removeFromBlackBlackList:(NSString *)userId
                      completion:(NIMUserBlock)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMUserManager *manager = [NIMUserManager sharedManager];
        if (manager) {
            return [manager removeFromBlackBlackList:userId
                                          completion:block];
        }
        else
        {
            if (block) {
                block(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }

    };
    nim_main_async_safe(mainBlock);

}


- (BOOL)isUserInBlackList:(NSString *)userId
{
    return [[NIMUserManager sharedManager] isUserInBlackList:userId];
}


- (NSArray *)myBlackList
{
    return [[NIMUserManager sharedManager] myBlackList];
}


- (void)updateNotifyState:(BOOL)notify
                  forUser:(NSString *)userId
               completion:(NIMUserBlock)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        NIMUserManager *manager = [NIMUserManager sharedManager];
        if (manager) {
            return [manager updateNotifyState:notify
                                      forUser:userId
                                   completion:block];
        }
        else
        {
            if (block) {
                block(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }

    };
    nim_main_async_safe(mainBlock);

}


- (BOOL)notifyForNewMsg:(NSString *)userId
{
    NIMUserManager *manager = [NIMUserManager sharedManager];
    return manager ? [manager notifyForNewMsg:userId] : YES;
}

- (NSArray *)myMuteUserList
{
    return [[NIMUserManager sharedManager] myMuteUserList];
}


- (void)fetchUserInfos:(NSArray *)users completion:(NIMUserInfoBlock)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMUserManager *manager = [NIMUserManager sharedManager];
        if (manager) {
            [[NIMUserManager sharedManager] fetchUserInfos:users completion:block];
        }else{
            if (block) {
                block(nil,NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }

    };
    nim_main_async_safe(mainBlock);

    
    }


- (NIMUser *)userInfo:(NSString *)userId{
    NIMUserManager *manager = [NIMUserManager sharedManager];
    return  manager ? [manager userInfo:userId] : nil;
}


- (void)updateMyUserInfo:(NSDictionary *)values completion:(NIMUserBlock)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMUserManager *manager = [NIMUserManager sharedManager];
        if (manager) {
            [[NIMUserManager sharedManager] updateMyUserInfo:values completion:block];
        }else{
            if (block) {
                block(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }
    };
    nim_main_async_safe(mainBlock);

    
    
}

- (void)updateUser:(NIMUser *)user
        completion:(NIMUserBlock)block{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMUserManager *manager = [NIMUserManager sharedManager];
        if (manager) {
            [[NIMUserManager sharedManager] updateUser:user completion:block];
        }else{
            if (block) {
                block(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }

        
    };
    nim_main_async_safe(mainBlock);

}


- (void)addDelegate:(id<NIMUserManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] addDelegate:delegate
                                          forType:NIMDelegateTypeUser];
}

- (void)removeDelegate:(id<NIMUserManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] removeDelegate:delegate
                                             forType:NIMDelegateTypeUser];
}
@end
