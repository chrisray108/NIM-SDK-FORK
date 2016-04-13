//
//  NIMChatManagerWrapper.m
//  NIMLib
//
//  Created by amao on 8/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMChatManagerWrapper.h"
#import "NIMChatManager.h"
#import "NIMDelegateCenter.h"
#import "NIMDispatch.h"

@implementation NIMChatManagerWrapper

+ (instancetype)sharedWrapper
{
    static NIMChatManagerWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMChatManagerWrapper alloc] init];
    });
    return instance;
}

- (BOOL)sendMessage:(NIMMessage *)message
          toSession:(NIMSession *)session
              error:(NSError **)error
{
    NIMAPITrace();
    NIMChatManager *manager = [NIMChatManager sharedManager];
    if (manager) {
        return [manager sendMessage:message
                          toSession:session
                              error:error];
    }
    else{
        if (error) {
            *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
        }
        return NO;
    }
}

- (BOOL)resendMessage:(NIMMessage *)message
                error:(NSError **)error
{
    NIMAPITrace();
    NIMChatManager *manager = [NIMChatManager sharedManager];
    if (manager) {
        return [manager resendMessage:message
                                error:error];
    }
    else{
        if (error) {
            *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
        }
        return NO;
    }
}

- (void)sendMessageReceipt:(NIMMessageReceipt *)receipt
                completion:(NIMSendMessageReceiptBlock)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
    
        NIMChatManager *manager = [NIMChatManager sharedManager];
        if (manager) {
            [manager sendMessageReceipt:receipt
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



- (BOOL)fetchMessageAttachment:(NIMMessage *)message
                         error:(NSError **)error
{
    NIMAPITrace();
    NIMChatManager *manager = [NIMChatManager sharedManager];
    if (manager) {
        return [manager fetchMessageAttachment:message
                                         error:error];
    }
    else{
        if (error) {
            *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
        }
        return NO;
    }
}


- (BOOL)messageInTransport:(NIMMessage *)message
{
    return [[NIMChatManager sharedManager] messageInTransport:message];
}

- (CGFloat)messageTransportProgress:(NIMMessage *)message
{
    return [[NIMChatManager sharedManager] messageTransportProgress:message];
}


- (void)addDelegate:(id<NIMChatManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] addDelegate:delegate
                                          forType:NIMDelegateTypeChat];
}

- (void)removeDelegate:(id<NIMChatManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] removeDelegate:delegate
                                             forType:NIMDelegateTypeChat];
}


@end
