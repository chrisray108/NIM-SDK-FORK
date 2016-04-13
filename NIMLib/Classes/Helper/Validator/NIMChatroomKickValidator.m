//
//  NIMChatroomKickValidator.m
//  NIMLib
//
//  Created by chris on 16/1/11.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomKickValidator.h"
#import "NIMChatroomMemberRequest.h"
#import "NIMNonEmptyStringValidator.h"

@implementation NIMChatroomKickValidator

- (BOOL)isValid
{
    NIMChatroomMemberKickRequest *request= [self.object nim_asObject:[NIMChatroomMemberKickRequest class]];
    return request &&
           [[NIMNonEmptyStringValidator validator:request.roomId] isValid] &&
           [[NIMNonEmptyStringValidator validator:request.userId] isValid];
}

@end
