//
//  NIMSystemNotification.h
//  NIMLib
//
//  Created by amao on 3/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSystemNotification.h"
#import "document.h"

typedef NS_ENUM(NSInteger, NIMSystemNotificationTypePrivate){
    NIMSystemNotificationTypeFriendDelete = 6,
};


typedef NS_ENUM(NSInteger, NIMNotificationStatus){
    NIMNotificationStatusNone   = 0,
    NIMNotificationStatusRead   = 1,
    NIMNotificationStatusDeleted= 2,
};


@interface NIMSystemNotification ()
@property (nonatomic,assign)        NSInteger serial;
@property (nonatomic,assign)        int64_t msgId;
@property (nonatomic,assign)        NIMSystemNotificationType type;
@property (nonatomic,assign)        NSTimeInterval timestamp;
@property (nonatomic,copy)          NSString *sourceID;
@property (nonatomic,copy)          NSString *targetID;
@property (nonatomic,copy)          NSString *postscript;
@property (nonatomic,copy)          NSString *attachString;
@property (nonatomic,assign)        NSInteger status;
@property (nonatomic,strong)        id attachmentObject;

- (BOOL)canSave;

- (void)saveDataAfterReceiving:(BOOL)online;

- (instancetype)initWithPorperty:(const nimbiz::Property &)property;


@end





@interface NIMUserAddAttachment ()
- (instancetype)initWithOperation:(NIMUserOperation)operation;
@end