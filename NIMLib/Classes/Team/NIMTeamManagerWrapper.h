//
//  NIMTeamManagerWrapper.h
//  NIMLib
//
//  Created by chris on 15/8/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMTeamManagerProtocol.h"

@interface NIMTeamManagerWrapper : NSObject<NIMTeamManager>

+ (instancetype)sharedWrapper;

@end
