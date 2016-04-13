//
//  NIMChatroomKickCallback.mm
//  NIMLib
//
//  Created by chris on 16/1/12.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomKickCallback.h"
#import "chatroom_protocol.h"

@implementation NIMChatroomKickCallback


- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBKickChatroomParam *kickParam = dynamic_cast<nimbiz::CBKickChatroomParam *>(param);
    if (kickParam)
    {
        result.error = NIMRemoteError(kickParam->code_);
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
