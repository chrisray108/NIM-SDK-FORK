//
//  NSObject+NIM.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NSObject+NIM.h"

@implementation NSObject (NIM)
- (NSString *)nim_asString
{
    return [self nim_asObject:[NSString class]];
}

- (NSNumber *)nim_asNumber
{
    return [self nim_asObject:[NSNumber class]];
}

- (id)nim_asObject:(Class)convertClass
{
    return [self isKindOfClass:convertClass] ? self : nil;
}
@end
