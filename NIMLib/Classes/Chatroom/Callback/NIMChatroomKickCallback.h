//
//  NIMChatroomKickCallback.h
//  NIMLib
//
//  Created by chris on 16/1/12.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMCallbackManager.h"

typedef void(^NIMChatroomKickHandler)(NSError *error);

@interface NIMChatroomKickCallback : NSObject<NIMCallback>

@property (nonatomic, copy) NIMChatroomKickHandler block;

@end
