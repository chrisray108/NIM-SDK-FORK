//
//  NIMCustomObject.m
//  NIMLib
//
//  Created by chris on 15/1/21.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMCustomObject_Private.h"
#import "NIMMessageDownloadParam.h"
#import "NSString+NIM.h"
#import "NIMPathManager.h"
#import "NIMValidator.h"
#import "NIMNonEmptyStringValidator.h"



static id<NIMCustomAttachmentCoding> attachmentDecoder = nil;

@implementation NIMCustomObject

@synthesize message = _message;

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

- (NIMMessageType)type{
    return NIMMessageTypeCustom;
}


- (NSString*)encodeContent
{
    NSString *content = nil;
    if ([_attachment respondsToSelector:@selector(encodeAttachment)])
    {
        NIMTry
        {
            content = [_attachment encodeAttachment];
        }
        NIMCatch (NSException *exception)
        {
            content = nil;
            NIMLogErr(@"encode custom content failed %@",exception);
        }
        NIMCatch(...)
        {
            content = nil;
            NIMLogErr(@"encode custom content failed");
        }
        
    }
    return content;
}

- (void)decodeWithContent:(NSString*)content
{
    id<NIMCustomAttachment> attachment = nil;
    if (attachmentDecoder && [attachmentDecoder respondsToSelector:@selector(decodeAttachment:)])
    {
        NIMTry
        {
            attachment = [attachmentDecoder decodeAttachment:content];
        }
        NIMCatch (NSException *exception)
        {
            attachment = nil;
            NIMLogErr(@"decode custom content failed %@ error %@",content,exception);
        }
        NIMCatch(...)
        {
            attachment = nil;
            NIMLogErr(@"decode custom content failed %@",content);
        }
    }
    
    self.attachment = attachment;
}


#pragma mark - 上传相关的接口
- (NSString*)filepathForUpload{
    NSString *filepath = nil;
    if ([_attachment respondsToSelector:@selector(attachmentPathForUploading)]) {
        filepath = [_attachment attachmentPathForUploading];
    }
    return filepath;
}

- (BOOL)needUpload{
    return [_attachment respondsToSelector:@selector(attachmentNeedsUpload)] &&
    [_attachment attachmentNeedsUpload];
}

- (void)setUploadURL:(NSString *)urlString{
    if ([_attachment respondsToSelector:@selector(updateAttachmentURL:)]) {
        [_attachment updateAttachmentURL:urlString];
    }
}


#pragma mark - 下载相关的接口
- (BOOL)needsDownloadAttachment
{
    return [_attachment respondsToSelector:@selector(attachmentNeedsDownload)] &&
           [_attachment attachmentNeedsDownload];
}


- (NSError*)prepareForDownLoad{
    
    if ([self needsDownloadAttachment] &&
        [_attachment respondsToSelector:@selector(attachmentURLStringForDownloading)] &&
        [_attachment respondsToSelector:@selector(attachmentPathForDownloading)])
    {
        NSString *url = [_attachment attachmentURLStringForDownloading];
        NSString *path= [_attachment attachmentPathForDownloading];
        NIMAndValidator *validator = [NIMAndValidator validator:@[[NIMNonEmptyStringValidator validator:url],
                                                                  [NIMNonEmptyStringValidator validator:path]]];
        if ([validator isValid])
        {
            return nil;
        }
        return NIMLocalError(NIMLocalErrorCodeInvalidParam);
    }
    return NIMLocalError(NIMLocalErrorCodeInvalidParam);
}

- (NIMMessageDownloadParam *)fileParamForDownload
{
    NIMMessageDownloadParam * param = [[NIMMessageDownloadParam alloc] init];
    if ([_attachment respondsToSelector:@selector(attachmentURLStringForDownloading)])
    {
        param.url = [_attachment attachmentURLStringForDownloading];
    }
    if ([_attachment respondsToSelector:@selector(attachmentPathForDownloading)])
    {
        param.destinationPath = [_attachment attachmentPathForDownloading];
    }
    return param;
}


#pragma mark - 反序列化接口
+ (void)registerCustomDecoder:(id<NIMCustomAttachmentCoding>)decoder
{
    attachmentDecoder = decoder;
}


@end
