//
//  NIMGzipArchive.m
//  NIMLib
//
//  Created by amao on 7/8/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMGzipArchive.h"
#import "NSData+NIM.h"



@implementation NIMGzipArchive
+ (BOOL)gzipArchive:(NSString *)path
              files:(NSArray *)filepaths
            maxSize:(NSInteger)maxSize
{
    NSMutableData *fileData = [NSMutableData data];
    do {
        for (NSString *filepath in filepaths) {
            @autoreleasepool {
                NSData *data = [NSData dataWithContentsOfFile:filepath];
                if ([data length]) {
                    [fileData appendData:data];
                    
                    //写入分隔符
                    NSData *sepData = [@"\n\n\n\n\n\n\n\n\n\nnim seperator\n\n\n\n\n\n\n\n\n\n" dataUsingEncoding:NSUTF8StringEncoding];
                    [fileData appendData:sepData];
                }
                if ([fileData length] >= maxSize) {
                    break;
                }
            }
        }
    } while (0);
    NSData *gzipData = [fileData nim_gzippedData];
    return [gzipData length] && [gzipData writeToFile:path
                                           atomically:YES];
}
@end
