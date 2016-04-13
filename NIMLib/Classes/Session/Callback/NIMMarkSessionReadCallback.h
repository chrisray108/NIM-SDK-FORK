//
//  NIMMarkSessionReadCallback.h
//  NIMLib
//
//  Created by amao on 3/1/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMCallbackManager.h"
#import "NIMChatManagerProtocol.h"

@interface NIMMarkSessionReadCallback : NSObject<NIMCallback>
@property (nonatomic,copy)  NIMSendMessageReceiptBlock  block;
@end
