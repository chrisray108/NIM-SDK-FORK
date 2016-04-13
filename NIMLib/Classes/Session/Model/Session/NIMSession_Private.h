//
//  NIMSession_Private.h
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSession.h"

@interface NIMSessionSaveResult : NSObject

@property(nonatomic,strong) NSMutableArray *savedMessages;

@property(nonatomic,assign) NSInteger unreadCount;

@end


@interface NIMSession ()

@property (nonatomic,copy)         NSString *sessionId;

@property (nonatomic,assign)       NIMSessionType sessionType;

//服务器Redis的key
- (NSString *)remoteSessionKey;
@end
