//
//  NIMPathManager.m
//  NIMLib
//
//  Created by amao on 1/20/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMPathManager.h"
#import "NIMCoreCenter.h"
#import "NIMSDK_Private.h"
#import "NIMUtil.h"
#import "NSString+NIM.h"
#import "NIMSDKConfig_Private.h"
#import "NSDictionary+NIMJson.h"

@interface NIMPathManager ()
@property (nonatomic,copy)      NSString    *sdkRootPath;
@property (nonatomic,copy)      NSString    *configCachePath;
@property (nonatomic,copy)      NSString    *logPath;
@property (nonatomic,copy)      NSString    *nosPath;
@property (nonatomic,copy)      NSString    *resourcePath;
@property (nonatomic,copy)      NSString    *usersPath;
@property (nonatomic,copy)      NSString    *tmpPath;
@property (nonatomic,copy)      NSString    *nvsLogPath;
@property (nonatomic,copy)      NSString    *ntsLogPath;

@end

@implementation NIMPathManager

- (instancetype)init
{
    if (self = [super init])
    {
        NSString *sdkDir = [[NIMSDKConfig sharedConfig] sdkDir];
        if (sdkDir == nil)
        {
            NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            sdkDir = [paths firstObject];
        }
        
        _sdkRootPath    = [sdkDir stringByAppendingPathComponent:@"NIMSDK"];
        _logPath        = [_sdkRootPath stringByAppendingPathComponent:@"Logs"];
        
        [self createDirIfNotExists:_sdkRootPath];
        [self createDirIfNotExists:_logPath];
        [self addSkipBackup:_logPath];
        
        NSString *rioLogPath = [_sdkRootPath stringByAppendingPathComponent:@"RioLogs"];
        _nvsLogPath     = [rioLogPath stringByAppendingPathComponent:@"nvs"];
        _ntsLogPath     = [rioLogPath stringByAppendingPathComponent:@"nts"];
        [self createDirIfNotExists:_nvsLogPath];
        [self createDirIfNotExists:_ntsLogPath];
        [self addSkipBackup:rioLogPath];
    }
    return self;
}

+ (instancetype)sharedManager
{
    static NIMPathManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMPathManager alloc] init];
    });
    return instance;
}

- (NSDictionary *)sdkRootDirAttributes
{
    return _sdkRootPath ?
    [[NSFileManager defaultManager] attributesOfItemAtPath:_sdkRootPath
                                                     error:nil] : nil;
}

- (void)setup:(NSString *)appKey
{
    NSString *appKeyMD5 = [appKey nim_md5];
    NSString *appRootPath   = [_sdkRootPath stringByAppendingPathComponent:appKeyMD5];
    
    _usersPath              = [appRootPath stringByAppendingPathComponent:@"Users"];
    NSString *globalPath    = [appRootPath stringByAppendingPathComponent:@"Global"];
    
    _configCachePath        = [globalPath stringByAppendingPathComponent:@"ConfigCache"];
    _resourcePath           = [globalPath stringByAppendingPathComponent:@"Resources"];
    _nosPath                = [globalPath stringByAppendingPathComponent:@"NOS"];
    _tmpPath                = [NSTemporaryDirectory() stringByAppendingPathComponent:@"NIM"];
    
    //创建APPKEY顶级目录
    [self createDirIfNotExists:appRootPath];
    
    //创建两个根目录:全局目录和用户目录
    [self createDirIfNotExists:globalPath];
    [self createDirIfNotExists:_usersPath];
    
    //目前两个顶级目录都设置成不同步,到时候再考虑要不要做同步
    [self addSkipBackup:globalPath];
    [self addSkipBackup:_usersPath];
    
    //创建各个功能子目录
    [self createDirIfNotExists:_configCachePath];
    [self createDirIfNotExists:_resourcePath];
    [self createDirIfNotExists:_nosPath];
    [self createDirIfNotExists:_tmpPath];

}


- (NSString *)sdkConfigCachePath
{
    return _configCachePath;
}

- (NSString *)sdkLogPath
{
    return _logPath;
}

- (NSString *)sdkNosPath
{
    return _nosPath;
}

- (NSString *)sdkNIMResourcePath
{
    return _resourcePath;
}

- (NSString *)sdkTempPath
{
    return _tmpPath;
}

- (NSString *)sdkNvsLogPath
{
    return _nvsLogPath;
}

- (NSString *)sdkNtsLogPath
{
    return _ntsLogPath;
}

- (NSString *)sdkCurrentUserDir
{
    NSString * currentUserDir = [NSString stringWithFormat:@"%@/",[[NIMCoreCenter sharedCenter] currentUserID]];
    NSString *dir = [_usersPath stringByAppendingPathComponent:currentUserDir];
    [self createDirIfNotExists:dir];
    return dir;
}

#pragma mark - misc
- (void)addSkipBackup:(NSString *)filepath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSURL *url = [NSURL fileURLWithPath:filepath];
        if (![url setResourceValue:@(YES)
                            forKey:NSURLIsExcludedFromBackupKey
                             error:nil])
        {
            
        }
    }
}

- (void)createDirIfNotExists:(NSString *)dirPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [self fileAttributes];
    
    if (![fileManager fileExistsAtPath:dirPath])
    {
        //按照默认属性进行创建,如果创建出来的结果里带有过高的Data Protection 权限,再进行设置
        [fileManager createDirectoryAtPath:dirPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        
        if ([self shouldResetAttributes:dirPath])
        {
            [fileManager setAttributes:attributes
                          ofItemAtPath:dirPath
                                 error:nil];
        }
    }
    else
    {
        if ([self shouldResetAttributes:dirPath])
        {
            [self resetAttributes:dirPath];
        }
    }
}

- (void)resetAttributes:(NSString *)dirPath
{
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    NSDictionary *attributes    = [self fileAttributes];
    
    [fileManager setAttributes:attributes
                  ofItemAtPath:dirPath
                         error:nil];
    
    NSArray *filenames = [fileManager contentsOfDirectoryAtPath:dirPath
                                                          error:nil];
    for (NSString *filename in filenames)
    {
        NSString *path = [dirPath stringByAppendingPathComponent:filename];
        BOOL isDir = NO;
        if ([fileManager fileExistsAtPath:path
                              isDirectory:&isDir])
        {
            if ([self shouldResetAttributes:path])
            {
                if (isDir)
                {
                    [self resetAttributes:path];
                }
                else
                {
                    [fileManager setAttributes:attributes
                                  ofItemAtPath:path
                                         error:nil];
                }
            }
        }
    }
}


- (BOOL)shouldResetAttributes:(NSString *)filepath
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath
                                                                                   error:nil];
    NSString *protection = [attributes nim_jsonString:NSFileProtectionKey];
    if ([[NIMSDKConfig sharedConfig] fileProtectionNone])
    {
        return (protection &&
               ([protection isEqualToString:NSFileProtectionComplete] ||
                [protection isEqualToString:NSFileProtectionCompleteUnlessOpen] ||
                [protection isEqualToString:NSFileProtectionCompleteUntilFirstUserAuthentication]));
    }
    else
    {
        return (protection &&
               ([protection isEqualToString:NSFileProtectionComplete] ||
                [protection isEqualToString:NSFileProtectionCompleteUnlessOpen]));
    }
}

- (NSDictionary *)fileAttributes
{
    return [[NIMSDKConfig sharedConfig] fileProtectionNone] ?
    @{NSFileProtectionKey : NSFileProtectionNone}:
    @{NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication};
}

@end

