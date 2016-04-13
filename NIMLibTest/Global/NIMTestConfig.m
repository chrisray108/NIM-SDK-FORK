//
//  NIMTestConfig.m
//  NIMLib
//
//  Created by chris on 15/12/23.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMTestConfig.h"
#import "NSString+NIM.h"
#import "NIMServerSetting.h"
#import "NIMSDK_Private.h"

@implementation NIMTestConfig

+ (instancetype)sharedConfig{
    static NIMTestConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMTestConfig alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self readConfig:@"online"];
    }
    return self;
}

- (void)useDevEnvironment
{
    [self readConfig:@"dev"];
}



- (NSArray *)sessions
{
    NSMutableArray *sessions = [NSMutableArray array];
    for (NSString *item in _friendIds)
    {
        [sessions addObject:[NIMSession session:item
                                           type:NIMSessionTypeP2P]];
    }
    
    for (NSString *item in _teamIds)
    {
        [sessions addObject:[NIMSession session:item
                                           type:NIMSessionTypeTeam]];
    }
    
    for (NSString *item in _chatroomIds)
    {
        [sessions addObject:[NIMSession session:item
                                           type:NIMSessionTypeChatroom]];
    }
    return sessions;
}


- (NSArray *)imSessions
{
    NSMutableArray *sessions = [NSMutableArray array];
    for (NSString *item in _friendIds)
    {
        [sessions addObject:[NIMSession session:item
                                           type:NIMSessionTypeP2P]];
    }
    
    for (NSString *item in _teamIds)
    {
        [sessions addObject:[NIMSession session:item
                                           type:NIMSessionTypeTeam]];
    }
    
    return sessions;
}

- (NSArray *)chatroomSessions
{
    NSMutableArray *sessions = [NSMutableArray array];
    for (NSString *item in _chatroomIds)
    {
        [sessions addObject:[NIMSession session:item
                                           type:NIMSessionTypeChatroom]];
    }
    return sessions;
}

- (void)readConfig:(NSString *)name
{
    NSString *path      = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"plist"];
    NSDictionary *dict  = [[NSDictionary alloc] initWithContentsOfFile:path];
    _appKey             = dict[@"appKey"];
    _appSecret          = dict[@"appSecret"];
    _webServer          = dict[@"webServer"];
    _cerName            = dict[@"cerName"];
    _account            = dict[@"account"];
    _token              = [dict[@"token"] nim_md5];
    _friendIds          = dict[@"friendIds"];
    _teamIds            = dict[@"teamIds"];
    _chatroomIds        = dict[@"chatroomIds"];
    
    NSDictionary *serverSetting = dict[@"serverSetting"];
    if ([serverSetting isKindOfClass:[NSDictionary class]])
    {
        NIMServerSetting *setting    = [[NIMServerSetting alloc] init];
        setting.lbsAddress = serverSetting[@"lbs"];
        setting.linkAddress= serverSetting[@"link"];
        setting.module = serverSetting[@"rsa"];
        [[NIMSDK sharedSDK] setSetting:setting];
    }
}
@end
