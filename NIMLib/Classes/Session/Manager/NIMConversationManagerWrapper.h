//
//  NIMConversationManagerWrapper.h
//  NIMLib
//
//  Created by chris on 15/8/3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMConversationManagerProtocol.h"

@interface NIMConversationManagerWrapper : NSObject<NIMConversationManager>

+ (instancetype)sharedWrapper;

@end
