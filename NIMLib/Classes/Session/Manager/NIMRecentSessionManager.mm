//
//  NIMRecentSessionManager.m
//  NIMLib
//
//  Created by amao on 2/4/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMRecentSessionManager.h"
#import "NIMRecentSession_Private.h"
#import "NIMSession_Private.h"
#import "NIMDatabase.h"
#import "NIMDispatch.h"
#import "NIMPathManager.h"
#import "NIMMessage_Private.h"
#import "NIMMessageObjectProtocol_Private.h"
#import "NIMModelConverter.h"
#import "NIMConversationManagerProtocol.h"
#import "NIMConversationManager.h"
#import "NIMDelegateCenter.h"
#import "NIMDatabaseUpgrader.h"
#import "NIMProtocolUtil.h"
#import "NIMMessageSetting_Private.h"

#define NIMRecentTable  @"recentSession"

@interface NIMRecentSessionManager ()
@property (nonatomic,readwrite,strong)    NSMutableDictionary    *sessions;
@property (nonatomic,strong)              NIMDatabase            *db;
@property (nonatomic,assign)              NSInteger              allUnreadCount;
@end

@implementation NIMRecentSessionManager
@synthesize sessions = _sessions;

- (instancetype)init
{
    if (self = [super init])
    {
        if([self openDataBase]){
            [self createTable];
            _sessions = [self dbAllRecentData];
        }
        _allUnreadCount = 0;
        for (NIMSession * session in _sessions) {
            NIMRecentSession * recentSession = _sessions[session];
            _allUnreadCount += recentSession.unreadCount;
        }
    }
    return self;
}

- (void)dealloc
{
    nim_io_sync_safe(^{
        [_db close];
        _db = nil;
    });
}


- (BOOL)openDataBase
{
    NSString *filepath = [self dbFilePath];
    NIMDatabase *db = [NIMDatabase databaseWithPath:filepath];
    BOOL res = [db open];
    if (!res)
    {
        NIMLogErr(@"error: open database failed %@",filepath);
        return res;
    }
    _db = db;
#ifdef DEBUG
    _db.logsErrors  = YES;
#endif
    return res;
}

- (void)createTable{
    
    NSArray * sqls = [self createTableSqls];
    for (NSString *sql in sqls)
    {
        if (![_db executeUpdate:sql])
        {
            NIMLogErr(@"error: execute sql %@ failed",sql);
        }
    }
    [self upgradeVersion1]; //第一个更新版本:添加local_ext和remote_ext
}

- (NSArray*)createTableSqls{
    //消息表
    NSString * sql = [NSString stringWithFormat:@"\
                      create table if not exists %@(serial integer primary key, session_id text unique, \
                      session_type integer, msg_serial integer,\
                      server_id text , msg_id text, msg_from_id text,\
                      msg_text text, msg_content text, msg_type integer, msg_time integer, \
                      msg_status integer default 0, msg_substatus integer default 0, unread_count integer default 0,local_ext blob,remote_ext blob, push_content text,push_payload blob, setting blob)",NIMRecentTable];
    return @[sql];
}

- (void)upgradeVersion1
{
    NIMDatabaseUpgrader *upgrader = [NIMDatabaseUpgrader upgrader:_db
                                                        tablename:NIMRecentTable];
    [upgrader addColumn:@"local_ext"
                   type:@"blob"];
    
    [upgrader addColumn:@"remote_ext"
                   type:@"blob"];
    
    [upgrader addColumn:@"push_content"
                   type:@"text"];
    
    [upgrader addColumn:@"push_payload"
                   type:@"blob"];
    
    [upgrader addColumn:@"setting"
                   type:@"blob"];
}

- (NSString *)dbFilePath
{
    NSString * path = [[[NIMPathManager sharedManager] sdkCurrentUserDir] stringByAppendingPathComponent:@"recent.db"];
    return path;
}


#pragma mark - Public Operation
- (NSInteger)allUnreadCount
{
    return MAX(0, _allUnreadCount);
}

- (void)main_addRecentSession:(NIMRecentSession *)recentSession{
    NIMMTAssert();
    if (recentSession.session)
    {
        self.allUnreadCount         += recentSession.unreadCount;
        NIMRecentSession *oldRecent = [_sessions objectForKey:recentSession.session];
        recentSession.unreadCount   += oldRecent.unreadCount;
        [self.sessions setObject:recentSession
                          forKey:recentSession.session];
        [self asyncDBUpdateRecentSession:recentSession];
        
        if (!oldRecent){
            [[NIMDelegateCenter conversationDelegate] didAddRecentSession:recentSession
                                                         totalUnreadCount:self.allUnreadCount];
        }else{
            [[NIMDelegateCenter conversationDelegate] didUpdateRecentSession:recentSession
                                                            totalUnreadCount:self.allUnreadCount];
        }
        
    }
}


//当前会话未读清零
- (void)main_cleanRecentSession:(NIMSession *)session{
    NIMMTAssert();
    if (session) {
        NIMRecentSession * recent = [self.sessions objectForKey:session];
        if (!recent) {
            return;
        }
        self.allUnreadCount       -= recent.unreadCount;
        recent.unreadCount = 0;
        [self.sessions setObject:recent
                          forKey:session];
        
        [self asyncDBUpdateRecentSession:recent];
        [[NIMDelegateCenter conversationDelegate] didUpdateRecentSession:recent totalUnreadCount:self.allUnreadCount];
        
    }
}

//重置当前会话的最后一条消息，如果消息ID不匹配则忽略
- (void)main_updateRecentSession:(NIMMessage *)message{
    NIMMTAssert();
    NIMSession * session = message.session;
    NIMRecentSession * recent = [self.sessions objectForKey:session];
    if (recent.lastMessage.serialID != message.serialID) {
        return;
    }
    recent.lastMessage = message;
    if (recent.session)
    {
        [self.sessions setObject:recent
                          forKey:session];
        
        [self asyncDBUpdateRecentSession:recent];
        [[NIMDelegateCenter conversationDelegate] didUpdateRecentSession:recent
                                                        totalUnreadCount:self.allUnreadCount];
    }
}

//重置当前会话的最后一条消息
- (void)main_replaceRecentSession:(NIMMessage *)message{
    NIMMTAssert();
    NIMSession *session = message.session;
    NIMRecentSession *recent = [self.sessions objectForKey:session];
    recent.lastMessage  = message;
    if (recent.session)
    {
        [self.sessions setObject:recent
                          forKey:session];
        [self asyncDBUpdateRecentSession:recent];
        
        [[NIMDelegateCenter conversationDelegate] didUpdateRecentSession:recent
                                                        totalUnreadCount:self.allUnreadCount];
    }
}


- (void)main_removeRecentSession:(NIMRecentSession *)recent{
    NIMMTAssert();
    if (recent.session)
    {
        NIMRecentSession *oldRecent = [_sessions objectForKey:recent.session];
        self.allUnreadCount -= oldRecent.unreadCount;
        [self.sessions removeObjectForKey:recent.session];
        [[NIMDelegateCenter conversationDelegate] didRemoveRecentSession:recent
                                                        totalUnreadCount:self.allUnreadCount];
        nim_io_async(^{
            [self dbRemoveRecentSession:recent];
        });
    }
}


- (NSArray*)allRecentSessions{
    NSArray * allValues = [_sessions.allValues copy];
    return [allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NIMRecentSession * recent1 = obj1;
        NIMRecentSession * recent2 = obj2;
        return recent1.lastMessage.timestamp > recent2.lastMessage.timestamp ? NSOrderedAscending : NSOrderedDescending;
    }];
}

#pragma mark - DB Operation
- (void)asyncDBUpdateRecentSession:(NIMRecentSession *)session
{
    NIMRecentSession *recent = [session copy]; //UI线程切换到IO线程时先做一次copy,防止多线程读写造成问题
    nim_io_async(^{
        [self dbUpdateRecentSession:recent];
    });
}

- (void)dbUpdateRecentSession:(NIMRecentSession *)session
{
    NSString * sql = [NSString stringWithFormat:@"insert or replace into %@(session_id,session_type,msg_serial,server_id, msg_id,msg_from_id,msg_text,msg_content,msg_type,msg_time,msg_status,msg_substatus,unread_count,local_ext,remote_ext,push_content,push_payload,setting) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", NIMRecentTable];
    NIMMessage * message = session.lastMessage;
    NSString *attach = message.rawAttachContent ? : [(id <NIMMessageObject_Private>)message.messageObject encodeContent];
    BOOL res = [self.db executeUpdate:sql,
                message.session.sessionId,
                @(message.session.sessionType),
                @(message.serialID),
                message.serverID,
                message.messageId,
                message.from,
                message.text,
                attach,
                @(message.messageType),
                @(NIMTimeDoubleToLong(message.timestamp)),
                @(message.status),
                @(message.subStatus),
                @(session.unreadCount),
                [NIMProtocolUtil jsonData:message.localExt],
                [NIMProtocolUtil jsonData:message.remoteExt],
                message.apnsContent,
                [NIMProtocolUtil jsonData:message.apnsPayload],
                [message.setting toJsonData]];
    if (!res) {
        NIMLogErr(@"error: update %@ fail %@",session,self.db.lastError);
    }
}

- (void)dbRemoveRecentSession:(NIMRecentSession *)recentSession
{
    NSString * sql = [NSString stringWithFormat:@"delete from %@ where session_id = ? and session_type = ? ", NIMRecentTable];
    
    BOOL res = [self.db executeUpdate:sql,
                recentSession.session.sessionId,
                @(recentSession.session.sessionType)];
    if (!res) {
        NIMLogErr(@"error: remove %@ failed %@",recentSession,self.db.lastError);
    }
}


- (NSMutableDictionary*)dbAllRecentData{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    NSString * sql = [NSString stringWithFormat:@"select * from %@ ",NIMRecentTable];
    NIMResultSet * set = [self.db executeQuery:sql];
    while ([set next]) {
        NIMRecentSession * recent = [self recentWithResultSet:set];
        [dict setObject:recent forKey:recent.session];
    }
    [set close];
    return dict;
}


- (NIMRecentSession*)recentWithResultSet:(NIMResultSet*)set{
    NIMMessage * msg;
    NIMMessageStatus status = [set intForColumn:@"msg_status"];
    msg             = [[NIMMessage alloc] init];
    msg.timestamp   = NIMTimeLongToDouble([set longLongIntForColumn:@"msg_time"]);
    if (status != NIMMessageStatusDeleted) {
        msg.messageType    = [set intForColumn:@"msg_type"];
        msg.status         = status;
        msg.from           = [set stringForColumn:@"msg_from_id"];
        msg.messageId      = [set stringForColumn:@"msg_id"];
        msg.text           = [set stringForColumn:@"msg_text"];
        msg.subStatus      = [set intForColumn:@"msg_substatus"];
        msg.serialID       = [set intForColumn:@"msg_serial"];
        msg.serverID       = [set stringForColumn:@"server_id"];
        NSString * content = [set stringForColumn:@"msg_content"];
        
        id<NIMMessageObject_Private> obj = [NIMModelConverter messaegObjectWithType:msg.messageType
                                                                            content:content];
        msg.messageObject  = obj;
        msg.localExt       = [NIMProtocolUtil dictByJsonData:[set dataForColumn:@"local_ext"]];
        msg.remoteExt      = [NIMProtocolUtil dictByJsonData:[set dataForColumn:@"remote_ext"]];
        msg.apnsContent    = [set stringForColumn:@"push_content"];
        msg.apnsPayload    = [NIMProtocolUtil dictByJsonData:[set dataForColumn:@"push_payload"]];
        msg.setting        = [NIMMessageSetting settingByJsonData:[set dataForColumn:@"setting"]];
        
    }
    NSString * sessionId   = [set stringForColumn:@"session_id"];
    NSInteger  sessionType = [set intForColumn:@"session_type"];
    NIMSession * session   = [NIMSession session:sessionId type:sessionType];
    msg.session = session;
    
    NSInteger unreadCount  = [set intForColumn:@"unread_count"];
    NIMRecentSession * recent = [[NIMRecentSession alloc] init];
    recent.lastMessage = msg;
    recent.unreadCount = unreadCount;
    recent.session     = session;
    return recent;
}

- (void)dbDeleteAllRecentSessions{
    NSString * sql = [NSString stringWithFormat:@"delete from %@ ", NIMRecentTable];
    BOOL res = [self.db executeUpdate:sql];
    if (!res) {
        NIMLogErr(@"all all recent session failed %@",self.db.lastError);
    }
}


@end



@implementation NIMRecentSessionManager(MessageOperation)

- (void)deleteMessage:(NIMMessage *)message{
    //如果发现是最最近联系人列表的last Message，那么获取最后一条消息，然后替换掉，否则神马都不做
    nim_main_async_safe(^(void){
        NIMRecentSession * recentSession = [self.sessions objectForKey:message.session];
        if ([recentSession.lastMessage isEqual:message]) {
            NIMMessage * newLastMessage = [[[NIMConversationManager sharedManager] messagesInSession:message.session message:nil limit:1] firstObject];
            if (newLastMessage) {
                [self main_replaceRecentSession:newLastMessage];
            }else{
                //做一条空消息
                NIMMessage *msg = [self emptyReadMsg:recentSession];
                [self main_replaceRecentSession:msg];
            }
        }
    });
}

- (void)deleteAllmessagesInSession:(NIMSession*)session
               removeRecentSession:(BOOL)removeRecentSession
{
    nim_main_async_safe(^(void){
        NIMRecentSession * recentSession = [self.sessions objectForKey:session];
        if (removeRecentSession) {
            [self main_removeRecentSession:recentSession];
        }else{
            //做一条空消息
            NIMMessage *msg = [self emptyReadMsg:recentSession];
            recentSession.lastMessage = msg;
            [self main_cleanRecentSession:session];
        }
    });
}

- (void)deleteAllmessages:(BOOL)removeRecentSessions
{
    nim_main_async_safe(^{
        _allUnreadCount = 0;
        if (removeRecentSessions)
        {
            [self.sessions removeAllObjects];
            nim_io_async(^{
                [self dbDeleteAllRecentSessions];
            });
        }
        else
        {
            for (NIMRecentSession *recentSession in self.sessions.allValues)
            {
                NIMMessage *msg = [self emptyReadMsg:recentSession];
                recentSession.lastMessage = msg;
                self.allUnreadCount       -= recentSession.unreadCount;
                recentSession.unreadCount = 0;
                [self asyncDBUpdateRecentSession:recentSession];
            }
        }
    });
}


- (NIMMessage *)emptyReadMsg:(NIMRecentSession *)recentSession{
    NIMMessage *msg = [[NIMMessage alloc] init];
    msg.timestamp   = recentSession.lastMessage.timestamp;
    msg.session     = recentSession.lastMessage.session;
    msg.text        = @"";
    msg.status      = NIMMessageStatusRead;
    return msg;
}

@end
