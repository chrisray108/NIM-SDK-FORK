//
//  NIMRecvMessageHandler.h
//  NIMLib
//
//  Created by amao on 15/4/17.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NIMRecvMessageHandler : NSObject
+ (instancetype)handler:(NSInteger)state;
- (void)recvMessages:(NSArray *)messages;
@end
