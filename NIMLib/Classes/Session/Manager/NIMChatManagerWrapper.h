//
//  NIMChatManagerWrapper.h
//  NIMLib
//
//  Created by amao on 8/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMChatManagerProtocol.h"


@interface NIMChatManagerWrapper : NSObject<NIMChatManager>
+ (instancetype)sharedWrapper;
@end
