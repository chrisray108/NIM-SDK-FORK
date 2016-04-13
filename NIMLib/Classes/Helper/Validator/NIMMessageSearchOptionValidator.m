//
//  NIMMessageSearchOptionValidator.m
//  NIMLib
//
//  Created by chris on 15/11/4.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMMessageSearchOptionValidator.h"
#import "NIMMessageSearchOption.h"
#import "NIMArrayValidator.h"

@implementation NIMMessageSearchOptionValidator

- (BOOL)isValid
{
    NIMMessageSearchOption *option = [self.object nim_asObject:[NIMMessageSearchOption class]];
    BOOL valid = option != nil;
    do {
        
        NSString *content = option.searchContent;
        NSArray *ids = option.fromIds;

        if (content && ![content isKindOfClass:[NSString class]]) {
            valid = NO;
            break;
        }
        
        if (ids && ![[NIMArrayValidator validator:ids] allObjectsAreKindOf:[NSString class]]) {
            valid = NO;
            break;
        }
        NSTimeInterval start = option.startTime;
        NSTimeInterval end = option.endTime;
        
        if (start && end && start >= end) {
            valid = NO;
            break;
        }
    } while (0);
    return valid;
}

@end
