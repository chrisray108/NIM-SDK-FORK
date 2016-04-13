//
//  NIMMessageSetting.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMMessageSetting.h"
#import "document.h"

@interface NIMMessageSetting ()
//收发消息时序列化和反序列化
+ (instancetype)settingByProperty:(const nimbiz::Property &)messageProperty;
- (nimbiz::Property)settingProperty;


//db存储序列化和反序列化
+ (instancetype)settingByJsonData:(NSData *)data;
- (NSData *)toJsonData;
@end
