//
//  NIMUser.m
//  NIMLib
//
//  Created by amao on 8/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMUser_Private.h"
#import "NIMSDK_Private.h"
#import "NIMUserInfo_Private.h"
#import "friend_protocol.h"

@implementation NIMUser

- (instancetype)initWithProperty:(const nimbiz::Property &)property{
    self = [super init];
    if (self) {
        _userId = NSUTF8(property.get_string(nimbiz::NIMUListTagId));
        _alias  = NSUTF8(property.get_string(nimbiz::NIMUListTagAlias));
        NSString *ext  = NSUTF8(property.get_string(nimbiz::NIMUListTagEx));
        NSData *data = [ext dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            _ext = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
    }
    return self;
}


- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[NIMUser class]]) {
        return NO;
    }
    return [self.userId isEqualToString:[object userId]] ;
}

- (BOOL)notifyForNewMsg
{
    return [[[NIMSDK sharedSDK] userManager] notifyForNewMsg:_userId];
}

- (BOOL)isInMyBlackList
{
    return [[[NIMSDK sharedSDK] userManager] isUserInBlackList:_userId];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@" NIMUser description: \n \
                                          userId: %@ \n  \
                                          alias: %@ \n  \
                                            ext: %@ \n  \
                                         notify: %d \n  \
                                          black: %d \n  \
                                       userInfo: %@ \n  ",_userId,_alias,_ext,[self notifyForNewMsg],[self isInMyBlackList],_userInfo];
}


@end


@implementation NIMUserRequest


@end