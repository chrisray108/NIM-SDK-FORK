//
//  NIMApnsManagerTest.m
//  NIMLib
//
//  Created by amao on 3/31/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMApnsManagerProtocol.h"

@interface NIMApnsManagerTest : NIMBaseTest

@end

@implementation NIMApnsManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testValidApnsSetting
{
    id<NIMApnsManager> apnsManager = [[NIMSDK sharedSDK] apnsManager];
    
    
    for (NSInteger type = NIMPushNotificationDisplayTypeDetail; type <=  NIMPushNotificationDisplayTypeNoDetail; type++)
    {
        for (NSInteger disturbing = 0;disturbing <= 1; disturbing++)
        {
            NIMPushNotificationSetting *setting = [[NIMPushNotificationSetting alloc] init];
            setting.type = type;
            setting.noDisturbing = (BOOL)disturbing;
            setting.noDisturbingStartH = arc4random() % 24;
            setting.noDisturbingStartM = arc4random() % 60;
            setting.noDisturbingEndH = arc4random() % 24;
            setting.noDisturbingEndM = arc4random() % 60;
            
            [apnsManager updateApnsSetting:setting
                                completion:^(NSError *error) {
                                    XCTAssertNil(error);
                                    NIM_TEST_NOTIFY;
                                }];
            
            NIM_TEST_WAIT;
            
            NIMPushNotificationSetting *cachedSetting = [apnsManager currentSetting];
            XCTAssertEqual(setting.type, cachedSetting.type);
            XCTAssertEqual(setting.noDisturbing, cachedSetting.noDisturbing);
            XCTAssertEqual(setting.noDisturbingStartH, cachedSetting.noDisturbingStartH);
            XCTAssertEqual(setting.noDisturbingStartM, cachedSetting.noDisturbingStartM);
            XCTAssertEqual(setting.noDisturbingEndH, cachedSetting.noDisturbingEndH);
            XCTAssertEqual(setting.noDisturbingEndM, cachedSetting.noDisturbingEndM);

        }
    }
}

- (void)testLocalVerifyApnsSetting
{
    id<NIMApnsManager> apnsManager = [[NIMSDK sharedSDK] apnsManager];
    
    
    for (NSInteger type = NIMPushNotificationDisplayTypeDetail; type <=  NIMPushNotificationDisplayTypeNoDetail; type++)
    {
        for (NSInteger disturbing = 0;disturbing <= 1; disturbing++)
        {
            NIMPushNotificationSetting *setting = [[NIMPushNotificationSetting alloc] init];
            setting.type = type;
            setting.noDisturbing = (BOOL)disturbing;
            setting.noDisturbingStartH = 24;
            setting.noDisturbingStartM = arc4random() % 60;
            setting.noDisturbingEndH = 24;
            setting.noDisturbingEndM = arc4random() % 60;
            
            [apnsManager updateApnsSetting:setting
                                completion:^(NSError *error) {
                                    XCTAssertNil(error);
                                    NIM_TEST_NOTIFY;
                                }];
            
            NIM_TEST_WAIT;
            
            NIMPushNotificationSetting *cachedSetting = [apnsManager currentSetting];
            XCTAssertEqual(setting.type, cachedSetting.type);
            XCTAssertEqual(setting.noDisturbing, cachedSetting.noDisturbing);
            XCTAssertEqual(setting.noDisturbingStartH, cachedSetting.noDisturbingStartH);
            XCTAssertEqual(setting.noDisturbingStartM, cachedSetting.noDisturbingStartM);
            XCTAssertEqual(setting.noDisturbingEndH, cachedSetting.noDisturbingEndH);
            XCTAssertEqual(setting.noDisturbingEndM, cachedSetting.noDisturbingEndM);
            XCTAssertEqual(cachedSetting.noDisturbingStartM, 0);
            XCTAssertEqual(cachedSetting.noDisturbingEndM, 0);
        }
    }
}

@end
