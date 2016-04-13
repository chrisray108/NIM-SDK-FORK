//
//  NIMLbsConfig.m
//  NIMLib
//
//  Created by amao on 4/13/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMLbsConfig.h"
#import "NIMAppLbsConfig.h"
#import "NIMNosLbsConfig.h"

@implementation NIMLbsConfig
- (instancetype)init
{
    if (self = [super init])
    {
        _timer = [[NIMTimer alloc] init];
    }
    return self;
}

- (NSString *)name
{
    NIMAssert();
    return nil;
}

- (NSString *)lbsURL
{
    NIMAssert();
    return nil;
}

- (NSDictionary *)parseData:(NSData *)data
{
    NIMAssert();
    return nil;
}

- (NSDictionary *)readConfig
{
    NIMAssert();
    return nil;
}

- (void)saveConfig:(NSData *)data
{
    NIMAssert();
}


@end