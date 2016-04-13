//
//  NIMChatManagerTest+Send.m
//  NIMLib
//
//  Created by amao on 12/28/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMTestMessageMaker.h"

@interface NIMChatManagerTest_Send : NIMBaseTest<NIMChatManagerDelegate>

@end

@implementation NIMChatManagerTest_Send

- (void)setUp {
    [super setUp];
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
}

- (void)tearDown {
    [[[NIMSDK sharedSDK] chatManager] removeDelegate:self];
    [super tearDown];
}

- (void)testSendMessages
{
    NSArray *sessions = [NIMTestConfig sharedConfig].imSessions;
    for (NIMSession *session in sessions) {
        NSArray *messages = [NIMTestMessageMaker makeAllMessages];
        for (NIMMessage *message in messages)
        {
            NSError *error = nil;
            BOOL success = [[[NIMSDK sharedSDK] chatManager] sendMessage:message
                                                               toSession:session
                                                                   error:&error];
            
            if ([message messageType] == NIMMessageTypeNotification)
            {
                XCTAssertFalse(success);
                XCTAssertNotNil(error);
                XCTAssertEqual([error code], NIMLocalErrorCodeInvalidParam);
            }
            else
            {
                XCTAssertNil(error);
                XCTAssertTrue(success);
                NIM_TEST_WAIT;
                NIMMessage *messageInDB = [[NIMSDK sharedSDK].conversationManager messagesInSession:session messageIds:@[message.messageId]].firstObject;
                
                XCTAssertEqualObjects(message.setting,   messageInDB.setting);
            }
        }
    }
}


#pragma mark - NIMChatManagerDelegate
- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    XCTAssertNil(error);
    NIM_TEST_NOTIFY
}

@end
