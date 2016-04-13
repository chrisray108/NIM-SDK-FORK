//
//  NIMNetworkConfig.h
//  NIMLib
//
//  Created by amao on 7/20/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NIMNetworkTypeUnknown,
    NIMNetworkType2G,
    NIMNetworkType3G,
    NIMNetworkType4G,
    NIMNetworkTypeWWAN,
    NIMNetworkTypeWifi,
} NIMNetworkType;

@interface NIMNetworkConfig : NSObject
+ (instancetype)sharedConfig;
- (NIMNetworkType)currentNetworkType;
@end
