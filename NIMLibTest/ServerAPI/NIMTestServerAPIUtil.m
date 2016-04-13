//
//  NIMTestServerAPIUtil.m
//  NIMLib
//
//  Created by amao on 1/26/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMTestServerAPIUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "NIMTestConfig.h"


@implementation NIMTestServerAPIUtil
+ (NSDictionary *)serverRequestHeaders
{
    NSMutableDictionary *headers = @{}.mutableCopy;
    
    NSString *appSecret = [[NIMTestConfig sharedConfig] appSecret];
    NSString *appKey = [[NIMTestConfig sharedConfig] appKey];
    headers[@"AppKey"] = appKey;
    
    NSString *nonce = [NSString stringWithFormat:@"%zd",(NSInteger)arc4random()];
    headers[@"Nonce"] = nonce;
    
    NSInteger time = [[NSDate date] timeIntervalSince1970];
    NSString *curTime = [NSString stringWithFormat:@"%zd",time];
    headers[@"CurTime"] = curTime;
    
    NSString *checkSum = [NIMTestServerAPIUtil sha1:[NSString stringWithFormat:@"%@%@%@",appSecret,nonce,curTime]];
    headers[@"CheckSum"] = checkSum;
    
    return headers;
    
}

+ (NSString *)sha1:(NSString *)source
{
    NSData *data = [source dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
@end
