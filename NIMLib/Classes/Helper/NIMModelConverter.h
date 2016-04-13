//
//  NIMModelConverter.h
//  NIMLib
//
//  Created by amao on 4/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMGlobalDefs.h"
#import "document.h"

@protocol NIMMessageObject_Private;
@class NIMMessage;
@class NIMNetCallRecord;
@interface NIMModelConverter : NSObject

+ (id<NIMMessageObject_Private>)messaegObjectWithType:(NIMMessageType)type
                                              content:(NSString*)content;

//IM消息
+ (NIMMessage *)imMessageFromProperty:(const nimbiz::Property &)messageProperty;

+ (nimbiz::Property)imPropertyFromMessage:(NIMMessage *)message;


//聊天室消息
+ (NIMMessage *)chatroomMessageFromProperty:(const nimbiz::Property)messageProperty;

+ (nimbiz::Property)chatroomPropertyFromMessage:(NIMMessage *)message;


//网络电话到聊天室消息
+ (NIMMessage *)netCallMessageFromRercord:(NIMNetCallRecord *)record;

@end
