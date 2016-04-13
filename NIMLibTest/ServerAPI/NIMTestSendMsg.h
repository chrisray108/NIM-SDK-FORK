//
//  NIMTestSendMsg.h
//  NIMLib
//
//  Created by amao on 1/26/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSDK.h"
#import "NIMTestServerRequest.h"


@interface NIMTestSendMsg : NSObject<NIMTestServerRequest>
@property (nonatomic,copy)      NSString            *from;
@property (nonatomic,copy)      NSString            *to;
@property (nonatomic,assign)    NIMSessionType      sessionType;
@property (nonatomic,assign)    NIMMessageType      messageType;
@property (nonatomic,copy)      NSString            *clientMessageId;

@end


@interface NIMMessage (NIMTest)
- (NSString *)clientMessageId;
@end



@interface NIMChatroomTestSendMsg : NIMTestSendMsg

@end
