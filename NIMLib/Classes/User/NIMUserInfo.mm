//
//  NIMUserInfo.m
//  NIMLib
//
//  Created by chris on 15/9/16.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMUserInfo_Private.h"
#import "user_protocol.h"
#import "NIMNOSResizer.h"

@implementation NIMUserInfo

+ (instancetype)userInfoWithProperty:(const nimbiz::Property &)property{
    if (!property.props.size()) {
        return nil;
    }
    return [[NIMUserInfo alloc] initWithProperty:property];
}

- (instancetype)initWithProperty:(const nimbiz::Property &)property{
    self = [super init];
    if (self) {
        _userId    = NSUTF8(property.get_string(nimbiz::NIMUserInfoTagId));
        _nickName  = NSUTF8(property.get_string(nimbiz::NIMUserInfoTagNick));
        _avatarUrl = NSUTF8(property.get_string(nimbiz::NIMUserInfoTagAvatar));
        _sign      = NSUTF8(property.get_string(nimbiz::NIMUserInfoTagSign));
        _gender    = property.get_int32(nimbiz::NIMUserInfoTagGender);
        _email     = NSUTF8(property.get_string(nimbiz::NIMUserInfoTagEmail));
        _birth     = NSUTF8(property.get_string(nimbiz::NIMUserInfoTagBirth));
        _mobile    = NSUTF8(property.get_string(nimbiz::NIMUserInfoTagMobile));
        _ex        = NSUTF8(property.get_string(nimbiz::NIMUserInfoTagEx));
    }
    return self;
}


- (NSString *)thumbAvatarUrl
{
    return [[NIMNOSResizer sharedResizer] imageThumbnailURL:self.avatarUrl];
}

- (NSString *)description{
    return [NSString stringWithFormat:@" NIMUserInfo description: \n \
                                                          userId: %@ \n  \
                                                        nickname: %@ \n  \
                                                          avatar: %@ \n  \
                                                            sign: %@ \n  \
                                                          gender: %zd \n  \
                                                           email: %@ \n  \
                                                           birth: %@ \n  \
                                                          mobile: %@ \n \
                                                              ex: %@ \n "
            ,_userId,_nickName,_avatarUrl,_sign,_gender,_email,_birth,_mobile,_ex];
}

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[NIMUserInfo class]])
    {
        return NO;
    };
    NIMUserInfo *userInfo = object;
    return [self fieldIsEqual:_userId anotherField:userInfo.userId]  &&
           [self fieldIsEqual:_nickName anotherField:userInfo.nickName]    &&
           [self fieldIsEqual:_avatarUrl anotherField:userInfo.avatarUrl]  &&
           [self fieldIsEqual:_sign anotherField:userInfo.sign]  &&
           _gender == userInfo.gender &&
           [self fieldIsEqual:_email anotherField:userInfo.email] &&
           [self fieldIsEqual:_birth anotherField:userInfo.birth] &&
           [self fieldIsEqual:_mobile anotherField:userInfo.mobile] &&
           [self fieldIsEqual:_ex anotherField:userInfo.ex];
}

- (BOOL)fieldIsEqual:(NSString *)field anotherField:(NSString *)anotherField{
    if (!field && !anotherField) {
        return YES;
    }
    return [field isEqualToString:anotherField];
}

@end
