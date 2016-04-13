//
//  NIMFileObject.m
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMFileObject_Private.h"
#import "NSDictionary+NIMJson.h"
#import "NSString+NIM.h"
#import "NIMPathManager.h"
#import "NIMNOSUtil.h"
#import "NIMUtil.h"
#import "NIMMessageDownloadParam.h"
#import "NSFileManager+NIM.h"
#import "NSData+NIM.h"

@implementation NIMFileObject

@synthesize message    = _message;

- (instancetype)initWithSourcePath:(NSString *)sourcePath{
    self = [super init];
    if (self)
    {
        _sourceFilepath = [sourcePath copy];
        _ext = [sourcePath pathExtension];
    }
    return self;
}

- (instancetype)initWithData:(NSData*)data extension:(NSString*)extension{
    self = [super init];
    if (self)
    {
        _sourceData = [data copy];
        _ext    = [extension copy];
    }
    return self;
}

- (NIMMessageType)type{
    return NIMMessageTypeFile;
}

- (NSString*)encodeContent{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    if (self.url.length) {
        [dict setObject:self.url forKey:NIMMessageObjTagUrl];
    }
    if (self.md5.length) {
        [dict setObject:self.md5 forKey:NIMMessageObjTagMD5];
    }
    if (self.displayName.length) {
        [dict setObject:self.displayName forKey:NIMMessageObjTagDisplayName];
    }
    if (self.ext.length){
        [dict setObject:self.ext forKey:NIMMessageObjTagExt];
    }
    
    [dict setObject:@(self.fileLength) forKey:NIMMessageObjTagFileSize];
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
            _fileLength       = [dict nim_jsonLongLong:NIMMessageObjTagFileSize];
            _md5              = [dict nim_jsonString:NIMMessageObjTagMD5];
            _displayName      = [dict nim_jsonString:NIMMessageObjTagDisplayName];
            NSString *ext     = [dict nim_jsonString:NIMMessageObjTagExt];
            _ext              = [ext length] ? ext : @"";
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
    NSString *fileName = nil;
    if ([_md5 length])
    {
        fileName = [_md5 nim_stringByAppendExt:self.ext];
    }
    if (fileName == nil)
    {
        NSString *urlMD5 = [_url nim_md5];
        NSString *name = urlMD5 ? : [NIMUtil uuid];
        fileName = [name nim_stringByAppendExt:self.ext];
    }
    return fileName.length ? [[[NIMPathManager sharedManager] sdkNIMResourcePath] stringByAppendingPathComponent:fileName] : @"";
}



- (NSString*)filepathForUpload{
    return self.path;
}

- (BOOL)needUpload{
    return !self.url.length;
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
    if (self.sourceFilepath)
    {
        res = [self prepareByFilepath];
    }
    else if (self.sourceData)
    {
        res = [self prepareByData];
    }
    if (res)
    {
        self.sourceFilepath = nil;
        self.sourceData = nil;
    }
    return  res ? nil : NIMLocalError(NIMLocalErrorCodeIOError);
}

- (BOOL)prepareByFilepath
{
    BOOL res = NO;
    NSFileManager *fileManager =[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.sourceFilepath])
    {

        NSString  *md5  = [NIMNOSUtil fileMD5:self.sourceFilepath];
        if (md5.length)
        {
            self.md5            = md5;
            self.fileLength     = [NIMNOSUtil fileSize:self.sourceFilepath];
            
            NSError *error = nil;
            res = [fileManager nim_copyFileAtPath:self.sourceFilepath
                                           toPath:self.path
                                            error:&error];
            if (!res)
            {
                NIMLogErr(@"copy %@ to %@ failed %@",self.sourceFilepath,self.path,error);
            }
        }
        else
        {
            NIMLogErr(@"handle file failed %@",self.sourceFilepath);
        }
    }
    else
    {
        NIMLogErr(@"handle file failed %@",self.sourceFilepath);
    }
    return res;

}

- (BOOL)prepareByData
{
    BOOL res = NO;
    NSString *md5  = [self.sourceData nim_md5];
    if ([md5 length])
    {
        self.md5    = md5;
        self.fileLength = [self.sourceData length];
        res = [self.sourceData nim_writeToFile:self.path];
        if (!res)
        {
            NIMLogErr(@"save file data failed for %@",self.path);
        }
        
    }
    else
    {
        NIMLogErr(@"handle file data failed");
    }
    return  res;
}

@end
