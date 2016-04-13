//
//  NIMChatroom.h
//  NIMLib
//
//  Created by amao on 12/14/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "document.h"
#import "NIMChatroom.h"
#import "NIMChatroomEnterRequest.h"
#import "NIMMessageChatroomExtension.h"

@interface NIMChatroom ()
- (instancetype)initWithProperty:(const nimbiz::Property &)info;
@end


@interface NIMChatroomEnterRequest ()
@end



@interface NIMMessageChatroomExtension ()
@end