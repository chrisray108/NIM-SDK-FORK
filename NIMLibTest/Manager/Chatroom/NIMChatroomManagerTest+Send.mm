//
//  NIMChatroomManagerTest+Send.m
//  NIMLib
//
//  Created by amao on 3/25/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMChatroomManagerTest.h"
#import "NIMTestConfig.h"
#import "NIMTestMessageMaker.h"
#import "NIMSession_Private.h"

@interface NIMChatroomManagerTest_Send : NIMChatroomManagerTest<NIMChatManagerDelegate>

@end

@implementation NIMChatroomManagerTest_Send

- (void)setUp {
    [super setUp];
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
}

- (void)tearDown {
    [super tearDown];
    [[[NIMSDK sharedSDK] chatManager] removeDelegate:self];
}

- (void)testSendMessages
{
    NSArray *chatroomIds =  [[NIMTestConfig sharedConfig] chatroomIds];
    for (NSString *roomId in chatroomIds)
    {
        NSArray *messages = [NIMTestMessageMaker makeAllMessages];
        NIMSession *session  = [NIMSession session:roomId
                                              type:NIMSessionTypeChatroom];
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
            }
        }
    }
}

- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    XCTAssertNil(error);
    NIM_TEST_NOTIFY
}
@end
