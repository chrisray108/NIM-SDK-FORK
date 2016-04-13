//
//  NIMChatroomFetchMembersCallback.h
//  NIMLib
//
//  Created by chris on 16/1/4.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMCallbackManager.h"

typedef void(^NIMFetchChatroomMemberHandler)(NSError *error,NSArray *members);

@interface NIMChatroomFetchMembersCallback : NSObject<NIMCallback>

@property (nonatomic,copy)  NIMFetchChatroomMemberHandler  block;

@end
