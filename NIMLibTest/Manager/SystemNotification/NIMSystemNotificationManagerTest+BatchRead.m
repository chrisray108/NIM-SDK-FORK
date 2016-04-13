//
//  NIMSystemNotificationManagerTest+BatchRead.m
//  NIMLib
//
//  Created by amao on 12/30/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMTestSystemNotificationMaker.h"


@interface NIMSystemNotificationManagerTest_BatchRead: NIMBaseTest
@property (nonatomic,strong)    NIMTestSystemNotificationMaker *maker;
@end

@implementation NIMSystemNotificationManagerTest_BatchRead

- (void)setUp {
    [super setUp];
    
    _maker = [[NIMTestSystemNotificationMaker alloc] init];
    [_maker setUp];
}

- (void)tearDown {
    [_maker tearDown];
    _maker = nil;
    
    [super tearDown];
}

- (void)testTotalReadCount
{
    NSDictionary *notifications = [_maker notifications];
    [self verifyNotifications:notifications];

}

- (void)testSingleMarkReadCount
{
    NSDictionary *notifications = [_maker notifications];
    id<NIMSystemNotificationManager> manager = [[NIMSDK sharedSDK] systemNotificationManager];
    
    NSMutableDictionary *modified = [NSMutableDictionary dictionaryWithDictionary:notifications];
    
    for (NSNumber *key in notifications.allKeys)
    {
        NIMSystemNotificationFilter *filter = [[NIMSystemNotificationFilter alloc] init];
        filter.notificationTypes = @[key];
        
        XCTAssertNotEqual([notifications[key] count], 0);
        XCTAssertEqual([notifications[key] count], [manager allUnreadCount:filter]);
        
        [manager markAllNotificationsAsRead:filter];
        
        XCTAssertEqual(0,[manager allUnreadCount:filter]);
        
        [modified removeObjectForKey:key];
        
        [self verifyNotifications:modified];
    }
}

- (void)test2Filters
{
    [self verifyMultiMarkRead:2];
}


- (void)test3Filters
{
    [self verifyMultiMarkRead:3];
}

- (void)test4Filters
{
    [self verifyMultiMarkRead:4];
}

#pragma mark - misc
- (NSInteger)totalCount:(NSDictionary *)notifications
{
    NSInteger count = 0;
    for (NSArray *notificationThisType in notifications.allValues)
    {
        count += [notificationThisType count];
    }
    return count;
}

- (void)verifyNotifications:(NSDictionary *)notifications
{
    if ([notifications count] == 0)
    {
        return;
    }
    
    
    id<NIMSystemNotificationManager> manager = [[NIMSDK sharedSDK] systemNotificationManager];
    
    NSInteger count = [self totalCount:notifications];
    XCTAssertNotEqual(count, 0);
    XCTAssertEqual(count, [manager allUnreadCount]);

    for (NSNumber *key in notifications.allKeys)
    {
        NIMSystemNotificationFilter *filter = [[NIMSystemNotificationFilter alloc] init];
        filter.notificationTypes = @[key];
        
        XCTAssertNotEqual([notifications[key] count], 0);
        XCTAssertEqual([notifications[key] count], [manager allUnreadCount:filter]);
    }
}

- (void)verifyMultiMarkRead:(NSInteger)count
{
    id<NIMSystemNotificationManager> manager = [[NIMSDK sharedSDK] systemNotificationManager];
    NSDictionary *notifications = [_maker notifications];
    NSMutableArray *keys = [NSMutableArray arrayWithArray:notifications.allKeys];
    NSMutableArray *filterTypes = [NSMutableArray array];
    
    for (NSInteger i = 0; i < count; i++)
    {
        NSInteger random = arc4random() % [keys count];
        [filterTypes addObject:[keys objectAtIndex:random]];
        [keys removeObjectAtIndex:random];
    }
    
    NIMSystemNotificationFilter *filter = [[NIMSystemNotificationFilter alloc] init];
    filter.notificationTypes = filterTypes;
    
    NSMutableDictionary *modifiedNotifications = [NSMutableDictionary dictionaryWithDictionary:notifications];
    for (NSString *type in filterTypes)
    {
        [modifiedNotifications removeObjectForKey:type];
    }
    NSInteger totalCount        = [self totalCount:notifications];
    NSInteger modifiedCount     = [self totalCount:modifiedNotifications];
    NSInteger filterCount       = totalCount - modifiedCount;
    XCTAssertNotEqual(totalCount, 0);
    XCTAssertNotEqual(modifiedCount, 0);
    XCTAssertNotEqual(filterCount, 0);
    

    XCTAssertEqual(filterCount, [manager allUnreadCount:filter]);
    [manager markAllNotificationsAsRead:filter];
    XCTAssertEqual(0, [manager allUnreadCount:filter]);

    
    XCTAssertEqual(modifiedCount, [manager allUnreadCount]);

}

@end
