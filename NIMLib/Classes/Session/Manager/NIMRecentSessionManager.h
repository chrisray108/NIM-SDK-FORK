//
//  NIMRecentSessionManager.h
//  NIMLib
//
//  Created by amao on 2/4/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMRecentSession;
@class NIMMessage;
@class NIMSession;


@interface NIMRecentSessionManager : NSObject

@property (nonatomic,readonly,strong) NSMutableDictionary  *sessions;

/* 注意：以< main_xxx >开头的方法只能在主线程调用 */

//增加最近会话
- (void)main_addRecentSession:(NIMRecentSession *)recentSession;

//当前会话未读清零
- (void)main_cleanRecentSession:(NIMSession *)session;

//更新当前会话的最后一条消息，如果消息ID不匹配则忽略，这个接口不会去更改未读数
- (void)main_updateRecentSession:(NIMMessage *)message;

//替换当前会话的最后一条消息,只能在主线程上调用
- (void)main_replaceRecentSession:(NIMMessage *)message;

//删除最近会话
- (void)main_removeRecentSession:(NIMRecentSession *)recentSession;

- (NSInteger)allUnreadCount;

- (NSArray*)allRecentSessions;

@end


//消息操作后相应的recent处理逻辑
@interface NIMRecentSessionManager(MessageOperation)

- (void)deleteMessage:(NIMMessage*)message;

- (void)deleteAllmessagesInSession:(NIMSession*)session
               removeRecentSession:(BOOL)removeRecentSession;

- (void)deleteAllmessages:(BOOL)removeRecentSessions;
@end
