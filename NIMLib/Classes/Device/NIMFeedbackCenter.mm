//
//  NIMFeedbackCenter.m
//  NIMLib
//
//  Created by amao on 7/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMFeedbackCenter.h"
#import "NIMPathManager.h"
#import "NIMUtil.h"
#import "NIMTaskEngine.h"
#import "NIMGzipArchive.h"
#import "NIMSDK_Private.h"
#import "misc_protocol.h"
#import "NIMSDK_Private.h"
#import "NIMReachability.h"
#import "NIMNVSManager.h"

@implementation NIMFeedbackCenter
+ (instancetype)sharedCenter
{
    static NIMFeedbackCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMFeedbackCenter alloc] init];
    });
    return instance;
}

- (void)feedback
{
    [[NIMTaskEngine sharedEngine] runTask:^{
        NSString *path = [self feedbackFilepath];
        if ([self zipLogs:path]) {
            [[[NIMSDK sharedSDK] resourceManager] upload:path
                                                progress:nil
                                              completion:^(NSString *urlString, NSError *error) {
                                                  NIMLogApp(@"upload fb files %@ %@",urlString,error);
                                                  if (urlString && error == nil) {
                                                      [self sendURL:urlString];
                                                  }
                                              }];
        }
        else{
            NIMLogErr(@"zip files failed %@",path);
        }

    }];
}



- (NSArray *)feedbackFiles
{
    NSMutableArray *feedbackFiles = [NSMutableArray array];
    
    //Log目录
    NSString *logPath = [[NIMPathManager sharedManager] sdkLogPath];
    NSArray *files  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logPath error:nil];
    NSArray *logs = [files pathsMatchingExtensions:[NSArray arrayWithObject:@"log"]];
    NSInteger count = [logs count];
    
    for (NSInteger i = [logs count] - 1; i >= 0 && i >= (count - 3); i--){
        
        NSString *filepath = [logPath stringByAppendingPathComponent:[logs objectAtIndex:i]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
            [feedbackFiles addObject:filepath];
        }
    }

    //音视频网络库log
    NSString *nvsLogFile = [[NIMNVSManager sharedManager] logFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:nvsLogFile]) {
        [feedbackFiles addObject:nvsLogFile];
    }
    
    //tcp通道logs
    NSString *ntsLogPath = [[NIMPathManager sharedManager] sdkNtsLogPath];
    NSArray *ntsPathfiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ntsLogPath error:nil];
    NSArray *ntsLogs = [ntsPathfiles pathsMatchingExtensions:[NSArray arrayWithObject:@"log"]];
    NSInteger ntsLogCount = [ntsLogs count];
    
    for (NSInteger i = ntsLogCount - 1; i >= 0 && i >= (ntsLogCount - 20); i--){
        NSString *filepath = [ntsLogPath stringByAppendingPathComponent:[ntsLogs objectAtIndex:i]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
            [feedbackFiles addObject:filepath];
        }
    }
    
    return feedbackFiles;
}

- (NSString *)feedbackFilepath
{
    NSString *appKey = [[NIMSDK sharedSDK] appKey];
    NSString *filename = [NSString stringWithFormat:@"%@_%zd.zip",appKey, (NSInteger)[[NSDate date] timeIntervalSince1970]];
    return [[[NIMPathManager sharedManager] sdkTempPath] stringByAppendingPathComponent:filename];
}

- (BOOL)zipLogs:(NSString *)filepath
{
    NSInteger maxSize = [[NIMReachability reachabilityForInternetConnection] isReachableViaWiFi] ?
    1024 * 1024 * 5 : 1024 * 1024;
    
    return [NIMGzipArchive gzipArchive:filepath
                                 files:[self feedbackFiles]
                               maxSize:maxSize];
}

- (void)sendURL:(NSString *)urlString
{
    nimbiz::IMiscService *service = (nimbiz::IMiscService *)GetServiceFromCore(nimbiz::SVID_NIM_MISC);
    if (service) {
        service->Invoke_UploadLogURL(UTF8(urlString));
    }
}

@end


namespace nimbiz
{
void    CallbackUploadLog(struct IAsynCallbackParam *param)
{
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NIMFeedbackCenter sharedCenter] feedback];
        });
    }
}
}