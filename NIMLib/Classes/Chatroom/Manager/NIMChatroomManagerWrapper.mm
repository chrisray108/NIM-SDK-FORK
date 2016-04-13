//
//  NIMChatroomManagerWrapper.m
//  NIMLib
//
//  Created by amao on 12/14/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMChatroomManagerWrapper.h"
#import "NIMChatroomManager.h"
#import "NIMDelegateCenter.h"
#import "NIMDispatch.h"
#import "response_code.h"



@implementation NIMChatroomManagerWrapper
+ (instancetype)sharedWrapper
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)enterChatroom:(NIMChatroomEnterRequest *)request
           completion:(NIMChatroomEnterHandler)completion
{
    NIMAPITrace();
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager enterChatroom:request
                        completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded),nil,nil);
            }
        }
    };
    nim_main_async_safe(mainBlock);
}



- (void)fetchChatroomMembers:(NIMChatroomMemberRequest *)request
                  completion:(NIMChatroomMembersHandler)completion{
    
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager fetchChatroomMembers:request completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded),nil);
            }
        }
        
    };
    nim_main_async_safe(mainBlock);
}




- (void)markMemberManager:(NIMChatroomMemberUpdateRequest *)request
               completion:(NIMChatroomHandler)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager markMemberManager:request completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }
        
    };
    nim_main_async_safe(mainBlock);
    
}


- (void)markNormalMember:(NIMChatroomMemberUpdateRequest *)request
              completion:(NIMChatroomHandler)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager markNormalMember:request
                           completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }
        
    };
    nim_main_async_safe(mainBlock);
    
}

- (void)updateMemberBlack:(NIMChatroomMemberUpdateRequest *)request
               completion:(NIMChatroomHandler)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager updateMemberBlack:request completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }
    };
    nim_main_async_safe(mainBlock);
}


- (void)updateMemberMute:(NIMChatroomMemberUpdateRequest *)request
              completion:(NIMChatroomHandler)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager updateMemberMute:request completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }
    };
    nim_main_async_safe(mainBlock);
    
}




- (void)exitChatroom:(NSString *)roomId
          completion:(NIMChatroomHandler)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager exitChatroom:roomId
                       completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
    
}

- (void)closeChatroom:(NSString *)roomId
            notifyExt:(NSDictionary *)ext
           completion:(NIMChatroomHandler)completion{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager closeChatroom:roomId
                         notifyExt:ext
                        completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
}

- (void)fetchChatroomInfo:(NSString *)roomId
               completion:(NIMChatroomInfoHandler)completion{
    
    NIMAPITrace();

    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager fetchChatroomInfo:roomId completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded),nil);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
}

- (void)fetchMessageHistory:(NSString *)roomId
                     option:(NIMHistoryMessageSearchOption *)option
                     result:(NIMFetchChatroomHistoryBlock)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager fetchMessageHistory:roomId option:option result:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded),nil);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
}


- (void)fetchChatroomMembersByIds:(NIMChatroomMembersByIdsRequest *)request
                       completion:(NIMChatroomMembersHandler)completion{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager fetchChatroomMembersByIds:request completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded),nil);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
}


- (void)kickMember:(NIMChatroomMemberKickRequest *)request
        completion:(NIMChatroomHandler)completion{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMChatroomManager *manager = [NIMChatroomManager sharedManager];
        if (manager)
        {
            [manager kickMember:request completion:completion];
        }
        else
        {
            if (completion) {
                completion(NIMRemoteError(NIMLocalErrorCodeUserInfoNeeded));
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
}

- (void)addDelegate:(id<NIMChatroomManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] addDelegate:delegate
                                          forType:NIMDelegateTypeChatroom];
}

- (void)removeDelegate:(id<NIMChatroomManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] removeDelegate:delegate
                                             forType:NIMDelegateTypeChatroom];
}

@end
