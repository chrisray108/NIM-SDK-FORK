//
//  NIMAMRDecoder.m
//  NIM
//
//  Created by amao on 13-3-15.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "NIMAMRDecoder.h"
#import "wav_amr.h"
#import "NIMPathManager.h"
#import "NSString+NIM.h"
using namespace NIM;

@implementation NIMAMRDecoder
+ (NSString *)decode: (NSString *)amrFilePath
{
    if ([amrFilePath length])
    {
        NSString *filename = [NSString stringWithFormat:@"%@.wav",[amrFilePath nim_md5]];
        NSString *wavFilepath = [[[NIMPathManager sharedManager] sdkNIMResourcePath] stringByAppendingPathComponent:filename];
        if ([[NSFileManager defaultManager] fileExistsAtPath:wavFilepath])
        {
            return wavFilepath;
        }
        else
        {
            if (decode_amr([amrFilePath UTF8String], [wavFilepath UTF8String]) == 0)
            {
                return wavFilepath;
            }
            else
            {
                return nil;
            }
        }
    }
    else
    {
        return nil;
    }
}

+ (BOOL)isFileAmr:(NSString *)filepath
{
    static NSData *amrFileHeader = [@"#!AMR\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *ext = [filepath pathExtension];
    BOOL isAmr = [ext isEqualToString:@"amr"]; //先判断后缀，如果后缀不匹配才再看文件头
    if (!isAmr && [[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filepath];
        NSData *data =  [handle readDataOfLength:[amrFileHeader length]];
        if ([data length] == [amrFileHeader length] &&
            [data rangeOfData:amrFileHeader
                      options:0
                        range:NSMakeRange(0, [data length])].location != NSNotFound)
        {
            isAmr = YES;
        }
    }
    return isAmr;
}
@end
