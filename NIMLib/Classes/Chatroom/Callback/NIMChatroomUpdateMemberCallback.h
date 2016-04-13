//
//  NIMChatroomUpdateMemberCallback.h
//  NIMLib
//
//  Created by chris on 16/1/6.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMCallbackManager.h"
#import "NIMChatroomMember.h"

typedef void(^NIMChatroomUpdateMemberHandler)(NSError *error);

@interface NIMChatroomUpdateMemberCallback : NSObject<NIMCallback>

@property (nonatomic,copy) NIMChatroomUpdateMemberHandler block;

@end
