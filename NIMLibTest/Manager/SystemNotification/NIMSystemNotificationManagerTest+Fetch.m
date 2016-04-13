//
//  NIMSystemNotificationManagerTest+Fetch.m
//  NIMLib
//
//  Created by amao on 12/30/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMTestSystemNotificationMaker.h"
#import "NIMTestSystemNotificationUtil.h"

@interface NIMSystemNotificationManagerTest_Fetch : NIMBaseTest
@property (nonatomic,strong)    NIMTestSystemNotificationMaker  *maker;
@end

@implementation NIMSystemNotificationManagerTest_Fetch

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

- (void)testFetchSeq
{
    id<NIMSystemNotificationManager> manager = [[NIMSDK sharedSDK] systemNotificationManager];
    
    NSDictionary *notifications = [_maker notifications];
    for (NSNumber *key in notifications.allKeys)
    {
        NIMSystemNotificationFilter *filter = [[NIMSystemNotificationFilter alloc] init];
        filter.notificationTypes = @[key];
        
        
        NSArray *savedNotifications = [notifications objectForKey:key];
        NSMutableArray *fetchedResult = [NSMutableArray array];
        while ([fetchedResult count] < [savedNotifications count])
        {
            NSInteger left = [savedNotifications count] - [fetchedResult count];
            NSInteger count = random() %  4 == 0 ? left : left / 2;
            
            NSArray *result = [manager fetchSystemNotifications:[fetchedResult lastObject]
                                                          limit:count
                                                         filter:filter];
            
            [fetchedResult addObjectsFromArray:result];
        }
        
        XCTAssertTrue([NIMTestSystemNotificationUtil notifications:savedNotifications
                                                        areEqualTo:fetchedResult]);
        
    }
    
    NSMutableArray *savedNotifications = [NSMutableArray array];
    for (NSArray *item in notifications.allValues) {
        [savedNotifications addObjectsFromArray:item];
    }

    NSMutableArray *fetchedResult = [NSMutableArray array];
    while ([fetchedResult count] < [savedNotifications count])
    {
        NSInteger left = [savedNotifications count] - [fetchedResult count];
        NSInteger count = random() %  4 == 0 ? left : left / 2;
        
        NSArray *result = [manager fetchSystemNotifications:[fetchedResult lastObject]
                                                      limit:count];
        
        [fetchedResult addObjectsFromArray:result];
    }
    
    XCTAssertTrue([NIMTestSystemNotificationUtil notifications:savedNotifications
                                                    areEqualTo:fetchedResult]);

    
    
}

- (void)testFetchAndModify
{
    id<NIMSystemNotificationManager> manager = [[NIMSDK sharedSDK] systemNotificationManager];
    NSDictionary *notifications = [_maker notifications];
    NSMutableArray *savedNotifications = [NSMutableArray array];
    for (NSArray *item in notifications.allValues) {
        [savedNotifications addObjectsFromArray:item];
    }
    
    //获取裸数据
    NSArray *fetchedReuslt = [manager fetchSystemNotifications:nil
                                                         limit:[savedNotifications count]];
    
    XCTAssertTrue([NIMTestSystemNotificationUtil notifications:fetchedReuslt
                                                    areEqualTo:savedNotifications]);
    
    
    
    //随机设置某个系统消息为已读，不影响读取数据
    {
        NSInteger index = arc4random() % [savedNotifications count];
        NIMSystemNotification *readNotification = [savedNotifications objectAtIndex:index];
        [manager markNotificationsAsRead:readNotification];
        
        NSArray *fetchedReuslt = [manager fetchSystemNotifications:nil
                                                             limit:[savedNotifications count]];
        
        XCTAssertTrue([NIMTestSystemNotificationUtil notifications:fetchedReuslt
                                                        areEqualTo:savedNotifications]);
    }
    
    //设置所有系统消息已读，不影响读取数据
    {
        [manager markAllNotificationsAsRead];
        
        NSArray *fetchedReuslt = [manager fetchSystemNotifications:nil
                                                             limit:[savedNotifications count]];
        
        XCTAssertTrue([NIMTestSystemNotificationUtil notifications:fetchedReuslt
                                                        areEqualTo:savedNotifications]);
    }
    
    //随机删除某个系统消息，影响读取数据
    {
        NSInteger index = arc4random() % [savedNotifications count];
        NIMSystemNotification *readNotification = [savedNotifications objectAtIndex:index];
        [savedNotifications removeObjectAtIndex:index];
        [manager deleteNotification:readNotification];
        
        NSArray *fetchedReuslt = [manager fetchSystemNotifications:nil
                                                             limit:[savedNotifications count]];
        
        XCTAssertTrue([NIMTestSystemNotificationUtil notifications:fetchedReuslt
                                                        areEqualTo:savedNotifications]);
    }
    
    
    //删除所有数据，影响读取数据
    {
        [manager deleteAllNotifications];
        NSArray *fetchedReuslt = [manager fetchSystemNotifications:nil
                                                             limit:[savedNotifications count]];
        
        XCTAssertTrue([fetchedReuslt count] == 0);
    }
    
}


- (void)testFilterFetchAndModify
{
    id<NIMSystemNotificationManager> manager = [[NIMSDK sharedSDK] systemNotificationManager];
    
    NSDictionary *notifications = [_maker notifications];
    for (NSNumber *key in notifications.allKeys)
    {
        NIMSystemNotificationFilter *filter = [[NIMSystemNotificationFilter alloc] init];
        filter.notificationTypes = @[key];
        
        NSMutableArray *savedNotifications = [NSMutableArray arrayWithArray:[notifications objectForKey:key]];
        
        //获取裸数据
        NSArray *fetchedReuslt = [manager fetchSystemNotifications:nil
                                                             limit:[savedNotifications count]
                                                            filter:filter];
        
        XCTAssertTrue([NIMTestSystemNotificationUtil notifications:fetchedReuslt
                                                        areEqualTo:savedNotifications]);
        
        
        
        //随机设置某个系统消息为已读，不影响读取数据
        {
            NSInteger index = arc4random() % [savedNotifications count];
            NIMSystemNotification *readNotification = [savedNotifications objectAtIndex:index];
            [manager markNotificationsAsRead:readNotification];
            
            NSArray *fetchedReuslt = [manager fetchSystemNotifications:nil
                                                                 limit:[savedNotifications count]
                                                                filter:filter];
            
            XCTAssertTrue([NIMTestSystemNotificationUtil notifications:fetchedReuslt
                                                            areEqualTo:savedNotifications]);
        }
        
        //设置所有系统消息已读，不影响读取数据
        {
            [manager markAllNotificationsAsRead:filter];
            
            NSArray *fetchedReuslt = [manager fetchSystemNotifications:nil
                                                                 limit:[savedNotifications count]
                                                                filter:filter];
            
            XCTAssertTrue([NIMTestSystemNotificationUtil notifications:fetchedReuslt
                                                            areEqualTo:savedNotifications]);
        }
        
        //随机删除某个系统消息，影响读取数据
        {
            NSInteger index = arc4random() % [savedNotifications count];
            NIMSystemNotification *readNotification = [savedNotifications objectAtIndex:index];
            [savedNotifications removeObjectAtIndex:index];
            [manager deleteNotification:readNotification];
            
            NSArray *fetchedReuslt = [manager fetchSystemNotifications:nil
                                                                 limit:[savedNotifications count]
                                                                filter:filter];
            
            XCTAssertTrue([NIMTestSystemNotificationUtil notifications:fetchedReuslt
                                                            areEqualTo:savedNotifications]);
        }
        
        
        //删除所有数据，影响读取数据
        {
            [manager deleteAllNotifications:filter];
            NSArray *fetchedReuslt = [manager fetchSystemNotifications:nil
                                                                 limit:[savedNotifications count]
                                                                filter:filter];
            
            XCTAssertTrue([fetchedReuslt count] == 0);
        }
    }
}

@end
