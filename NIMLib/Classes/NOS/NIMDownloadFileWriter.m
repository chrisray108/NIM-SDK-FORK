//
//  NIMDownloadFileWriter.m
//  NIMLib
//
//  Created by amao on 2/6/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMDownloadFileWriter.h"

@interface NIMDownloadFileWriter ()
@property (nonatomic,copy)      NSString        *filepath;
@property (nonatomic,strong)    NSFileHandle    *fileHandle;
@end


@implementation NIMDownloadFileWriter
+ (instancetype)fileWriter:(NSString *)filepath
{
    NIMDownloadFileWriter *instance = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        [[NSFileManager defaultManager] createFileAtPath:filepath
                                                contents:nil
                                              attributes:nil];
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filepath];
    if (handle)
    {
        [handle seekToEndOfFile];
        instance = [[NIMDownloadFileWriter alloc] init];
        instance.filepath   = filepath;
        instance.fileHandle = handle;
    }
    return instance;
}

- (void)dealloc
{
    [self close];
}

- (unsigned long long)fileSize
{
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:_filepath
                                                             error:nil] fileSize];
}

- (void)writeData:(NSData *)data
{
    [_fileHandle writeData:data];
    [_fileHandle synchronizeFile];
}

- (void)close
{
    [_fileHandle closeFile];
    _fileHandle = nil;
}

- (BOOL)clearData
{
    [self close];
    
    NSError *error = nil;
    BOOL removedOld =
    [[NSFileManager defaultManager] removeItemAtPath:_filepath
                                               error:&error];
    BOOL createNew =
    [[NSFileManager defaultManager] createFileAtPath:_filepath
                                            contents:nil
                                          attributes:nil];
    if (removedOld && createNew)
    {
        _fileHandle =  [NSFileHandle fileHandleForWritingAtPath:_filepath];
    }
    else
    {
        NIMLogApp(@"clear data for %@ failed %@",_filepath,error);
    }
    
    return _fileHandle != nil;
    
}
@end
