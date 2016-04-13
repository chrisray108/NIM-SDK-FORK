//
//  NIMVideoObject.m
//  NIMLib
//
//  Created by chris on 15/1/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMVideoObject_Private.h"
#import "NSDictionary+NIMJson.h"
#import "NSString+NIM.h"
#import "NIMMessageDownloadParam.h"
#import "NIMUtil.h"
#import "NIMNOSUtil.h"
#import "NIMPathManager.h"
#import "UIImage+NIMUtil.h"
#import "NIMNOSResizer.h"
#import "NSFileManager+NIM.h"
#import "NSData+NIM.h"

#define NIMVideoMp4Ext  (@"mp4")

@interface NSString (NIMVideo)
@end

@implementation NSString (NIMVideo)

- (NSString *)nim_stringByAppendVideoCoverExt
{
    return [self stringByAppendingString:@".jpg"];
}

@end

@implementation NIMVideoObject

@synthesize message   = _message;

- (instancetype)initWithSourcePath:(NSString *)sourcePath
{
    self = [super init];
    if (self)
    {
        _sourcePath = [sourcePath copy];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
                   extension:(NSString *)extension
{
    self = [super init];
    if (self)
    {
        _sourceData = [data copy];
        _sourceExtension = [extension copy];
    }
    return self;
}

- (NIMMessageType)type{
    return NIMMessageTypeVideo;
}

#pragma mark - NIMMessageObject
- (NSString*)encodeContent{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    if (_displayName.length) {
        [dict setObject:_displayName forKey:NIMMessageObjTagDisplayName];
    }
    if (_url.length) {
        [dict setObject:_url forKey:NIMMessageObjTagUrl];
    }
    if (_md5.length) {
        [dict setObject:_md5 forKey:NIMMessageObjTagMD5];
    }
    NSString *ext = [_fileName pathExtension];
    if ([ext length]){
        [dict setObject:ext forKey:NIMMessageObjTagExt];
    }

    [dict setObject:@(_duration) forKey:NIMMessageObjTagDuration];
    [dict setObject:@(_fileLength) forKey:NIMMessageObjTagFileSize];
    [dict setObject:@(self.coverSize.width) forKey:NIMMessageObjTagPicWidth];
    [dict setObject:@(self.coverSize.height) forKey:NIMMessageObjTagPicHeight];

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
            _displayName      = [dict nim_jsonString:NIMMessageObjTagDisplayName];
            _url              = [dict nim_jsonString:NIMMessageObjTagUrl];
            _duration         = [dict nim_jsonInteger:NIMMessageObjTagDuration];
            _md5              = [dict nim_jsonString:NIMMessageObjTagMD5];
            _fileLength       = [dict nim_jsonLongLong:NIMMessageObjTagFileSize];
            _coverSize.width  = [dict nim_jsonDouble:NIMMessageObjTagPicWidth];
            _coverSize.height = [dict nim_jsonDouble:NIMMessageObjTagPicHeight];

            NSString *ext     = [dict nim_jsonString:NIMMessageObjTagExt];
            ext = [ext length] ? ext : NIMVideoMp4Ext;
            
            if ([_md5 length])
            {
                _fileName  = [_md5 nim_stringByAppendExt:ext];
                _coverName = [_md5 nim_stringByAppendVideoCoverExt];
            }
            if (_fileName == nil)
            {
                NSString *urlMD5 = [_url nim_md5];
                NSString *name = urlMD5 ? : [NIMUtil uuid];
                _fileName  = [name nim_stringByAppendExt:ext];
                _coverName = [name nim_stringByAppendVideoCoverExt];
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


- (NSError*)prepareForDownLoad{
    if (!self.fileParamForDownload.url.length) {
        return NIMLocalError(NIMLocalErrorCodeInvalidUrl);
    }
    return nil;
}

- (NSString *)filepathForUpload{
    return self.path;
}

- (BOOL)needUpload{
    return !self.url.length;
}

- (NIMMessageDownloadParam *)fileParamForDownload{
    NIMMessageDownloadParam *param = [[NIMMessageDownloadParam alloc] init];
    param.url                      = self.coverUrl;
    param.destinationPath          = self.coverPath;
    return param;
}


- (void)setUploadURL:(NSString *)urlString{
    self.url = urlString;
}

- (NSString*)uploadURL{
    return self.url;
}

- (CGSize)coverSize
{
    if (CGSizeEqualToSize(_coverSize, CGSizeZero))
    {
        NSString *path = [self coverPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            _coverSize = image ? image.size : CGSizeZero;
        }
    }
    return _coverSize;
}

#pragma mark - Geter & Setter

- (NSString*)path{
    return [[[NIMPathManager sharedManager] sdkNIMResourcePath] stringByAppendingPathComponent:self.fileName];
}

- (NSString*)coverPath{
    return [[[NIMPathManager sharedManager] sdkNIMResourcePath] stringByAppendingPathComponent:self.coverName];
}

- (NSString*)coverUrl{
    return [[NIMNOSResizer sharedResizer] videoThumbnailURL:self.url];
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *ext    = [self.sourcePath pathExtension];
    NSString *md5  = [NIMNOSUtil fileMD5:self.sourcePath];
    if ([md5 length])
    {
        self.md5        = md5;
        self.fileLength = [NIMNOSUtil fileSize:self.sourcePath];
        self.fileName   = [self.md5 nim_stringByAppendExt:ext];
        self.coverName  = [self.md5 nim_stringByAppendVideoCoverExt];
        
        
        //拷贝视频
        NSError * error = nil;
        res = [fileManager nim_copyFileAtPath:self.sourcePath
                                       toPath:self.path
                                        error:&error];
        if (res)
        {
            //生成缩略图
            UIImage * thumb = [NIMUtil generateThumbForVideo:self.sourcePath];
            self.coverSize  = thumb.size;
            if (![thumb nim_saveToFilepathWithJpeg:self.coverPath])
            {
                NIMLogErr(@"generate thumbnail failed %@",self.coverPath);
            }
            
            //如果上层已设置duration,就使用上层设置的duration
            if (self.duration == 0)
            {
                self.duration  = [NIMUtil mediaLengthForFile:self.sourcePath];
            }
        }
        else
        {
            NIMLogErr(@"copy %@ to %@ failed %@",self.sourcePath,self.path,error);
        }
    }
    else
    {
        NIMLogErr(@"handle video error %@",self.sourcePath);
    }

    return res;

}

- (BOOL)prepareByData
{
    BOOL res = NO;
    NSString *md5 = [self.sourceData nim_md5];
    NSString *ext = self.sourceExtension;
    if ([md5 length])
    {
        self.md5        = md5;
        self.fileLength = [self.sourceData length];
        self.fileName   = [self.md5 nim_stringByAppendExt:ext];
        self.coverName  = [self.md5 nim_stringByAppendVideoCoverExt];
        
        res = [self.sourceData nim_writeToFile:self.path];
        if (res)
        {
            //生成缩略图
            UIImage * thumb = [NIMUtil generateThumbForVideo:self.path];
            self.coverSize  = thumb.size;
            if (![thumb nim_saveToFilepathWithJpeg:self.coverPath])
            {
                NIMLogErr(@"generate thumbnail failed %@",self.coverPath);
            }
            
            //如果上层已设置duration,就使用上层设置的duration
            if (self.duration == 0)
            {
                self.duration  = [NIMUtil mediaLengthForFile:self.path];
            }
        }
        else
        {
            NIMLogErr(@"handle video data failed");
        }
    }
    else
    {
        NIMLogErr(@"handle video data failed");

    }
    return res;
}
@end
