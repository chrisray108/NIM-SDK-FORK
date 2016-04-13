//
//  NSData+NIM.h
//  NIMLib
//
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NIM)
- (NSString *)nim_md5;

- (NSData *)nim_gzippedData;

- (NSData *)nim_gunzippedData;

- (NSData *)nim_gzippedDataWithCompressLevel:(float)level;

- (BOOL)nim_writeToFile:(NSString *)filepath;
@end
