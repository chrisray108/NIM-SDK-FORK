//
//  NIMCoreCenter.h
//  YixinCall
//
//  Created by amao on 10/7/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMCoreCenter : NSObject
+ (instancetype)sharedCenter;
- (void)start;
- (void)close;
- (void)setup:(NSString *)userID;

- (NSString *)currentUserID;
- (void)beginToConnect;
- (void)save;
@end
