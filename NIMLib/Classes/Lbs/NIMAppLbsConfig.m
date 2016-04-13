//
//  NIMAppLbsConfig.m
//  NIMLib
//
//  Created by amao on 4/13/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMAppLbsConfig.h"
#import "NIMSDK_Private.h"
#import "NSDictionary+NIMJson.h"
#import "NIMHostSwitcher.h"
#import "NIMSDKConfig_Private.h"

@implementation NIMAppLbsConfig

- (NSString *)name
{
    return @"link lbs";
}
- (NSString *)lbsURL
{
    NSString *cachedLbs = self.cachedLbs;
    NSMutableString *lbs = [[NSMutableString alloc] initWithString:
                            [cachedLbs length] ? cachedLbs : [[[NIMSDK sharedSDK] setting] lbsAddress]];
    NIMSDKConfig *config = [NIMSDKConfig sharedConfig];
    [lbs appendFormat:@"?sv=%zd&pv=%zd&tp=2",[config sdkVersion],[config protocolVersion]];
    NSString *appKey = [[NIMSDK sharedSDK] appKey];
    if ([appKey length])
    {
        [lbs appendFormat:@"&k=%@",appKey];
    }
    NSString *userID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    if ([userID length])
    {
        [lbs appendFormat:@"&id=%@",userID];
    }
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
            NSDictionary *commonDict = [jsonData nim_jsonDict:@"common"];
            self.cachedLbs = [commonDict nim_jsonString:@"lbs"];
            dict = commonDict;
            NIMLogApp(@"cached lbs for link %@",self.cachedLbs);
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
    return [[[NIMPathManager sharedManager] sdkConfigCachePath] stringByAppendingPathComponent:@"link_lbs_cache.info"];
}


@end
