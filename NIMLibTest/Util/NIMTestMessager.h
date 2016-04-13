//
//  NIMTestMessager.h
//  NIMLib
//
//  Created by amao on 2/18/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMBaseTest.h"

@interface NIMTestMessager : NIMBaseTest

//普通消息
- (NSArray *)sendRandomMessages;

- (NSArray *)receiveRandomMessages;


//聊天室消息
- (NSArray *)sendRandomChatroomMessages;

- (NSArray *)receiveRandomChatroomMessages;

@end
