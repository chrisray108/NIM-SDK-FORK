//
//  NIMSessionDB.h
//  NIMLib
//
//  Created by chris on 15/1/21.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMSessionDB.h"
#import "NIMPathManager.h"
#import "NIMDB.h"
#import "NIMSession_Private.h"
#import "NIMMessage_Private.h"
#import "NIMMessageObjectProtocol_Private.h"
#import "NIMSessionTable.h"
#import "NIMDispatch.h"
#import "NIMDatabaseModel.h"


@interface NIMSessionDB()
{
    NIMDatabase * _db;
}

@property (nonatomic ,strong) NSMutableDictionary * tableDict;

@end

@implementation NIMSessionDB

- (id)init
{
    self = [super init];
    if (self) {
        [self openDataBase];
        self.tableDict = [[NSMutableDictionary  alloc] init];
    }
    return self;
}

- (void)dealloc{
    nim_io_sync_safe(^{
        [_db close];
        _db = nil;
    });
}

- (void)openDataBase
{
    NSString *filepath = [self dbFilePath];
    NIMDatabase *db = [NIMDatabase databaseWithPath:filepath];
    if (![db open])
    {
        NIMLogErr(@"Error: Open Database Failed %s",[filepath UTF8String]);
        return;
    }
    _db = db;
#ifdef DEBUG
    _db.logsErrors  = YES;
#endif
}

- (NIMSessionTable *)table:(NIMSession *)session
{
    __block NIMSessionTable *table = nil;
    nim_io_sync_safe(^{
        if (session.sessionId)
        {
            NSString *key = [NSString stringWithFormat:@"%@-%zd",session.sessionId,session.sessionType];
            table = [_tableDict objectForKey:key];
            if (table == nil)
            {
                table = [[NIMSessionTable alloc] initWithDb:_db
                                                    session:session];
                [_tableDict setObject:table
                               forKey:key];
            }
        }
        if (table == nil)
        {
            NIMLogErr(@"invalid session %@ %zd",session.sessionId,session.sessionType);
        }
    });
    return table;
}


- (NSString *)dbFilePath
{
    NSString * path = [[[NIMPathManager sharedManager] sdkCurrentUserDir] stringByAppendingPathComponent:@"message.db"];
    return path;
}

#pragma mark - DB Operation

- (NIMSessionSaveResult*)saveMessages:(NSArray*)messages{
    NIMSessionSaveResult *result = [[NIMSessionSaveResult alloc] init];
    result.unreadCount = 0;
    nim_io_trans_sync(_db, ^{
        for (NIMMessage * message in messages) {
            @autoreleasepool {
                NIMSession *session    = message.session;
                NIMSessionTable *table = [self table:session];
                if ([table saveMessage:message])
                {
                    [result.savedMessages addObject:message];
                    if ([message shouldCountUnread])
                    {
                        result.unreadCount++;
                    }
                }
            }
        }
    });
    return result;
}

- (void)updateMessage:(NIMMessage *)message
    includeAttachment:(BOOL)attachment{
    nim_io_async(^{
        NIMSessionTable *table = [self table:message.session];
        [table updateMessage:message
           includeAttachment:attachment];
    });
}

- (void)updateMessage:(NIMMessageUpdateInfo *)info
           forSession:(NIMSession *)session
           completion:(NIMUpdateMessageBlock)completion
{
    nim_io_async(^{
        NIMSessionTable *table = [self table:session];
        BOOL result = [table updateMessageInfo:info];
        NSError *error = result ? nil : NIMLocalError(NIMLocalErrorCodeSQLFailed);
        nim_main_async_safe(^{
            if (completion) {
                completion(error);
            }
        });
    });
}


- (void)saveMessage:(NIMMessage *)message
         completion:(NIMUpdateMessageBlock)completion
{
    nim_io_async(^{
        NIMSessionTable *table = [self table:message.session];
        BOOL result = [table saveMessage:message];
        NSError *error = result ? nil : NIMLocalError(NIMLocalErrorCodeSQLFailed);
        nim_main_async_safe(^{
            if (completion) {
                completion(error);
            }
        });
    });
}


- (void)searchMessages:(NIMSession *)session
                option:(NIMMessageSearchOption *)option
                result:(NIMSearchMessageBlock)block
{
    nim_io_async(^{
        NIMSessionTable *table = [self table:session];
        NSArray *messages = [table searchMessages:option];
        nim_main_async_safe(^{
            if (block) {
                block(nil,messages);
            }
        });
    });
}


- (void)delMessages:(NSArray*)messages{
    nim_io_trans_async(_db, ^{
        for (NIMMessage * msg in messages) {
            @autoreleasepool {
               NIMSession * session    = msg.session;
               NIMSessionTable * table = [self table:session];
               [table deleteMessage:msg];
            }
        }
    });
}

- (void)delMessagesInSession:(NIMSession*)session{
    nim_io_async(^{
        NIMSessionTable * table = [self table:session];
        [table deleteAllMessageStatus];
    });
}

- (void)deleteAllmessages
{
    nim_io_sync_safe(^{
        [NIMSessionTable earseAllTables:_db];
    });
}

- (void)readAllMessageInSession:(NIMSession*)session{
    nim_io_async(^{
        NIMSessionTable * table = [self table:session];
        [table readAllMessageStatus];
    });
}


//同步读接口 所有读接口都是按时间排序
- (NSArray*)fetchMessagesInSession:(NIMSession*)session message:(NIMMessage*)message limit:(NSInteger)limit{
    __block NSArray * array;
    nim_io_sync_safe(^{
        NIMSessionTable * table = [self table:session];
        array = [table fetchMessagesWithLimit:limit lastMessage:message];
        for (NIMMessage * message in array) {
            message.session = session;
        }
    });
    return array;
}

- (NSArray *)fetchMessagesInSession:(NIMSession *)session byIds:(NSArray *)messageIds{
    __block NSArray * array;
    nim_io_sync_safe(^{
        NIMSessionTable * table = [self table:session];
        array = [table fetchMessagesByIds:messageIds];
        for (NIMMessage * message in array) {
            message.session = session;
        }
    });
    return array;
}

- (BOOL)isMessageReceived:(NSString *)messageId
               forSession:(NIMSession *)session
{
    __block BOOL isReceived = NO;
    nim_io_sync_safe(^{
        NIMSessionTable *table = [self table:session];
        isReceived = [table isMessageReceived:messageId];
    });
    return isReceived;
}




@end
