//
//  NIMUserCallback.h
//  NIMLib
//
//  Created by amao on 9/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMCallbackManager.h"
#import "NIMUserManagerProtocol.h"

@interface NIMUserCallback : NSObject<NIMCallback>
@property (nonatomic,copy)  NIMUserBlock    block;
@end



@interface NIMUserInfoCallback : NSObject<NIMCallback>

@property (nonatomic,copy)  NIMUserInfoBlock  block;

@end