//
//  NIMSDKConfig.m
//  NIMLib
//
//  Created by amao on 4/14/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSDKConfig_Private.h"
#import "NIMGitVersion.h"

@implementation NIMSDKConfig

+ (instancetype)sharedConfig
{
    static NIMSDKConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMSDKConfig alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _fetchAttachmentAutomaticallyAfterReceiving = YES;
        _hostUserInfos = YES;
    }
    return self;
}

- (void)setupSDKDir:(NSString *)sdkDir
{
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:sdkDir
                                             isDirectory:&isDir]
        && isDir)
    {
        self.sdkDir = sdkDir;
    }
    else
    {
        NSAssert(0,@"sdk dir not exist");
    }
}


- (NSInteger)sdkVersion
{
    return 21;
}

- (NSInteger)protocolVersion
{
    return 1;
}

- (NSString *)sdkPublicVersion
{
    return @"2.1.0";
}

- (NSString *)gitVersion
{
    return NIMGitVersion;
}

- (NSString *)description
{
    
    return [NSString stringWithFormat:@"\n{\nsdk version %@\ninternal version %zd\nprotocol version %zd\ngit version %@\n\
            dir %@\nhost infos %d\nauto fetch attachment %d\nfile protection none %d\n}\n",
            [self sdkPublicVersion],[self sdkVersion],[self protocolVersion],[self gitVersion],
            [self sdkDir],_hostUserInfos,_fetchAttachmentAutomaticallyAfterReceiving,_fileProtectionNone];
}

@end
