//
//  NIMBaseTest.m
//  NIMLib
//
//  Created by amao on 12/24/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMBaseTest.h"
#import "NIMTestCustomObject.h"
#import "NIMNOSTokenManager.h"
#import "NIMTimer.h"

@interface NIMBaseTest ()<NIMLoginManagerDelegate>
@end

@implementation NIMBaseTest


- (void)setUp {
    [super setUp];
    
    static BOOL setup = NO;
    if (!setup)
    {
        [self login];
        [self setupSDK];
        [self queryNOSToken];
        setup = YES;
    }
}

- (void)tearDown {
    [super tearDown];

    [[[NIMSDK sharedSDK] loginManager] removeDelegate:self];
}

#pragma mark - 登录
- (void)login
{
    NIMTestConfig *config = [NIMTestConfig sharedConfig];
    [config useDevEnvironment];
    
    [[NIMSDK sharedSDK] registerWithAppID:config.appKey
                                  cerName:config.cerName];
    
    [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
    
    [[[NIMSDK sharedSDK] loginManager] login:config.account
                                       token:config.token
                                  completion:^(NSError *error) {
                                      XCTAssertNil(error);
                                  }];
    NIM_TEST_WAIT_WITH_KEY(@"nim_login_synced")
}


- (void)onLogin:(NIMLoginStep)step
{
    if (step == NIMLoginStepSyncOK)
    {
        NIM_TEST_NOTIFY_WITH_KEY(@"nim_login_synced")
    }
}

#pragma mark - 配置sdk
- (void)setupSDK
{
    [NIMCustomObject registerCustomDecoder:[NIMTestCustomObject new]];
}

#pragma mark - 检查NOS token
- (void)queryNOSToken
{
    NIM_WAIT_WHILE([[NIMNOSTokenManager sharedManager] fetchToken] == nil, 30);
}
@end
