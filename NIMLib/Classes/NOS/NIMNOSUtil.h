//
//  NIMNOSUtil.h
//  YixinCall
//
//  Created by amao on 12/26/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMNOSUtil : NSObject
+ (NSString *)mimeType:(NSString *)filepath;

+ (NSString *)fileMD5:(NSString *)filepath;

+ (unsigned long long)fileSize:(NSString *)filepath;

@end
