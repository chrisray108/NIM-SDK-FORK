//
//  NIMNetCallRecordManager.m
//  NIMLib
//
//  Created by amao on 3/25/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMNetCallRecordManager.h"
#import "NIMNetCallRecord_Private.h"
#import "NIMDispatch.h"
#import "NIMDatabase.h"
#import "NIMPathManager.h"

@interface NIMNetCallRecordManager ()
@property(nonatomic, strong) NIMDatabase *db;
@end

@implementation NIMNetCallRecordManager

- (instancetype)init
{
    if (self = [super init])
    {
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



- (void)openDatabase
{
    NSString *filepath = [[[NIMPathManager sharedManager] sdkCurrentUserDir] stringByAppendingPathComponent:@"netcall.db"];
    NIMDatabase *db = [NIMDatabase databaseWithPath:filepath];
    if ([db open])
    {
        _db = db;
        NSArray *sqls = @[@"create table if not exists netcall(serial integer primary key,netcall_id text unique,\
                          type integer,from_id text,ids text,duration integer,timetag integer,status integer)",
                          @"create index if not exists statusindex on netcall(status)",
                          @"create index if not exists typeindex on netcall(type)",
                          @"create index if not exists timetagindex on netcall(timetag)"];
        for (NSString *sql in sqls)
        {
            if (![_db executeUpdate:sql])
            {
                NIMLogErr(@"error: execute sql %@ failed error %@",sql,_db.lastError);
            }
        }
    }
    else
    {
        NIMLogErr(@"error open database failed %@",filepath);
    }
}

- (BOOL)saveCallRecord:(NIMNetCallRecord *)record{
    __block BOOL result = NO;
    nim_io_sync_safe(^{
        if (record)
        {
            NSData * data = [NSJSONSerialization dataWithJSONObject:record.members options:0 error:nil];
            NSString *ids = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"[]";
            NSString *sql = @"insert or replace into netcall(netcall_id,type,from_id,ids,duration,timetag,status)  \
            values(?,?,?,?,?,?,?)";
            if (![self.db executeUpdate:sql,
                  record.recordId,
                  @(record.recordType),
                  record.from,
                  ids,
                  @(NIMTimeDoubleToLong(record.duration)),
                  @(NIMTimeDoubleToLong(record.timestamp)),
                  @(record.status)]
                )
            {
                NIMLogErr(@"update failed %@ error %@",record,self.db.lastError);
            }
            else
            {
                record.serial = (NSInteger)[self.db lastInsertRowId];
                result = YES;
            }
        }
    });
    return result;
}

@end
