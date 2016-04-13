//
//  NIMMessageDownloadParam.h
//  NIMLib
//
//  Created by chris on 15/2/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMMessageDownloadParam : NSObject
//下载url
@property (nonatomic, copy) NSString *url;
//保存路径
@property (nonatomic, copy) NSString *destinationPath;

@end
