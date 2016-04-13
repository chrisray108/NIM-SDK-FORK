//
//  NIMApnsManager.h
//  NIMLib
//
//  Created by amao on 4/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMManager.h"
#import "NIMApnsManagerProtocol.h"

@interface NIMApnsManager : NIMManager
- (NIMPushNotificationSetting *)currentSetting;

- (void)updateApnsSetting:(NIMPushNotificationSetting *)setting
               completion:(NIMApnsHandler)completion;
@end


