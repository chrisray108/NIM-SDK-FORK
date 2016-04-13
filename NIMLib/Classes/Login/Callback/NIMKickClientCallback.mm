//
//  NIMKickClientCallback.m
//  NIMLib
//
//  Created by amao on 1/21/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMKickClientCallback.h"
#import "auth_protocol.h"
#import "NIMProtocolUtil.h"

@implementation NIMKickClientCallback
- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBKickOtherParam *kickParam = dynamic_cast<nimbiz::CBKickOtherParam *>(param);
    if (kickParam)
    {
        result.error = NIMRemoteError(kickParam->code_);
        NSArray *deviceIds = [NIMProtocolUtil stringVectorToArray:kickParam->clients_];
        result.resultObject = deviceIds;
    }
}

- (void)run:(NIMCallbackResult *)result
{
    if (_handler) {
        _handler(result.error,(NSArray *)result.resultObject);
    }
}
@end
