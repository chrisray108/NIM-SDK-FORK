//
//  NIMSystemNotificationManager.h
//  NIMLib
//
//  Created by amao on 3/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIMManager.h"
#import "NIMSystemNotificationManagerProtocol.h"


@interface NIMSystemNotificationManager : NIMManager

#pragma mark - 对外接口
- (NSArray *)fetchSystemNotifications:(NIMSystemNotification *)notification
                                limit:(NSInteger)limit
                               filter:(NIMSystemNotificationFilter *)filter;

- (NSInteger)allUnreadCount:(NIMSystemNotificationFilter *)filter;

- (void)deleteNotification:(NIMSystemNotification *)notification;

- (void)deleteAllNotifications:(NIMSystemNotificationFilter *)filter;

- (void)markNotificationsAsRead:(NIMSystemNotification *)notification;

- (void)markAllNotificationsAsRead:(NIMSystemNotificationFilter *)filter;

- (void)sendCustomNotification:(NIMCustomSystemNotification *)notification
                     toSession:(NIMSession *)session
                    completion:(NIMSystemNotificationHandler)completion;


#pragma mark - SDK内部接口
- (BOOL)saveNotification:(NIMSystemNotification *)notification;

- (void)updateNotificationStatus:(NIMSystemNotification *)notification;
- (void)updateNotificationSubStatus:(NIMSystemNotification *)notification;

- (void)onReceiveSystemNotification:(NIMSystemNotification *)notification;
- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification;

- (void)queryUnreadCount;
@end

namespace nimbiz
{
    struct IAsynCallbackParam;
    void    CallbackRecvSysMsgs(struct IAsynCallbackParam *msgParam);                           //收到系统消息
    void    CallbackSendCustomNotification(struct IAsynCallbackParam *msgParam);               //自定义通知ACK
}



