//
//  NIMChatManagerTest+Receipt.m
//  NIMLib
//
//  Created by amao on 3/31/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMTestMessager.h"
#import "NIMTestConfig.h"

@interface NIMChatManagerTest_Receipt : NIMBaseTest

@end

@implementation NIMChatManagerTest_Receipt

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSendReceipts
{
    NIMTestMessager *messager = [[NIMTestMessager alloc] init];
    NSArray *messages =  [messager receiveRandomMessages];
    NSInteger count = [messages count];
    
    XCTAssertNotEqual(count, 0);
    
    NSMutableArray *messagesForReceipt = [NSMutableArray array];
    for (NIMMessage *message in messages)
    {
        NIMSession *session = message.session;
        if (session.sessionType == NIMSessionTypeP2P)
        {
            BOOL hasSameTimetag = NO;
            for (NIMMessage *inMessage in messagesForReceipt)
            {
                if (inMessage.timestamp == message.timestamp)
                {
                    hasSameTimetag = YES;
                    break;
                }
            }
            if (!hasSameTimetag)
            {
                [messagesForReceipt addObject:message];
            }
            
        }
    }
    
    XCTAssertNotEqual([messagesForReceipt count], 0);

    
    [messagesForReceipt sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NIMMessage *message1 = (NIMMessage *)obj1;
        NIMMessage *message2 = (NIMMessage *)obj2;
        return message1.timestamp < message2.timestamp ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    for (NIMMessage *message in messagesForReceipt)
    {
        NIMMessageReceipt *receipt = [[NIMMessageReceipt alloc] initWithMessage:message];
        [[[NIMSDK sharedSDK] chatManager] sendMessageReceipt:receipt
                                                  completion:^(NSError *error) {
                                                      XCTAssertNil(error);
                                                      NIM_TEST_NOTIFY;
                                                  }];
        NIM_TEST_WAIT;
    }
    
    
    for (NIMMessage *message in messagesForReceipt)
    {
        NIMMessageReceipt *receipt = [[NIMMessageReceipt alloc] initWithMessage:message];
        [[[NIMSDK sharedSDK] chatManager] sendMessageReceipt:receipt
                                                  completion:^(NSError *error) {
                                                      XCTAssertNotNil(error);
                                                      XCTAssertEqual([error code], NIMRemoteErrorCodeExist);
                                                      NIM_TEST_NOTIFY;
                                                  }];
        NIM_TEST_WAIT;
    }
}


@end
