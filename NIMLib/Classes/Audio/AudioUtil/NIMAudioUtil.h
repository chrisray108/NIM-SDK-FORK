//
//  NIMAudioUtil.h
//  NIM
//
//  Created by amao on 13-2-22.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface NIMAudioUtil : NSObject

//扬声器模式
+ (BOOL)switchToSpeakerMode;
//听筒模式
+ (BOOL)switchToReceiverMode;

//是否正在使用蓝牙
+ (BOOL)isUsingBluetooth;
//是否授权访问麦克风，ios7默认否
+ (void)hasRecordGranted:(PermissionBlock)block;
//开启蓝牙耳机检测
+ (void)enableBluetooth;

@end
