//
//  NIMCustomSystemNotificationSetting.m
//  NIMLib
//
//  Created by chris on 15/11/27.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMCustomSystemNotificationSetting_Private.h"
#import "session_protocol.h"

@implementation NIMCustomSystemNotificationSetting

- (instancetype)init
{
    if (self = [super init])
    {
        _shouldBeCounted = YES;
        _apnsEnabled     = YES;
        _apnsWithPrefix  = NO;
    }
    return self;
}

+ (instancetype)settingByProperty:(const nimbiz::Property &)messageProperty
{
    NIMCustomSystemNotificationSetting *instance = nil;
    BOOL valid = messageProperty.has_tag(nimbiz::NIMSystemMsgTagApnsEnable) ||
    messageProperty.has_tag(nimbiz::NIMSystemMsgTagShouldBeCounted) ||
    messageProperty.has_tag(nimbiz::NIMSystemMsgTagNeedPushNick);
    if (valid)
    {
        instance = [[NIMCustomSystemNotificationSetting alloc] init];
        instance.shouldBeCounted = messageProperty.get_uint32(nimbiz::NIMSystemMsgTagShouldBeCounted);
        instance.apnsEnabled     = messageProperty.get_uint32(nimbiz::NIMSystemMsgTagApnsEnable);
        instance.apnsWithPrefix  = messageProperty.get_uint32(nimbiz::NIMSystemMsgTagNeedPushNick);
    }
    return instance;
    
}


- (nimbiz::Property)settingProperty
{
    nimbiz::Property settingProperty;
    
    settingProperty.put_uint32(nimbiz::NIMSystemMsgTagShouldBeCounted, _shouldBeCounted);
    settingProperty.put_uint32(nimbiz::NIMSystemMsgTagApnsEnable, _apnsEnabled);
    settingProperty.put_uint32(nimbiz::NIMSystemMsgTagNeedPushNick, _apnsWithPrefix);
    
    return settingProperty;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"shouldBeCounted %d apnsEnabled %d apnsWithPrefix %d",
            _shouldBeCounted,_apnsEnabled,_apnsWithPrefix];
}


@end
