//
//  NIMLoginClient.m
//  NIMLib
//
//  Created by amao on 4/22/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMLoginClient_Private.h"
#import "auth_protocol.h"

@implementation NIMLoginClient
- (instancetype)initWithProperty:(const nimbiz::Property &)property
{
    if (self = [super init])
    {
        _deviceId   = NSUTF8(property.get_string(nimbiz::NIMAuthTagDeviceID));
        _type       = (NIMLoginClientType)property.get_uint32(nimbiz::NIMAuthTagClientType);
        _os         = NSUTF8(property.get_string(nimbiz::NIMAuthTagOS));
        _timestamp  = NIMTimeLongToDouble(property.get_uint64(nimbiz::NIMAuthTagLoginTime));
    }
    return self;
}
@end


@implementation NIMAutoLoginData

- (NSString *)description
{
    return [NSString stringWithFormat:@"account %@ forced mode %d",_account,_forcedMode];
}
@end