
//
//  NIMPrivateHacker.m
//  NIM
//
//  Created by amao on 15/4/8.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMPrivateHacker.h"

@protocol NIMPrivateServerSetting <NSObject>
- (void)setLbsAddress:(NSString *)address;
- (void)setNosLbsAddress:(NSString *)address;
- (void)setLinkAddress:(NSString *)address;
- (void)setNosUploadAddress:(NSString *)address;
- (void)setNosDownloadAddress:(NSString *)address;
- (void)setNosAccAddress:(NSString *)address;
- (void)setModule:(NSString *)module;
- (void)setVersion:(NSInteger)version;
@end


@protocol NIMPrivateSDK <NSObject>
- (void)setSetting:(id)setting;
@end



@implementation NIMPrivateServerSetting
@end

@interface NIMPrivateHacker ()
@end

@implementation NIMPrivateHacker
+ (instancetype)sharedHacker
{
    static NIMPrivateHacker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMPrivateHacker alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
    }
    return self;
}


- (void)setServerSetting:(NIMPrivateServerSetting *)setting
{
    Class cls = NSClassFromString(@"NIMServerSetting");
    if (cls)
    {
        id<NIMPrivateServerSetting>obj = [[cls alloc] init];
  
        if ([obj respondsToSelector:@selector(setLbsAddress:)])
        {
            [obj setLbsAddress:setting.lbsAddress];
        }
        if ([obj respondsToSelector:@selector(setNosLbsAddress:)])
        {
            [obj setNosLbsAddress:setting.nosLbsAddress];
        }
        if ([obj respondsToSelector:@selector(setLinkAddress:)])
        {
            [obj setLinkAddress:setting.linkAddress];
        }
        if ([obj respondsToSelector:@selector(setNosUploadAddress:)])
        {
            [obj setNosUploadAddress:setting.nosUploadAddress];
        }
        if ([obj respondsToSelector:@selector(setNosDownloadAddress:)])
        {
            [obj setNosDownloadAddress:setting.nosDownloadAddress];
        }
        if ([obj respondsToSelector:@selector(setNosAccAddress:)])
        {
            [obj setNosAccAddress:setting.nosAccAddress];
        }
        if ([obj respondsToSelector:@selector(setModule:)])
        {
            [obj setModule:setting.module];
        }
        if ([obj respondsToSelector:@selector(setVersion:)])
        {
            [obj setVersion:setting.version];
        }
        
        id<NIMPrivateSDK> sdk = (id<NIMPrivateSDK>)[NIMSDK sharedSDK];
        if ([sdk respondsToSelector:@selector(setSetting:)])
        {
            [sdk setSetting:obj];
        }
    }
}



@end
