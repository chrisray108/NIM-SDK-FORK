//
//  NIMSDKConfig.h
//  NIMLib
//
//  Created by amao on 4/14/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSDKConfig.h"

@interface NIMSDKConfig ()
@property (nonatomic,copy)  NSString    *sdkDir;

- (NSInteger)sdkVersion;

- (NSInteger)protocolVersion;

- (NSString *)sdkPublicVersion;

@end
