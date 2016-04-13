//
//  NIMNOSUploadTask.m
//  YixinCall
//
//  Created by amao on 12/26/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import "NIMNOSUploadTask.h"
#import "NIMNOSUtil.h"
#import "NIMSDK_Private.h"
#import "NIMNOSTokenManager.h"
#import "NIMUtil.h"
#import "NSDictionary+NIMJson.h"
#import "NIMGlobalDefs.h"
#import "NSString+NIM.h"
#import "NIMNetworkConfig.h"

#define MaxPartSize     (512 * 1024)
#define MinPartSize     (4 * 1024)


@interface NIMNOSUploadTask ()
//上传信息
@property (nonatomic,copy)      NSString *filepath;
@property (nonatomic,strong)    NIMNOSToken *token;
@property (nonatomic,copy)      NIMUploadCompleteBlock callback;
@property (nonatomic,copy)      NIMHttpProgressBlock progress;
@property (nonatomic,copy)      NSString *nosURL;
@property (nonatomic,copy)      NSString *fileMD5;

//上传中信息
@property (nonatomic,assign)    unsigned long long fileSize;
@property (nonatomic,assign)    unsigned long long offset;
@property (nonatomic,assign)    unsigned long long currentPartSize;
@property (nonatomic,strong)    NSFileHandle  *fileHandle;
@property (nonatomic,copy)      NSString *contentType;
@property (nonatomic,assign)    NSInteger lastHttpCode;

//上传结果
@property (nonatomic,copy)      NSString *urlString;
@property (nonatomic,strong)    NSError  *nosError;
@end

@implementation NIMNOSUploadTask
+ (instancetype)task:(NSString *)filepath
            progress:(NIMHttpProgressBlock)progress
            callback:(NIMUploadCompleteBlock)callback
{
    NIMNOSUploadTask *task = [[NIMNOSUploadTask alloc] init];
    task.filepath   = filepath;
    task.progress   = progress;
    task.callback   = callback;
    return task;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _currentPartSize = [self suggestMinPartSize];
        _nosURL = [[[NIMSDK sharedSDK] lbsManager] nosURL];
    }
    return self;

}

- (void)main
{
    if ([self isParamValid])
    {
        [self queryOffset];
        [self doUpload];
    }
    else
    {
        NIMLogErr(@"invalid upload param %@ error %@",_filepath,_nosError);
    }
    [self raiseCallback];
}


#pragma mark - 检查上传参数
- (BOOL)isParamValid
{
    BOOL valid = YES;
    
    do
    {
        if (![[NSFileManager defaultManager] fileExistsAtPath:_filepath] ||
            (_fileSize = [NIMNOSUtil fileSize:_filepath]) == 0)
        {
            _nosError = NIMLocalError(NIMLocalErrorCodeIOError);
            valid = NO;
            break;
        }
        else
        {
            _fileHandle = [NSFileHandle fileHandleForReadingAtPath:_filepath];
            if (_fileHandle == nil)
            {
                _nosError = NIMLocalError(NIMLocalErrorCodeIOError);
                valid = NO;
                break;
            }
        }
        
        self.fileMD5 = [NIMNOSUtil fileMD5:_filepath];
        self.token = [[NIMNOSTokenManager sharedManager] tokenByMD5:self.fileMD5];
        
        
        if ([[_token token] length] == 0||
            [[_token bucketName] length] == 0 ||
            [[_token objectName] length] == 0)
        {
            _nosError = NIMLocalError(NIMLocalErrorCodeInvalidToken);
            valid = NO;
            break;
        }
        
        _contentType = [NIMNOSUtil mimeType:_filepath];
        
        NIMLogApp(@"check file info %@\n\nmd5 %@\n\ntoken %@\n\ncontent type %@",_filepath,_fileMD5,_token,_contentType);
        
    }
    while (0);
    return valid;
}

- (void)queryOffset
{
    if ([_token.context length] == 0)
    {
        NIMLogApp(@"cache upload info not exists %@",self.fileMD5);
        return;
    }
    [self raiseProgressCallback];
    NSMutableString *uploadURL = [[NSMutableString alloc] initWithString:_nosURL];
    [uploadURL appendFormat:@"/%@/%@",_token.bucketName,_token.objectName];
    [uploadURL appendFormat:@"?uploadContext&context=%@&version=1.0",_token.context];
    NSURL *url = [NSURL URLWithString:uploadURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setTimeoutInterval:20];
    [request addValue:[_token token]
   forHTTPHeaderField:@"x-nos-token"];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request
                                                returningResponse:&response
                                                            error:&error];
    
    NSInteger responseCode = [response isKindOfClass:[NSHTTPURLResponse class]] ?
    [(NSHTTPURLResponse *)response statusCode] : 0;
    

    
    if (error == nil && responseCode != 0)
    {
        if (responseCode == 200)
        {
            if (responseData)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:0
                                                                       error:0];
                if ([dict isKindOfClass:[NSDictionary class]])
                {
                    self.offset = [dict nim_jsonUnsignedLongLong:@"offset"];
                    NIMLogApp(@"query offset successfully %llu for %@",self.offset,self.fileMD5);
                }
            }
        }
        else
        {
            [[NIMNOSTokenManager sharedManager] removeTokenByMD5:self.fileMD5];
            self.token = [[NIMNOSTokenManager sharedManager] fetchToken];
            NIMLogApp(@"fetch token again status code %zd token",responseCode,self.token);
        }
    }
}


#pragma mark - 上传过程
- (void)doUpload
{
    NIMLogApp(@"begin upload %@ to %@/%@/%@",[_filepath lastPathComponent],_nosURL,[_token bucketName],[_token objectName]);
    BOOL failedOnce = NO;
    [self raiseProgressCallback];
    while (_offset < _fileSize && ![self isCancelled])
    {
        if ([self uploadNextPart])
        {
            if (!failedOnce)    //每次上传成功都尝试增大上传块大小
            {
                _currentPartSize = MIN(_currentPartSize * 2, MaxPartSize);
            }
        }
        else
        {
            if (failedOnce)
            {
                break;
            }
            else
            {
                failedOnce = YES;   //失败一次后降低上传块大小,并一直以这个块进行上传
                _currentPartSize = MAX(_currentPartSize / 2, MinPartSize);
            }
        }
        [self raiseProgressCallback];
    }
    BOOL success = _offset == _fileSize && _offset != 0;
    if (success)
    {
        [self generateURL];
    }
    else
    {
        _nosError =  [NSError errorWithDomain:NIMLocalErrorDomain
                                         code:NIMLocalErrorCodeHttpReqeustFailed
                                     userInfo:@{@"http code" : @(_lastHttpCode)}];
        BOOL isCancelled = [self isCancelled];
        NIMLogErr(@"upload %@ failed offset %lld size %lld nos url %@ is cancelled %d",[_filepath lastPathComponent],_offset,_fileSize,_nosURL,isCancelled);
        if (!isCancelled)
        {
            [[[NIMSDK sharedSDK] lbsManager] reportError:NIMLbsTypeNOS
                                                   fatal:NO];
        }
        
    }
    NIMLogApp(@"end upload %@ to %@/%@/%@",[_filepath lastPathComponent],_nosURL,[_token bucketName],[_token objectName]);
}

- (BOOL)uploadNextPart
{
    @autoreleasepool
    {
        NIMLogApp(@"begin upload part offset %d to %@/%@/%@",
                  _offset,_nosURL,[_token bucketName],[_token objectName]);
        BOOL success = NO;
        [_fileHandle seekToFileOffset:_offset];
        NSData *data = [_fileHandle readDataOfLength:(NSUInteger)_currentPartSize];
        NSUInteger dataLength = [data length];
        if (dataLength)
        {
            BOOL complete = _offset + dataLength >= _fileSize;
            if ([self uploadData:data
                        complete:complete])
            {
                _offset += dataLength;
                success = YES;
            }
        }
        NIMLogApp(@"end upload part offset %d length %@ to %@/%@/%@ result %d",
                  _offset,@(dataLength),_nosURL,[_token bucketName],[_token objectName],success);
        return success;
    }
}

- (BOOL)uploadData:(NSData *)data
          complete:(BOOL)complete
{
    BOOL success = NO;
    NSArray *timeouts = @[@(20),@(30)];
    for (NSNumber *timeout in timeouts)
    {
        unsigned long long expectedOffset = [data length] + _offset;
        
        NSMutableString *uploadURL = [[NSMutableString alloc] initWithString:_nosURL];
        [uploadURL appendFormat:@"/%@/%@",_token.bucketName,_token.objectName];
        [uploadURL appendFormat:@"?offset=%llu&complete=%@&version=1.0",
         _offset,complete ? @"true" : @"false"];
        if([_token.context length])
        {
            [uploadURL appendFormat:@"&context=%@",_token.context];
        }
        NSURL *url = [NSURL URLWithString:uploadURL];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setTimeoutInterval:[timeout doubleValue]];
        [request setHTTPMethod:@"POST"];
        [request addValue:_contentType
       forHTTPHeaderField:@"Content-Type"];
       [request addValue:[_token token] forHTTPHeaderField:@"x-nos-token"];
        [request setHTTPBody:data];
        
        
        
        NSError *error = nil;
        NSURLResponse *response = nil;
        NSData *responseData =[NSURLConnection sendSynchronousRequest:request
                                                    returningResponse:&response
                                                                error:&error];
        
        NSInteger responseCode = [response isKindOfClass:[NSHTTPURLResponse class]] ?
        [(NSHTTPURLResponse *)response statusCode] : 0;
        
        if (responseCode == 200  &&
            error == nil &&
            [responseData length]
            )
        {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:0
                                                                       error:nil];
            if ([jsonDict isKindOfClass:[NSDictionary class]])
            {
                unsigned long long offset = [jsonDict nim_jsonUnsignedLongLong:@"offset"];
                NSString *context = [jsonDict nim_jsonString:@"context"];
                if ([context length])
                {
                    BOOL isTokenContextEmpty = [_token.context length] == 0;
                    _token.context = context;
                    if (isTokenContextEmpty)
                    {
                        [[NIMNOSTokenManager sharedManager] saveToken:self.token
                                                               forMD5:self.fileMD5];
                    }
                }
                success = expectedOffset == offset;
            }
            else
            {
                NIMLogErr(@"invalid data");
            }
        }
        else
        {
            _lastHttpCode = responseCode;
            NIMLogErr(@"upload failed %@  code %zd error %@ time %@",uploadURL,responseCode,error,timeout);
            if (responseCode == 403 || responseCode == 400) //token失效,如果token失效,那么说明DB里面的数据应该都有问题，统一做清理
            {
                [[NIMNOSTokenManager sharedManager] removeAllTokens];
                break;
            }
        }
        if (success)
        {
            break;
        }
    }
    return success;
}

- (void)generateURL
{

    NSString *nosDownloadURL = [[[NIMSDK sharedSDK] setting] nosDownloadAddress];
    NSString *urlString = [NSString stringWithFormat:nosDownloadURL,[_token bucketName],[_token objectName]];
    _urlString = [urlString nim_urlDecodeString];//梁叔把token的objectNameEncode了一把(为了兼容NOS).. 这里需要Decode回来
    _nosError  = nil;
    [[NIMNOSTokenManager sharedManager] removeTokenByMD5:self.fileMD5];
}



#pragma mark - 回调
- (void)raiseCallback
{
    NIMLogApp(@"%@",self);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_callback)
        {
            _callback(_urlString,_nosError);
        }
    });
}

- (void)raiseProgressCallback
{
    CGFloat progress = _fileSize == 0 ? 0 : _offset * 1.0 / _fileSize;
    NIMLogApp(@"%@ %lf",self,progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_progress)
        {
            _progress(progress);
        }
    });
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"file %@ url %@ error %@",
            [_filepath lastPathComponent],_urlString,_nosError];
}

#pragma mark - 上传配置
- (unsigned long long)suggestMinPartSize
{
    unsigned long long partSize = MinPartSize;
    NIMNetworkType type = [[NIMNetworkConfig sharedConfig] currentNetworkType];
    switch (type) {
        case NIMNetworkTypeWWAN:
            partSize = MinPartSize * 2;
            break;
        case NIMNetworkType3G:
            partSize = MinPartSize * 4;
            break;
        case NIMNetworkType4G:
        case NIMNetworkTypeWifi:
            partSize = MinPartSize * 8;
            break;
        default:
            break;
    }
    return partSize;
}
@end
