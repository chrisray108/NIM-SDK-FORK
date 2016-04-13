//
//  NIMChatroomTestManager_Message.m
//  NIMLib
//
//  Created by chris on 16/1/5.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomManagerTest.h"
#import "NIMTestMessageMaker.h"
#import "NIMTestMessager.h"

@interface NIMChatroomManagerTest_Message : NIMChatroomManagerTest
@end

@implementation NIMChatroomManagerTest_Message

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}


- (void)testFetchHistoryMessage
{

    NSArray *testRoomIds = [NIMTestConfig sharedConfig].chatroomIds;
    
    for (NSInteger index=0; index<testRoomIds.count; index++) {
        NSString *roomId = testRoomIds[index];
        NIMHistoryMessageSearchOption *option = [[NIMHistoryMessageSearchOption alloc] init];
        option.startTime = 0;
        option.limit = 100;
        
        [[[NIMSDK sharedSDK] chatroomManager] fetchMessageHistory:roomId
                                                           option:option
                                                           result:^(NSError *error, NSArray *messages) {
                                                               XCTAssertNil(error);
                                                               for (NIMMessage *message in messages) {
                                                                   [self checkMessage:message];
                                                               }
                                                               if (index == testRoomIds.count-1) {
                                                                   NIM_TEST_NOTIFY
                                                               }

                                                           }];
    }
    NIM_TEST_WAIT
}


- (void)testChatroomMessages
{
    NIMTestMessager *messager = [[NIMTestMessager alloc] init];
    [messager sendRandomChatroomMessages];
    [messager receiveRandomChatroomMessages];
}



#pragma mark - Private

- (void)checkMessage:(NIMMessage *)message{
    XCTAssertTrue([message isKindOfClass:[message class]]);
    XCTAssertTrue(message.session.sessionType == NIMSessionTypeChatroom);
    XCTAssertNotEqual(message.timestamp,0);
}




@end
