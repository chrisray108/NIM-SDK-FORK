//
//  NIMChatroomStateEmitter.h
//  NIMLib
//
//  Created by amao on 3/11/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMChatroomStateManager.h"

@interface NIMChatroomStateEmitter : NSObject
+ (instancetype)emitterByRoomId:(NSString *)roomId;

- (void)commit:(NIMChatroomState)state
         error:(NSError *)error;
@end
