//
//  NIMUserInfo.h
//  NIMLib
//
//  Created by chris on 15/9/16.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMUser.h"
#import "document.h"

@interface NIMUserInfo()

@property (nonatomic,copy,readwrite) NSString *userId;

@property (nonatomic,copy,readwrite) NSString *nickName;

@property (nonatomic,copy,readwrite) NSString *avatarUrl;

@property (nonatomic,copy,readwrite) NSString *sign;

@property (nonatomic,assign,readwrite) NSInteger gender;

@property (nonatomic,copy,readwrite) NSString* email;

@property (nonatomic,copy,readwrite) NSString* birth;

@property (nonatomic,copy,readwrite) NSString* mobile;

@property (nonatomic,copy,readwrite) NSString* ex;

+ (instancetype)userInfoWithProperty:(const nimbiz::Property &)property;

@end
