//
//  NIMChatroomInfoCallback.h
//  NIMLib
//
//  Created by chris on 16/1/11.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMChatroom_Private.h"
#import "NIMCallbackManager.h"

typedef void(^NIMChatroomInfoHandler)(NSError *error, NIMChatroom *room);

@interface NIMChatroomInfoCallback : NSObject<NIMCallback>

@property (nonatomic, copy) NIMChatroomInfoHandler block;

@end
