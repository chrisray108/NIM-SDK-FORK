//
//  NIMKeyValueStore.m
//  YixinCall
//
//  Created by amao on 10/11/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import "NIMKeyValueStore.h"
#import "NIMDatabase.h"

static const void * const NIMGetShareKeyValueQueueSpecificKey = &NIMGetShareKeyValueQueueSpecificKey;
dispatch_queue_t NIMGetShareKeyValueQueue()
{
    static dispatch_queue_t sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = dispatch_queue_create("com.netease.nim.kv.queue", 0);
        dispatch_queue_set_specific(sharedQueue, NIMGetShareKeyValueQueueSpecificKey, (void *)NIMGetShareKeyValueQueueSpecificKey, NULL);
    });
    return sharedQueue;
}



@implementation NIMKeyValueItem
@end

@interface NIMKeyValueStore ()
@property (nonatomic,strong)    NIMDatabase *db;
@end

@implementation NIMKeyValueStore
+ (instancetype)storeByPath:(NSString *)path
{
    NIMKeyValueStore *instance = [[NIMKeyValueStore alloc] init];
    [instance createDB:path];
    return instance;
}

- (void)dealloc
{
    dispatch_block_t block = ^(){
        [_db close];
        _db = nil;
    };
    
    if (dispatch_get_specific(NIMGetShareKeyValueQueueSpecificKey))
    {
        block();
    }
    else
    {
        dispatch_sync(NIMGetShareKeyValueQueue(), block);
    }
}

- (void)storeObject:(id<NIMKeyValueProtocol>)item
{
    dispatch_async(NIMGetShareKeyValueQueue(), ^{
        NSString *key = [item key];
        NSString *value = [item value];
        if (key && value)
        {
            BOOL result = [_db executeUpdate:@"REPLACE INTO nim_table (nim_key,nim_value) values (?,?)",key,value];
            if (!result)
            {
                NIMLogErr(@"insert/update %@ failed %@",key,_db.lastError);
            }
        }
    });
}

- (void)removeObject:(id<NIMKeyValueProtocol>)item
{
    return [self removeObjectByID:[item key]];
}

- (void)removeObjectByID:(NSString *)key
{
    if (key)
    {
        dispatch_async(NIMGetShareKeyValueQueue(), ^{
            BOOL result = [_db executeUpdate:@"DELETE FROM nim_table WHERE nim_key = ?",key];
            if (!result)
            {
                NIMLogErr(@"remove object %@ failed %@",key,_db.lastError);
            }
        });
    }
}

- (id<NIMKeyValueProtocol>)objectByID:(NSString *)key
{
    __block NIMKeyValueItem *item = nil;
    if(key)
    {
        dispatch_sync(NIMGetShareKeyValueQueue(), ^{
            NIMResultSet *rs = [_db executeQuery:@"SELECT * FROM nim_table WHERE nim_key = ?",key];
            if ([rs next])
            {
                item = [[NIMKeyValueItem alloc]init];
                item.key = key;
                item.value = [rs stringForColumn:@"nim_value"];
            }
            [rs close];
        });
    }
    return item;
}

- (NSArray *)allObjects
{
    __block NSMutableArray *objects = nil;
    dispatch_sync(NIMGetShareKeyValueQueue(), ^{
        NIMResultSet *rs = [_db executeQuery:@"SELECT * FROM nim_table"];
        objects = [NSMutableArray array];
        while ([rs next])
        {
            NIMKeyValueItem * item = [[NIMKeyValueItem alloc]init];
            item.key = [rs stringForColumn:@"nim_key"];
            item.value = [rs stringForColumn:@"nim_value"];
            [objects addObject:item];
        }
        [rs close];
    });
    return objects;
}

- (void)removeAllObjects
{
    dispatch_async(NIMGetShareKeyValueQueue(), ^{
        
        BOOL removed =  [_db executeUpdate:@"DELETE FROM nim_table"];
        if (!removed)
        {
            NIMLogErr(@"remove all objects failed %@",_db.lastError);
        }
    });
}

#pragma mark - misc
- (BOOL)createDB:(NSString *)filepath
{
    _db = [[NIMDatabase alloc] initWithPath:filepath];
    BOOL result = [_db open];
    if (result)
    {
        NSString *sql = @"CREATE TABLE IF NOT EXISTS 'nim_table' ('nim_key' TEXT PRIMARY KEY,'nim_value' TEXT)";
        result =  [_db executeUpdate:sql];
    }
    if (!result)
    {
        NIMLogErr(@"create db failed %@ %@",filepath,_db.lastError);
    }
    return result;
}
@end
