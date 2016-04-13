//
//  NIMVideoObject_Private.h
//  NIMLib
//
//  Created by chris on 15/1/20.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMVideoObject.h"
#import "NIMMessageObjectProtocol_Private.h"

@interface NIMVideoObject ()<NIMMessageObject_Private>

@property (nonatomic,copy)    NSString *fileName;

@property (nonatomic,copy)    NSString *coverName;

@property (nonatomic,copy)    NSString *md5;

@property (nonatomic,copy)    NSString *url;

@property (nonatomic,assign)  CGSize coverSize;

@property (nonatomic,assign)  long long fileLength;


//上层传入数据
@property (nonatomic,copy)    NSString *sourcePath;

@property (nonatomic,strong)  NSData *sourceData;

@property (nonatomic,copy)    NSString *sourceExtension;

@end
