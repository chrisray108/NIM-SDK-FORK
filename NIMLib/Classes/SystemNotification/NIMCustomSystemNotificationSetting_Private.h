//
//  NIMCustomSystemNotificationSetting_Private.h
//  NIMLib
//
//  Created by chris on 15/11/27.
//  Copyright © 2015年 Netease. All rights reserved.
//
#import "NIMCustomSystemNotificationSetting.h"
#import "document.h"

@interface NIMCustomSystemNotificationSetting()

+ (instancetype)settingByProperty:(const nimbiz::Property &)messageProperty;

- (nimbiz::Property)settingProperty;

@end
