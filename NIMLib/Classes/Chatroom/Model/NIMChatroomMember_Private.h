//
//  NIMChatroomMember.h
//  NIMLib
//
//  Created by chris on 16/1/4.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMChatroomMember.h"
#import "Property.h"

@interface NIMChatroomMember()

@property (nonatomic,assign) BOOL isVaild;

@property (nonatomic,assign) NSTimeInterval updateTimeInterval;

- (instancetype)initWithProperty:(const nimbiz::Property&)user;

@end
