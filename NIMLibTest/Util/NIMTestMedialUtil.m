//
//  NIMTestMedialUtil.m
//  NIMLib
//
//  Created by amao on 3/15/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMTestMedialUtil.h"
#import "NIMUtil.h"

@implementation NIMTestMedialUtil
+ (UIImage *)randomImage
{
    return [NIMTestMedialUtil generateImage:1024
                                circleCount:200];
}

+ (NSData *)randomImageWithData
{
    return [NSData dataWithContentsOfFile:[self randomImageWithPath]];
}

+ (NSString *)randomImageWithPath
{
    UIImage *image = [NIMTestMedialUtil randomImage];
    NSString *filename = [[NIMUtil uuid] stringByAppendingString:@".jpg"];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    [data writeToFile:path atomically:YES];
    return path;
}


+ (NSString *)randomAudioWithPath
{
    NSData *data = [self randomAudioWithData];
    NSString *name = [NSString stringWithFormat:@"%@.aac",[NIMUtil uuid]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    [data writeToFile:path
           atomically:YES];
    return path;
}


+ (NSData *)randomAudioWithData
{
    NSString *srcFilepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"audio" ofType:@"aac"];
    NSData *data = [NSData dataWithContentsOfFile:srcFilepath];
    NSData *appendData = [[NIMUtil uuid] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *result = [NSMutableData dataWithData:data];
    [result appendData:appendData];
    return result;
}

+ (NSString *)randomVideoWithPath
{
    NSData *data = [self randomVideoWithData];
    NSString *name = [NSString stringWithFormat:@"%@.mp4",[NIMUtil uuid]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    [data writeToFile:path
           atomically:YES];
    return path;
}


+ (NSData *)randomVideoWithData
{
    NSString *srcFilepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"video" ofType:@"mp4"];
    NSData *data = [NSData dataWithContentsOfFile:srcFilepath];
    NSData *appendData = [[NIMUtil uuid] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *result = [NSMutableData dataWithData:data];
    [result appendData:appendData];
    return result;
}


+ (NSString *)randomFileWithPath
{
    NSData *data = [self randomFileWithData];
    NSString *name = [NSString stringWithFormat:@"%@.txt",[NIMUtil uuid]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    [data writeToFile:path
           atomically:YES];
    return path;
}


+ (NSData *)randomFileWithData
{
    
    NSString *srcFilepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"file" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:srcFilepath];
    NSData *appendData = [[NIMUtil uuid] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *result = [NSMutableData dataWithData:data];
    [result appendData:appendData];
    return result;
}



#pragma mark - misc
+ (UIImage *)generateImage:(CGFloat)imageWidth
               circleCount:(NSInteger)count
{
    CGSize size = CGSizeMake(imageWidth, imageWidth);
    
    UIGraphicsBeginImageContext(size);//设置上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    
    for (NSInteger i = 0; i < count; i++)
    {
        CGFloat r = (arc4random() % (NSInteger)(imageWidth / 2)) / 2;
        CGFloat x = arc4random() % (NSInteger)imageWidth;
        CGFloat y = arc4random() % (NSInteger)imageWidth;
        
        CGContextAddArc(ctx, x, y, r, 0, 2*M_PI, 0);
        CGContextSetRGBFillColor(ctx, rand()/(RAND_MAX+1.0),rand()/(RAND_MAX+1.0),rand()/(RAND_MAX+1.0),rand()/(RAND_MAX+1.0));//随机颜色
        CGContextFillPath(ctx);
    }
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
