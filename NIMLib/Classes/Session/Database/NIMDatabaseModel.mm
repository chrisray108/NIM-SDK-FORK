//
//  NIMDatabaseModel.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMDatabaseModel.h"
#import "NIMMessage_Private.h"
#import "NIMProtocolUtil.h"

@implementation NIMMessageUpdateInfo
+ (instancetype)updateInfoByMessage:(NIMMessage *)message
{
    NIMMessageUpdateInfo *info = [[NIMMessageUpdateInfo alloc] init];
    if ([message isKindOfClass:[NIMMessage class]])
    {
        info.serialID = message.serialID;
        
        if ([message.messageObject isKindOfClass:[NIMCustomObject class]])
        {
            info.customObject = (NIMCustomObject *)message.messageObject;
        }
        
        info.localExt = [NIMProtocolUtil jsonData:message.localExt];
    }
    return info;
}
@end