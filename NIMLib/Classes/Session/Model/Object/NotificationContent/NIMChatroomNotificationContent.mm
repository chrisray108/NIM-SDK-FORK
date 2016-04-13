//
//  NIMChatroomNotificationContent.m
//  NIMLib
//
//  Created by chris on 16/1/8.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomNotificationContent_Private.h"
#import "NSDictionary+NIMJson.h"

@implementation NIMChatroomNotificationContent

- (BOOL)decode:(NSDictionary *)jsonBody
{
    BOOL decodeSuccess = NO;
    if ([jsonBody objectForKey:@"id"])
    {
        _eventType = [jsonBody nim_jsonInteger:@"id"];
        NIMLogApp(@"notify id %zd",_eventType);
        NSDictionary *data = [jsonBody nim_jsonDict:@"data"];
        [self decodeUsers:data];
        [self decodeExt:data];
        decodeSuccess = YES;
    }
    else
    {
        NIMLogErr(@"invalid chatroom notification");
        NIMAssert();
    }
    return decodeSuccess;
}


- (NIMNotificationType)notificationType
{
    return NIMNotificationTypeChatroom;
}


#pragma mark - Private

- (void)decodeUsers:(NSDictionary *)data{
    NSString *sourceId = [data nim_jsonString:@"operator"];
    if (sourceId.length) {
        NIMChatroomNotificationMember *source = [[NIMChatroomNotificationMember alloc] init];
        source.userId = sourceId;
        source.nick   = [data nim_jsonString:@"opeNick"];
    }
    
    NSArray *targetIds   = [data nim_jsonArray:@"target"];
    NSArray *targetNicks = [data nim_jsonArray:@"tarNick"];
    if (targetIds.count == targetNicks.count)
    {
        NSMutableArray *targets = [[NSMutableArray alloc] init];
        for (NSInteger index=0; index<targetIds.count; index++) {
            NSString *targetId = targetIds[index];
            if (targetId.length) {
                NIMChatroomNotificationMember *target = [[NIMChatroomNotificationMember alloc] init];
                target.userId = targetId;
                target.nick = targetNicks[index];
                [targets addObject:target];
            }
        }
        _targets = targets.count ? [[NSArray alloc] initWithArray:targets] : nil;
    }
    else
    {
        NIMLogApp(@"error notify data %@",data);
    }
}

- (void)decodeExt:(NSDictionary *)data{
    NSString *ext = [data nim_jsonString:@"ext"];
    NSData *jsonData = [ext dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            _notifyExt = dict;
        }
    }
}

@end


@implementation NIMChatroomNotificationMember

@end
