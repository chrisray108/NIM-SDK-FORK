//
//  NIMAMRDecoder.h
//  NIM
//
//  Created by amao on 13-3-15.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMAMRDecoder : NSObject
+ (NSString *)decode: (NSString *)amrFilePath;
+ (BOOL)isFileAmr:(NSString *)filepath;
@end
