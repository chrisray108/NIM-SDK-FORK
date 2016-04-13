//
//  NIMSystemNotificationManager.m
//  NIMLib
//
//  Created by amao on 3/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSystemNotificationManager.h"
#import "session_protocol.h"
#import "NIMGlobalDefs.h"
#import "NIMDispatch.h"
#import "NIMDatabase.h"
#import "NIMPathManager.h"
#import "NIMSystemNotification_Priviate.h"
#import "NIMCustomSystemNotification_Private.h"
#import "session_protocol.h"
#import "NIMDispatch.h"
#import "NIMSystemNotificationReceiver.h"
#import "NIMCoreCenter.h"
#import "NIMUtil.h"
#import "NIMSession_Private.h"
#import "NIMDelegateCenter.h"
#import "NIMSessionValidator.h"
#import "NIMProtocolUtil.h"
#import "NIMCustomSystemNotificationSetting_Private.h"
#import "NIMUserInfoManager.h"

@interface NIMSystemNotificationManager ()
@property (nonatomic,assign)    NSInteger totalUnreadCount;
@property (nonatomic,strong)    NIMDatabase *db;
@property (nonatomic,strong)    NSMutableDictionary *customNotifications;
@end

@implementation NIMSystemNotificationManager
- (instancetype)init
{
    if (self = [super init])
    {
        _customNotifications = [NSMutableDictionary dictionary];
        [self openDatabase];
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

#pragma mark - Public API
- (NSArray *)fetchSystemNotifications:(NIMSystemNotification *)notification
                                limit:(NSInteger)limit
                               filter:(NIMSystemNotificationFilter *)filter
{
    __block NSArray *result = nil;
    
    NSString *sql = nil;
    NSString *timeCondition = @" order by timetag desc limit ?";
    NSString *filterCondition = [self filterCondition:filter];
    if (notification)
    {
        sql = [NSString stringWithFormat:@"select * from notifications where timetag < %lld and status != ?",
               NIMTimeDoubleToLong(notification.timestamp)] ;
    }
    else
    {
        sql = @"select * from notifications where status != ?";
    }
    if (filterCondition)
    {
        sql = [sql stringByAppendingFormat:@" and %@",filterCondition];
    }
    sql = [sql stringByAppendingString:timeCondition];
    
    
    nim_io_sync_safe(^{
        NSMutableArray *array = [NSMutableArray array];
        NIMResultSet *rs = [self.db executeQuery:sql,@(NIMNotificationStatusDeleted),@(limit)];
        while ([rs next])
        {
            NIMSystemNotification *notification = [[NIMSystemNotification alloc] init];
            notification.serial         = (NSInteger)[rs intForColumn:@"serial"];
            notification.type           = (NSInteger)[rs intForColumn:@"type"];
            notification.timestamp      = NIMTimeLongToDouble([rs longLongIntForColumn:@"timetag"]);
            notification.sourceID       = [rs stringForColumn:@"source"];
            notification.targetID       = [rs stringForColumn:@"target"];
            notification.attachString   = [rs stringForColumn:@"attach"];
            notification.postscript     = [rs stringForColumn:@"postscript"];
            notification.status         = (NSInteger)[rs intForColumn:@"status"];
            notification.handleStatus   = (NSInteger)[rs intForColumn:@"substatus"];
            notification.msgId          = [rs longLongIntForColumn:@"msg_id"];
            
            [array addObject:notification];
        }
        [rs close];
        result = array;
    });
    
    return result;
}

- (NSInteger)allUnreadCount:(NIMSystemNotificationFilter *)filter
{
    __block NSInteger count = 0;
    nim_io_sync_safe(^{
        NSString *condition = [self filterCondition:filter];
        if (condition)
        {
            NSString *sql = [NSString stringWithFormat:@"select count(serial) from notifications where status = ? and %@",condition];
            NIMResultSet *rs = [_db executeQuery:sql,@(NIMNotificationStatusNone)];
            if ([rs next])
            {
                count = (NSInteger)[rs intForColumnIndex:0];
            }
            [rs close];
        }
        else
        {
            count = _totalUnreadCount;
        }
    });
    return count;
}

- (void)deleteNotification:(NIMSystemNotification *)notification
{
    NSString *sql = @"update notifications set status  = ? where serial = ?";
    nim_io_async(^{
        if (![self.db executeUpdate:sql,@(NIMNotificationStatusDeleted),@(notification.serial)])
        {
            NIMLogErr(@"update failed %@ error %@",notification,self.db.lastError);
        }
        [self queryUnreadCount];
    });
}

- (void)deleteAllNotifications:(NIMSystemNotificationFilter *)filter
{
    NSString *sql = @"update notifications set status  = ? where (status < ? or status > ?)";
    NSString *filterCondition = [self filterCondition:filter];
    if (filterCondition)
    {
        sql = [sql stringByAppendingFormat:@" and %@",filterCondition];
    }
    nim_io_async(^{
        if (![self.db executeUpdate:sql,@(NIMNotificationStatusDeleted),@(NIMNotificationStatusDeleted),@(NIMNotificationStatusDeleted)])
        {
            NIMLogErr(@"delete notifications failed");
        }
        [self queryUnreadCount];
    });
}

- (void)markNotificationsAsRead:(NIMSystemNotification *)notification
{
    if (notification.status == NIMNotificationStatusNone)
    {
        notification.status = NIMNotificationStatusRead;
    }
    NSString *sql = @"update notifications set status  = ? where serial = ? and status = ?";
    nim_io_async(^{
        if (![self.db executeUpdate:sql,@(NIMNotificationStatusRead),@(notification.serial),@(NIMNotificationStatusNone)])
        {
            NIMLogErr(@"update failed %@",notification);
        }
        [self queryUnreadCount];
    });

}

- (void)markAllNotificationsAsRead:(NIMSystemNotificationFilter *)filter
{
    NSString *sql = @"update notifications set status  = ? where status = ?";
    NSString *filterCondition = [self filterCondition:filter];
    if (filterCondition)
    {
        sql = [sql stringByAppendingFormat:@" and %@ ",filterCondition];
    }
    nim_io_async(^{
        if (![self.db executeUpdate:sql,@(NIMNotificationStatusRead),@(NIMNotificationStatusNone)])
        {
            NIMLogErr(@"mark notifications read failed");
        }
        [self queryUnreadCount];
    });
}

- (void)sendCustomNotification:(NIMCustomSystemNotification *)notification
                     toSession:(NIMSession *)session
                    completion:(NIMSystemNotificationHandler)completion
{
    if (![[NIMSessionValidator validator:session] isValid] ||
        ![notification isKindOfClass:[NIMCustomSystemNotification class]])
    {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    notification.sender         = [[NIMCoreCenter sharedCenter] currentUserID];
    notification.receiver       = session.sessionId;
    notification.receiverType   = session.sessionType;
    
    NSString *messageId = [NIMUtil uuid];
    if (completion)
    {
        [_customNotifications setObject:[completion copy]
                                 forKey:messageId];
        
    }
    [self sendCustomNotification:notification
                   withMessageId:messageId];
}



#pragma mark - 更新系统消息状态
- (void)updateNotificationStatus:(NIMSystemNotification *)notification
{
    NSString *sql = @"update notifications set status  = ? where serial = ?";
    nim_io_async(^{
        if (![self.db executeUpdate:sql,@(notification.status),@(notification.serial)])
        {
            NIMLogErr(@"update failed %@",notification);
        }
        [self queryUnreadCount];
    });


}

- (void)updateNotificationSubStatus:(NIMSystemNotification *)notification
{
    NSString *sql = @"update notifications set substatus  = ? where serial = ?";
    nim_io_async(^{
        if (![self.db executeUpdate:sql,@(notification.handleStatus),@(notification.serial)])
        {
            NIMLogErr(@"update failed %@",notification);
        }
    });

}

#pragma mark - misc
- (void)openDatabase
{
    NSString *filepath = [[[NIMPathManager sharedManager] sdkCurrentUserDir] stringByAppendingPathComponent:@"notification.db"];
    NIMDatabase *db = [NIMDatabase databaseWithPath:filepath];
    if ([db open])
    {
        _db = db;
        NSArray *sqls = @[@"create table if not exists notifications(serial integer primary key, \
                          type integer,timetag integer,source text,target text,postscript text,attach text,status integer,\
                          substatus integer, msg_id integer unique)",
                          //移除旧的index
                         @"drop index if exists statusindex",
                          //添加新的index
                         @"create index if not exists statustypeindex on notifications(status,type)",
                         @"create index if not exists timetagindex on notifications(timetag)"];
        for (NSString *sql in sqls)
        {
            if (![_db executeUpdate:sql])
            {
                NIMLogErr(@"error: execute sql %@ failed error %@",sql,_db.lastError);
            }
        }
        [self queryUnreadCount];
    }
    else
    {
        NIMLogErr(@"error open database failed %@",filepath);
    }
}

- (void)queryUnreadCount
{
    NSInteger count = 0;
    NSString *sql = @"select count(serial) from notifications where status = ?";
    NIMResultSet *rs = [_db executeQuery:sql,@(NIMNotificationStatusNone)];
    if ([rs next])
    {
         count = (NSInteger)[rs intForColumnIndex:0];
    }
    [rs close];

    if (count != _totalUnreadCount)
    {
        _totalUnreadCount = count;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NIMDelegateCenter notificationDelegate] onSystemNotificationCountChanged:count];
        });
    }
}

- (BOOL)saveNotification:(NIMSystemNotification *)notification
{
    __block BOOL result = NO;
    nim_io_sync_safe(^{
        if (notification)
        {
            NSString *sql = @"insert into notifications(type,timetag,source,target,postscript,attach,status,substatus,msg_id)  \
            values(?,?,?,?,?,?,?,?,?)";
            if (![self.db executeUpdate:sql,
                @(notification.type),
                 @(NIMTimeDoubleToLong(notification.timestamp)),
                 notification.sourceID,
                 notification.targetID,
                 notification.postscript,
                 notification.attachString,
                 @(NIMNotificationStatusNone),
                 @(0),
                 @(notification.msgId)])
            {
                NIMLogErr(@"update failed %@ error %@",notification,self.db.lastError);
            }
            else
            {
                notification.serial = (NSInteger)[self.db lastInsertRowId];
                result = YES;
            }
        }
    });
    return result;
}


- (void)onReceiveSystemNotification:(NIMSystemNotification *)notification{
    [[NIMUserInfoManager sharedManager] checkSystemNotification:notification];
    [[NIMDelegateCenter notificationDelegate]  onReceiveSystemNotification:notification];
}

- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification{
    
    [[NIMUserInfoManager sharedManager] checkCustomSystemNotification:notification];
    [[NIMDelegateCenter notificationDelegate]  onReceiveCustomSystemNotification:notification];
}

#pragma mark - types
- (NSString *)filterCondition:(NIMSystemNotificationFilter *)filter
{
    NSString *condition = nil;
    if ([filter isKindOfClass:[NIMSystemNotificationFilter class]])
    {
        NSMutableArray *types = [NSMutableArray array];
        if ([filter.notificationTypes isKindOfClass:[NSArray class]])
        {
            for (id type in filter.notificationTypes)
            {
                if ([type isKindOfClass:[NSString class]])
                {
                    [types addObject:type];
                }
                else if([type isKindOfClass:[NSNumber class]])
                {
                    [types addObject:[type stringValue]];
                }
            }
        }
        
        NSInteger count = [types count];
        if (count == 1)
        {
            condition = [NSString stringWithFormat:@" type = %@ ",[types firstObject]];
        }
        else if(count > 1)
        {
            NSString *inValue = [NSString stringWithFormat:@" (%@) ",[types componentsJoinedByString:@","]];
            condition = [NSString stringWithFormat:@" type in %@ ",inValue];
        }
    }
    return condition;

}


#pragma mark - 自定义系统通知
- (void)sendCustomNotification:(NIMCustomSystemNotification *)notification
                 withMessageId:(NSString *)messageId
{
    nimbiz::ISessionService *service = (nimbiz::ISessionService *)GetServiceFromCore(nimbiz::SVID_NIM_SESSION);
    if (service)
    {
        nimbiz::Property msg;
        msg.put_uint32(nimbiz::NIMSystemMsgTagType, (uint32_t)[self notificationType:notification.receiverType]);
        msg.put_string(nimbiz::NIMSystemMsgTagToAccount, UTF8(notification.receiver));
        msg.put_string(nimbiz::NIMSystemMsgTagFromAccount, UTF8(notification.sender));
        msg.put_string(nimbiz::NIMSystemMsgTagAttach, UTF8(notification.content));
        msg.put_uint32(nimbiz::NIMSystemMsgTagSaveFlag, notification.sendToOnlineUsersOnly ? 0 : 1);
        
        if ([notification.apnsContent length]) {
            msg.put_string(nimbiz::NIMSystemMsgTagApnsText, UTF8(notification.apnsContent));
        }
        nimbiz::UTF8String payload = [NIMProtocolUtil stringByJsonDictionary:notification.apnsPayload];
        if (!payload.empty()) {
            msg.put_string(nimbiz::NIMSystemMsgTagApnsPayload, payload);
        }
        if (notification.setting) {
            nimbiz::Property settingProperty = notification.setting.settingProperty;
            msg.update(settingProperty.props);
        }
        
        service->Invoke_SendCustomNotification(msg, UTF8(messageId));
    }
}

- (NIMCustomSystemNotificationType)notificationType:(NIMSessionType)sessionType
{
    NIMCustomSystemNotificationType type = NIMCustomSystemNotificationTypeP2P;
    switch (sessionType) {
        case NIMSessionTypeP2P:
            type = NIMCustomSystemNotificationTypeP2P;
            break;
        case NIMSessionTypeTeam:
            type = NIMCustomSystemNotificationTypeTeam;
            break;
        default:
            NSAssert(0, @"invalid type");
            NIMLogErr(@"invalid session type %zd to notification type",sessionType);
            break;
    }
    return type;
}


- (void)onSendCustomNotificationAck:(NSString *)messageId
                               code:(NSInteger)code
{
    NIMSystemNotificationHandler handler = [_customNotifications objectForKey:messageId];
    if (handler)
    {
        [_customNotifications removeObjectForKey:messageId];
        handler(NIMRemoteError(code));
        
    }
}


@end


#pragma mark - Callback
namespace nimbiz
{
void    CallbackRecvSysMsgs(struct IAsynCallbackParam *msgParam)
{
    @autoreleasepool
    {
        CBRecvSysMsgsParam *param = (CBRecvSysMsgsParam *)msgParam;
        NIMSystemNotificationReceiver *receiver = [[NIMSystemNotificationReceiver alloc] init];
        receiver.onlineNotification = param->online_msg_;
        [receiver receiveNotifications:param->msgs_];
    }
}


void    CallbackSendCustomNotification(struct IAsynCallbackParam *msgParam)
{
    @autoreleasepool
    {
        CBSendCustomNotificationParam *param = (CBSendCustomNotificationParam *)msgParam;
        NSString *messageId = NSUTF8(param->client_id_);
        NSInteger code = (NSInteger)param->code_;
        nim_main_async_safe(^{
            [[NIMSystemNotificationManager sharedManager] onSendCustomNotificationAck:messageId
                                                                                 code:code];
        });
    }
}
    
}




