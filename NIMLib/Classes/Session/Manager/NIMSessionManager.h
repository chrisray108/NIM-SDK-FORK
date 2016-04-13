//
//  NIMSessionManager.h
//  NIMLib
//  负责文件上传下载和消息投递
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NIMMessage;
@class NIMMulticastDelegate;

#define NIMACKCode          (@"code")
#define NIMACKTimetag       (@"timetag")
#define NIMACKServerID      (@"server_id")

@interface NIMSessionManager : NSObject
- (void)sendMessage:(NIMMessage *)message;
- (void)fetchMessageAttachments:(NSArray *)messages;


- (BOOL)messageInTransport:(NIMMessage *)message;
- (CGFloat)messageTransportProgress:(NIMMessage *)message;

- (void)onMsgAck:(NSString *)messageId
            info:(NSDictionary *)userInfo;

- (void)onRoomMsgAck:(NSString *)roomId
           messageId:(NSString *)messageId
                info:(NSDictionary *)userInfo;
@end


