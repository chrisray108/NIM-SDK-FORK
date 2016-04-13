//
//  UIImage+NIMUtil.m
//  NIMLib
//
//  Created by chris on 15/1/30.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "UIImage+NIMUtil.h"
#import "NIMNOSResizer.h"
@implementation UIImage (NIMUtil)

- (UIImage *)nim_thumb
{
    CGSize scaleSize = [[NIMNOSResizer sharedResizer] resizeWidth:150 height:150];
    return [self nim_externalScaleSize:scaleSize];
}

- (UIImage *)nim_externalScaleSize: (CGSize)scaledSize
{
    CGFloat width  = self.size.width;
    CGFloat height = self.size.height;
    CGFloat newSizeWidth = scaledSize.width;
    CGFloat newSizeHeight= scaledSize.height;
    if (width < newSizeWidth || height < newSizeHeight)
    {
        return self;
    }
    if (width == 0 || height == 0)
    {
        return nil;
    }
    CGSize size;
    if (width / height > newSizeWidth / newSizeHeight)
    {
        size = CGSizeMake(newSizeHeight * width / height, newSizeHeight);
    }
    else
    {
        size = CGSizeMake(newSizeWidth, newSizeWidth * height / width);
    }
    return [self nim_drawImageWithSize:size];
    
}

- (UIImage *)nim_drawImageWithSize: (CGSize)size
{
    CGSize drawSize = CGSizeMake(floor(size.width), floor(size.height));
    UIGraphicsBeginImageContext(drawSize);
    
    [self drawInRect:CGRectMake(0, 0, drawSize.width, drawSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (BOOL)nim_saveToFilepathWithPng:(NSString*)filepath{
    NSData *data = UIImagePNGRepresentation(self);
    return [data length] && [data writeToFile:filepath atomically:YES];
}

- (BOOL)nim_saveToFilepathWithJpeg:(NSString *)filepath
{
    NSData *data = UIImageJPEGRepresentation(self, 0.75);
    return [data length] && [data writeToFile:filepath atomically:YES];
}


@end
