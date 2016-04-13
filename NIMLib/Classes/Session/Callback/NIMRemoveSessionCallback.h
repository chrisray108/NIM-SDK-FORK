//
//  NIMRemoveSessionCallback.h
//  NIMLib
//
//  Created by amao on 9/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMCallbackManager.h"
#import "NIMConversationManagerProtocol.h"

@interface NIMRemoveSessionCallback : NSObject<NIMCallback>
@property (nonatomic,copy)  NIMRemoveRemoteSessionBlock block;
@end
