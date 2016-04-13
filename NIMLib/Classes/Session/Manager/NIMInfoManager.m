//
//  NIMInfoManager.m
//  NIMLib
//
//  Created by amao on 3/19/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMInfoManager.h"
#import "NIMMessage_Private.h"
#import "NIMKeyValueStore.h"
#import "NIMPathManager.h"
#import "NSDictionary+NIMJson.h"


@interface NIMInfo : NSObject
@property (nonatomic,copy)  NSString    *name;
@end

@implementation NIMInfo
+ (NIMInfo *)infoByData:(NSDictionary *)dict
{
    NIMInfo *info = [[NIMInfo alloc] init];
    info.name = [dict nim_jsonString:@"name"];
    return info;
}
- (NSString *)toValue
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([_name length])
    {
        [dict setObject:_name
                 forKey:@"name"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}
@end

@interface NIMInfoManager ()
@property (nonatomic,strong)    NSMutableDictionary *infos;
@property (nonatomic,strong)    NIMKeyValueStore *store;
@property (nonatomic,strong)    NSRecursiveLock *lock;
@end

@implementation NIMInfoManager

- (instancetype)init
{
    if (self = [super init])
    {
        _infos = [NSMutableDictionary dictionary];
        NSString *path = [[[NIMPathManager sharedManager] sdkCurrentUserDir] stringByAppendingPathComponent:@"infos.db"];
        _store = [NIMKeyValueStore storeByPath:path];
        
        NSArray *array = [_store allObjects];
        for (id<NIMKeyValueProtocol>object in array)
        {
            NSString *dataString = [object value];
            NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:nil];
                if ([dict isKindOfClass:[NSDictionary class]])
                {
                    NIMInfo *info = [NIMInfo infoByData:dict];
                    NSString *key = [object key];
                    if ([key length] && info)
                    {
                        [_infos setObject:info
                                   forKey:key];
                    }
                }
            }
        }
        _lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (NSString *)senderNameByMessage:(NIMMessage *)message
{
    NSString *key = [self keyByMessage:message];
    return key ? [self nameByKey:key] : nil;
}



- (void)saveSenderName:(NSString *)name
            forMessage:(NIMMessage *)message
{
    if ([name length])
    {
        NIMInfo *info = [[NIMInfo alloc] init];
        info.name = name;
        NSString *value = [info toValue];
        NSString *key = [self keyByMessage:message];
        
        
        if ([key length] && [value length])
        {
            NIMKeyValueItem *item = [[NIMKeyValueItem alloc] init];
            item.key = key;
            item.value = value;
            [_store storeObject:item];
            
            [_lock lock];
            [_infos setObject:info
                       forKey:key];
            [_lock unlock];
        }
    }
}

#pragma mark - misc
- (NSString *)nameByKey:(NSString *)key
{
    NSString *name = nil;
    [_lock lock];
    name = [[_infos objectForKey:key] name];
    [_lock unlock];
    return name;
}

- (NSString *)keyByMessage:(NIMMessage *)message
{
    NSString *key = nil;
    NIMSession *session = message.session;
    NSString *userId = message.from;
    if (session.sessionType == NIMSessionTypeP2P)
    {
        key = [NSString stringWithFormat:@"info_%@",userId];
    }
    else if (session.sessionType == NIMSessionTypeTeam)
    {
        key = [NSString stringWithFormat:@"tinfo_%@_%@",session.sessionId,userId];
    }
    else
    {
        key = @"invliad_info_key";
        NIMAssert();
    }
    return key;
}
@end
