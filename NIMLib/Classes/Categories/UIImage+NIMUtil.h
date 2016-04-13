//
//  UIImage+NIMUtil.h
//  NIMLib
//
//  Created by chris on 15/1/30.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (NIMUtil)

- (UIImage *)nim_thumb;

- (BOOL)nim_saveToFilepathWithPng:(NSString*)filepath;

- (BOOL)nim_saveToFilepathWithJpeg:(NSString *)filepath;

@end
