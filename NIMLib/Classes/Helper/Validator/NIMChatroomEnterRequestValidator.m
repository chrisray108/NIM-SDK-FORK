//
//  NIMChatroomEnterRequestValidator.m
//  NIMLib
//
//  Created by amao on 1/5/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMChatroomEnterRequestValidator.h"
#import "NIMChatroomEnterRequest.h"
#import "NSObject+NIM.h"
#import "NIMNonEmptyStringValidator.h"

@implementation NIMChatroomEnterRequestValidator
- (BOOL)isValid
{
    NIMChatroomEnterRequest *request = [self.object nim_asObject:[NIMChatroomEnterRequest class]];
    return request && [[NIMNonEmptyStringValidator validator:request.roomId] isValid];
}
@end
