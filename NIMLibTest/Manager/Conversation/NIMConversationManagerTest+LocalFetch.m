//
//  NIMConversationManagerTest+Fetch.m
//  NIMLib
//
//  Created by amao on 12/28/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMTestMessager.h"

@interface NIMConversationManagerTest_LocalFetch : NIMBaseTest

@end

@implementation NIMConversationManagerTest_LocalFetch

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFetchMessagesFromTestSessions
{
    NSArray *sessions = [NIMTestConfig sharedConfig].imSessions;
    for (NIMSession *session in sessions) {
        NSArray *messages = [[NIMSDK sharedSDK].conversationManager messagesInSession:session message:nil limit:100];
        for (NIMMessage *message in messages) {
            [self checkMessage:message];
        }
    }
}

- (void)testFetchMessagesFromSendMessages{
    NIMTestMessager *messager = [[NIMTestMessager alloc] init];
    NSArray *messages = [messager sendRandomMessages];
    for (NIMMessage *message in messages) {
        [self checkMessage:message];
        NIMMessage *messageFromDB = [[NIMSDK sharedSDK].conversationManager messagesInSession:message.session messageIds:@[message.messageId]].firstObject;
        [self checkMessage:messageFromDB];
        [self message:message isEqual:messageFromDB];
    }
}


- (void)testSearchMessages{
    NSArray *sessions = [NIMTestConfig sharedConfig].imSessions;
    NIMMessageSearchOption *opt = [[NIMMessageSearchOption alloc] init];
    opt.startTime = 0;
    opt.endTime   = 0;
    opt.limit     = 100;
    for (NIMSession *session in sessions) {
        NIM_CONDITION_SETUP
        [[NIMSDK sharedSDK].conversationManager searchMessages:session option:opt result:^(NSError *error, NSArray *messages) {
            XCTAssertNil(error);
            XCTAssertTrue(messages.count);
            NIM_CONDITION_NOTIFY
        }];
        NIM_CONDITION_WAIT
    }
}

- (void)testRecntSessions{
    NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
    for (NIMRecentSession *recent in recentSessions) {
        NIMMessage *message = recent.lastMessage;
        if (message.isReceivedMsg) {
            XCTAssertTrue(message.attachmentDownloadState == NIMMessageAttachmentDownloadStateDownloaded);
        }else{
            XCTAssertTrue(message.deliveryState == NIMMessageDeliveryStateDeliveried);
        }
    }

}


#pragma mark - Private
- (void)checkMessage:(NIMMessage *)message{
    NIMSession *session = message.session;
    NSString *messageId = message.messageId;
    NSTimeInterval timestamp = message.timestamp;
    XCTAssertNotNil(session);
    XCTAssertTrue(session.sessionId.length);
    XCTAssertTrue(messageId.length);
    XCTAssertNotEqual(timestamp,0);
    
    [self checkMessageObject:message.messageObject];
}

- (void)message:(NIMMessage *)message isEqual:(NIMMessage *)anotherMessage{
    XCTAssertEqualObjects(message.messageId,anotherMessage.messageId);
    XCTAssertEqualObjects(message.session,anotherMessage.session);
    XCTAssertTrue(message.messageType == anotherMessage.messageType);
    XCTAssertTrue(message.deliveryState == anotherMessage.deliveryState);
    XCTAssertTrue(message.attachmentDownloadState == anotherMessage.attachmentDownloadState);
    XCTAssertTrue(message.isPlayed == anotherMessage.isPlayed);
    XCTAssertTrue(message.isReceivedMsg == anotherMessage.isReceivedMsg);
    XCTAssertTrue(message.isOutgoingMsg == anotherMessage.isOutgoingMsg);
    XCTAssertEqualObjects(message.setting, anotherMessage.setting);
    XCTAssertEqualObjects(message.apnsContent, anotherMessage.apnsContent);
    XCTAssertEqualObjects(message.apnsPayload, anotherMessage.apnsPayload);
    XCTAssertEqualObjects(message.localExt, anotherMessage.localExt);
    XCTAssertEqualObjects(message.remoteExt, anotherMessage.remoteExt);
}


- (void)checkMessageObject:(id<NIMMessageObject>)messageObject{
    if (!messageObject) {
        return;
    }
    NIMMessage *message = [messageObject message];
    switch (message.messageType) {
        case NIMMessageTypeImage:{
            NIMImageObject *object = messageObject;
            XCTAssertTrue([object isKindOfClass:[NIMImageObject class]]);
            XCTAssertTrue(object.path.length);
            XCTAssertTrue(object.thumbPath.length);
            if (message.isReceivedMsg) {
                XCTAssertTrue(object.url.length);
                XCTAssertTrue(object.thumbUrl.length);
            }else{
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.path]);
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath]);
            }
        }
            break;
        case NIMMessageTypeAudio:{
            NIMAudioObject *object = messageObject;
            XCTAssertTrue([object isKindOfClass:[NIMAudioObject class]]);
            //不管收到还是发出，路径名肯定是会事先生成的
            XCTAssertTrue(object.path.length);
            if (message.isReceivedMsg) {
                XCTAssertTrue(object.url.length);
            }else{
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.path]);
            }
        }
            break;
        case NIMMessageTypeVideo:{
            NIMVideoObject *object = messageObject;
            XCTAssertTrue([object isKindOfClass:[NIMVideoObject class]]);
            XCTAssertTrue(object.path.length);
            if (message.isReceivedMsg) {
                XCTAssertTrue(object.url.length);
                XCTAssertTrue(object.coverUrl.length);
            }else{
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.path]);
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.coverPath]);
            }
            
        }
            break;
        case NIMMessageTypeFile:{
            NIMFileObject *object = messageObject;
            XCTAssertTrue([object isKindOfClass:[NIMFileObject class]]);
            XCTAssertTrue(object.path.length);
            if (message.isReceivedMsg) {
                XCTAssertTrue(object.url.length);
            }else{
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.path]);
            }
        }
            break;
        case NIMMessageTypeCustom:
        case NIMMessageTypeLocation:
        case NIMMessageTypeNotification:
        case NIMMessageTypeTip:
            break;
        default:
            XCTAssert(0,@"message type not support : \n %@",message);
            break;
    }
}

@end
