//
//  NIMDownloadFileWriter.h
//  NIMLib
//
//  Created by amao on 2/6/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMDownloadFileWriter : NSObject
+ (instancetype)fileWriter:(NSString *)filepath;

- (unsigned long long)fileSize;

- (void)writeData:(NSData *)data;
- (void)close;
- (BOOL)clearData;
@end
