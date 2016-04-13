//
//  NIMAppTokenManager.h
//  NIMLib
//  App Key/Token管理
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMApnsManagerProtocol.h"

@interface NIMAppTokenManager : NSObject
@property (nonatomic,copy)  NIMBadgeHandler badgeHandler;
@property (atomic,copy) NSString *appKey;
@property (atomic,copy) NSString *apnsCerName;

- (void)sendToken;
@end



@interface NIMAppTokenStore : NSObject
@property (atomic,copy) NSString *apnsToken;
+ (instancetype)store;
@end