//
//  NIMNotificationContent.m
//  NIMLib
//
//  Created by amao on 7/23/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMNotificationContent_Private.h"
#import "NIMUnsupportedNotificationContent.h"

@implementation NIMNotificationContent
- (BOOL)decode:(NSDictionary *)jsonBody
{
    NIMAssert();
    return NO;
}

- (NIMNotificationType)notificationType
{
    NIMAssert();
    return NIMNotificationTypeUnsupport;
}
@end


@implementation NIMUnsupportedNotificationContent

- (BOOL)decode:(NSDictionary *)jsonBody
{
    NIMLogApp(@"get unsupported notification %@",jsonBody);
    return NO;
}

- (NIMNotificationType)notificationType
{
    return NIMNotificationTypeUnsupport;
}

@end