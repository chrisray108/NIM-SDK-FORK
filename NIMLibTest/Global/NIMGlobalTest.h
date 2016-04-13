//
//  NIMGlobalTest.h
//  NIMLib
//
//  Created by chris on 15/12/23.
//  Copyright © 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_NIMGloablTest_h
#define NIMLib_NIMGloablTest_h
#import <Foundation/Foundation.h>


#define NIM_TEST_WAIT \
{\
    [self expectationForNotification:@"nim_test_notification" object:nil handler:nil];\
    [self waitForExpectationsWithTimeout:60 handler:nil];\
}


#define NIM_TEST_NOTIFY \
{\
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nim_test_notification" object:nil];\
}


#define NIM_TEST_WAIT_WITH_KEY(key)\
{\
    [self expectationForNotification:key object:nil handler:nil];\
    [self waitForExpectationsWithTimeout:60 handler:nil];\
}

#define NIM_TEST_NOTIFY_WITH_KEY(key)\
{\
    [[NSNotificationCenter defaultCenter] postNotificationName:key object:nil];\
}

#define NIM_CONDITION_SETUP __block BOOL NIMTestWaitCondition = NO;

#define NIM_CONDITION_WAIT \
{\
    if(!NIMTestWaitCondition) \
    { \
        [self expectationForNotification:@"nim_condition_notification" object:nil handler:nil];\
        [self waitForExpectationsWithTimeout:60 handler:nil];\
    }\
}


#define NIM_CONDITION_NOTIFY \
{\
    NIMTestWaitCondition = YES;\
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nim_condition_notification" object:nil];\
}



#define NIM_WAIT_WHILE(whileTrue, limitInSeconds) \
{\
    NSDate *giveUpDate = [NSDate dateWithTimeIntervalSinceNow:(limitInSeconds)];\
    while ((whileTrue) && [giveUpDate timeIntervalSinceNow] > 0)\
    {\
    NSDate *loopIntervalDate = [NSDate dateWithTimeIntervalSinceNow:0.01];\
    [[NSRunLoop currentRunLoop] runUntilDate:loopIntervalDate];\
    }\
    if((whileTrue)) \
    {\
        XCTAssertNil(@"invalid path");\
    }\
}\

#endif
