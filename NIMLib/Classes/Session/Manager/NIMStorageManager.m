//
//  NIMStorageManager.m
//  NIMLib
//
//  Created by chris on 15/1/24.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMStorageManager.h"
#import "NIMSessionDB.h"
#import "NIMKeyValueStore.h"
#import "NIMPathManager.h"
#import "NIMTaskEngine.h"
#import "NIMSession_Private.h"
#import "NIMMessage_Private.h"
@interface NIMStorageManager()

@property (nonatomic,strong) NIMSessionDB         * sessionDB;
@end

@implementation NIMStorageManager
@synthesize sessionDB = _sessionDB;

- (instancetype)init
{
    if (self = [super init])
    {
        _sessionDB           = [[NIMSessionDB alloc] init];
    }
    return self;
}


- (NIMSessionSaveResult*)saveMessages:(NSArray*)messages{
    return [self.sessionDB saveMessages:messages];
}

- (void)updateMessage:(NIMMessage *)message
    includeAttachment:(BOOL)attachment{
    [self.sessionDB updateMessage:message
                includeAttachment:attachment];
}

- (void)updateMessage:(NIMMessageUpdateInfo *)info
           forSession:(NIMSession *)session
           completion:(NIMUpdateMessageBlock)completion
{
    [self.sessionDB updateMessage:info
                       forSession:session
                       completion:completion];
}

- (void)saveMessage:(NIMMessage *)message
         completion:(NIMUpdateMessageBlock)completion
{
    [self.sessionDB saveMessage:message
                     completion:completion];
}

- (void)searchMessages:(NIMSession *)session
                option:(NIMMessageSearchOption *)option
                result:(NIMSearchMessageBlock)block;
{
    [self.sessionDB searchMessages:session
                            option:option
                            result:block];
}


- (void)deleteMessage:(NIMMessage*)message{
    message.status = NIMMessageStatusDeleted;
    [self.sessionDB delMessages:@[message]];
}

- (void)deleteAllmessagesInSession:(NIMSession*)session{
    [self.sessionDB delMessagesInSession:session];
}

- (void)deleteAllmessages
{
    [self.sessionDB deleteAllmessages];
}

- (void)markAllMessagesReadInSession:(NIMSession*)session{
    [self.sessionDB readAllMessageInSession:session];
}

- (NSArray*)messagesInSession:(NIMSession*)session message:(NIMMessage*)message limit:(NSInteger)limit{
    return [self.sessionDB fetchMessagesInSession:session message:message limit:limit];
}

- (NSArray *)messagesInSession:(NIMSession *)session
                    messageIds:(NSArray *)messageIds{
    return [self.sessionDB fetchMessagesInSession:session byIds:messageIds];
}

- (BOOL)isMessageReceived:(NSString *)messageId
               forSession:(NIMSession *)session
{
    return messageId ?
    [self.sessionDB isMessageReceived:messageId
                           forSession:session]
    : NO;
}


@end
