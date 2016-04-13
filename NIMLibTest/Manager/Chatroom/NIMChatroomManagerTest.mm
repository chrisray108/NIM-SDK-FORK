//
//  NIMChatroomManager.m
//  NIMLib
//
//  Created by chris on 16/1/5.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NIMChatroomManagerTest.h"

@implementation NIMChatroomManagerTest

- (void)setUp{
    [super setUp];
    static BOOL chatroomSetup = NO;
    if (!chatroomSetup)
    {
        [self enterChatroom];
        chatroomSetup = YES;
    }
}

- (void)tearDown{
    [super tearDown];
}

- (void)enterChatroom{
    NSArray *roomIds = [NIMTestConfig sharedConfig].chatroomIds;
    for (NSInteger index=0; index<roomIds.count; index++) {
        NSString *roomId = roomIds[index];
        NIMChatroomEnterRequest *request = [[NIMChatroomEnterRequest alloc] init];
        request.roomId = roomId;
        [[NIMSDK sharedSDK].chatroomManager enterChatroom:request completion:^(NSError *error, NIMChatroom *chatroom, NIMChatroomMember *me) {
            XCTAssertNil(error);
            [self checkChatroom:chatroom];
            [self checkMe:me];
            if (index == roomIds.count - 1) {
                NIM_TEST_NOTIFY
            }
        }];
    }
    NIM_TEST_WAIT
}

- (void)checkChatroom:(NIMChatroom *)chatroom{
    XCTAssertTrue([chatroom isKindOfClass:[NIMChatroom class]]);
    XCTAssertTrue(chatroom.roomId.length);
    XCTAssertTrue(chatroom.creator.length);
}

- (void)checkMe:(NIMChatroomMember *)me{
    XCTAssertTrue([me isKindOfClass:[NIMChatroomMember class]]);
    XCTAssertTrue(me.userId.length);
}

@end
