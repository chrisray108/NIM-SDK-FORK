//
//  NIMServerSetting.m
//  NIMLib
//
//  Created by amao on 15/4/7.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMServerSetting.h"
#import "NIMSDKConfig_Private.h"


static NSString * NIMModule =
@"0081c4bb8bf3ec6941275d4a74af3e4bcd38775caf912eab0fa490e4b33bf6ee0cc85e09f1482d10bfbf9fa7bfc06c2fbfd86565690c0f2c2014f17cd46a482bb4b8b8e56c9a93fec3273d3d71c5d42b91bd474a7b92c936d96ea6889d0d77b4113649f70086c419249d61290484d90c8a38cc503e13f9f37a9cb088436dd131bf";
static NSInteger NIMVersion = 0;



@implementation NIMServerSetting
- (instancetype)init
{
    if (self = [super init])
    {
        _lbsAddress         = @"http://lbs.netease.im/lbs/conf.jsp";
        _nosLbsAddress      = @"http://wanproxy.127.net/lbs";
        _linkAddress        = @"link.netease.im:8080";
        _nosUploadAddress   = @"http://223.252.196.41";
        _nosDownloadAddress = @"http://%@.nos.netease.com/%@";
        _module             = NIMModule;
        _version         = NIMVersion;
    }
    return self;
}

- (void)update:(NIMServerSetting *)setting
{
    if ([setting.lbsAddress length])
    {
        self.lbsAddress = setting.lbsAddress;
    }
    if ([setting.nosLbsAddress length])
    {
        self.nosLbsAddress = setting.nosLbsAddress;
    }
    if ([setting.linkAddress length])
    {
        self.linkAddress = setting.linkAddress;
    }
    if ([setting.nosUploadAddress length])
    {
        self.nosUploadAddress = setting.nosUploadAddress;
    }
    if ([setting.nosDownloadAddress length])
    {
        self.nosDownloadAddress = setting.nosDownloadAddress;
    }
    if ([setting.nosAccAddress length])
    {
        self.nosAccAddress = setting.nosAccAddress;
    }
    if ([setting.module length])
    {
        self.module = setting.module;
    }
    self.version = setting.version;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n{\nserver setting:\nlbs : %@\nlink : %@\nnos lbs : %@\nupload : %@\ndownload : %@\n}\n",
            _lbsAddress,_linkAddress,_nosLbsAddress,_nosUploadAddress,_nosDownloadAddress];
}
@end

