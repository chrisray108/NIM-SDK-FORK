//
//  NIMChatroomMemberRequestValidator.m
//  NIMLib
//
//  Created by chris on 16/1/6.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomMemberRequestValidator.h"
#import "NIMChatroomMemberRequest.h"
#import "NIMNonEmptyStringValidator.h"
#import "NIMChatroomMember.h"

@implementation NIMChatroomMemberRequestValidator

- (BOOL)isValid
{
    NIMChatroomMemberRequest *request= [self.object nim_asObject:[NIMChatroomMemberRequest class]];
    BOOL valid =  request &&
           [[NIMNonEmptyStringValidator validator:request.roomId] isValid];;
    if (valid) {
        switch (request.type) {
            case NIMChatroomFetchMemberTypeRegular:
            case NIMChatroomFetchMemberTypeRegularOnline:
                valid = request.lastMember.type != NIMChatroomMemberTypeGuest;
                break;
            case NIMChatroomFetchMemberTypeTemp:
                valid = request.lastMember.type == NIMChatroomMemberTypeGuest || !request.lastMember;
                break;
            default:
                valid = NO;
                break;
        }
    }
    return valid;
}

@end
