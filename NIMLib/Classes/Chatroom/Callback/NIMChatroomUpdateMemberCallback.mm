//
//  NIMChatroomUpdateMemberCallback.m
//  NIMLib
//
//  Created by chris on 16/1/6.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomUpdateMemberCallback.h"
#import "chatroom_protocol.h"
#import "NIMChatroomMember_Private.h"

@implementation NIMChatroomUpdateMemberCallback

- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBChatroomUpdateMemberParam *chatroomParam = dynamic_cast<nimbiz::CBChatroomUpdateMemberParam *>(param);
    if (chatroomParam)
    {
        result.error = NIMRemoteError(chatroomParam->code_);
    }
}

- (void)run:(NIMCallbackResult *)result
{
    NSError *error= result.error;
    if (_block) {
        _block(error);
    }
}

@end
