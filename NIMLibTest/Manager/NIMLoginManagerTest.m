//
//  NIMLoginManagerTest.m
//  NIMLib
//
//  Created by amao on 12/24/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMTestConfig.h"

@interface NIMLoginManagerTest : NIMBaseTest

@end

@implementation NIMLoginManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCurrentUserId
{
    id<NIMLoginManager> manager = [[NIMSDK sharedSDK] loginManager];
    NSString *currentAccount = [manager currentAccount];
    NSString *loginId = [[NIMTestConfig sharedConfig] account];
    
    XCTAssertTrue([currentAccount isEqualToString:loginId]);
}

@end
