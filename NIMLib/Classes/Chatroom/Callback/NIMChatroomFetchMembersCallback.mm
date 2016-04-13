//
//  NIMChatroomFetchMembersCallback.mm
//  NIMLib
//
//  Created by chris on 16/1/4.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomFetchMembersCallback.h"
#import "chatroom_protocol.h"
#import "NIMChatroomMember_Private.h"

@implementation NIMChatroomFetchMembersCallback

- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBChatroomFetchMembersParam *membersParam = dynamic_cast<nimbiz::CBChatroomFetchMembersParam *>(param);
    if (membersParam)
    {
        result.error = NIMRemoteError(membersParam->code_);
        
        if (!result.error)
        {
            NSMutableArray *members = [[NSMutableArray alloc] init];
            for (auto it = membersParam->members_.begin(); it != membersParam->members_.end(); it++)
            {
                NIMChatroomMember *member = [[NIMChatroomMember alloc] initWithProperty:*it];
                [members addObject:member];
            }
            result.resultObject = members;
        }
    }
}


- (void)run:(NIMCallbackResult *)result
{
    if (_block) {
        _block(result.error,(NSArray *)result.resultObject);
    }
}

@end
