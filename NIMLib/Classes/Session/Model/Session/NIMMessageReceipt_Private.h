//
//  NIMMessageReceipt.h
//  NIMLib
//
//  Created by amao on 2/29/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMMessageReceipt.h"
#import "NIMSession_Private.h"

@interface NIMMessageReceipt ()
@property (nonatomic,strong)    NIMSession  *session;
@property (nonatomic,assign)    NSTimeInterval timestamp;
@property (nonatomic,copy)      NSString    *messageId;
@end