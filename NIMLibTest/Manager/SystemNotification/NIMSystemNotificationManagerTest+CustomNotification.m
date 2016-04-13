//
//  NIMSystemNotificationManagerTest+CustomNotification.m
//  NIMLib
//
//  Created by amao on 12/30/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMTestConfig.h"

@interface NIMSystemNotificationManagerTest_CustomNotification : NIMBaseTest

@end

@implementation NIMSystemNotificationManagerTest_CustomNotification

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testValidCustomNotification
{
    
    id<NIMSystemNotificationManager> manager = [[NIMSDK sharedSDK] systemNotificationManager];
    NSArray *sessions = [[NIMTestConfig sharedConfig] imSessions];
    
    {
        for (NIMSession *session in sessions)
        {
            NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:@"test custom notification"];
            [manager sendCustomNotification:notification
                                  toSession:session
                                 completion:^(NSError *error) {
                                     XCTAssertNil(error);
                                     NIM_TEST_NOTIFY;
                                 }];
            NIM_TEST_WAIT;
        }

    }
    
    {
        NSArray *settings = [self settings];
        for (NIMSession *session in sessions)
        {
            for (NIMCustomSystemNotificationSetting *setting in settings)
            {
                NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:@"test custom notification"];
                notification.setting = setting;
                notification.apnsContent = arc4random() % 2 ? @"unit test content" : nil;
                notification.apnsPayload = arc4random() % 2 ? @{@"unit test" : @(2)} : nil;
                [manager sendCustomNotification:notification
                                      toSession:session
                                     completion:^(NSError *error) {
                                         XCTAssertNil(error);
                                         NIM_TEST_NOTIFY;
                                     }];
                NIM_TEST_WAIT;

            }
        }
        
    }
    
}

- (NSArray *)settings
{
    NSMutableArray *settings = [NSMutableArray array];
    {
        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
        setting.shouldBeCounted = NO;
        setting.apnsEnabled = NO;
        setting.apnsEnabled = NO;
        [settings addObject:setting];
    }
    
    {
        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
        setting.shouldBeCounted = YES;
        setting.apnsEnabled = NO;
        setting.apnsEnabled = NO;
        [settings addObject:setting];
    }
    
    {
        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
        setting.shouldBeCounted = NO;
        setting.apnsEnabled = YES;
        setting.apnsEnabled = NO;
        [settings addObject:setting];
    }
    
    {
        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
        setting.shouldBeCounted = NO;
        setting.apnsEnabled = NO;
        setting.apnsEnabled = YES;
        [settings addObject:setting];
    }
    
    {
        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
        setting.shouldBeCounted = YES;
        setting.apnsEnabled = YES;
        setting.apnsEnabled = YES;
        [settings addObject:setting];
    }
    
    {
        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
        setting.shouldBeCounted = YES;
        setting.apnsEnabled = YES;
        setting.apnsEnabled = NO;
        [settings addObject:setting];
    }
    
    {
        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
        setting.shouldBeCounted = YES;
        setting.apnsEnabled = NO;
        setting.apnsEnabled = YES;
        [settings addObject:setting];
    }
    
    {
        NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
        setting.shouldBeCounted = NO;
        setting.apnsEnabled = YES;
        setting.apnsEnabled = YES;
        [settings addObject:setting];
    }
    
    return settings;
}


@end
