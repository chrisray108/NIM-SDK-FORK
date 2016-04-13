//
//  NIMChatroomManager+User.m
//  NIMLib
//
//  Created by chris on 16/1/4.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomManagerTest.h"

@interface NIMChatroomManagerTest_User : NIMChatroomManagerTest

@end


@implementation NIMChatroomManagerTest_User

- (void)testFetchUser{
    NIMChatroomMemberRequest *request = [[NIMChatroomMemberRequest alloc] init];
    request.roomId = [NIMTestConfig sharedConfig].chatroomIds.firstObject;
    request.type   = self.randomFetchMemberType;
    //request.offset = 0;
    request.limit  = 100;
    NIM_CONDITION_SETUP
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembers:request completion:^(NSError *error, NSArray *members) {
        XCTAssertNil(error);
        for (NIMChatroomMember *user in members) {
            [self checkChatroomMember:user];
        }
        NIM_CONDITION_NOTIFY
    }];
    NIM_CONDITION_WAIT
}


- (void)testMarkUserStepAManager{
    NSString *userId = [NIMTestConfig sharedConfig].friendIds.firstObject;
    [self markUser:userId manager:YES];
    [self markUser:userId manager:NO];
}


- (void)testMarkUserStepBNormalMember
{
    NSString *userId = [NIMTestConfig sharedConfig].friendIds.firstObject;
    [self markUser:userId normal:YES];
    [self markUser:userId normal:NO];
}


#pragma mark - Private
- (NIMChatroomFetchMemberType)randomFetchMemberType{
    return arc4random() % 2;
}

- (void)checkChatroomMember:(NIMChatroomMember *)member{
    XCTAssertTrue([member isKindOfClass:[NIMChatroomMember class]]);
    XCTAssertTrue(member.userId.length);
}

- (void)markUser:(NSString *)userId manager:(BOOL)isManager
{
    NIMChatroomMemberUpdateRequest *request = [[NIMChatroomMemberUpdateRequest alloc] init];
    request.roomId = [NIMTestConfig sharedConfig].chatroomIds.firstObject;
    request.userId = userId;
    request.enable = isManager;
    NIM_CONDITION_SETUP
    [[NIMSDK sharedSDK].chatroomManager markMemberManager:request completion:^(NSError *error) {
        XCTAssertTrue(error.code == NIMRemoteErrorCodeExist || !error);
        NIMChatroomMembersByIdsRequest *req = [[NIMChatroomMembersByIdsRequest alloc] init];
        req.roomId  = request.roomId;
        req.userIds = @[request.userId];
        [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:req completion:^(NSError *error, NSArray *members) {
            XCTAssertNil(error);
            NIMChatroomMember *member = members.firstObject;
            XCTAssertTrue(member.type == (isManager ? NIMChatroomMemberTypeManager : NIMChatroomMemberTypeNormal));
            NIM_CONDITION_NOTIFY
        }];
    }];
    NIM_CONDITION_WAIT
}

- (void)markUser:(NSString *)userId normal:(BOOL)isNormal
{
    NIMChatroomMemberUpdateRequest *request = [[NIMChatroomMemberUpdateRequest alloc] init];
    request.roomId = [NIMTestConfig sharedConfig].chatroomIds.firstObject;
    request.userId = userId;
    request.enable = isNormal;
    NIM_CONDITION_SETUP
    [[NIMSDK sharedSDK].chatroomManager markNormalMember:request completion:^(NSError *error) {
        XCTAssertTrue(error.code == NIMRemoteErrorCodeExist || !error);
        NIMChatroomMembersByIdsRequest *req = [[NIMChatroomMembersByIdsRequest alloc] init];
        req.roomId  = request.roomId;
        req.userIds = @[request.userId];
        [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:req completion:^(NSError *error, NSArray *members) {
            XCTAssertNil(error);
            NIMChatroomMember *member = members.firstObject;
            XCTAssertTrue(isNormal ? (member.type == NIMChatroomMemberTypeNormal) : !member);
            NIM_CONDITION_NOTIFY
        }];
    }];
    NIM_CONDITION_WAIT
}

@end
