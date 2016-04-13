//
//  NIMSystemNotificationReceiver.h
//  NIMLib
//
//  Created by amao on 15/4/23.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <vector>
#import "document.h"

@interface NIMSystemNotificationReceiver : NSObject
@property (nonatomic,assign)    BOOL    onlineNotification;
- (void)receiveNotifications:(std::vector<nimbiz::Property> &)msgs;
@end
