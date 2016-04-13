//
//  NIMTestSystemNotificationMaker.m
//  NIMLib
//
//  Created by amao on 12/30/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMTestSystemNotificationMaker.h"
#import "NIMSDK.h"
#import "NIMSystemNotificationManager.h"
#import "NIMSystemNotification_Priviate.h"
#import "NIMDispatch.h"


@interface NIMTestSystemNotificationMaker ()
@end

@implementation NIMTestSystemNotificationMaker
- (instancetype)init
{
    if (self = [super init])
    {

    }
    return self;
}

- (void)setUp
{

    
    [[[NIMSDK sharedSDK] systemNotificationManager] deleteAllNotifications];
    
    
    NIMSystemNotificationManager *manager = [NIMSystemNotificationManager sharedManager];

    NSDictionary *notificationCount = @{@(NIMSystemNotificationTypeTeamApply) : @(arc4random() % 10 + 5),
                                        @(NIMSystemNotificationTypeTeamApplyReject) : @(arc4random() % 10 + 5),
                                        @(NIMSystemNotificationTypeTeamInvite) : @(arc4random() % 10 + 5),
                                        @(NIMSystemNotificationTypeTeamIviteReject) : @(arc4random() % 10 + 5),
                                        @(NIMSystemNotificationTypeFriendAdd) : @(arc4random() % 10 + 5)};
    
    NSMutableDictionary *notifications = [NSMutableDictionary dictionary];
    
    for (NSNumber *type in notificationCount)
    {
        NSMutableArray *notificationsThisType = [NSMutableArray array];
        NSInteger count = [[notificationCount objectForKey:type] integerValue];
        for (NSInteger i = 0; i < count; i++)
        {
            NIMSystemNotification *notification = [[NIMSystemNotification alloc] init];
            notification.type           = [type integerValue];
            notification.timestamp      = [[NSDate date] timeIntervalSince1970];
            notification.sourceID       = @"111";
            notification.targetID       = @"222";
            notification.msgId          = [self generateMsgId];
            usleep(10000);
            
            if ([manager saveNotification:notification])
            {
                [notificationsThisType addObject:notification];
            }
        }
        
        [notifications setObject:[notificationsThisType copy]
                          forKey:type];
    }
    nim_io_sync_safe(^{
        [manager queryUnreadCount];
    });
    _notifications = [notifications copy];
}

- (void)tearDown
{
    [[[NIMSDK sharedSDK] systemNotificationManager] deleteAllNotifications];
}


- (void)dealloc
{
    [self tearDown];
}


- (int64_t)generateMsgId
{
    static int64_t msgId = (int64_t)([[NSDate date] timeIntervalSince1970] * 1000);
    msgId++;
    return msgId;
}
@end
