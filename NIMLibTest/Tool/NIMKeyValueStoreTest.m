//
//  NIMKeyValueStoreTest.m
//  NIMLib
//
//  Created by amao on 3/16/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMKeyValueStore.h"
#import "NIMUtil.h"

@interface NIMKeyValueStoreTest : XCTestCase

@end

@implementation NIMKeyValueStoreTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testStoreNormal
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NIMUtil uuid]];
    NIMKeyValueStore *store = [NIMKeyValueStore storeByPath:path];
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger  i = 0; i < 100; i++)
    {
        NIMKeyValueItem *item = [[NIMKeyValueItem alloc] init];
        item.key = [NSString stringWithFormat:@"key_%zd",arc4random()];
        item.value = [NSString stringWithFormat:@"value_%zd",arc4random()];
        [items addObject:item];
        
        [store storeObject:item];
    }
    
    [self checkStore:store
         memoryCache:items];
    
    
    for (NSInteger i = 0; i < 5; i++)
    {
        NSInteger index = arc4random() % [items count];
        NIMKeyValueItem *item = [items objectAtIndex:index];
        
        id<NIMKeyValueProtocol> itemBefore = [store objectByID:[item key]];
        XCTAssertNotNil(itemBefore);
        XCTAssertNotNil([itemBefore key]);
        XCTAssertNotNil([itemBefore value]);
        XCTAssertTrue([[itemBefore key] isEqualToString:item.key]);
        XCTAssertTrue([[itemBefore value] isEqualToString:item.value]);
        
        [items removeObjectAtIndex:index];
        if (i % 2 == 0 )
        {
            [store removeObject:itemBefore];
        }
        else
        {
            [store removeObjectByID:[itemBefore key]];
        }

        id<NIMKeyValueProtocol> itemAfter = [store objectByID:[item key]];
        XCTAssertNil(itemAfter);
        
        [self checkStore:store
             memoryCache:items];
        
    }
    
    
    NSArray *leftItems = [store allObjects];
    XCTAssertTrue([leftItems count] != 0);
    [store removeAllObjects];
    leftItems = [store allObjects];
    XCTAssertTrue([leftItems count] == 0);
    
}

- (void)checkStore:(NIMKeyValueStore *)store
       memoryCache:(NSArray *)items
{
    
    for (NIMKeyValueItem *item in items)
    {
        NSString *key = item.key;
        id<NIMKeyValueProtocol> object = [store objectByID:key];
        
        XCTAssertTrue([item.key isEqualToString:[object key]]);
        XCTAssertTrue([item.value isEqualToString:[object value]]);
    }
    
    NSComparator block = ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        id<NIMKeyValueProtocol> item1 = (id<NIMKeyValueProtocol>)obj1;
        id<NIMKeyValueProtocol> item2 = (id<NIMKeyValueProtocol>)obj2;
        return [[item1 key] compare:[item2 key]];
    };
    
    
    NSArray *objects = [store allObjects];
    NSArray *diskItems = [objects sortedArrayUsingComparator:block];
    NSArray *memoryItems = [items sortedArrayUsingComparator:block];
    XCTAssertEqual([diskItems count], [memoryItems count]);
    
    for (NSInteger i = 0; i < [diskItems count]; i++)
    {
        id<NIMKeyValueProtocol> diskItem = [diskItems objectAtIndex:i];
        id<NIMKeyValueProtocol> memoryItem = [memoryItems objectAtIndex:i];
        
        XCTAssertNotNil([diskItem value]);
        XCTAssertNotNil([diskItem value]);
        
        XCTAssertTrue([diskItem.key isEqualToString:[memoryItem key]]);
        XCTAssertTrue([diskItem.value isEqualToString:[memoryItem value]]);
    }
}

- (void)testInvalidData
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NIMUtil uuid]];
    NIMKeyValueStore *store = [NIMKeyValueStore storeByPath:path];
    
    NIMKeyValueItem *item = [[NIMKeyValueItem alloc] init];
    item.key = [NSString stringWithFormat:@"key_%zd",arc4random()];
    item.value = (NSString *)[[NSString stringWithFormat:@"key_%zd",arc4random()] dataUsingEncoding:NSUTF8StringEncoding];
    
    [store storeObject:item];
}
@end
