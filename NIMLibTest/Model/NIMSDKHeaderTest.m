//
//  NIMSDKHeaderTest.m
//  NIMLib
//
//  Created by chris on 15/12/31.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMSDK.h"

@interface NIMSDKHeaderTest : XCTestCase

@end

@implementation NIMSDKHeaderTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testSDKVersion{
    NSString *sdkVersion = [NIMSDK sharedSDK].sdkVersion;
    XCTAssertTrue(sdkVersion.length);
}

@end
