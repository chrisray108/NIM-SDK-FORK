//
//  NIMChatroomTokenCallback.h
//  NIMLib
//
//  Created by amao on 12/16/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMChatroomToken.h"
#import "NIMCallbackManager.h"

typedef void(^NIMRequestChatroomTokenHandler)(NSError *error,NIMChatroomToken *token);


@interface NIMChatroomTokenCallback : NSObject<NIMCallback>
@property (nonatomic,copy)  NIMRequestChatroomTokenHandler  block;
@end
