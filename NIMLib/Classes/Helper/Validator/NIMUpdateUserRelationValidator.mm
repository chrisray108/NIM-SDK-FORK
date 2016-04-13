//
//  NIMUpdateUserRelationValidator.m
//  NIMLib
//
//  Created by chris on 15/11/5.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMUpdateUserRelationValidator.h"
#import "NIMUser.h"
#import "yixin_core.h"

@implementation NIMUpdateUserRelationValidator

- (BOOL)isValid
{
    NIMUser *user = [self.object nim_asObject:[NIMUser class]];
    nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
    BOOL valid = user != nil && core;
    do
    {
        if (![user.userId isKindOfClass:[NSString class]] || !user.userId.length) {
            valid = NO;
            break;
        }
        if ([user.userId isEqualToString:NSUTF8(core->GetUid())]) {
            valid = NO;
            break;
        }
        if (user.alias && ![user.alias isKindOfClass:[NSString class]]) {
            valid = NO;
            break;
        }
        if (user.ext) {
            if (![user.ext isKindOfClass:[NSDictionary class]]) {
                valid = NO;
                break;
            }
            NSError *error;
            [NSJSONSerialization dataWithJSONObject:user.ext options:0 error:&error];
            valid = (error == nil);
        }
    
    }while (0);
    return valid;
}


@end
