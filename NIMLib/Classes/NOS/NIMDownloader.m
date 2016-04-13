//
//  NIMDownloader.m
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMDownloader.h"
#import "NIMDownloadTask.h"

@interface NIMDownloader ()
@property (nonatomic,strong)    NSOperationQueue    *downloadQueue;
@end

@implementation NIMDownloader

- (instancetype)init
{
    if (self = [super init])
    {
        _downloadQueue = [[NSOperationQueue alloc] init];
        [_downloadQueue setMaxConcurrentOperationCount:3];
    }
    return self;
}

- (NSOperation *)download:(NSString *)urlString
                 filepath:(NSString *)filepath
                 progress:(NIMHttpProgressBlock)progress
               completion:(NIMDownloadCompleteBlock)completion
{
    NIMDownloadTask *task = [NIMDownloadTask task:urlString
                                         filepath:filepath
                                         progress:progress
                                       completion:completion];
    [_downloadQueue addOperation:task];
    NIMLogApp(@"add to download queue,url %@ file %@",urlString,[filepath lastPathComponent]);
    return task;
}
@end
