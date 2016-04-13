//
//  NIMNetCallManagerWrapper.h
//  NIMLib
//
//  Created by 高峰 on 15/8/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNetCallManagerProtocol.h"

@interface NIMNetCallManagerWrapper : NSObject<NIMNetCallManager>

+ (instancetype)sharedWrapper;

@end
