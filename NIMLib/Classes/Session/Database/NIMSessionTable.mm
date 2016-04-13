//
//  NIMConversationTable.m
//  NIMLib
//
//  Created by chris on 15/1/22.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMSessionTable.h"
#import "NIMSessionDB.h"
#import "NIMMessage_Private.h"
#import "NIMDatabase.h"
#import "NIMMessageObjectProtocol_Private.h"
#import "NIMModelConverter.h"
#import "NSString+NIM.h"
#import "NIMMessageSearchOption_Private.h"
#import "NIMDatabaseUpgrader.h"
#import "NIMUtil.h"
#import "NIMDatabaseModel.h"
#import "NIMProtocolUtil.h"
#import "NIMMessageSetting_Private.h"
#import "NIMSDK_Private.h"
#import "NIMReplacableMessageValidator.h"

@interface NIMSessionTable()

@property (nonatomic,weak)   NIMDatabase * db;

@property (nonatomic,strong) NSString * tableName;

@end

@implementation NIMSessionTable

- (instancetype)initWithDb:(NIMDatabase*)db session:(NIMSession *)session{
    self = [super init];
    if (self) {
        _db = db;
        _tableName = [NSString stringWithFormat:@"msg_%@_%zd",[session.sessionId nim_md5],session.sessionType];
        [self createTable];
        
        if (session.sessionType == NIMSessionTypeChatroom)
        {
            NIMLogErr(@"\n\n\n\n\ninvalid session table for %@\n\n\n\n\n",session);
        }
    }
    return self;
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
                      create table if not exists %@(serial integer primary key, \
                      server_id text , msg_id text, msg_from_id text,\
                      msg_text text, msg_content text, msg_type integer, msg_time integer, \
                      msg_status integer default 0, msg_substatus integer default 0,local_ext blob,remote_ext blob, \
                      push_content text,push_payload blob,setting blob)",self.tableName];
    //索引
    NSString *msgStatusIndex = [NSString stringWithFormat:@"create index if not exists %@_statusindex on %@(msg_status)",self.tableName,self.tableName];
    NSString *msgIdIndex = [NSString stringWithFormat:@"create index if not exists %@_msgidindex ON %@(msg_id)",self.tableName,self.tableName];
    NSString *msgTimeStatusIndex =  [NSString stringWithFormat:@"create index if not exists %@_timestatusindex ON %@(msg_time,msg_status)",self.tableName,self.tableName];
    return @[sql,msgStatusIndex,msgIdIndex,msgTimeStatusIndex];
}

- (void)upgradeVersion1
{
    NIMDatabaseUpgrader *upgrader = [NIMDatabaseUpgrader upgrader:_db
                                                        tablename:_tableName];
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

@end

@implementation NIMSessionTable(Private)

- (BOOL)saveMessage:(NIMMessage*)message
{
    if ([[NIMReplacableMessageValidator validator:message] isValid])
    {
        return [self insertOrReplaceMessage:message];
    }
    else
    {
        return [self insertMessage:message];
    }
}

- (BOOL)updateMessage:(NIMMessage *)message
    includeAttachment:(BOOL)attachment
{
    BOOL res = NO;
    if (attachment)
    {
        NSString * sql = [NSString stringWithFormat:@"update %@ set server_id = ?, msg_id = ?, msg_from_id = ?, msg_text = ?, msg_content = ?, msg_type = ?, msg_time = ?, msg_status = ? , msg_substatus = ?, local_ext = ?, remote_ext = ? ,push_content = ? , push_payload = ?, setting = ? where serial = ?", self.tableName];
        res = [self.db executeUpdate:sql,
               message.serverID,
               message.messageId,
               message.from,
               message.text,
               [(id <NIMMessageObject_Private>)message.messageObject encodeContent],
               @(message.messageType),
               @(NIMTimeDoubleToLong(message.timestamp)),
               @(message.status),
               @(message.subStatus),
               [NIMProtocolUtil jsonData:message.localExt],
               [NIMProtocolUtil jsonData:message.remoteExt],
               message.apnsContent,
               [NIMProtocolUtil jsonData:message.apnsPayload],
               [message.setting toJsonData],
               message.serialID ? @(message.serialID) : nil];
    }
    else
    {
        NSString * sql = [NSString stringWithFormat:@"update %@ set server_id = ?, msg_id = ?, msg_from_id = ?, msg_text = ?, msg_type = ?, msg_time = ?, msg_status = ? , msg_substatus = ?, local_ext = ?, remote_ext = ? ,push_content = ? , push_payload = ? , setting = ? where serial = ?", self.tableName];
        res = [self.db executeUpdate:sql,
               message.serverID,
               message.messageId,
               message.from,
               message.text,
               @(message.messageType),
               @(NIMTimeDoubleToLong(message.timestamp)),
               @(message.status),
               @(message.subStatus),
               [NIMProtocolUtil jsonData:message.localExt],
               [NIMProtocolUtil jsonData:message.remoteExt],
               message.apnsContent,
               [NIMProtocolUtil jsonData:message.apnsPayload],
               [message.setting toJsonData],
               message.serialID ? @(message.serialID) : nil];
    }
    
    
    if (!res) {
        NIMLogErr(@"error: update %@ to %@ failed %@",message,self.tableName,self.db.lastError);
    }
    return res;
}


- (BOOL)updateMessageInfo:(NIMMessageUpdateInfo *)info
{
    BOOL res = NO;
    if (info.customObject)
    {
        NSString * sql = [NSString stringWithFormat:@"update %@ set  msg_content = ?, local_ext = ?  where serial = ?", self.tableName];
        res = [self.db executeUpdate:sql,
               [(id <NIMMessageObject_Private>)info.customObject encodeContent],
               info.localExt,
               info.serialID ? @(info.serialID) : nil];
    }
    else
    {
        NSString * sql = [NSString stringWithFormat:@"update %@ set local_ext = ? where serial = ?", self.tableName];
        res = [self.db executeUpdate:sql,
               info.localExt,
               info.serialID ? @(info.serialID) : nil];
    }

    if (!res) {
        NIMLogErr(@"error: update %lld to %@ failed %@",info.serialID,self.tableName,self.db.lastError);
    }
    return res;
}


- (void)deleteMessage:(NIMMessage*)message{
    NSString * sql = [NSString stringWithFormat:@"update %@ set msg_status = ? where serial = ?",self.tableName];
    BOOL res = [self.db executeUpdate:sql,
           @(NIMMessageStatusDeleted),
           @(message.serialID)];
    if (!res) {
        NIMLogErr(@"error: del %@ from %@ failed",message,self.tableName);
    }
}

- (NSArray*)fetchMessagesWithLimit:(NSInteger)limit lastMessage:(NIMMessage*)lastMessage{
    
    NSString *sql;
    if (lastMessage) {
        int64_t timetag = NIMTimeDoubleToLong(lastMessage.timestamp);
        sql = [NSString stringWithFormat:@"select * from %@  where msg_time < %lld and msg_status != %zd ",self.tableName,timetag,NIMMessageStatusDeleted];
    }else{
        sql = [NSString stringWithFormat:@"select * from %@  where msg_status != %zd ",self.tableName,NIMMessageStatusDeleted];
    }
    BOOL needLimit = limit > 0;
    if (needLimit) {
        sql = [sql stringByAppendingFormat:@"order by msg_time desc limit %zd",limit];
    }else{
        sql = [sql stringByAppendingFormat:@"order by msg_time desc "];
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NIMResultSet * set = [self.db executeQuery:sql];
    while ([set next]) {
        NIMMessage * msg = [self messageWithResultSet:set];
        [array addObject:msg];
    }
    [set close];
    //倒序输出
    return [array reverseObjectEnumerator].allObjects;
}

- (NSArray *)fetchMessagesByIds:(NSArray *)messageIds{
    NSString *ids = @"";
    for (NSString *messageId in messageIds) {
        ids = [ids stringByAppendingFormat:@"'%@'",messageId];
        if (![messageId isEqualToString:messageIds.lastObject]) {
            ids = [ids stringByAppendingString:@","];
        }
    }
    NSString *sql = [NSString stringWithFormat:@"select * from %@  where msg_id in (%@) order by msg_time ",self.tableName,ids];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NIMResultSet * set = [self.db executeQuery:sql];
    while ([set next]) {
        NIMMessage * msg = [self messageWithResultSet:set];
        [array addObject:msg];
    }
    [set close];
    return array;
}


- (void)deleteAllMessageStatus{
    NSString * sql = [NSString stringWithFormat:@"update %@ set msg_status = ? where msg_status < ? or msg_status > ?",self.tableName];
    BOOL res = [self.db executeUpdate:sql,@(NIMMessageStatusDeleted),@(NIMMessageStatusDeleted),@(NIMMessageStatusDeleted)];
    if (!res) {
         NIMLogErr(@"error: set all messages delete status in  %@ failed",self.tableName);
    }
}

- (void)readAllMessageStatus{
    NSString * sql = [NSString stringWithFormat:@"update %@ set msg_status = ? where msg_status = ?",self.tableName];
    BOOL res = [self.db executeUpdate:sql,@(NIMMessageStatusRead),@(NIMMessageStatusNone)];
    if (!res) {
        NIMLogErr(@"error: set all messages read status in  %@ failed",self.tableName);
    }
}

- (BOOL)isMessageReceived:(NSString *)messageId
{
    NSString *sql = [NSString stringWithFormat:@"select msg_id from %@ where msg_id = ?",self.tableName];
    NIMResultSet *set = [self.db executeQuery:sql,messageId];
    BOOL isReceived = [set next];
    [set close];
    return isReceived;
}


- (NSArray *)searchMessages:(NIMMessageSearchOption *)option
{

    NSMutableArray *messages = [NSMutableArray array];
    //构造筛选条件
    NIMMessageSearchOrder order = option.order;
    int64_t start = NIMTimeDoubleToLong(option.startTime);
    int64_t end = option.endTime == 0 ? LONG_LONG_MAX : NIMTimeDoubleToLong(option.endTime);
    
    
    
    NSString *selectCondition = [NSString stringWithFormat:@"msg_time > %lld and msg_time < %lld and msg_status != %d \
                                 order by msg_time %@ ",start,end,NIMMessageStatusDeleted,
                                 order == NIMMessageSearchOrderDesc ? @"desc" : @"" ];

    
    //构造查询条件
    NSMutableString *searchCondition = [[NSMutableString alloc] init];
    
    //消息类型
    NIMMessageType messageType = option.messageType;
    [searchCondition appendFormat:@"msg_type = %zd ",messageType];
    
    NSMutableArray *conditions = [NSMutableArray array];
    //匹配文本内容
    if (messageType == NIMMessageTypeText && option.searchContent.length) {
        NSString *textCondition = [NSString stringWithFormat:@"msg_text like '%%%@%%' ",option.searchContent];
        [conditions addObject:textCondition];
    }
    
    //匹配消息发起者
    if ([option.fromIds count]) {
        NSString *fromIdCondition = [NSString stringWithFormat:@"msg_from_id in ('%@') ",[option.fromIds componentsJoinedByString:@"','"]];
        [conditions addObject:fromIdCondition];
    }

    if ([conditions count]) {
        [searchCondition appendFormat:@"and ( %@ ) ",[conditions componentsJoinedByString:@" or "]];
    }
    
    
    //添加limit
    if (option.limit) {
        [searchCondition appendFormat:@"limit %@ ",@(option.limit)];
    }
    
    
    
    //构造sql语句
    NSString *sql = [NSString stringWithFormat:@"select * from (select * from %@ where %@) where %@",self.tableName,selectCondition,searchCondition];
    
    
    NIMLogApp(@"begin search %@",sql);
    NIMResultSet *set = [self.db executeQuery:sql];
    while ([set next]) {
        @autoreleasepool {
            NIMMessage * msg = [self messageWithResultSet:set];
            if (order == NIMMessageSearchOrderDesc) {
                [messages insertObject:msg
                               atIndex:0];
            }
            else
            {
                [messages addObject:msg];
            }
        }
    }
    [set close];
    NIMLogApp(@"end search %@",sql);
    return messages;

}

+ (void)earseAllTables:(NIMDatabase *)db
{
    NSMutableArray *tables = [NSMutableArray array];
    NSString *sql = @"select name from sqlite_master where type='table' and name like 'msg%'";
    NIMResultSet *set = [db executeQuery:sql];
    while ([set next])
    {
        NSString *name = [set stringForColumn:@"name"];
        if (name) {
            [tables addObject:name];
        }
    }
    [set close];
    for (NSString *tableName in tables)
    {
        NSString * sql = [NSString stringWithFormat:@"update %@ set msg_status = ? where msg_status < ? or msg_status > ?",tableName];
        BOOL res = [db executeUpdate:sql,@(NIMMessageStatusDeleted),@(NIMMessageStatusDeleted),@(NIMMessageStatusDeleted)];
        if (!res) {
            NIMLogErr(@"error: set all messages delete status in  %@ failed",tableName);
        }
    }
}

#pragma mark - set => message
- (NIMMessage*)messageWithResultSet:(NIMResultSet*)set{
    NIMMessage * msg = [[NIMMessage alloc] init];
    msg.messageType  = [set intForColumn:@"msg_type"];
    msg.from         = [set stringForColumn:@"msg_from_id"];
    msg.messageId    = [set stringForColumn:@"msg_id"];
    msg.text         = [set stringForColumn:@"msg_text"];
    msg.status       = [set intForColumn:@"msg_status"];
    msg.subStatus    = [set intForColumn:@"msg_substatus"];
    msg.timestamp    = NIMTimeLongToDouble([set longLongIntForColumn:@"msg_time"]);
    msg.serialID     = [set longLongIntForColumn:@"serial"];
    msg.serverID     = [set stringForColumn:@"server_id"];
    
    NSString * content      = [set stringForColumn:@"msg_content"];
    id<NIMMessageObject_Private> obj = [NIMModelConverter messaegObjectWithType:msg.messageType
                                                                        content:content];
    msg.messageObject = obj;
    
    msg.localExt    = [NIMProtocolUtil dictByJsonData:[set dataForColumn:@"local_ext"]];
    msg.remoteExt   = [NIMProtocolUtil dictByJsonData:[set dataForColumn:@"remote_ext"]];
    msg.apnsContent = [set stringForColumn:@"push_content"];
    msg.apnsPayload = [NIMProtocolUtil dictByJsonData:[set dataForColumn:@"push_payload"]];
    msg.setting     = [NIMMessageSetting settingByJsonData:[set dataForColumn:@"setting"]];
    
    return msg;
}

#pragma mark - 写操作
- (BOOL)insertMessage:(NIMMessage *)message
{
    BOOL result = NO;
    NSString * sql = [NSString stringWithFormat:@"insert into %@(server_id,msg_id,msg_from_id,msg_text,msg_content,msg_type,msg_time,msg_status,msg_substatus,local_ext,remote_ext,push_content,push_payload,setting) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)", self.tableName];
    NSString *attach = message.rawAttachContent ? : [(id <NIMMessageObject_Private>)message.messageObject encodeContent];
    BOOL res = [self.db executeUpdate:sql,
                message.serverID,
                message.messageId,
                message.from,
                message.text,
                attach,
                @(message.messageType),
                @(NIMTimeDoubleToLong(message.timestamp)),
                @(message.status),
                @(message.subStatus),
                [NIMProtocolUtil jsonData:message.localExt],
                [NIMProtocolUtil jsonData:message.remoteExt],
                message.apnsContent,
                [NIMProtocolUtil jsonData:message.apnsPayload],
                [message.setting toJsonData]];
    if (!res) {
        NIMLogErr(@"error: save message %@ to %@ failed %@",message,self.tableName,self.db.lastError);
    }else{
        message.serialID = self.db.lastInsertRowId;
        result = YES;
    }
    return result;
}

- (BOOL)insertOrReplaceMessage:(NIMMessage *)message
{
    BOOL result = NO;
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where msg_id = ?",self.tableName];
    NIMResultSet *set = [self.db executeQuery:sql,message.messageId];
    //如果本地有对应的数据,只做替换,并返回NO:只替换不通知
    if ([set next])
    {
        message.serialID     = [set longLongIntForColumn:@"serial"];
        message.status       = [set intForColumn:@"msg_status"];
        message.subStatus    = [set intForColumn:@"msg_substatus"];
        
        
        NIMLogApp(@"message duplicated %@ serial %lld",message.messageId,message.serialID);
        [self updateMessage:message
          includeAttachment:YES];
    }
    else
    {
        result =  [self insertMessage:message];
    }
    [set close];
    return result;

}
@end
