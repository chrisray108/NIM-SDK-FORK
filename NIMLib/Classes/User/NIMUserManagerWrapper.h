//
//  NIMUserManagerWrapper.h
//  NIMLib
//
//  Created by amao on 8/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMUserManagerProtocol.h"

@interface NIMUserManagerWrapper : NSObject<NIMUserManager>
+ (instancetype)sharedWrapper;
@end
