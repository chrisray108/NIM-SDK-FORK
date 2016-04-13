//
//  NIMRecentSessionValidator.m
//  NIMLib
//
//  Created by chris on 15/11/4.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMRecentSessionValidator.h"
#import "NIMRecentSession.h"
#import "NIMSessionValidator.h"

@implementation NIMRecentSessionValidator

- (BOOL)isValid
{
    NIMRecentSession *recent = [self.object nim_asObject:[NIMRecentSession class]];
    return recent && [[NIMSessionValidator validator:recent.session] isValid];
}

@end
