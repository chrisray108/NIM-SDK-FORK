//
//  NIMDatabaseModel.h
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NIMMessage;
@class NIMCustomObject;

@interface NIMMessageUpdateInfo  : NSObject
@property (nonatomic,assign)        int64_t             serialID;

@property (nonatomic,strong)        NIMCustomObject     *customObject;

@property (nonatomic,strong)        NSData              *localExt;

+ (instancetype)updateInfoByMessage:(NIMMessage *)message;
@end
