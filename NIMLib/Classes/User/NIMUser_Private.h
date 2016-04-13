//
//  NIMUser.h
//  NIMLib
//
//  Created by amao on 8/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMUser.h"
#import "document.h"

@interface NIMUser ()

- (instancetype)initWithProperty:(const nimbiz::Property &)property;

@property (nonatomic,strong) NIMUserInfo *userInfo;

@end
