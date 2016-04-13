//
//  NIMUtil.h
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMUtil : NSObject

//返回UUID
+ (NSString *)uuid;

//生成文件名
+ (NSString *)genFilenameWithExt:(NSString *)ext;

@end

@interface NIMUtil(Media)

//获取media length,以毫秒为单位
+ (NSInteger)mediaLengthForFile:(NSString *)filepath;

//产生缩略图
+ (UIImage *)generateThumbForVideo:(NSString *)filepath;

+ (NSInteger)sampleRateForFile:(NSString *)filepath;


@end
