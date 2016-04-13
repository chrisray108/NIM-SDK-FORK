//
//  NIMCustomSystemNotification.h
//  NIMLib
//
//  Created by amao on 7/28/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSystemNotification.h"
#import "document.h"

typedef enum : NSUInteger {
    NIMCustomSystemNotificationTypeP2P  = 100,
    NIMCustomSystemNotificationTypeTeam = 101,
} NIMCustomSystemNotificationType;



@interface NIMCustomSystemNotification ()
@property (nonatomic,assign)                int64_t msgId;
@property (nonatomic,assign)                NSTimeInterval timestamp;
@property (nonatomic,copy)                  NSString *sender;
@property (nonatomic,copy)                  NSString *receiver;
@property (nonatomic,assign)                NIMSessionType  receiverType;
@property (nonatomic,copy)                  NSString    *content;
- (instancetype)initWithPorperty:(const nimbiz::Property &)property;
@end