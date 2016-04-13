//
//  NIMApnsManagerWrapper.h
//  NIMLib
//
//  Created by amao on 8/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMApnsManagerProtocol.h"

@interface NIMApnsManagerWrapper : NSObject<NIMApnsManager>
+ (instancetype)sharedWrapper;
@end
