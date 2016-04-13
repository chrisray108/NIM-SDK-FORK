//
//  NIMDatabaseUpgrader.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMDatabaseUpgrader.h"
#import "NIMDatabase.h"

@interface NIMDatabaseUpgrader ()
@property (nonatomic,strong)    NIMDatabase *db;
@property (nonatomic,copy)      NSString *tablename;
@property (nonatomic,strong)    NSMutableArray *columns;
@end

@implementation NIMDatabaseUpgrader
+ (instancetype)upgrader:(NIMDatabase *)database
               tablename:(NSString *)tablename
{
    NIMDatabaseUpgrader *instance = [[NIMDatabaseUpgrader alloc] init];
    instance.db = database;
    instance.tablename = tablename;
    [instance queryTableInfos];
    return instance;
}

- (void)queryTableInfos
{
    NSMutableArray *columns = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"pragma table_info(%@)",_tablename];
    NIMResultSet *rs = [_db executeQuery:sql];
    while ([rs next])
    {
        NSString *name = [rs stringForColumn:@"name"];
        if (name)
        {
            [columns addObject:name];
        }
    }
    [rs close];
    _columns = columns;
}

- (BOOL)columnExists:(NSString *)name
{
    for (NSString *column in _columns)
    {
        if ([name isEqualToString:column])
        {
            return YES;
        }
    }
    return NO;
}

- (void)addColumn:(NSString *)name
             type:(NSString *)type
{
    if (![self columnExists:name])
    {
        [self dbAddColumn:name
                     type:type];
    }
}

- (void)dbAddColumn:(NSString *)name
               type:(NSString *)type
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add column %@ %@",_tablename,name,type];
    if ([_db executeUpdate:sql])
    {
        [_columns addObject:name];
    }
    else
    {
        NIMLogApp(@"add column %@ for table %@ failed",name,_tablename);
    }
}
@end
