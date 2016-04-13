//
//  NIMModelCopyTest.m
//  NIMLib
//
//  Created by amao on 2/17/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMSession_Private.h"
#import "NIMRecentSession_Private.h"
#import "NIMTestMessageMaker.h"

@interface NIMModelCopyTest : NIMBaseTest

@end

@implementation NIMModelCopyTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSessionCopy
{
    NSArray *sessionIds = @[@"1",@"2",@"3"];
    NSArray *sessionTypes = @[@(NIMSessionTypeP2P),@(NIMSessionTypeTeam),@(NIMSessionTypeChatroom)];
    for (NSString *sessionId in sessionIds)
    {
        for (NSNumber *sessionType in sessionTypes)
        {
            NIMSession *session = [NIMSession session:sessionId
                                                 type:[sessionType integerValue]];
            NIMSession *copiedSession = [session copy];
            [self checkSession:session
                 copiedSession:copiedSession];
        }
    }
}

- (void)testRecentSession
{
    NSArray *sessionIds = @[@"1",@"2",@"3"];
    NSArray *sessionTypes = @[@(NIMSessionTypeP2P),@(NIMSessionTypeTeam),@(NIMSessionTypeChatroom)];
    NSArray *messages = [NIMTestMessageMaker makeAllMessages];
    NSArray *counts = @[@(0),@(3),@(100),@(2390423049908)];
    for (NSString *sessionId in sessionIds)
    {
        for (NSNumber *sessionType in sessionTypes)
        {
            for (NIMMessage *message in messages)
            {
                for (NSNumber *count in counts)
                {
                    NIMRecentSession *recentSession = [[NIMRecentSession alloc] init];
                    recentSession.session = [NIMSession session:sessionId
                                                           type:[sessionType integerValue]];
                    recentSession.lastMessage = message;
                    recentSession.unreadCount = [count integerValue];
                    
                    NIMRecentSession *copiedRecentSession = [recentSession copy];
                    
                    [self checkRecentSession:recentSession
                         copiedRecentSession:copiedRecentSession];
                }
            }
        }
    }

    
}

#pragma mark - check functions
- (void)checkSession:(NIMSession *)session
       copiedSession:(NIMSession *)copiedSession
{
    XCTAssertEqual(session.sessionId, copiedSession.sessionId);
    XCTAssertEqual(session.sessionType, copiedSession.sessionType);
}

- (void)checkRecentSession:(NIMRecentSession *)recentSession
       copiedRecentSession:(NIMRecentSession *)copiedRecentSession
{
    [self checkSession:recentSession.session
         copiedSession:copiedRecentSession.session];
    
    XCTAssertEqual(recentSession.lastMessage, copiedRecentSession.lastMessage);
    XCTAssertEqual(recentSession.unreadCount, copiedRecentSession.unreadCount);
}
@end
