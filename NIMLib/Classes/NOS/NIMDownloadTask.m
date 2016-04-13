//
//  NIMDownloadTask.m
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMDownloadTask.h"
#import "NIMUtil.h"
#import "NSString+NIM.h"
#import "NSData+NIM.h"
#import "NIMGlobalDefs.h"
#import "NIMDownloadFileWriter.h"
#import "NIMPathManager.h"

@interface NIMHttpThread : NSObject
@end

@implementation NIMHttpThread
+ (NSThread *)thread
{
    static NSThread *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSThread alloc] initWithTarget:self
                                           selector:@selector(threadStart:)
                                             object:nil];
        [instance start];
    });
    return instance;
}

+ (void)threadStart:(id)sender
{
    @autoreleasepool
    {
        [[NSThread currentThread] setName:@"com.netease.download.thread"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

@end

@interface NIMDownloadTask ()
@property (nonatomic,copy)  NSString    *urlString;
@property (nonatomic,copy)  NSString    *filepath;
@property (nonatomic,copy)  NIMHttpProgressBlock        progress;
@property (nonatomic,copy)  NIMDownloadCompleteBlock    callback;

@property (nonatomic,strong)    NSURLConnection *connection;
@property (nonatomic,strong)    NIMDownloadFileWriter *writer;
@property (nonatomic,copy)      NSString        *tempFilepath;
@property (nonatomic,strong)    NSError         *lastError;
@property (nonatomic,strong)    NSURLRequest    *request;
@property (nonatomic,assign)    NSInteger       statusCode;
@property (nonatomic,assign)    unsigned long long       expectedSize;
@property (nonatomic,assign)    unsigned long long       currentReceived;
@end

@implementation NIMDownloadTask
+ (instancetype)task:(NSString *)urlString
            filepath:(NSString *)filepath
            progress:(NIMHttpProgressBlock)progress
          completion:(NIMDownloadCompleteBlock)completion
{
    NIMDownloadTask *task = [[NIMDownloadTask alloc]init];
    task.urlString = [urlString nim_accURLString];
    task.filepath = filepath;
    task.progress = progress;
    task.callback = completion;
    return task;
}


- (void)main
{
    if (![self isParamValid])
    {
        [self raiseCallback];
        return;
    }
    
    
    @synchronized(self)
    {
        if (self.isCancelled)
        {
            return;
        }
        NSURL *url = [NSURL URLWithString:_urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                timeoutInterval:30];
        unsigned long long offset = [_writer fileSize];
        if (offset)
        {
            NSString *range = [NSString stringWithFormat:@"bytes=%llu-",offset];
            [request addValue:range
           forHTTPHeaderField:@"Range"];
            _currentReceived = offset;
        }
        
        self.request = request;
        if (_request == nil ||
            ![NSURLConnection canHandleRequest:_request])
        {
            _lastError = NIMLocalError(NIMLocalErrorCodeInvalidParam);
            [self raiseCallback];
            NIMLogErr(@"invalid request %@",[_request URL]);
            return;
        }
        
    
        [self performSelector:@selector(request:)
                     onThread:[NIMHttpThread thread]
                   withObject:nil
                waitUntilDone:NO];
    }
}

- (BOOL)isParamValid
{
    BOOL valid = YES;
    do
    {
        if ([_filepath length] == 0 || [_urlString length] == 0)
        {
            _lastError = NIMLocalError(NIMLocalErrorCodeInvalidParam);
            valid = NO;
            NIMLogErr(@"invalid download param %@ %@",_urlString,[_filepath lastPathComponent]);
            break;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:_filepath])
        {
            _lastError = nil;
            valid = NO;
            NIMLogWar(@"filepath for downloading %@ exists %@",_urlString,[_filepath lastPathComponent]);
            break;
        }
        
        [self genTempFilepath];
        _writer = [NIMDownloadFileWriter fileWriter:_tempFilepath];
        
        if (_writer == nil)
        {
            _lastError = NIMLocalError(NIMLocalErrorCodeIOError);
            valid = NO;
            NIMLogErr(@"io error %@",[_filepath lastPathComponent]);
        }
        
    }
    while (0);
    return valid;
}

- (void)genTempFilepath
{
    NSString *filename = [_filepath nim_md5];
    if (filename == nil)
    {
        filename = [_urlString nim_md5];
        if (filename == nil)
        {
            filename = [NIMUtil uuid];
        }
    }
    _tempFilepath = [[[NIMPathManager sharedManager] sdkTempPath] stringByAppendingPathComponent:filename];
}

- (void)cancel
{
    @synchronized(self)
    {
        if (![self isCancelled])
        {
            [super cancel];
            [self cancelConnection];
        }
    }
}

- (void)cancelConnection
{
    [self.connection cancel];
    self.connection = nil;
}


- (void)request:(id)sender
{
    @synchronized(self)
    {
        self.connection = [NSURLConnection connectionWithRequest:self.request
                                                        delegate:self];
    }
}


#pragma mark - NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NIMLogErr(@"request %@ failed %@",[_request URL],error);
    _lastError = error;
    [self raiseCallback];
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        _statusCode = [(NSHTTPURLResponse *)response statusCode];
        _expectedSize = [response expectedContentLength];
    }
    
    
    switch (_statusCode) {
        case 200:
        {
            if (_currentReceived != 0) //如果服务器不支持range,需要reset Writer
            {
                 NIMLogApp(@"range not support for %@",_urlString);
                if (![_writer clearData])
                {
                    @synchronized(self)
                    {
                        [self cancelConnection];
                    }
                    _lastError = NIMLocalError(NIMLocalErrorCodeIOError);
                    [self raiseCallback];
                    return;
                }
            }
            _currentReceived = 0;
            [self raiseProgressCallback];
        }
            break;
        case 206:
        {
            _expectedSize += _currentReceived;
            [self raiseProgressCallback];
        }
            break;
        default:
        {
            @synchronized(self)
            {
                [self cancelConnection];
            }
            _lastError = [NSError errorWithDomain:NIMLocalErrorDomain
                                             code:NIMLocalErrorCodeHttpReqeustFailed
                                         userInfo:@{@"http code" : @(_statusCode)}];
            [self raiseCallback];
            if (_statusCode)
            {
                NIMLogErr(@"download %@ failed code %zd",_urlString,_statusCode);
                [self removeTempFile];
            }
        }
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_statusCode != 200 && _statusCode != 206)
    {
        NIMLogErr(@"invalid code path for download %@",_urlString);
        return;
    }
    if (_lastError)
    {
        NIMLogApp(@"data should not be received when error occured %@",_lastError);
        return;
    }
    
    
    [_writer writeData:data];
    _currentReceived += [data length];
    [self raiseProgressCallback];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_writer close];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:_tempFilepath
                                            toPath:_filepath
                                             error:&error];
    
    if (error) //如果有错误发生,删除临时文件
    {
        _lastError = error;
        [self removeTempFile];
    }
    
    
    [self raiseCallback];
}

#pragma mark - misc 
- (void)raiseCallback
{
    NSError *error = _lastError;
    NIMLogApp(@"request %@ status code %zd error %@",_urlString,_statusCode,error);

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback)
        {
            self.callback(error);
        }
    });
}

- (void)raiseProgressCallback
{
    if (_expectedSize)
    {
        CGFloat progress = _currentReceived * 1.0 / _expectedSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progress)
            {
                self.progress(progress);
            }
        });
    }
}

- (void)removeTempFile
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:_tempFilepath
                                               error:&error];
    if (error)
    {
        NIMLogErr(@"remove path %@ failed for downloading %@",
                  [_tempFilepath lastPathComponent],_urlString);
    }
}

@end

