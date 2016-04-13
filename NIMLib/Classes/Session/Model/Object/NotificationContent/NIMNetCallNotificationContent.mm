//
//  NIMNetCallNotificationContent.m
//  NIMLib
//
//  Created by amao on 7/23/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMNetCallNotificationContent_Private.h"
#import "NSDictionary+NIMJson.h"

#pragma mark - 网络通话通知
@implementation NIMNetCallNotificationContent
- (BOOL)decode:(NSDictionary *)jsonBody
{
    BOOL decodeSuccess = NO;
    if ([jsonBody objectForKey:@"id"])
    {
        decodeSuccess = YES;
        NSDictionary *data = [jsonBody nim_jsonDict:@"data"];
        NIMNetCallEventType type = [jsonBody nim_jsonInteger:@"id"];
        self.eventType = type;
        switch (self.eventType) {
            case NIMNetCallEventTypeBill:
                self.duration = [data nim_jsonUnsignedLongLong:@"duration"];
                break;
            case NIMNetCallEventTypeMiss:
            case NIMNetCallEventTypeReject:
            case NIMNetCallEventTypeNoResponse:
                self.from = [data nim_jsonString:@"from"];
                break;
            default:
                NIMAssert();
                decodeSuccess = NO;
                break;
        }
        self.callType = [data nim_jsonInteger:@"calltype"];
        self.callID = [data nim_jsonLongLong:@"channel"];
        self.timetag = NIMTimeLongToDouble([data nim_jsonUnsignedLongLong:@"time"]);;
    }
    else
    {
        NIMAssert();
    }
    return decodeSuccess;
}

- (NIMNotificationType)notificationType
{
    return NIMNotificationTypeNetCall;
}

@end
