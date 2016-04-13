//
//  NSString+NIM.h
//  NIMLib
//
//  Created by amao on 2/9/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NIM)
- (NSString *)nim_stringByAppendExt:(NSString *)ext;

- (NSString *)nim_md5;

- (NSString *)nim_accURLString;

//判断是否为纯整形
- (BOOL)nim_isPureInteger;

//判断是否为浮点形：
- (BOOL)nim_isPureFloat;

- (NSString *)nim_urlEncodeString;

- (NSString *)nim_urlDecodeString;
@end
