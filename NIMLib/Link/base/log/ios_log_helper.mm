//
//  ios_log_helper.m
//  NIM
//
//  Created by amao on 7/16/14.
//  Copyright (c) 2014 Netease. All rights reserved.
//

#import "ios_log_helper.h"
#import "NIMSDK_Private.h"
#include "base/time/time.h"

static NSString *NIMFileLogBreakLine = @"\n";

dispatch_queue_t nim_get_shared_log_queue()
{
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.yixin.log.queue", NULL);
    });
    return queue;
}

@interface NIMFileLogger : NSObject
@property (nonatomic,strong)  NSString *cachedLog;  //发送打开文件错误时,将log暂存于此,最大长度 1M
@end

@implementation NIMFileLogger
+ (instancetype)sharedLogger
{
    static NIMFileLogger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMFileLogger alloc] init];
    });
    return instance;
}

- (void)log:(NSString *)log
{
    if ([[NIMSDK sharedSDK] consoleLogEnabled])
    {
        NSLog(@"%@",log);
    }
    else
    {
#if defined(DEBUG) || defined(_DEBUG)
        printf("%s\n",[log UTF8String]);
#endif
    }
    
    dispatch_async(nim_get_shared_log_queue(), ^{
        [self writeLog:log];
    });
}

- (void)writeLog:(NSString *)log
{
    const char *filepath = [[self logFilepath] UTF8String];
    int fd = open(filepath, O_CREAT|O_RDWR|O_APPEND, 0660);
    if (fd < 0)
    {
        [self cacheError:log];
        return;
    }
    
    [self writeCachedError:fd];
    
    [self write:log
         toFile:fd];
    
    [self write:NIMFileLogBreakLine
         toFile:fd];
    
    close(fd);

}

- (NSString *)logFilepath
{
    nbase::Time::TimeStruct ts = nbase::Time::Now().ToTimeStruct(true);
    NSString *dir = [[NIMPathManager sharedManager] sdkLogPath];
    NSString *filename = [NSString stringWithFormat:@"nim_%04d%02d%02d.log", ts.year(), ts.month(), ts.day_of_month()];
    NSString *path = [dir stringByAppendingPathComponent:filename];
    return path;
}

- (void)write:(NSString *)log
       toFile:(int)fd
{
    const char *buffer = [log UTF8String];
    int32_t size = (int32_t)[log length];
    
    int32_t savedSize = 0;
    while (savedSize < size)
    {
        size_t n = write(fd, buffer + savedSize, size - savedSize);
        if (n > 0)
        {
            savedSize += (int32_t)n;
        }
        else
        {
            break;
        }
    }
}

- (void)cacheError:(NSString *)log
{
    //最多缓存 2M 的错误信息
    static NSInteger maxCacheErrorLogLength = 1024 * 1024 * 2;
    NSUInteger length = [_cachedLog length];
    if (length == 0)
    {
        _cachedLog = [log copy];
    }
    else if (length < maxCacheErrorLogLength)
    {
        _cachedLog = [_cachedLog stringByAppendingFormat:@"%@%@",NIMFileLogBreakLine,log];
    }
}

- (void)writeCachedError:(int)fd
{
    if ([_cachedLog length])
    {
        [self write:@"\n\n\n--------- cache error log begin -------\n\n\n"
             toFile:fd];
        [self write:_cachedLog
             toFile:fd];
        [self write:@"\n\n\n--------- cache error log end -------\n\n\n"
             toFile:fd];
        _cachedLog = nil;
    }
}
@end


namespace nbase
{
    void    Log2File(const std::string &log)
    {
        @autoreleasepool
        {
            NSString *content = [NSString stringWithUTF8String:log.c_str()];
            [[NIMFileLogger sharedLogger] log:content];
        }
        
    }
}






