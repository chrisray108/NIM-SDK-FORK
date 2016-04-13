//
//  NIMServerSetting.h
//  NIMLib
//
//  Created by amao on 15/4/7.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMServerSetting;


@interface NIMServerSetting : NSObject
@property (nonatomic,copy)      NSString    *lbsAddress;                //APP lbs地址
@property (nonatomic,copy)      NSString    *nosLbsAddress;             //NOS lbs地址
@property (nonatomic,copy)      NSString    *linkAddress;               //默认link地址
@property (nonatomic,copy)      NSString    *nosUploadAddress;          //默认NOS 上传地址
@property (nonatomic,copy)      NSString    *nosDownloadAddress;        //默认NOS 下载地址 (用于拼装URL)
@property (nonatomic,copy)      NSString    *nosAccAddress;             //默认NOS 加速地址 (用于替换下载地址)
@property (nonatomic,copy)      NSString    *module;                    //RSA 公钥模
@property (nonatomic,assign)    NSInteger   version;                    //RSA 公钥版本号

- (void)update:(NIMServerSetting *)setting;

@end
