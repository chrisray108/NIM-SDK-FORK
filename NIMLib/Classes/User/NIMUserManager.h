//
//  NIMUserManager.h
//  NIMLib
//
//  Created by amao on 8/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "document.h"
#import "NIMManager.h"
#import "NIMUserManagerProtocol.h"

@interface NIMUserManager : NIMManager

#pragma mark - 对外接口
- (void)requestFriend:(NIMUserRequest *)request
           completion:(NIMUserBlock)block;
                
- (void)deleteFriend:(NSString *)userId
          completion:(NIMUserBlock)block;

- (NSArray *)myFriends;


- (void)addToBlackList:(NSString *)userId
            completion:(NIMUserBlock)block;


- (void)removeFromBlackBlackList:(NSString *)userId
                      completion:(NIMUserBlock)block;


- (BOOL)isUserInBlackList:(NSString *)userId;


- (NSArray *)myBlackList;


- (void)updateNotifyState:(BOOL)notify
                  forUser:(NSString *)userId
               completion:(NIMUserBlock)block;


- (BOOL)notifyForNewMsg:(NSString *)userId;

- (NSArray *)myMuteUserList;

- (void)fetchUserInfos:(NSArray *)users completion:(NIMUserInfoBlock)block;

- (NIMUser *)userInfo:(NSString *)userId;

- (void)updateMyUserInfo:(NSDictionary *)values completion:(NIMUserBlock)block;

- (void)updateUser:(NIMUser *)user completion:(NIMUserBlock)block;

@end