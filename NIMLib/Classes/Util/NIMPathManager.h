//
//  NIMPathManager.h
//  NIMLib
//
//  Created by amao on 1/20/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMPathManager : NSObject
+ (instancetype)sharedManager;
- (NSDictionary *)sdkRootDirAttributes;

- (void)setup:(NSString *)appKey;

- (NSString *)sdkConfigCachePath;   //本地配置资源目录,如 RSA Key,lbs缓存等
- (NSString *)sdkLogPath;           //Log 目录
- (NSString *)sdkNosPath;           //存储NOS信息
- (NSString *)sdkNIMResourcePath;   //资源文件 目录 (所有资源放在同一个目录下)
- (NSString *)sdkTempPath;          //临时目录
- (NSString *)sdkNvsLogPath;        //音视频日志目录
- (NSString *)sdkNtsLogPath;        //可靠数据通道日志目录

- (NSString *)sdkCurrentUserDir;    //当前用户目录
@end
