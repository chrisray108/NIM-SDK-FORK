//
//  NIMTeamInfoValidator.m
//  NIMLib
//
//  Created by chris on 15/11/4.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMTeamInfoValidator.h"
#import "NIMArrayValidator.h"

@implementation NIMTeamInfoValidator

- (BOOL)isValid
{
    NSDictionary *dict = [self.object nim_asObject:[NSDictionary class]];
    BOOL valid = dict != nil;
    if (valid)
    {
        NSArray *keys = [dict allKeys];
        NSArray *values = [dict allValues];
        
        valid =[[NIMArrayValidator validator:keys] allObjectsAreKindOf:[NSNumber class]] &&
               [[NIMArrayValidator validator:values] allObjectsAreKindOf:[NSString class]];

    }
    return valid;
}

@end
