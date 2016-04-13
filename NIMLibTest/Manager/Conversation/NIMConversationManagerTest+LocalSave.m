//
//  NIMConversationManager+Save.m
//  NIMLib
//
//  Created by amao on 12/28/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMTestMessageMaker.h"

@interface NIMConversationManagerTest_LocalSave : NIMBaseTest

@end

@implementation NIMConversationManagerTest_LocalSave

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSaveMessageForSessionTypes
{
    //P2P消息,接受者a，发送者a
    {
        NSString *sessionId = [[[NIMTestConfig sharedConfig] friendIds] firstObject];
        
        NIMMessage *message = [[NIMMessage alloc] init];
        message.text = @"save text for p2p other";
        message.from = sessionId;
        
        NIMSession *session = [NIMSession session:sessionId
                                             type:NIMSessionTypeP2P];
        NIM_CONDITION_SETUP;
        [[[NIMSDK sharedSDK] conversationManager] saveMessage:message
                                                   forSession:session
                                                   completion:^(NSError *error) {
                                                       XCTAssertNil(error);
                                                       NIM_CONDITION_NOTIFY;
                                                   }];
        NIM_CONDITION_WAIT;
    }
    
    //P2P消息，接受者a，发送者我
    {
        NSString *sessionId = [[[NIMTestConfig sharedConfig] friendIds] firstObject];
        
        NIMMessage *message = [[NIMMessage alloc] init];
        message.text = @"save text for p2p me";
        message.from = [[[NIMSDK sharedSDK] loginManager] currentAccount];
        
        NIMSession *session = [NIMSession session:sessionId
                                             type:NIMSessionTypeP2P];
        
        NIM_CONDITION_SETUP;
        [[[NIMSDK sharedSDK] conversationManager] saveMessage:message
                                                   forSession:session
                                                   completion:^(NSError *error) {
                                                       XCTAssertNil(error);
                                                       NIM_CONDITION_NOTIFY;
                                                   }];
        NIM_CONDITION_WAIT;
    }
    
    //TEAM消息，接受者群Id，发送者a
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        message.text = @"save text for team other";
        message.from = [[[NIMTestConfig sharedConfig] friendIds] firstObject];
        
        NIMSession *session = [NIMSession session:@"team_for_save"
                                             type:NIMSessionTypeTeam];
        
        NIM_CONDITION_SETUP;
        [[[NIMSDK sharedSDK] conversationManager] saveMessage:message
                                                   forSession:session
                                                   completion:^(NSError *error) {
                                                       XCTAssertNil(error);
                                                       NIM_CONDITION_NOTIFY;
                                                   }];
        NIM_CONDITION_WAIT;
    }
    
    
    //TEAM消息，接受者群Id，发送者我
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        message.text = @"save text for team me";
        message.from = [[[NIMSDK sharedSDK] loginManager] currentAccount];
        
        NIMSession *session = [NIMSession session:@"team_for_save"
                                             type:NIMSessionTypeTeam];
        
        NIM_CONDITION_SETUP;
        [[[NIMSDK sharedSDK] conversationManager] saveMessage:message
                                                   forSession:session
                                                   completion:^(NSError *error) {
                                                       XCTAssertNil(error);
                                                       NIM_CONDITION_NOTIFY;
                                                   }];
        NIM_CONDITION_WAIT;
    }
    
    //聊天室消息，接受者聊天室Id，发送者a
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        message.text = @"save text for chatromm other";
        message.from = [[[NIMTestConfig sharedConfig] friendIds] firstObject];
        
        NIMSession *session = [NIMSession session:@"chatroom for save"
                                             type:NIMSessionTypeChatroom];
        
        
        NIM_CONDITION_SETUP;
        [[[NIMSDK sharedSDK] conversationManager] saveMessage:message
                                                   forSession:session
                                                   completion:^(NSError *error) {
                                                       XCTAssertNotNil(error);
                                                       XCTAssertEqual([error code], NIMLocalErrorCodeInvalidParam);
                                                       NIM_CONDITION_NOTIFY;
                                                   }];
        NIM_CONDITION_WAIT;
    }
    
    //聊天室消息，接受者聊天室Id,发送者我
    {
        
        NIMMessage *message = [[NIMMessage alloc] init];
        message.text = @"save text for chatroom me";
        message.from = [[[NIMSDK sharedSDK] loginManager] currentAccount];
        
        NIMSession *session = [NIMSession session:@"chatroom for save"
                                             type:NIMSessionTypeChatroom];
        
        NIM_CONDITION_SETUP;
        [[[NIMSDK sharedSDK] conversationManager] saveMessage:message
                                                   forSession:session
                                                   completion:^(NSError *error) {
                                                       XCTAssertNotNil(error);
                                                       XCTAssertEqual([error code], NIMLocalErrorCodeInvalidParam);
                                                       NIM_CONDITION_NOTIFY;
                                                   }];
        NIM_CONDITION_WAIT;
    }
}

- (void)testSaveMessageForMessageTypes
{
    
    NIMSession *session = [NIMSession session:@"1024" type:NIMSessionTypeP2P];
    NSArray *messages = [NIMTestMessageMaker makeAllMessages];
    for (NIMMessage *message in messages)
    {
        NIM_CONDITION_SETUP;
        
        BOOL canBeSaved = [self messageCanBeSaved:message];
        [[[NIMSDK sharedSDK] conversationManager] saveMessage:message
                                                   forSession:session
                                                   completion:^(NSError *error) {
                                                       if (canBeSaved)
                                                       {
                                                           XCTAssertNil(error);
                                                       }
                                                       else
                                                       {
                                                           XCTAssertNotNil(error);
                                                           XCTAssertEqual([error code], NIMLocalErrorCodeInvalidParam);
                                                       }
                                                       NIM_CONDITION_NOTIFY;
                                                   }];
        NIM_CONDITION_WAIT;
        
    }
}


- (BOOL)messageCanBeSaved:(NIMMessage *)message
{
    NIMMessageType type = [message messageType];
    return type == NIMMessageTypeText ||
    type == NIMMessageTypeTip ||
    type == NIMMessageTypeCustom;
}


@end
