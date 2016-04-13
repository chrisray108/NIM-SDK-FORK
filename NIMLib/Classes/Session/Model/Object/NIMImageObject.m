//
//  NIMImageObject.m
//  NIMLib
//
//  Created by chris on 15/1/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMImageObject_Private.h"
#import "NSDictionary+NIMJson.h"
#import "NSString+NIM.h"
#import "NSData+NIM.h"
#import "UIImage+NIMUtil.h"
#import "NIMPathManager.h"
#import "NIMUtil.h"
#import "NIMNOSResizer.h"
#import "NIMNOSUtil.h"
#import "NIMMessageDownloadParam.h"
#import "NSFileManager+NIM.h"
#import "NSData+NIM.h"

#define NIMImageJpegExt     (@"jpg")
#define NIMImagePngExt      (@"png")

@implementation NIMImageOption
- (CGFloat)imageCompressQuality
{
    if (_compressQuality >= 0 && _compressQuality <= 1.0)
    {
        return _compressQuality;
    }
    return 0.5;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _compressQuality = 0.5;
        _format = NIMImageFormatJPEG;
    }
    return self;
}
@end

@implementation NIMImageObject

@synthesize message   = _message;

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        _sourceImage = image;
    }
    return self;
}

- (instancetype)initWithFilepath:(NSString *)filepath
{
    if (self = [super init])
    {
        _sourceFilepath = [filepath copy];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
                   extension:(NSString *)extension
{
    if (self = [super init])
    {
        _sourceData = [data copy];
        _sourceExtension = [extension copy];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString*)encodeContent{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    if (self.displayName.length) {
        [dict setObject:self.displayName forKey:NIMMessageObjTagDisplayName];
    }
    if (self.url.length) {
        [dict setObject:self.url forKey:NIMMessageObjTagUrl];
    }
    if (self.md5.length) {
        [dict setObject:self.md5 forKey:NIMMessageObjTagMD5];
    }
    NSString *ext = [_fileName pathExtension];
    if ([ext length])
    {
        [dict setObject:ext forKey:NIMMessageObjTagExt];
    }
    
    [dict setObject:@(self.size.width) forKey:NIMMessageObjTagPicWidth];
    [dict setObject:@(self.size.height) forKey:NIMMessageObjTagPicHeight];
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
            _displayName      = [dict nim_jsonString:NIMMessageObjTagDisplayName];
            _url              = [dict nim_jsonString:NIMMessageObjTagUrl];
            _size.width       = [dict nim_jsonDouble:NIMMessageObjTagPicWidth];
            _size.height      = [dict nim_jsonDouble:NIMMessageObjTagPicHeight];
            _md5              = [dict nim_jsonString:NIMMessageObjTagMD5];
            _fileLength       = [dict nim_jsonLongLong:NIMMessageObjTagFileSize];
            
            NSString *ext     = [dict nim_jsonString:NIMMessageObjTagExt];
            ext = [ext length] ? ext : NIMImageJpegExt;
            
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

#pragma mark - NIMMessageObject_Private
- (NSString *)filepathForUpload{
    return self.path;
}

- (BOOL)needUpload{
    return !self.url.length;
}

- (NIMMessageDownloadParam *)fileParamForDownload{
    NIMMessageDownloadParam * param = [[NIMMessageDownloadParam alloc] init];
    param.url             = self.thumbUrl;
    param.destinationPath = self.thumbPath;
    return param;
}

- (void)setUploadURL:(NSString *)urlString{
    self.url = urlString;
}

- (NSString*)uploadURL{
    return self.thumbUrl;
}


- (NIMMessageType)type{
    return NIMMessageTypeImage;
}

- (NSError*)prepareForDownLoad
{
    if (!self.fileParamForDownload.url.length)
    {
        return NIMLocalError(NIMLocalErrorCodeInvalidUrl);
    }
    return nil;
}

#pragma mark - Geter & Seter
- (NSString*)imageName{
    return _fileName;
}

- (NSString*)thumbName{
    NSString *imageName = [self imageName];
    return imageName ? [@"thumb_" stringByAppendingString:imageName] : nil;
}

- (NSString*)thumbUrl
{
    return [[NIMNOSResizer sharedResizer] imageThumbnailURL:self.url];
}

- (NSString*)path{
    return [[[NIMPathManager sharedManager] sdkNIMResourcePath] stringByAppendingPathComponent:self.imageName];
}

- (NSString*)thumbPath{
    return [[[NIMPathManager sharedManager] sdkNIMResourcePath] stringByAppendingPathComponent:self.thumbName];
}

- (CGSize)size
{
    if (CGSizeEqualToSize(_size, CGSizeZero))
    {
        if (self.sourceImage)
        {
            _size = self.sourceImage.size;
        }
        else if (self.sourceFilepath)
        {
            UIImage *image = [UIImage imageWithContentsOfFile:self.sourceFilepath];
            _size = image ? image.size : CGSizeZero;

        }
        else if (self.sourceData)
        {
            UIImage *image = [UIImage imageWithData:self.sourceData];
            _size = image ? image.size : CGSizeZero;
        }
        else
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *path = self.path;
            if ([fileManager fileExistsAtPath:path])
            {
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                _size = image ? image.size : CGSizeZero;

            }
        }
        
    }
    return _size;
}


#pragma mark - 上传准备
- (NSError*)prepareForSend
{
    BOOL res = NO;
    if (self.sourceImage)
    {
        res = [self prepareByImage];
    }
    else if (self.sourceFilepath)
    {
        res = [self prepareByFilepath];
    }
    else if (self.sourceData)
    {
        res = [self prepareByData];
    }
    if (res)
    {
        self.sourceImage = nil;
        self.sourceData = nil;
        self.sourceFilepath = nil;
        self.sourceExtension = nil;
    }
    
    return res ? nil : NIMLocalError(NIMLocalErrorCodeInvalidPicture);
}


- (BOOL)prepareByImage
{
    BOOL res = NO;
    NSData *data = nil;
    NSString *ext = nil;
    NIMImageOption *option = self.option ? : [[NIMImageOption alloc] init];
    if (option.format == NIMImageFormatPNG)
    {
        data = UIImagePNGRepresentation(self.sourceImage);
        ext  =  NIMImagePngExt;
    }
    else
    {
        data = UIImageJPEGRepresentation(self.sourceImage, [option imageCompressQuality]);
        ext  = NIMImageJpegExt;
    }
    
    NSString *md5 = [data nim_md5];
    if (data && [md5 length])
    {
        _size = self.sourceImage.size;
        _md5 = md5;
        _fileName = [_md5 nim_stringByAppendExt:ext];
        _fileLength = data.length;
        
        res = [data nim_writeToFile:[self path]];
        
        if (res)
        {
            UIImage *thumb = [self.sourceImage nim_thumb];
            res = [thumb nim_saveToFilepathWithJpeg:[self thumbPath]];
            
            if (!res)
            {
                NIMLogErr(@"handle image @ failed",[self thumbPath]);
            }
        }
        else
        {
            NIMLogErr(@"handle image @ failed",[self path]);
        }
    }
    return res;
}

- (BOOL)prepareByFilepath
{
    BOOL res = NO;
    UIImage *image = [UIImage imageWithContentsOfFile:_sourceFilepath];
    if (image)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *md5 = [NIMNOSUtil fileMD5:_sourceFilepath];
        NSString *pathExtension = [_sourceFilepath pathExtension];
        NSString *ext = [pathExtension length] ? pathExtension : NIMImageJpegExt;
        if ([md5 length])
        {
            
            _size = image.size;
            _md5 = md5;
            _fileName = [_md5 nim_stringByAppendExt:ext];
            _fileLength = [NIMNOSUtil fileSize:_sourceFilepath];
            
            res = [fileManager nim_copyFileAtPath:_sourceFilepath
                                           toPath:self.path
                                            error:nil];
            
            
            if (res)
            {
                UIImage *thumb = [image nim_thumb];
                res = [thumb nim_saveToFilepathWithJpeg:[self thumbPath]];
                if (!res)
                {
                    NIMLogErr(@"handle image @ failed",[self thumbPath]);
                }
            }
            else
            {
                NIMLogErr(@"handle image @ failed",_sourceFilepath);
            }
        }
    }
    else
    {
        NIMLogWar(@"can't init from filepath %@ to image",_sourceFilepath);
    }
    return res;
}

- (BOOL)prepareByData
{
    BOOL res = NO;
    UIImage *image = [UIImage imageWithData:_sourceData];
    if (image)
    {
        NSString *md5 = [_sourceData nim_md5];
        NSString *ext = self.sourceExtension;
        if ([md5 length])
        {
            _size = image.size;
            _md5 = md5;
            _fileName = [_md5 nim_stringByAppendExt:ext];
            _fileLength = [_sourceData length];
            
            res = [_sourceData nim_writeToFile:self.path];
            
            if (res)
            {
                UIImage *thumb = [image nim_thumb];
                res = [thumb nim_saveToFilepathWithJpeg:[self thumbPath]];
                if (!res)
                {
                    NIMLogErr(@"handle image @ failed",[self thumbPath]);
                }
            }
            else
            {
                NIMLogErr(@"handle image data failed");
            }
        }
    }
    else
    {
        NIMLogWar(@"can't init from data to image");
    }
    return res;
}

@end
