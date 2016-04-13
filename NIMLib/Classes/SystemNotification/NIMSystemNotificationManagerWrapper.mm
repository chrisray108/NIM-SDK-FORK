//
//  NIMSystemNotificationManagerWrapper.m
//  NIMLib
//
//  Created by amao on 8/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSystemNotificationManagerWrapper.h"
#import "NIMSystemNotificationManager.h"
#import "NIMDelegateCenter.h"
#import "NIMDispatch.h"
#import "NIMSessionPersistValidator.h"


@implementation NIMSystemNotificationManagerWrapper

+ (instancetype)sharedWrapper
{
    static NIMSystemNotificationManagerWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMSystemNotificationManagerWrapper alloc] init];
    });
    return instance;
}

- (NSArray *)fetchSystemNotifications:(NIMSystemNotification *)notification
                                limit:(NSInteger)limit
{
    return [self fetchSystemNotifications:notification
                                    limit:limit
                                   filter:nil];
}

- (NSArray *)fetchSystemNotifications:(NIMSystemNotification *)notification
                                limit:(NSInteger)limit
                               filter:(NIMSystemNotificationFilter *)filter
{
    return [[NIMSystemNotificationManager sharedManager] fetchSystemNotifications:notification
                                                                            limit:limit
                                                                           filter:filter];
}


- (NSInteger)allUnreadCount
{
    return [self allUnreadCount:nil];
}

- (NSInteger)allUnreadCount:(NIMSystemNotificationFilter *)filter
{
    return [[NIMSystemNotificationManager sharedManager] allUnreadCount:filter];
}


- (void)deleteNotification:(NIMSystemNotification *)notification
{
    return [[NIMSystemNotificationManager sharedManager] deleteNotification:notification];
}


- (void)deleteAllNotifications
{
    [self deleteAllNotifications:nil];
}

- (void)deleteAllNotifications:(NIMSystemNotificationFilter *)filter
{
    [[NIMSystemNotificationManager sharedManager] deleteAllNotifications:filter];
}


- (void)markNotificationsAsRead:(NIMSystemNotification *)notification
{
    [[NIMSystemNotificationManager sharedManager] markNotificationsAsRead:notification];
}

- (void)markAllNotificationsAsRead
{
    [self markAllNotificationsAsRead:nil];
 
}

- (void)markAllNotificationsAsRead:(NIMSystemNotificationFilter *)filter
{
    [[NIMSystemNotificationManager sharedManager] markAllNotificationsAsRead:filter];
}



- (void)sendCustomNotification:(NIMCustomSystemNotification *)notification
                     toSession:(NIMSession *)session
                    completion:(NIMSystemNotificationHandler)completion
{
    NIMAPITrace();
    
    dispatch_block_t mainBlock = ^(){
        

        if (![[NIMSessionPersistValidator validator:session] isValid])
        {
            if (completion) {
                completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
            }
            return;
        }
        
        NIMSystemNotificationManager *manager = [NIMSystemNotificationManager sharedManager];
        if (manager) {
            [manager sendCustomNotification:notification
                                  toSession:session
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

- (void)addDelegate:(id<NIMSystemNotificationManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] addDelegate:delegate
                                          forType:NIMDelegateTypeNotification];
}

- (void)removeDelegate:(id<NIMSystemNotificationManagerDelegate>)delegate
{
    NIMAPITrace();
    
    [[NIMDelegateCenter sharedCenter] removeDelegate:delegate
                                             forType:NIMDelegateTypeNotification];
}


@end
