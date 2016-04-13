//
//  NIMChatroomNotificationContent.h
//  NIMLib
//
//  Created by chris on 16/1/8.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomNotificationContent.h"

@interface NIMChatroomNotificationContent()

@end


@interface NIMChatroomNotificationMember()
/**
 *  聊天室成员ID
 */
@property (nonatomic,copy,readwrite) NSString *userId;
/**
 *  聊天室成员昵称
 */
@property (nonatomic,copy,readwrite) NSString *nick;

@end