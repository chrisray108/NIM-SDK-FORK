//
//  NIMChatroomManagerWrapper.h
//  NIMLib
//
//  Created by amao on 12/14/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMChatroomManagerProtocol.h"

@interface NIMChatroomManagerWrapper : NSObject<NIMChatroomManager>
+ (instancetype)sharedWrapper;
@end
