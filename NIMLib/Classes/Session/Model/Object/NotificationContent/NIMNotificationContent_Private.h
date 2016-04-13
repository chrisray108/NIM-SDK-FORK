//
//  NIMNotificationContent.h
//  NIMLib
//
//  Created by amao on 7/23/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNotificationContent.h"
#import "NIMMessage_Private.h"


@interface NIMNotificationContent ()
- (BOOL)decode:(NSDictionary *)jsonBody;

@property (nonatomic,weak)     id<NIMMessageObject> messageObject;

@end



