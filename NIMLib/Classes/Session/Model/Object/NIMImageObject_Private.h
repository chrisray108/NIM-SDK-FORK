//
//  NIMImageObject_Private.h
//  NIMLib
//
//  Created by chris on 15/1/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMImageObject.h"
#import "NIMMessageObjectProtocol_Private.h"

@interface NIMImageObject ()<NIMMessageObject_Private>

//文件md5
@property(nonatomic, copy)              NSString *md5;

@property(nonatomic, readwrite, assign) CGSize size;

@property(nonatomic, copy)              NSString *fileName; //文件保存在本地的名字

@property(nonatomic, readwrite, copy)   NSString *url;

@property(nonatomic, assign)            long long fileLength;




//传入的字段
@property(nonatomic, strong)            UIImage  *sourceImage;

@property(nonatomic, copy)              NSString *sourceFilepath;

@property(nonatomic,strong)             NSData *sourceData;

@property(nonatomic,copy)               NSString *sourceExtension;

@end
