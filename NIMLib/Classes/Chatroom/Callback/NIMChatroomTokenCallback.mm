//
//  NIMChatroomTokenCallback.m
//  NIMLib
//
//  Created by amao on 12/16/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMChatroomTokenCallback.h"
#import "chatroom_protocol.h"
#import "NIMProtocolUtil.h"

@implementation NIMChatroomTokenCallback
- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBChatroomRequestChatroomParam *tokenParam = dynamic_cast<nimbiz::CBChatroomRequestChatroomParam *>(param);
    if (tokenParam)
    {
        result.error = NIMRemoteError(tokenParam->code_);
        
        if (result.error == nil)
        {
            NSString *roomId = NSUTF8(tokenParam->room_id_);
            NSArray *addresses = [NIMProtocolUtil stringListToArray:tokenParam->addresses_];
            result.resultObject = [NIMChatroomToken tokenBy:addresses
                                                     roomId:roomId];
        }
    }
}


- (void)run:(NIMCallbackResult *)result
{
    if (_block) {
        _block(result.error,(NIMChatroomToken *)result.resultObject);
    }
}
@end
