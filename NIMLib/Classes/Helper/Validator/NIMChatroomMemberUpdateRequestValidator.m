//
//  NIMChatroomMemberRequestValidator.m
//  NIMLib
//
//  Created by chris on 16/1/6.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomMemberUpdateRequestValidator.h"
#import "NIMChatroomMemberRequest.h"
#import "NIMNonEmptyStringValidator.h"

@implementation NIMChatroomMemberUpdateRequestValidator

- (BOOL)isValid
{
    NIMChatroomMemberUpdateRequest *request= [self.object nim_asObject:[NIMChatroomMemberUpdateRequest class]];
    BOOL valid = request != nil;
    if (valid)
    {
        do{
            if (![[NIMNonEmptyStringValidator validator:request.roomId] isValid])
            {
                valid = NO;
                break;
            }
            if (![[NIMNonEmptyStringValidator validator:request.userId] isValid])
            {
                valid = NO;
                break;
            }
        }while (0);
    }
    return valid;
}

@end
