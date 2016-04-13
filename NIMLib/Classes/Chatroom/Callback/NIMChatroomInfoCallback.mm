//
//  NIMChatroomInfoCallback.m
//  NIMLib
//
//  Created by chris on 16/1/11.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomInfoCallback.h"
#import "chatroom_protocol.h"

@implementation NIMChatroomInfoCallback

- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBChatroomInfoParam *chatroomParam = dynamic_cast<nimbiz::CBChatroomInfoParam *>(param);
    if (chatroomParam)
    {
        result.error = NIMRemoteError(chatroomParam->code_);
        if (!result.error) {
            nimbiz::Property property = chatroomParam->room_;
            NIMChatroom *member = [[NIMChatroom alloc] initWithProperty:property];
            result.resultObject = member;
        }
    }
}

- (void)run:(NIMCallbackResult *)result
{
    NSError *error= result.error;
    if (_block) {
        _block(error,result.resultObject);
    }
}

@end
