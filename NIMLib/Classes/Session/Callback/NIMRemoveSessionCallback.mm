//
//  NIMRemoveSessionCallback.m
//  NIMLib
//
//  Created by amao on 9/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMRemoveSessionCallback.h"
#import "session_protocol.h"
#import "NIMGlobalDefs.h"


@implementation NIMRemoveSessionCallback
- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBDeleteSessionParam *sessionParam = dynamic_cast<nimbiz::CBDeleteSessionParam *>(param);
    if (sessionParam)
    {
        result.error = NIMRemoteError(sessionParam->code_);
    }
}

- (void)run:(NIMCallbackResult *)result
{
    if (_block) {
        _block(result.error);
    }
}
@end
