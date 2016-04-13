//
//  NIMRecentSession_Private.h
//  NIMLib
//
//  Created by amao on 2/4/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMRecentSession.h"

@interface NIMRecentSession ()<NSCopying>

@property (nonatomic,readwrite,strong)   NIMSession  *session;

@property (nonatomic,readwrite,strong)   NIMMessage  *lastMessage;

@property (nonatomic,readwrite,assign)   NSInteger   unreadCount;

+ (instancetype)recentSessionWithSession:(NIMSession *)session;

+ (instancetype)recentSessionWithMessage:(NIMMessage *)message;

@end
