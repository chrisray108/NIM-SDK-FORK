//
//  NIMMessageObjectValidator.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMMessageObjectValidator.h"
#import "NIMMessage_Private.h"

@implementation NIMMessageObjectValidator
- (BOOL)isValid
{
    id messageObject = self.object;
    return messageObject == nil ||
    [messageObject isKindOfClass:[NIMImageObject class]] ||
    [messageObject isKindOfClass:[NIMAudioObject class]] ||
    [messageObject isKindOfClass:[NIMLocationObject class]] ||
    [messageObject isKindOfClass:[NIMVideoObject class]] ||
    [messageObject isKindOfClass:[NIMFileObject class]] ||
    [messageObject isKindOfClass:[NIMNotificationObject class]] ||
    [messageObject isKindOfClass:[NIMCustomObject class]] ||
    [messageObject isKindOfClass:[NIMTipObject class]];

}
@end
