//
//  NIMNetworkConfig.m
//  NIMLib
//
//  Created by amao on 7/20/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMNetworkConfig.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "NIMReachability.h"

@interface NIMNetworkConfig ()
@property (nonatomic,strong)    NSDictionary    *networkTypes;
@end

@implementation NIMNetworkConfig

+ (instancetype)sharedConfig
{
    static NIMNetworkConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMNetworkConfig alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]){
        
        if (NIMIOS7) {
            _networkTypes = @{CTRadioAccessTechnologyGPRS:@(NIMNetworkType2G),
                              CTRadioAccessTechnologyEdge:@(NIMNetworkType2G),
                              CTRadioAccessTechnologyWCDMA:@(NIMNetworkType3G),
                              CTRadioAccessTechnologyHSDPA:@(NIMNetworkType3G),
                              CTRadioAccessTechnologyHSUPA:@(NIMNetworkType3G),
                              CTRadioAccessTechnologyCDMA1x:@(NIMNetworkType3G),
                              CTRadioAccessTechnologyCDMAEVDORev0:@(NIMNetworkType3G),
                              CTRadioAccessTechnologyCDMAEVDORevA:@(NIMNetworkType3G),
                              CTRadioAccessTechnologyCDMAEVDORevB:@(NIMNetworkType3G),
                              CTRadioAccessTechnologyeHRPD:@(NIMNetworkType3G),
                              CTRadioAccessTechnologyLTE:@(NIMNetworkType4G),
                              };
        }
    }
    return self;
}

- (NIMNetworkType)currentNetworkType
{
    NIMNetworkType type = NIMNetworkTypeUnknown;
    NIMNetworkStatus status = [[NIMReachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (status) {
        case NIMReachableViaWiFi:
            type = NIMNetworkTypeWifi;
            break;
        case NIMReachableViaWWAN:{
            if (NIMIOS7) {
                CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
                NSNumber *typeNumber = [_networkTypes objectForKey:telephonyInfo.currentRadioAccessTechnology];
                type = typeNumber ? [typeNumber integerValue] : NIMNetworkTypeWWAN;
            }
            else{
                type = NIMNetworkTypeWWAN;
            }
        }
            break;
        default:
            break;
    }
    
    
    return type;
}
@end
