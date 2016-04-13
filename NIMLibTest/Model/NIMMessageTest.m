//
//  NIMMessageTest.m
//  NIMLib
//
//  Created by amao on 12/23/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMMessage_Private.h"
#import "NIMMessageSetting.h"

typedef bool(^SubstatusBlock)(SEL selecotr);


@interface NIMMessageTest : NIMBaseTest

@end

@implementation NIMMessageTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMessageInit
{
    NIMMessage *message = [[NIMMessage alloc] init];
    
    XCTAssertNotNil(message.messageId);
    XCTAssertNotEqual(message.timestamp,0);
    XCTAssertFalse(message.isReceivedMsg);
    XCTAssertFalse(message.isPlayed);
    XCTAssertFalse(message.isDeliveried);
    XCTAssertFalse(message.tryDownloadOnce);
    
    
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    XCTAssertTrue(setting.historyEnabled);
    XCTAssertTrue(setting.roamingEnabled);
    XCTAssertTrue(setting.syncEnabled);
    XCTAssertTrue(setting.shouldBeCounted);
    XCTAssertTrue(setting.apnsEnabled);
    XCTAssertTrue(setting.apnsWithPrefix);
}

- (void)testMessageSubstatus
{
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        [message setIsDeliveried:YES];
        XCTAssertTrue(message.isDeliveried);
        [message setIsDeliveried:NO];
        XCTAssertFalse(message.isDeliveried);
    }
    
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        [message setIsReceivedMsg:YES];
        XCTAssertTrue(message.isReceivedMsg);
        [message setIsReceivedMsg:NO];
        XCTAssertFalse(message.isReceivedMsg);
    }
    
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        [message setTryDownloadOnce:YES];
        XCTAssertTrue(message.tryDownloadOnce);
        [message setTryDownloadOnce:NO];
        XCTAssertFalse(message.tryDownloadOnce);
    }
    
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        [message setIsPlayed:YES];
        XCTAssertTrue(message.isPlayed);
        [message setIsPlayed:NO];
        XCTAssertFalse(message.isPlayed);
    }
    
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        [self message:message
         shouldModify:^bool(SEL selecotr) {
             return selecotr != @selector(setIsPlayed:);
         } subStatusChange:^{
             XCTAssertFalse(message.isPlayed);
         }];
    }
    
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        [self message:message
         shouldModify:^bool(SEL selecotr) {
             return selecotr != @selector(setIsDeliveried:);
         } subStatusChange:^{
             XCTAssertFalse(message.isDeliveried);
         }];
    }
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        [self message:message
         shouldModify:^bool(SEL selecotr) {
             return selecotr != @selector(setIsReceivedMsg:);
         } subStatusChange:^{
             XCTAssertFalse(message.isReceivedMsg);
         }];
    }
    
    {
        NIMMessage *message = [[NIMMessage alloc] init];
        [self message:message
         shouldModify:^bool(SEL selecotr) {
             return selecotr != @selector(setTryDownloadOnce:);
         } subStatusChange:^{
             XCTAssertFalse(message.tryDownloadOnce);
         }];
    }
    
}

#pragma mark - misc
- (void)message:(NIMMessage *)message
   shouldModify:(SubstatusBlock)modifyBlock
subStatusChange:(dispatch_block_t)block

{
    if (modifyBlock(@selector(setIsDeliveried:)))
    {
        [message setIsDeliveried:YES];
        block();
    }
    if (modifyBlock(@selector(setIsReceivedMsg:)))
    {
        [message setIsReceivedMsg:YES];
        block();
    }
    if (modifyBlock(@selector(setTryDownloadOnce:)))
    {
        [message setTryDownloadOnce:YES];
        block();
    }
    if (modifyBlock(@selector(setIsPlayed:)))
    {
        [message setIsPlayed:YES];
        block();
    }
    
    if (modifyBlock(@selector(setIsDeliveried:)))
    {
        [message setIsDeliveried:NO];
        block();
    }
    if (modifyBlock(@selector(setIsReceivedMsg:)))
    {
        [message setIsReceivedMsg:NO];
        block();
    }
    if (modifyBlock(@selector(setTryDownloadOnce:)))
    {
        [message setTryDownloadOnce:NO];
        block();
    }
    if (modifyBlock(@selector(setIsPlayed:)))
    {
        [message setIsPlayed:NO];
        block();
    }
}

@end
