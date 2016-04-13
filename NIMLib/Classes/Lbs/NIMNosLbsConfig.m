//
//  NIMNosLbsConfig.m
//  NIMLib
//
//  Created by amao on 4/13/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMNosLbsConfig.h"
#import "NIMSDK_Private.h"
#import "NSDictionary+NIMJson.h"
#import "NIMHostSwitcher.h"

@implementation NIMNosLbsConfig

- (NSString *)name
{
    return @"nos lbs";
}
- (NSString *)lbsURL
{
    NSString *cachedLbs = self.cachedLbs;
    NSMutableString *lbs = [[NSMutableString alloc] initWithString:
                            [cachedLbs length] ? cachedLbs : [[[NIMSDK sharedSDK] setting] nosLbsAddress]];
    [lbs appendString:@"?version=1.0"];
    return lbs;
}


- (NSDictionary *)parseData:(NSData *)data
{
    NSDictionary *dict = nil;
    if (data)
    {
        id jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                      options:0
                                                        error:nil];
        if ([jsonData isKindOfClass:[NSDictionary class]])
        {
            self.cachedLbs = [jsonData nim_jsonString:@"lbs"];
            dict = jsonData;
            NIMLogApp(@"cached lbs for nos %@",self.cachedLbs);
        }

    }
    return dict;
}

- (NSDictionary *)readConfig
{
    NSString *filepath = [self filepath];
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    return [self parseData:data];
}

- (void)saveConfig:(NSData *)data
{
    NSString *filepath = [self filepath];
    if (data)
    {
        [data writeToFile:filepath atomically:YES];
    }
}


- (NSString *)filepath
{
    return [[[NIMPathManager sharedManager] sdkConfigCachePath] stringByAppendingPathComponent:@"nos_lbs_cache.info"];
}


@end
