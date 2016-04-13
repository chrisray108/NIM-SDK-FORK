//
//  NSString+NIM.m
//  NIMLib
//
//  Created by amao on 2/9/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NSString+NIM.h"
#import "NSData+NIM.h"
#import "NIMSDK_Private.h"

@implementation NSString (NIM)
- (NSString *)nim_stringByAppendExt:(NSString *)ext
{
    return [ext length]? [self stringByAppendingFormat:@".%@",ext] : self;
}

- (NSString *)nim_md5
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data nim_md5];
}

- (NSString *)nim_accURLString
{
    static NSString *internalHost = @"nos.netease.im";
    NSString *result = self;
    NSURL *url = [NSURL URLWithString:self];
    NSString *host = [url host];
    if ([host hasSuffix:internalHost])
    {
        NSRange range = [self rangeOfString:internalHost];
        if (range.location != NSNotFound &&
            range.length != 0)
        {
            NSString *nosAccURL = [[[NIMSDK sharedSDK] lbsManager] nosAccURL];
            if ([nosAccURL length])
            {
                NSRange prefixRange = NSMakeRange(0, range.location + range.length);
                result = [self stringByReplacingCharactersInRange:prefixRange
                                                       withString:nosAccURL];
            }
        }
    }
    
    return result;
}

- (BOOL)nim_isPureInteger{
    NSScanner* scan = [NSScanner scannerWithString:self];
    NSInteger val;
    return[scan scanInteger:&val] && [scan isAtEnd];
}

//判断是否为浮点形：
- (BOOL)nim_isPureFloat{
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}



- (NSString *)nim_urlEncodeString{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

- (NSString *)nim_urlDecodeString{
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)self,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}
@end
