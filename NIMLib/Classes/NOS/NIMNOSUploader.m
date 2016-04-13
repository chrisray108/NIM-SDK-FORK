//
//  NIMNOSUploader.m
//  YixinCall
//
//  Created by amao on 12/26/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import "NIMNOSUploader.h"
#import "NIMNOSUploadTask.h"
#import "NIMNOSTokenManager.h"

@interface NIMNOSUploader ()
@property (nonatomic,strong)    NSOperationQueue    *uploadQueue;
@end

@implementation NIMNOSUploader

- (instancetype)init
{
    if (self = [super init])
    {
        _uploadQueue = [[NSOperationQueue alloc] init];
        [_uploadQueue setMaxConcurrentOperationCount:3];
    }
    return self;
}

- (NSOperation *)upload:(NSString *)filepath
               progress:(NIMHttpProgressBlock)progress
             completion:(NIMUploadCompleteBlock)completion
{
    NIMNOSUploadTask *task = [NIMNOSUploadTask task:filepath
                                           progress:progress
                                           callback:completion];
    
    [_uploadQueue addOperation:task];
    NIMLogApp(@"add to upload queue, file %@",[filepath lastPathComponent]);
    return task;
}

@end
