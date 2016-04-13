//
//  NIMTestSendMsg.m
//  NIMLib
//
//  Created by amao on 1/26/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMTestSendMsg.h"
#import "NIMUtil.h"

#define NIMTestClientMessageID  @"msgid"

@implementation NIMTestSendMsg
- (NSString *)name
{
    return @"/msg/sendMsg.action";
}

- (NSDictionary *)dict
{
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"from"]   = _from;
    dict[@"to"]     = _to;
    dict[@"ope"]    = [NSString stringWithFormat:@"%zd",_sessionType];
    dict[@"type"]   = [NSString stringWithFormat:@"%zd",_messageType];
    dict[@"body"]   = [self bodyByType:_messageType];
    dict[@"ext"]    = [self ext];
    
    
    return dict;
}

- (NSString *)ext
{
    NSDictionary *dict = @{NIMTestClientMessageID : _clientMessageId};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:0];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)bodyByType:(NIMMessageType)type
{
    NSDictionary *dict = [self dictByType:type];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:0];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)dictByType:(NIMMessageType)type
{
    NSDictionary *dict = nil;
    switch (type) {
        case NIMMessageTypeText:
            dict = [self dictByText];
            break;
        case NIMMessageTypeImage:
            dict = [self dictByImage];
            break;
        case NIMMessageTypeAudio:
            dict = [self dictByAudio];
            break;
        case NIMMessageTypeVideo:
            dict = [self dictByVideo];
            break;
        case NIMMessageTypeFile:
            dict = [self dictByFile];
            break;
        case NIMMessageTypeLocation:
            dict = [self dictbyLocation];
            break;
        case NIMMessageTypeTip:
            dict = [self dictByTip];
            break;
        case NIMMessageTypeCustom:
            dict = [self dictByCustom];
            break;
        default:
            dict = @{};
            break;
    }
    return dict;
}

- (NSDictionary *)dictByText
{
    return @{@"msg" : @"hello nim sdk"};
}

- (NSDictionary *)dictByImage
{
    return @{@"size":@(10231),
             @"ext":@"jpg",
             @"w":@(400),
             @"url":@"http://b12026.nos.netease.com/MTAxMTAxMA==/bmltYV8yMDE2NzlfMTQ1MTQ1NTU3NTU4N185Mjg1N2MzMC1hMGNkLTRjYTEtOTRmNy1kNjc0YjI3MjM3Mjg=",
             @"md5":@"cc29cce959914d1e0a62f0f6478bdac2",
             @"h":@(400)};
}

- (NSDictionary *)dictByAudio
{
    return @{@"size":@(20399),
             @"ext":@"aac",
             @"dur":@(5619),
             @"url":@"http://b12026.nos.netease.com/MTAxMTAxMA==/bmltYV8yMDE2NzlfMTQ1MTQ1NTU3NTU4N18wMjU5OWI1ZC1lYjcyLTRlZTItYTVlMC04MmQ1M2QyZDE0OTY=",
             @"md5":@"6c4ffccf991d7346707f91f417b29069"};
}

- (NSDictionary *)dictByVideo
{
    return @{@"url":@"http://b12026.nos.netease.com/MTAxMTAxMA==/bmltYV8yMDE2NzlfMTQ1MTQ1NTU3NTU4N18wNWI1Y2UxNi1iMWY5LTQzNzQtYjI0Ni05MzUwY2ViNDZkZGU=",
             @"md5":@"f67114a4486c3b22bc6b29d61a27f3dd",
             @"ext":@"mp4",
             @"h":@(360),
             @"size":@(741442),
             @"w":@(480),
             @"dur":@(7238)};
}

- (NSDictionary *)dictbyLocation
{
    return @{@"title":@"地理位置消息",
             @"lat":@(37.787359),
             @"lng":@(-122.408227)};
}

- (NSDictionary *)dictByFile
{
    return @{@"name": @"filename",
             @"size":@(1785436),
             @"ext":@"pdf",
             @"url":@"http://b12026.nos.netease.com/MTAxMTAxMA==/bmltYV8yMDE2NzlfMTQ1MTQ1NTU3NTU4N185OTE2ZmVkZS03MDM0LTQ2ZDUtODM1My03MzYwNTYxYzY1Yjg=",
             @"md5":@"fc06122657a909f19e4064fc2c03171c"};
}

- (NSDictionary *)dictByTip
{
    return @{};
}

- (NSDictionary *)dictByCustom
{
    return @{@"type" : @(1)};
}
@end


@implementation NIMMessage (NIMTest)

- (NSString *)clientMessageId
{
    return self.remoteExt[NIMTestClientMessageID];
}

@end


@implementation NIMChatroomTestSendMsg

- (NSString *)name
{
    return @"/chatroom/sendMsg.action";
}

- (NSDictionary *)dict
{
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"fromAccid"] = self.from;
    dict[@"roomid"]    = self.to;
    dict[@"msgId"]     = [NIMUtil uuid];
    dict[@"ope"]       = [NSString stringWithFormat:@"%zd",self.sessionType];
    dict[@"msgType"]   = [NSString stringWithFormat:@"%zd",self.messageType];
    dict[@"attach"]    = [self bodyByType:self.messageType];
    dict[@"ext"]       = [self ext];
    
    
    return dict;
}

@end
