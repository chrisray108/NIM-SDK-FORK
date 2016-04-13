//
//  NIMMessageSetting.m
//  NIMLib
//
//  Created by amao on 11/9/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMMessageSetting_Private.h"
#import "session_protocol.h"
#import "NSDictionary+NIMJson.h"

@implementation NIMMessageSetting

- (instancetype)init
{
    if (self = [super init])
    {
        _historyEnabled = YES;
        _roamingEnabled = YES;
        _syncEnabled    = YES;
        _shouldBeCounted= YES;
        _apnsWithPrefix = YES;
        _apnsEnabled    = YES;
    }
    return self;
}

+ (instancetype)settingByProperty:(const nimbiz::Property &)messageProperty
{
    NIMMessageSetting *instance = nil;
    BOOL valid = messageProperty.has_tag(nimbiz::NIMSessionTagHisotryEnable) ||
                 messageProperty.has_tag(nimbiz::NIMSessionTagRoamingEnable) ||
                 messageProperty.has_tag(nimbiz::NIMSessionTagSelfSyncEnable) ||
                 messageProperty.has_tag(nimbiz::NIMSessionTagShouldBeCounted) ||
                 messageProperty.has_tag(nimbiz::NIMSessionTagNeedPushNick) ||
                 messageProperty.has_tag(nimbiz::NIMSessionTagPushEnable);
    if (valid)
    {
        instance = [[NIMMessageSetting alloc] init];
        instance.historyEnabled = messageProperty.get_uint32(nimbiz::NIMSessionTagHisotryEnable);
        instance.roamingEnabled = messageProperty.get_uint32(nimbiz::NIMSessionTagRoamingEnable);
        instance.syncEnabled    = messageProperty.get_uint32(nimbiz::NIMSessionTagSelfSyncEnable);
        instance.shouldBeCounted= messageProperty.get_uint32(nimbiz::NIMSessionTagShouldBeCounted);
        instance.apnsWithPrefix = messageProperty.get_uint32(nimbiz::NIMSessionTagNeedPushNick);
        instance.apnsEnabled    = messageProperty.get_uint32(nimbiz::NIMSessionTagPushEnable);
    }
    return instance;
    
}


- (nimbiz::Property)settingProperty
{
    nimbiz::Property settingProperty;
    
    settingProperty.put_uint32(nimbiz::NIMSessionTagHisotryEnable, _historyEnabled);
    settingProperty.put_uint32(nimbiz::NIMSessionTagRoamingEnable, _roamingEnabled);
    settingProperty.put_uint32(nimbiz::NIMSessionTagSelfSyncEnable, _syncEnabled);
    settingProperty.put_uint32(nimbiz::NIMSessionTagShouldBeCounted, _shouldBeCounted);
    settingProperty.put_uint32(nimbiz::NIMSessionTagNeedPushNick, _apnsWithPrefix);
    settingProperty.put_uint32(nimbiz::NIMSessionTagPushEnable, _apnsEnabled);
    return settingProperty;
}


+ (instancetype)settingByJsonData:(NSData *)data
{
    NIMMessageSetting *instance = nil;
    if (data)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            instance = [[NIMMessageSetting alloc] init];
            instance.historyEnabled = [dict nim_jsonBool:@"history"
                                            defaultValue:YES];
            instance.roamingEnabled = [dict nim_jsonBool:@"roaming"
                                            defaultValue:YES];
            instance.syncEnabled    = [dict nim_jsonBool:@"sync"
                                            defaultValue:YES];
            instance.shouldBeCounted= [dict nim_jsonBool:@"count"
                                            defaultValue:YES];
            instance.apnsWithPrefix = [dict nim_jsonBool:@"apns_prefix"
                                            defaultValue:YES];
            instance.apnsEnabled    = [dict nim_jsonBool:@"apns_enabled"
                                            defaultValue:YES];
        }
    }
    return instance;
}


- (NSData *)toJsonData
{
    NSDictionary *dict = @{@"history"           : @(_historyEnabled),
                           @"roaming"           : @(_roamingEnabled),
                           @"sync"              : @(_syncEnabled),
                           @"count"             : @(_shouldBeCounted),
                           @"apns_prefix"       : @(_apnsWithPrefix),
                           @"apns_enabled"      : @(_apnsEnabled)};
    return [NSJSONSerialization dataWithJSONObject:dict
                                           options:0
                                             error:nil];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[NIMMessageSetting class]]) {
        return NO;
    }
    NIMMessageSetting *setting = object;
    return setting.historyEnabled  == _historyEnabled &&
           setting.roamingEnabled  == _roamingEnabled &&
           setting.syncEnabled     == _syncEnabled &&
           setting.shouldBeCounted == _shouldBeCounted &&
           setting.apnsWithPrefix  == _apnsWithPrefix &&
           setting.apnsEnabled     == _apnsEnabled;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"hisotry %d roaming %d sync %d count %d apns_prefix %d apns_enabled %d",
            _historyEnabled,_roamingEnabled,_syncEnabled,_shouldBeCounted,_apnsWithPrefix,_apnsEnabled];
}
@end
