//
//  NIMUserManagerTest.m
//  NIMLib
//
//  Created by amao on 12/24/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMGlobalTest.h"

@interface NIMUserManagerTest : NIMBaseTest

@end

@implementation NIMUserManagerTest


- (void)testFetchMyUserInfo
{
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:[NIMSDK sharedSDK].loginManager.currentAccount];
    XCTAssertNotNil(user.userInfo);
    XCTAssertTrue([user.userId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]);
}


- (void)testMyFriends
{
    NIMUserRequest *request = [[NIMUserRequest alloc] init];
    request.userId       = [NIMTestConfig sharedConfig].friendIds.firstObject;
    request.operation    = NIMUserOperationAdd;
    [[NIMSDK sharedSDK].userManager requestFriend:request completion:^(NSError *error) {
        NIMUser *user = [[NIMUser alloc] init];
        user.userId = [NIMTestConfig sharedConfig].friendIds.firstObject;
        XCTAssertTrue([[NIMSDK sharedSDK].userManager.myFriends containsObject:user]);
        NIM_TEST_NOTIFY;
    }];
    NIM_TEST_WAIT
}

- (void)testAddFriendDirectly
{
    NIMUserRequest *request = [[NIMUserRequest alloc] init];
    request.userId       = [NIMTestConfig sharedConfig].friendIds.firstObject;
    request.operation    = NIMUserOperationAdd;
    [[NIMSDK sharedSDK].userManager requestFriend:request completion:^(NSError *error) {
        NIMUser *user = [[NIMUser alloc] init];
        user.userId = [NIMTestConfig sharedConfig].friendIds.firstObject;
        XCTAssertTrue([[NIMSDK sharedSDK].userManager.myFriends containsObject:user]);
        NIM_TEST_NOTIFY;
    }];
    NIM_TEST_WAIT

}


- (void)testUpdateFriends{
    NIMUser *user = [[NIMUser alloc] init];
    user.userId       = [NIMTestConfig sharedConfig].friendIds.firstObject;
    NSString *alias   = [NSString stringWithFormat:@"%.3f",[[NSDate date] timeIntervalSince1970]];
    NSDictionary *ext = @{@"alias":alias};
    user.alias        = alias;
    user.ext          = ext;
    [[NIMSDK sharedSDK].userManager updateUser:user completion:^(NSError *error) {
        XCTAssertNil(error);
        NIMUser *modifyUser = [[NIMSDK sharedSDK].userManager userInfo:user.userId];
        XCTAssertEqualObjects(modifyUser.alias, alias);
        XCTAssertEqualObjects(modifyUser.ext[@"alias"], alias);
        NIM_TEST_NOTIFY
    }];
    NIM_TEST_WAIT

}


- (void)testNotifyUser{
    NSString *friendId = [NIMTestConfig sharedConfig].friendIds.firstObject;
    BOOL isNotify = [[NIMSDK sharedSDK].userManager notifyForNewMsg:friendId];
    [[NIMSDK sharedSDK].userManager updateNotifyState:!isNotify forUser:friendId completion:^(NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(!isNotify == [[NIMSDK sharedSDK].userManager notifyForNewMsg:friendId]);
        if (!error) {
            [[NIMSDK sharedSDK].userManager updateNotifyState:isNotify forUser:friendId completion:^(NSError *error) {
               XCTAssertNil(error);
               XCTAssertTrue(isNotify == [[NIMSDK sharedSDK].userManager notifyForNewMsg:friendId]);
               NIM_TEST_NOTIFY
            }];
        }
    }];
    NIM_TEST_WAIT
}

- (void)testBlackUser{
    NSString *friendId = [NIMTestConfig sharedConfig].friendIds.firstObject;
    [[NIMSDK sharedSDK].userManager addToBlackList:friendId completion:^(NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue([[NIMSDK sharedSDK].userManager isUserInBlackList:friendId]);
        if (!error) {
            [[NIMSDK sharedSDK].userManager removeFromBlackBlackList:friendId completion:^(NSError *error) {
                XCTAssertNil(error);
                XCTAssertFalse([[NIMSDK sharedSDK].userManager isUserInBlackList:friendId]);
                NIM_TEST_NOTIFY
            }];
        }
    }];
}


@end
