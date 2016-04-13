//
//  NIMTestConfig.h
//  NIMLib
//
//  Created by chris on 15/12/23.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NIMSession;

@interface NIMTestConfig : NSObject

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, copy) NSString *appSecret;

@property (nonatomic, copy) NSString *webServer;

@property (nonatomic, copy) NSString *cerName;

@property (nonatomic, copy) NSString *account;

@property (nonatomic, copy) NSString *token;

@property (nonatomic, copy) NSArray *friendIds;

@property (nonatomic, copy) NSArray *teamIds;

@property (nonatomic, copy) NSArray *chatroomIds;

+ (instancetype)sharedConfig;

- (NSArray *)sessions;  //所有sessions包括聊天室
- (NSArray *)imSessions;//用户和群Session
- (NSArray *)chatroomSessions;//聊天室Session

- (void)useDevEnvironment;

@end
