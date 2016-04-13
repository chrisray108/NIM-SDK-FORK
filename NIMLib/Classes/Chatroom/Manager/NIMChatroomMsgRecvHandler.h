//
//  NIMChatroomMsgRecvHandler.h
//  NIMLib
//
//  Created by amao on 12/16/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMMessage_Private.h"

@interface NIMChatroomMsgRecvHandler : NSObject

- (void)onRecvMsg:(NIMMessage *)message;

@end
