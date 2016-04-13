//
//  RSAConfig.h
//  NIM
//
//  Created by amao on 13-9-2.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMRSAConfig : NSObject<NSCoding>
@property (nonatomic,strong)        NSString    *module;    //16进制表示的module
@property (nonatomic,assign)        NSInteger   version;
@property (nonatomic,assign)        NSInteger   crc32;

+ (instancetype)config:(NSString *)module
              version:(NSInteger)version;
+ (instancetype)readLocalConfig;

- (BOOL)save;
- (BOOL)isValidConfig;


@end
