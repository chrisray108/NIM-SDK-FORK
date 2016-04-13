 //
//  NIMSystemNotificationReceiver.m
//  NIMLib
//
//  Created by amao on 15/4/23.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMSystemNotificationReceiver.h"
#import "NIMSystemNotification_Priviate.h"
#import "NIMCustomSystemNotification_Private.h"
#import "NIMDispatch.h"
#import "session_protocol.h"
#import "NIMSystemNotificationManager.h"



@interface NIMSystemNotificationReceiver ()
@property (nonatomic,strong)    NSMutableArray *sysNotifications;
@property (nonatomic,strong)    NSMutableArray *customNotifications;
@end

@implementation NIMSystemNotificationReceiver
- (instancetype)init
{
    if (self = [super init])
    {
        _sysNotifications = [NSMutableArray array];
        _customNotifications = [NSMutableArray array];
    }
    return self;
}


- (void)receiveNotifications:(std::vector<nimbiz::Property> &)msgs
{
    for (NSInteger i = 0; i < msgs.size(); i ++)
    {
        @autoreleasepool
        {
            nimbiz::Property &messageProperty = msgs[i];
            NIMSystemNotificationType type      = messageProperty.get_int32(nimbiz::NIMSystemMsgTagType);
            if (![self typeCanBeHandled:type])
            {
                NIMAssert();
                continue;
            }
            switch (type) {
                case NIMCustomSystemNotificationTypeP2P:
                case NIMCustomSystemNotificationTypeTeam:
                    [self handleCustomnSystemNotification:messageProperty];
                    break;
                default:
                    [self handleSystemNotification:messageProperty
                                              type:type];
                    break;
            }
        }
    }
    [self saveAndFireSysNotifications];
    [self fireCustomNotifications];
}




- (BOOL)typeCanBeHandled:(NIMSystemNotificationType)type
{
    static NSDictionary *supportedTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        supportedTypes = @{ @(NIMSystemNotificationTypeTeamApply)       : [NSNull null],
                            @(NIMSystemNotificationTypeTeamApplyReject) : [NSNull null],
                            @(NIMSystemNotificationTypeTeamInvite)      : [NSNull null],
                            @(NIMSystemNotificationTypeTeamIviteReject) : [NSNull null],
                            @(NIMSystemNotificationTypeFriendAdd)       : [NSNull null],
                            @(NIMSystemNotificationTypeFriendDelete)    : [NSNull null],
                            @(NIMCustomSystemNotificationTypeP2P)       : [NSNull null],
                            @(NIMCustomSystemNotificationTypeTeam)      : [NSNull null],
                           };
    });
    return [supportedTypes objectForKey:@(type)] != nil;
}

#pragma mark - 自定义系统通知
- (void)handleCustomnSystemNotification:(const nimbiz::Property &)property
{
    
    NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithPorperty:property];
    [_customNotifications addObject:notification];

}

- (void)fireCustomNotifications
{
    if ([_customNotifications count] == 0)
    {
        return;
    }
    [_customNotifications sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
        if ([(NIMCustomSystemNotification *)obj1 timestamp] ==  [(NIMCustomSystemNotification *)obj2 timestamp])
        {
            return [(NIMCustomSystemNotification *)obj1 msgId] < [(NIMCustomSystemNotification *)obj2 msgId] ? NSOrderedAscending : NSOrderedDescending;
        }
        else
        {
            return [(NIMCustomSystemNotification *)obj1 timestamp] < [(NIMCustomSystemNotification *)obj2 timestamp] ? NSOrderedAscending : NSOrderedDescending;
        }
        
    }];
    
    for (NIMCustomSystemNotification *notification in _customNotifications)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NIMSystemNotificationManager sharedManager] onReceiveCustomSystemNotification:notification];
        });
    }
}

#pragma mark - 系统通知
- (void)handleSystemNotification:(const nimbiz::Property &)property
                            type:(NIMSystemNotificationType)type
{
    NIMSystemNotification *notification = [[NIMSystemNotification alloc] initWithPorperty:property];
    [notification saveDataAfterReceiving:_onlineNotification];
    
    if ([notification canSave])
    {
        [_sysNotifications addObject:notification];
    }
    
}


- (void)saveAndFireSysNotifications
{
    if ([_sysNotifications count] == 0)
    {
        return;
    }
    
    [_sysNotifications sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        if ([(NIMSystemNotification *)obj1 timestamp] == [(NIMSystemNotification *)obj2 timestamp])
        {
            return [(NIMSystemNotification *)obj1 msgId] < [(NIMSystemNotification *)obj2 msgId] ? NSOrderedAscending : NSOrderedDescending;
        }
        else
        {
            return [(NIMSystemNotification *)obj1 timestamp] < [(NIMSystemNotification *)obj2 timestamp] ? NSOrderedAscending : NSOrderedDescending;
        }
    }];
    
    for (NIMSystemNotification *notification in _sysNotifications)
    {
        if ([[NIMSystemNotificationManager sharedManager] saveNotification:notification])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NIMSystemNotificationManager sharedManager]  onReceiveSystemNotification:notification];
            });
        }
    }
    nim_io_async(^{
        [[NIMSystemNotificationManager sharedManager] queryUnreadCount];
    });
    
}

@end
