//
//  NIMSystemNotificationManagerWrapper.h
//  NIMLib
//
//  Created by amao on 8/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSystemNotificationManagerProtocol.h"

@interface NIMSystemNotificationManagerWrapper : NSObject<NIMSystemNotificationManager>
+ (instancetype)sharedWrapper;
@end
