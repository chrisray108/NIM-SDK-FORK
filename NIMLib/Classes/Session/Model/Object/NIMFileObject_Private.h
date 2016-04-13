//
//  NIMFileObject_Private.h
//  NIMLib
//
//  Created by chris on 15/4/16.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMFileObject.h"
#import "NIMMessageObjectProtocol_Private.h"
@interface NIMFileObject()<NIMMessageObject_Private>

@property (nonatomic,copy)   NSString *ext;
//文件md5
@property (nonatomic,copy)   NSString *md5;

@property (nonatomic,assign) long long fileLength;

@property (nonatomic,copy)   NSString *url;

//上层传过来的原始文件路径
@property (nonatomic,copy)   NSString *sourceFilepath;

@property (nonatomic,strong)   NSData *sourceData;

@end