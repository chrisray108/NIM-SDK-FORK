//
//  NIMNonEmptyStringValidator.m
//  NIMLib
//
//  Created by amao on 11/16/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMNonEmptyStringValidator.h"

@implementation NIMNonEmptyStringValidator
- (BOOL)isValid
{
    return [self.object isKindOfClass:[NSString class]] &&
    [self.object length] > 0;
}
@end
