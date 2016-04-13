//
//  NIMNotificationObject.h
//  NIMLib
//
//  Created by amao on 3/6/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNotificationObject.h"
#import "NIMMessageObjectProtocol_Private.h"

@interface NIMNotificationObject ()<NIMMessageObject_Private>
@property (nonatomic,copy)     NSString    *attachContent;

@end


