//
//  NIMTaskEngine.h
//  NIMLib
//
//  Created by amao on 1/30/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef dispatch_block_t EngineTask;

@interface NIMTaskEngine : NSObject
+ (instancetype)sharedEngine;

- (void)runTask:(EngineTask)task;
@end
