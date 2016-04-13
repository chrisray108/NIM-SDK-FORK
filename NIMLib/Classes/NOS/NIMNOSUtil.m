//
//  NIMNOSUtil.m
//  YixinCall
//
//  Created by amao on 12/26/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import "NIMNOSUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+NIM.h"

@import MobileCoreServices;

@implementation NIMNOSUtil
+ (NSString *)mimeType:(NSString *)filepath
{
    NSString *mimeType = nil;
    NSString *extension = [filepath pathExtension];
    if ([extension length])
    {
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
        CFStringRef mimeTypeRef = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
        CFRelease(UTI);
        if (!mimeTypeRef)
        {
            //某些机器无法解析某些后缀,加特别判断
            if ([extension isEqualToString:@"aac"])
            {
                mimeType = @"audio/aac";
            }
        }
        else
        {
            mimeType = CFBridgingRelease(mimeTypeRef);
        }
    }
    if (!mimeType)
    {
        mimeType = @"application/octet-stream";
    }
    return mimeType;
}

+ (NSString *)fileMD5:(NSString *)filepath
{
    NSString *md5 = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        md5 =  [data nim_md5];
    }
    return md5;
}


+ (unsigned long long)fileSize:(NSString *)filepath
{
    unsigned long long fileSize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath
                                                                                    error:nil];
        id item = [attributes objectForKey:NSFileSize];
        fileSize = [item isKindOfClass:[NSNumber class]] ? [item unsignedLongLongValue] : 0;
    }
    return fileSize;

}

@end


