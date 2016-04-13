//
//  NIMTestSystemNotificationUtil.m
//  NIMLib
//
//  Created by amao on 12/30/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMTestSystemNotificationUtil.h"
#import "NIMSystemNotification_Priviate.h"

@implementation NIMTestSystemNotificationUtil
+ (BOOL)notification:(NIMSystemNotification *)notification
           isEqualTo:(NIMSystemNotification *)other
{
    return notification.serial == other.serial &&
           notification.serial != 0 &&
           notification.msgId == other.msgId &&
           notification.msgId != 0;
}

+ (BOOL)notifications:(NSArray *)notifications
              contain:(NIMSystemNotification *)notification
{
    BOOL contain = NO;
    for (NIMSystemNotification *item in notifications)
    {
        if ([self notification:notification isEqualTo:item])
        {
            contain = YES;
            break;
        }
    }
    return contain;
}

+ (BOOL)notifications:(NSArray *)notifications
           areEqualTo:(NSArray *)others
{
    if ([notifications count] == 0 || [others count] == 0)
    {
        return NO;
    }
    
    NSArray *one = [notifications sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [(NIMSystemNotification *)obj1 serial] > [(NIMSystemNotification *)obj2 serial] ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSArray *another = [others sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [(NIMSystemNotification *)obj1 serial] > [(NIMSystemNotification *)obj2 serial] ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    BOOL same = [one count] == [another count];
    if (same)
    {
        for (NSInteger i = 0; i < [one count]; i++)
        {
            NIMSystemNotification *notification1 = [one objectAtIndex:i];
            NIMSystemNotification *notification2 = [another objectAtIndex:i];
            
            if (![self notification:notification1
                isEqualTo:notification2])
            {
                same = NO;
            }
        }
    }
    return same;
}
@end
