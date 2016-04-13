//
//  NIMAudioObject.m
//  NIMLib
//
//  Created by chris on 15/1/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMAudioObject_Private.h"
#import "NSDictionary+NIMJson.h"
#import "NSString+NIM.h"
#import "NIMUtil.h"
#import "NIMPathManager.h"
#import "NIMMessageDownloadParam.h"
#import "NIMNOSUtil.h"
#import "NSString+NIM.h"
#import "NSFileManager+NIM.h"
#import "NSData+NIM.h"

#define NIMAudioAACExt  (@"aac")

@implementation NIMAudioObject

@synthesize message = _message;

- (instancetype)initWithSourcePath:(NSString *)sourcePath{
    self = [super init];
    if (self) {
        _sourcePath = [sourcePath copy];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
                   extension:(NSString *)extension
{
    self = [super init];
    if (self) {
        _sourceData = [data copy];
        _sourceExtension = [extension copy];
    }
    return self;
}

- (NIMMessageType)type{
    return NIMMessageTypeAudio;
}

- (NSString*)encodeContent{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    if (self.url.length) {
        [dict setObject:self.url forKey:NIMMessageObjTagUrl];
    }
    if (self.md5.length) {
        [dict setObject:self.md5 forKey:NIMMessageObjTagMD5];
    }
    
    NSString *ext = [self.fileName pathExtension];
    if ([ext length]){
        [dict setObject:ext forKey:NIMMessageObjTagExt];
    }
    
    [dict setObject:@(self.fileLength) forKey:NIMMessageObjTagFileSize];
    [dict setObject:@(self.duration) forKey:NIMMessageObjTagDuration];
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    if (data)
    {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else
    {
        NIMLogErr(@"encode object failed %@",dict);
        return nil;
    }
}

- (void)decodeWithContent:(NSString*)content{
    NSData * data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data)
    {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            _url              = [dict nim_jsonString:NIMMessageObjTagUrl];
            _duration         = [dict nim_jsonInteger:NIMMessageObjTagDuration];
            _fileLength       = [dict nim_jsonLongLong:NIMMessageObjTagFileSize];
            _md5              = [dict nim_jsonString:NIMMessageObjTagMD5];
            
            NSString * ext    = [dict nim_jsonString:NIMMessageObjTagExt];
            ext = [ext length] ? ext : NIMAudioAACExt;
            
            if ([_md5 length])
            {
                _fileName = [_md5 nim_stringByAppendExt:ext];
            }
            if (_fileName == nil)
            {
                NSString *urlMD5 = [_url nim_md5];
                NSString *name = urlMD5 ? : [NIMUtil uuid];
                _fileName = [name nim_stringByAppendExt:ext];
            }
        }
        else
        {
            NIMLogErr(@"decode object content failed %@",content);
        }
    }
    else
    {
        NIMLogErr(@"decode object content failed %@",content);
    }
}

- (NSString*)path{
    return [[[NIMPathManager sharedManager] sdkNIMResourcePath] stringByAppendingPathComponent:self.fileName];
}


- (NSError*)prepareForDownLoad{
    if (!self.fileParamForDownload.url.length) {
        return NIMLocalError(NIMLocalErrorCodeInvalidUrl);
    }
    return nil;
}

- (NSString*)filepathForUpload{
    return self.path;
}

- (BOOL)needUpload{
    return !self.url.length;
}

- (NIMMessageDownloadParam *)fileParamForDownload{
    NIMMessageDownloadParam * param = [[NIMMessageDownloadParam alloc] init];
    param.url                       = self.url;
    param.destinationPath           = self.path;
    return param;
}

- (void)setUploadURL:(NSString *)urlString{
    self.url = urlString;
}

- (NSString*)uploadURL{
    return self.url;
}


#pragma mark - 上传准备
- (NSError*)prepareForSend
{
    BOOL res = NO;
    if (self.sourcePath)
    {
        res = [self prepareByFilepath];
    }
    else if (self.sourceData)
    {
        res = [self prepareByData];
    }
    if (res)
    {
        self.sourcePath = nil;
        self.sourceData = nil;
        self.sourceExtension = nil;
    }
    return  res ? nil : NIMLocalError(NIMLocalErrorCodeInvalidMedia);
    
}

- (BOOL)prepareByFilepath
{
    BOOL res = NO;
    NSFileManager *fileManager =[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.sourcePath])
    {
        
        NSString * md5  = [NIMNOSUtil fileMD5:self.sourcePath];
        NSString *ext    = self.sourcePath.pathExtension;
        if (md5.length)
        {
            self.md5        = md5;
            self.fileLength = [NIMNOSUtil fileSize:self.sourcePath];
            self.fileName = [self.md5 nim_stringByAppendExt:ext];
            
            //如果上层已设置duration,就使用上层设置的duration
            if (self.duration == 0)
            {
                self.duration = [NIMUtil mediaLengthForFile:self.sourcePath];
            }
            
            NSError *error = nil;
            res = [fileManager nim_copyFileAtPath:self.sourcePath
                                           toPath:self.path
                                            error:&error];
            if (!res)
            {
                NIMLogErr(@"copy %@ to %@ failed %@",self.sourcePath,self.path,error);
            }
        }
        else
        {
            NIMLogErr(@"handle audio failed %@",self.sourcePath);
        }
    }
    else
    {
        NIMLogErr(@"handle audio failed %@",self.sourcePath);
    }
    return res;

}

- (BOOL)prepareByData
{
    BOOL res = NO;
    if (self.sourceData)
    {
        NSString *md5 = [self.sourceData nim_md5];
        NSString *ext = self.sourceExtension;
        if ([md5 length])
        {
            self.md5        = md5;
            self.fileLength = [self.sourceData length];
            self.fileName   = [self.md5 nim_stringByAppendExt:ext];
            
            res = [self.sourceData nim_writeToFile:self.path];
            
            if (res)
            {
                //如果上层已设置duration,就使用上层设置的duration
                if (self.duration == 0)
                {
                    self.duration = [NIMUtil mediaLengthForFile:self.path];
                }
            }
            else
            {
                NIMLogErr(@"handle audio failed for data");
            }
        }
        else
        {
            NIMLogErr(@"handle audio failed for data");
        }
    }
    else
    {
        NIMLogErr(@"handle audio failed for data");
    }
    return  res;
}


@end
