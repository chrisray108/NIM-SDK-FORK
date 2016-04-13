//
//  NIMChatroomMembersByIdsValidator.m
//  NIMLib
//
//  Created by chris on 16/1/11.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomMembersByIdsValidator.h"
#import "NIMChatroomMemberRequest.h"
#import "NIMNonEmptyStringValidator.h"
#import "NIMArrayValidator.h"

@implementation NIMChatroomMembersByIdsValidator

- (BOOL)isValid
{
    NIMChatroomMembersByIdsRequest *request= [self.object nim_asObject:[NIMChatroomMembersByIdsRequest class]];
    return request &&
           [[NIMNonEmptyStringValidator validator:request.roomId] isValid] &&
           [[NIMArrayValidator validator:request.userIds] allObjectsAreKindOf:[NSString class]];
}

@end
