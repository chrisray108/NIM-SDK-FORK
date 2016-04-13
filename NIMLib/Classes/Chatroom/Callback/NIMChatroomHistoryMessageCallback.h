//
//  NIMChatroomHistoryMessageCallback.h
//  NIMLib
//
//  Created by chrisRay on 16/1/5.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMCallbackManager.h"

typedef void(^NIMChatroomHistoryMessageHandler)(NSError *error,NSArray *messages);

@interface NIMChatroomHistoryMessageCallback : NSObject<NIMCallback>

@property (nonatomic,copy)  NIMChatroomHistoryMessageHandler  block;

@end
