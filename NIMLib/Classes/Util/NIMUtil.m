//
//  NIMUtil.m
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>

@implementation NIMUtil

+ (NSString *)uuid
{
    return [[[NSUUID UUID] UUIDString] lowercaseString];
}

+ (NSString *)genFilenameWithExt: (NSString *)ext
{
    NSString *uuid = [NIMUtil uuid];
    NSDate *timestamp = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timestampStr = [formatter stringFromDate:timestamp];
    NSString *name = [NSString stringWithFormat:@"%@%@",uuid,timestampStr];
    return [ext length] ? [NSString stringWithFormat:@"%@.%@",name,ext] : name;
}


@end


@implementation NIMUtil(Media)

+ (NSInteger)mediaLengthForFile:(NSString *)filepath
{
    NSInteger mediaLength = 0;
    if( [[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSURL    *movieURL = [NSURL fileURLWithPath:filepath];
        AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:movieURL options:nil];
        CMTime time = urlAsset.duration;
        mediaLength = CMTimeGetSeconds(time) * 1000;
    }
    return mediaLength;
}


+ (UIImage *)generateThumbForVideo:(NSString *)filepath
{
    UIImage *thumbImage = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSURL    *movieURL = [NSURL fileURLWithPath:filepath];
        AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:movieURL options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if (image)
        {
            thumbImage = [UIImage imageWithCGImage:image];
            CFRelease(image);
        }
    }
    return thumbImage;
}


+ (NSInteger)sampleRateForFile:(NSString *)filepath
{
    NSInteger sampleRate = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        NSURL *url = [NSURL fileURLWithPath:filepath];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetTrack *track = [[asset tracks] firstObject];
        NSArray *formateDescriptions = [track formatDescriptions];
        for (id item in formateDescriptions) {
            CMAudioFormatDescriptionRef audioItem = (__bridge CMAudioFormatDescriptionRef)item;
            const AudioStreamBasicDescription *basicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(audioItem);
            if (basicDescription) {
                sampleRate = basicDescription->mSampleRate;
                break;
            }
            
        }
    }
    return sampleRate;
}


@end
