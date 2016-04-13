//
//  NIMFileCenter.m
//  NIMLib
//
//  Created by amao on 1/22/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMFileCenter.h"
#import "NIMDispatch.h"
#import "NIMGlobalDefs.h"
#import "NIMDownloader.h"
#import "NIMNOSUploader.h"
#import "NIMFileInfo.h"




@interface NIMFileCenter ()
@property (nonatomic,strong)    NSMutableDictionary *uploadFiles;
@property (nonatomic,strong)    NIMNOSUploader  *uploader;

@property (nonatomic,strong)    NSMutableDictionary *downloadFiles;
@property (nonatomic,strong)    NIMDownloader   *downloader;
@end

@implementation NIMFileCenter
- (instancetype)init
{
    if (self = [super init])
    {
        _uploadFiles    = [[NSMutableDictionary alloc] init];
        _uploader       = [[NIMNOSUploader alloc] init];
        _downloadFiles  = [[NSMutableDictionary alloc] init];
        _downloader     = [[NIMDownloader alloc] init];
    }
    return self;
}


#pragma mark - 上传任务
- (void)upload:(NSString *)filepath
      progress:(NIMHttpProgressBlock)progress
    completion:(NIMUploadCompleteBlock)completion
{
    NIMLogApp(@"add %@ to upload queue",filepath);
    
    dispatch_block_t mainBlock = ^()
    {
        if (![[NSFileManager defaultManager] fileExistsAtPath:filepath])
        {
            NIMLogErr(@"invalid filepath for uploading %@",filepath);
            if (completion)
            {
                completion(nil,NIMLocalError(NIMLocalErrorCodeInvalidParam));
            }
            return;
        }
        
        NIMFileCallback *callback = [[NIMFileCallback alloc] init];
        callback.progress = progress;
        callback.uploadBlock = completion;
        
        
        NIMFileInfo *info = [_uploadFiles objectForKey:filepath];
        if (info)
        {
            [info addCallback:callback];
        }
        else
        {
            info = [[NIMFileInfo alloc] init];
            [info addCallback:callback];
            [_uploadFiles setObject:info
                             forKey:filepath];
            
            __weak typeof(self) weakSelf = self;
            info.operation =
            [_uploader upload:filepath
                     progress:^(CGFloat progress) {
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         [strongSelf notifyUploadProgress:progress
                                                  forFile:filepath];
                         
                     } completion:^(NSString *urlString, NSError *error) {
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         [strongSelf notifyUploadResult:urlString
                                                  error:error
                                                forFile:filepath];
                         
                     }];
        }
    };
    
    nim_main_async_safe(mainBlock);
}

- (void)notifyUploadProgress:(CGFloat)progress
                     forFile:(NSString *)filepath
{
    NSArray *callbacks = [[self.uploadFiles objectForKey:filepath] callbacks];
    for (NIMFileCallback *cb in callbacks)
    {
        if (cb.progress)
        {
            cb.progress(progress);
        }
    }
}

- (void)notifyUploadResult:(NSString *)urlString
                     error:(NSError *)error
                   forFile:(NSString *)filepath
{
    NIMFileInfo *fileInfo = [self.uploadFiles objectForKey:filepath];
    if (fileInfo)
    {
        [self.uploadFiles removeObjectForKey:filepath];
        NSArray *callbacks = [fileInfo callbacks];
        for (NIMFileCallback *cb in callbacks)
        {
            if (cb.uploadBlock)
            {
                cb.uploadBlock(urlString,error);
            }
        }
    }
}


#pragma mark - 下载
- (void)download:(NSString *)urlString
        filepath:(NSString *)filepath
        progress:(NIMHttpProgressBlock)progress
      completion:(NIMDownloadCompleteBlock)completion
{
    
    NIMLogApp(@"add url %@ filepath %@ to download queue",urlString,filepath);
    
    dispatch_block_t mainBlock = ^()
    {
        if ([urlString length] == 0 ||
            [filepath length] == 0)
        {
            NIMLogErr(@"invalid url or filepath for downloading %@ %@",urlString,filepath);
            if (completion)
            {
                completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
            }
            return;
        }
        NIMFileCallback *callback = [[NIMFileCallback alloc] init];
        callback.progress       = progress;
        callback.downloadBlock  = completion;
        
        NIMFileInfo *info = [_downloadFiles objectForKey:filepath];
        if (info)
        {
            [info addCallback:callback];
        }
        else
        {
            info = [[NIMFileInfo alloc] init];
            [info addCallback:callback];
            [_downloadFiles setObject:info
                               forKey:filepath];
            
           
            info.operation = [self download:urlString
                                   filepath:filepath];
        }

    };
    nim_main_async_safe(mainBlock);
}

- (NSOperation *)download:(NSString *)urlString
                 filepath:(NSString *)filepath
{
    __weak typeof(self) weakSelf = self;
    NSOperation *operation = [_downloader download:urlString
                                          filepath:filepath
                                          progress:^(CGFloat progress) {
                                              __strong typeof(weakSelf) strongSelf = weakSelf;
                                              [strongSelf notifyDownloadProgress:progress
                                                                         forFile:filepath];
                                          } completion:^(NSError *error) {
                                              __strong typeof(weakSelf) strongSelf = weakSelf;
                                              [strongSelf notifyDownloadResult:urlString
                                                                         error:error
                                                                       forFile:filepath];
                                          }];
    return operation;
}

- (void)notifyDownloadProgress:(CGFloat)progress
                       forFile:(NSString *)filepath
{
    NSArray *callbacks = [[self.downloadFiles objectForKey:filepath] callbacks];
    for (NIMFileCallback *cb in callbacks)
    {
        if (cb.progress)
        {
            cb.progress(progress);
        }
    }
}

- (void)notifyDownloadResult:(NSString *)urlString
                       error:(NSError *)error
                     forFile:(NSString *)filepath
{
    NIMFileInfo *fileInfo = [self.downloadFiles objectForKey:filepath];
    if (fileInfo)
    {
        if (error == nil || fileInfo.retryTimes == 0)
        {
            [self.downloadFiles removeObjectForKey:filepath];
            NSArray *callbacks = [fileInfo callbacks];
            for (NIMFileCallback *cb in callbacks)
            {
                if (cb.downloadBlock)
                {
                    cb.downloadBlock(error);
                }
            }
        }
        else
        {
            NIMLogErr(@"download %@ to %@ failed error %@ retry times %zd",urlString,filepath,error,fileInfo.retryTimes);
            fileInfo.retryTimes--;
            fileInfo.operation = [self download:urlString
                                       filepath:filepath];
        }
    }
}


#pragma mark - 取消任务
- (void)cancelTask:(NSString *)filepath
{
    if ([filepath length] == 0)
    {
        return;
    }
    dispatch_block_t mainBlock = ^()
    {
        [self cancelTask:filepath
                 inFiles:_uploadFiles];
        [self cancelTask:filepath
                 inFiles:_downloadFiles];
    };
    nim_main_async_safe(mainBlock);
}

- (void)cancelTask:(NSString *)filepath
           inFiles:(NSMutableDictionary *)files
{
    NIMFileInfo *info = [files objectForKey:filepath];
    if (info)
    {
        [files removeObjectForKey:filepath];
        NSOperation *operation = info.operation;
        if (operation)
        {
            [operation cancel];
        }
    }
}

@end
