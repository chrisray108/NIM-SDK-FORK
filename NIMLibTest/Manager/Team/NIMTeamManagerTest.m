//
//  NIMTeamManagerTest.m
//  NIMLib
//
//  Created by chris on 15/12/29.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMGlobalTest.h"
#import "NIMTestConfig.h"

@interface NIMTeamManagerTest : NIMBaseTest

@end

@implementation NIMTeamManagerTest

- (void)testFetchTeamMembers{
    NSArray *testTeamIds = [NIMTestConfig sharedConfig].teamIds;
    for (NSString *teamId in testTeamIds) {
        NIM_CONDITION_SETUP
        [[NIMSDK sharedSDK].teamManager fetchTeamMembers:teamId completion:^(NSError *error, NSArray *members) {
            XCTAssertNil(error);
            for (NIMTeamMember *member in members) {
                [self checkVaildTeamMember:member];
            }
            NIM_CONDITION_NOTIFY
        }];
        NIM_CONDITION_WAIT
    }

}


- (void)testMakeNormalTeam
{
    //无法直接单人建普通群
    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
    option.type = NIMTeamTypeNormal;
    option.name = @"123";
    NSString *currentUserId = [[NIMSDK sharedSDK].loginManager currentAccount];
    NIM_CONDITION_SETUP
    [[NIMSDK sharedSDK].teamManager createTeam:option users:@[currentUserId] completion:^(NSError *error, NSString *teamId) {
        XCTAssertTrue(error.code == NIMRemoteErrorCodeParameterError);
        NIM_CONDITION_NOTIFY
    }];
    NIM_CONDITION_WAIT
    
}

- (void)testMakeAdvancedTeam
{
    //无法直接单人建普通群
    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
    option.type = NIMTeamTypeAdvanced;
    option.name = @"123";
    NSString *currentUserId = [[NIMSDK sharedSDK].loginManager currentAccount];
    NIM_CONDITION_SETUP
    [[NIMSDK sharedSDK].teamManager createTeam:option users:@[currentUserId] completion:^(NSError *error, NSString *teamId) {
        XCTAssertNil(error);
        NIM_CONDITION_NOTIFY
    }];
    NIM_CONDITION_WAIT
}


- (void)checkVaildTeamMember:(NIMTeamMember *)member{
    XCTAssertTrue([member isKindOfClass:[NIMTeamMember class]]);
    XCTAssertTrue(member.teamId.length);
    XCTAssertTrue(member.userId.length);
    if ([member.userId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        if (member.type == NIMTeamMemberTypeOwner) {
            XCTAssertEqualObjects(member.invitor, @"0");
        }else{
            XCTAssertTrue(member.invitor.length);
        }
    }
}

@end
