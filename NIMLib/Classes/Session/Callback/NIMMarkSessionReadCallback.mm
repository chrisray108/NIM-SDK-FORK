//
//  NIMMarkSessionReadCallback.m
//  NIMLib
//
//  Created by amao on 3/1/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMMarkSessionReadCallback.h"
#import "session_protocol.h"

@implementation NIMMarkSessionReadCallback

- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBMarkSessionReadParam *sessionParam = dynamic_cast<nimbiz::CBMarkSessionReadParam *>(param);
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
