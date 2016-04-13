//
//  NIMTestSystemNotificationUtil.h
//  NIMLib
//
//  Created by amao on 12/30/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSDK.h"

@interface NIMTestSystemNotificationUtil : NSObject
+ (BOOL)notification:(NIMSystemNotification *)notification
           isEqualTo:(NIMSystemNotification *)other;

+ (BOOL)notifications:(NSArray *)notifications
              contain:(NIMSystemNotification *)notification;

+ (BOOL)notifications:(NSArray *)notifications
           areEqualTo:(NSArray *)others;
@end
