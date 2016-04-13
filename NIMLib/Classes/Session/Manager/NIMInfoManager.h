//
//  NIMInfoManager.h
//  NIMLib
//
//  Created by amao on 3/19/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMManager.h"

@class NIMMessage;

@interface NIMInfoManager : NIMManager
- (NSString *)senderNameByMessage:(NIMMessage *)message;

- (void)saveSenderName:(NSString *)name
            forMessage:(NIMMessage *)message;
@end
