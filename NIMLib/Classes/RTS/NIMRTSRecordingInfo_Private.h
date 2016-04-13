//
//  NIMRTSRecordingInfo_Private.h
//  NIMLib
//
//  Created by 高峰 on 15/8/31.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMRTSRecordingInfo.h"

@interface NIMRTSRecordingInfo()

- (instancetype)initWithService:(NIMRTSService) service
                         address:(NSString *)serverAddress
                           file:(NSString *)fileName;

@end
