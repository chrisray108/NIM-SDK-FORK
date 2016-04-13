//
//  NIMConversationManagerWrapper.m
//  NIMLib
//
//  Created by chris on 15/8/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMConversationManagerWrapper.h"
#import "NIMConversationManager.h"
#import "NIMMacros.h"
#import "NIMGlobalDefs.h"
#import "NIMDelegateCenter.h"
#import "NIMDispatch.h"
#import "NIMMessage_Private.h"
#import "NIMSession_Private.h"
#import "NIMRecentSession_Private.h"
#import "NIMArrayValidator.h"
#import "NIMSessionPersistValidator.h"
#import "NIMMessageSearchOption.h"

@implementation NIMConversationManagerWrapper

+ (instancetype)sharedWrapper
{
    static NIMConversationManagerWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMConversationManagerWrapper alloc] init];
    });
    return instance;
}

- (void)deleteMessage:(NIMMessage *)message{
    
    if (![[NIMSessionPersistValidator validator:message] isValid])
    {
        return;
    }

    [[NIMConversationManager sharedManager] deleteMessage:message];
}

- (void)deleteAllmessagesInSession:(NIMSession *)session
               removeRecentSession:(BOOL)removeRecentSession{
    
    if (![[NIMSessionPersistValidator validator:session] isValid])
    {
        return;
    }
    [[NIMConversationManager sharedManager] deleteAllmessagesInSession:session removeRecentSession:removeRecentSession];
}

- (void)deleteAllMessages:(BOOL)removeRecentSessions{
    [[NIMConversationManager sharedManager] deleteAllMessages:removeRecentSessions];
}

- (void)deleteRecentSession:(NIMRecentSession *)recentSession{
    
    if (![[NIMSessionPersistValidator validator:recentSession] isValid])
    {
        return;
    }
    
    [[NIMConversationManager sharedManager] deleteRecentSession:recentSession];
}


- (void)markAllMessagesReadInSession:(NIMSession *)session
{
    if (![[NIMSessionPersistValidator validator:session] isValid])
    {
        return;
    }
    
    [[NIMConversationManager sharedManager] markAllMessagesReadInSession:session];
}


- (void)updateMessage:(NIMMessage *)message
           forSession:(NIMSession *)session
           completion:(NIMUpdateMessageBlock)completion
{
    dispatch_block_t mainBlock = ^(){
    
        if (![[NIMSessionPersistValidator validator:message] isValid])
        {
            if (completion) {
                completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
            }
            return;
        }
        
        NIMConversationManager *manager = [NIMConversationManager sharedManager];
        if (manager) {
            [manager updateMessage:message forSession:session completion:completion];
        }else{
            if (completion) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                completion(error);
            }
        }
        
    };
    
    nim_main_async_safe(mainBlock);
}


- (void)saveMessage:(NIMMessage *)message
         forSession:(NIMSession *)session
         completion:(NIMUpdateMessageBlock)completion
{
    
    dispatch_block_t mainBlock = ^(){
        
        if (![[NIMSessionPersistValidator validator:session] isValid]) {
            if (completion) {
                completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
            }
            return;
        }
        
        
        NIMConversationManager *manager = [NIMConversationManager sharedManager];
        if (manager) {
            [manager saveMessage:message forSession:session completion:completion];
        }else{
            if (completion) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                completion(error);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
    
}


- (NSArray*)messagesInSession:(NIMSession *)session
                      message:(NIMMessage *)message
                        limit:(NSInteger)limit{
    
    if (![[NIMSessionPersistValidator validator:session] isValid])
    {
        return nil;
    }

    
    return [[NIMConversationManager sharedManager] messagesInSession:session message:message limit:limit];
}

- (NSArray *)messagesInSession:(NIMSession *)session
                    messageIds:(NSArray *)messageIds
{
    if (![[NIMSessionPersistValidator validator:session] isValid])
    {
        return nil;
    }

    
    return [[NIMConversationManager sharedManager] messagesInSession:session messageIds:messageIds];
}


- (NSInteger)allUnreadCount{
    __block NSInteger count = 0;
    nim_main_sync_safe(^{
        count = [[NIMConversationManager sharedManager] allUnreadCount];
    });
    return count;
}


- (NSArray*)allRecentSessions{
    __block NSArray *sessions = nil;
    nim_main_sync_safe(^{
        sessions = [[NIMConversationManager sharedManager] allRecentSessions];
    });
    return sessions;
}


- (void)fetchMessageHistory:(NIMSession *)session
                     option:(NIMHistoryMessageSearchOption *)option
                     result:(NIMFetchMessageHistoryBlock)block
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        if (![[NIMSessionPersistValidator validator:session] isValid])
        {
            if (block) {
                block(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
            }
            return;
        }
        
        
        NIMConversationManager *manager = [NIMConversationManager sharedManager];
        if (manager) {
            return [manager fetchMessageHistory:session option:option result:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error,nil);
            }
        }
    };
    nim_main_async_safe(mainBlock);
    
}


- (void)searchMessages:(NIMSession *)session
                option:(NIMMessageSearchOption *)option
                result:(NIMSearchMessageBlock)block{
    
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        if (![[NIMSessionPersistValidator validator:session] isValid]) {
            if (block) {
                block(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
            }
            return;
        }
        
        
        NIMConversationManager *manager = [NIMConversationManager sharedManager];
        if (manager) {
            return [manager searchMessages:session option:option result:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error,nil);
            }
        }
    };
    
    nim_main_async_safe(mainBlock);
    
}


- (void)deleteRemoteSessions:(NSArray *)sessions
                  completion:(NIMRemoveRemoteSessionBlock)block{
    
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        
        NIMArrayValidator *validator = [NIMArrayValidator validator:sessions];
        BOOL valid = [validator allObjectsAreKindOf:[NIMSession class]];
        if (valid)
        {
            for (NIMSession *session in sessions)
            {
                if (![[NIMSessionPersistValidator validator:session] isValid])
                {
                    if (block) {
                        block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
                    }
                    return;
                }
            }
        }
        
        NIMConversationManager *manager = [NIMConversationManager sharedManager];
        if (manager) {
            return [manager deleteRemoteSessions:sessions completion:block];
        }else{
            if (block) {
                NSError *error = NIMLocalError(NIMLocalErrorCodeUserInfoNeeded);
                block(error);
            }
            
        }
        
    };
    
    nim_main_async_safe(mainBlock);
    
}

- (void)addDelegate:(id<NIMConversationManagerDelegate>)delegate{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] addDelegate:delegate
                                          forType:NIMDelegateTypeConversation];
}

- (void)removeDelegate:(id<NIMConversationManagerDelegate>)delegate{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] removeDelegate:delegate
                                             forType:NIMDelegateTypeConversation];
}


@end
