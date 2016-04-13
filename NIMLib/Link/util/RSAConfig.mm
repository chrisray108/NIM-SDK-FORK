//
//  RSAConfig.m
//  NIM
//
//  Created by amao on 13-9-2.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "RSAConfig.h"
#import <zlib.h>
#import "NIMPathManager.h"
#import "NIMSDK_Private.h"
#import "NIMSDKConfig_Private.h"

#define RSA_CONFIG_MODULE       @"rsa_config_module"
#define RSA_CONFIG_VERSION      @"rsa_config_version"
#define RSA_CONFIG_CRC32        @"rsa_config_crc32"

@interface NIMRSAConfig ()
+ (NSString *)keyFilepath;

- (NSInteger)calcCRC:(NSString *)module
             version:(NSInteger)version;

@end

@implementation NIMRSAConfig




- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_module forKey:RSA_CONFIG_MODULE];
    [aCoder encodeInteger:_version forKey:RSA_CONFIG_VERSION];
    [aCoder encodeInteger:_crc32  forKey:RSA_CONFIG_CRC32];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.module = [aDecoder decodeObjectForKey:RSA_CONFIG_MODULE];
        self.version= [aDecoder decodeIntegerForKey:RSA_CONFIG_VERSION];
        self.crc32  = [aDecoder decodeIntegerForKey:RSA_CONFIG_CRC32];
    }
    
    return self;
}


+ (instancetype)config:(NSString *)module
               version:(NSInteger)version
{
    NIMRSAConfig *config       = [[NIMRSAConfig alloc]init];
    config.module           = module;
    config.version          = version;
    config.crc32            = [config calcCRC:module
                                      version:version];
    return config;
}

- (BOOL)save
{
    BOOL success = NO;
    if ([self isValidConfig])
    {
        NSString *filepath = [NIMRSAConfig keyFilepath];
        NSData *data   = [NSKeyedArchiver archivedDataWithRootObject:self];
        success = [data writeToFile:filepath atomically:YES];
    }
    return success;
}

- (BOOL)isValidConfig
{
    BOOL isValid = [_module length] &&
    [self calcCRC:_module version:_version] == _crc32;
    if (!isValid)
    {
        NIMLogErr(@"Invalid Module");
    }
    return isValid;
}


+ (instancetype)readLocalConfig
{
    NIMRSAConfig *config = nil;
    NSString *filepath = [NIMRSAConfig keyFilepath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([object isKindOfClass:[NIMRSAConfig class]])
        {
            if ([object isValidConfig])
            {
                config = object;
            }
        }
    }
    return config;
}

#pragma mark - misc
+ (NSString *)keyFilepath
{
    return [[[NIMPathManager sharedManager] sdkConfigCachePath] stringByAppendingPathComponent:@"rsa_key"];
}

- (NSInteger)calcCRC:(NSString *)module
             version:(NSInteger)version
{
    NSString *formatedKey = [NSString stringWithFormat:@"%@%ld",module,(long)version];
    return (NSInteger)crc32(0, (const Bytef *)[formatedKey UTF8String], (uInt)[formatedKey length]);
}

@end
