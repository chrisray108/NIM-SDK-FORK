//
//  NIMAudioObject_Private.h
//  NIMLib
//
//  Created by chris on 15/1/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMAudioObject.h"
#import "NIMMessageObjectProtocol_Private.h"

@interface NIMAudioObject ()<NIMMessageObject_Private>

@property (nonatomic,copy) NSString *fileName;
//文件md5
@property (nonatomic,copy) NSString *md5;

@property (nonatomic,assign) long long fileLength;

@property (nonatomic,copy) NSString *url;

//上层传过来的原始文件路径
@property (nonatomic,copy) NSString *sourcePath;

@property (nonatomic,strong) NSData *sourceData;

@property (nonatomic,copy) NSString *sourceExtension;

@end
