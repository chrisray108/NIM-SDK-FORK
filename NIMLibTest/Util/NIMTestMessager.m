//
//  NIMTestMessager.m
//  NIMLib
//
//  Created by amao on 2/18/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMTestMessager.h"
#import "NIMSDK.h"
#import "NIMTestMessageMaker.h"
#import "NIMTestConfig.h"
#import "NIMTestSendMsg.h"
#import "NIMTestServerAPI.h"
#import "NIMUtil.h"

@interface NIMTestMessager ()<NIMChatManagerDelegate>
@property (nonatomic,strong)    NSMutableArray  *messages;
@property (nonatomic,strong)    NSMutableArray  *sendedMessages;
@property (nonatomic,strong)    NSMutableArray  *receivedMessages;
@end

@implementation NIMTestMessager

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSArray *)sendRandomChatroomMessages
{
    NSArray *sessions = [[NIMTestConfig sharedConfig] chatroomSessions];
    return [self sendMessagesToSessions:sessions];
}

- (NSArray *)receiveRandomChatroomMessages
{
    NSArray *sessions = [[NIMTestConfig sharedConfig] chatroomSessions];
    return [self receiveMessagesInSessions:sessions];
}

- (NSArray *)sendRandomMessages
{
    NSArray *sessions = [[NIMTestConfig sharedConfig] imSessions];
    return [self sendMessagesToSessions:sessions];
}

- (NSArray *)receiveRandomMessages
{
    NSArray *sessions = [[NIMTestConfig sharedConfig] imSessions];
    return [self receiveMessagesInSessions:sessions];
}

#pragma mark - misc
- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    XCTAssertNil(error);
    
    if (error == nil)
    {
        [_sendedMessages removeObject:message];
    }
    if ([_sendedMessages count] == 0)
    {
        NIM_TEST_NOTIFY_WITH_KEY(@"send_random_messages_notifications")
    }
}


- (void)onRecvMessages:(NSArray *)messages
{
    for (NIMMessage *message in messages)
    {
        NSString *messageId = [message clientMessageId];
        if (messageId)
        {
            if([_receivedMessages containsObject:messageId])
            {
                [_receivedMessages removeObject:messageId];
                [_messages addObject:message];
            }
        }
    }
    if ([_receivedMessages count] == 0)
    {
        NIM_TEST_NOTIFY_WITH_KEY(@"receive_random_messages_notifications")
    }
}

- (NSArray *)supportMessageTypes
{
    return @[@(NIMMessageTypeText),@(NIMMessageTypeImage),@(NIMMessageTypeAudio),@(NIMMessageTypeVideo),@(NIMMessageTypeFile),@(NIMMessageTypeCustom)];
}


#pragma mark - Private
- (NSArray *)receiveMessagesInSessions:(NSArray *)sessions
{
    _messages = [NSMutableArray array];
    _receivedMessages = [NSMutableArray array];
    
    id<NIMTeamManager> teamManager = [[NIMSDK sharedSDK] teamManager];
    
    
    [[[NIMSDK sharedSDK] chatManager] addDelegate:self];
    
    for (NIMSession *session in sessions)
    {
        if (session.sessionType == NIMSessionTypeTeam &&
            [[teamManager teamById:session.sessionId] type] == NIMTeamTypeNormal)
        {
            continue;   //普通群不支持服务器发送消息
        }
        [self serverPost:session];
    }
    NSInteger count = [_receivedMessages count];
    
    NIM_TEST_WAIT_WITH_KEY(@"receive_random_messages_notifications")
    
    [[[NIMSDK sharedSDK] chatManager] removeDelegate:self];
    XCTAssertEqual([_messages count], count);
    
    return _messages;
}

- (NSArray *)sendMessagesToSessions:(NSArray *)sessions
{
    _messages = [NSMutableArray array];
    _sendedMessages = [NSMutableArray array];
    
    
    [[[NIMSDK sharedSDK] chatManager] addDelegate:self];
    for (NIMSession *session in sessions)
    {
        NSArray *messages = [NIMTestMessageMaker makeAllMessages];
        for (NIMMessage *message in messages)
        {
            NSError *error = nil;
            [[[NIMSDK sharedSDK] chatManager] sendMessage:message
                                                toSession:session
                                                    error:&error];
            if (error)
            {
                XCTAssertEqual([message messageType], NIMMessageTypeNotification);
            }
            else
            {
                [_messages addObject:message];
                [_sendedMessages addObject:message];
            }
            
        }
    }
    
    [self expectationForNotification:@"send_random_messages_notifications" object:nil handler:nil];\
    [self waitForExpectationsWithTimeout:60 handler:nil];
    
    
    [[[NIMSDK sharedSDK] chatManager] removeDelegate:self];
    XCTAssertNotEqual([_messages count], 0);
    return _messages;
}



- (void)serverPost:(NIMSession *)session
{
    NSString *me = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    for (NSNumber *messageType in [self supportMessageTypes])
    {
        NIMTestSendMsg *request;
        if (session.sessionType == NIMSessionTypeChatroom)
        {
            request = [[NIMChatroomTestSendMsg alloc] init];
        }
        else
        {
            request = [[NIMTestSendMsg alloc] init];
        }
        request.from = session.sessionType == NIMSessionTypeP2P ? session.sessionId : me;
        request.to = session.sessionType == NIMSessionTypeP2P ? me : session.sessionId;
        request.sessionType = session.sessionType;
        request.messageType = [messageType integerValue];
        request.clientMessageId = [NIMUtil uuid];
        
        [_receivedMessages addObject:request.clientMessageId];
        
        [NIMTestServerAPI post:request
                    completion:^(NSError *error, id resultObject) {
                        XCTAssertNil(error);
                    }];
        
    }
}

@end
