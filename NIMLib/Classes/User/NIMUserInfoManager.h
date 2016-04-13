//
//  NIMUserInfoManager.h
//  NIMLib
//
//  Created by amao on 12/7/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMManager.h"

@class NIMSystemNotification;
@class NIMCustomSystemNotification;

@interface NIMUserInfoManager : NIMManager
- (void)checkSystemNotification:(NIMSystemNotification *)notification;
- (void)checkCustomSystemNotification:(NIMCustomSystemNotification *)notification;

- (void)checkUserInfo:(NSArray *)userIds;
@end
