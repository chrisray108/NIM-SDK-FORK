//
//  NIMPushNotificationSetting.m
//  NIMLib
//
//  Created by amao on 4/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMPushNotificationSetting.h"

@implementation NIMPushNotificationSetting
- (void)verify
{
    _noDisturbingStartH = MIN(24, _noDisturbingStartH);
    _noDisturbingStartM = MIN(59, _noDisturbingStartM);
    _noDisturbingEndH   = MIN(24, _noDisturbingEndH);
    _noDisturbingEndM   = MIN(59, _noDisturbingEndM);
    
    if (_noDisturbingStartH == 24)
    {
        _noDisturbingStartM = 0;
    }
    
    if (_noDisturbingEndH == 24)
    {
        _noDisturbingEndM = 0;
    }
}
@end
