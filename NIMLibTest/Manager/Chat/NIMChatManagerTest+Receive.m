//
//  NIMChatManagerTest+Receive.m
//  NIMLib
//
//  Created by amao on 1/26/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMTestMessager.h"
#import "NIMTestConfig.h"


@interface NIMChatManagerTest_Receive : NIMBaseTest
@end

@implementation NIMChatManagerTest_Receive



- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testReceive
{
    NIMTestMessager *messager = [[NIMTestMessager alloc] init];
    NSArray *messages =  [messager receiveRandomMessages];
    NSInteger count = [messages count];
    
    XCTAssertNotEqual(count, 0);
}



@end
