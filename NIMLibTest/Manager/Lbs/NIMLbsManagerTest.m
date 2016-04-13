//
//  NIMLbsManagerTest.m
//  NIMLib
//
//  Created by amao on 12/28/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMLbsManager.h"
#import "NIMTimer.h"
#import "NIMGlobalTest.h"
#import "NIMServerSetting.h"
#import "NIMSDK_Private.h"
#import "NIMBaseTest.h"



@interface NIMLbsManagerTest : NIMBaseTest
@end

@implementation NIMLbsManagerTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testLbsQuery
{
    NIMLbsManager *lbsManager = [[NIMSDK sharedSDK] lbsManager];
    
    //测试Link汇报错误后的表现
    {
        NSMutableArray *linkHosts = [NSMutableArray array];
        NIMLinkAddress *link = [lbsManager link];
        XCTAssertNotNil(link);
        [linkHosts addObject:link];
        
        for (NSInteger i = 0; i < 100; i++)
        {
            BOOL fatal = i % 4 == 0;
            if (!fatal)
            {
                //3次汇报聚集成一次致命请求
                [lbsManager reportError:NIMLbsTypeLink
                                   fatal:NO];
                [lbsManager reportError:NIMLbsTypeLink
                                   fatal:NO];
                [lbsManager reportError:NIMLbsTypeLink
                                   fatal:NO];
            }
            else
            {
                [lbsManager reportError:NIMLbsTypeLink
                                   fatal:YES];
            }
            
            
            NIMLinkAddress *address = [lbsManager link];
            
            BOOL equal = [self hostAddress:address
                                     equal:[linkHosts lastObject]];
            XCTAssertFalse(equal);
            [linkHosts addObject:address];
        }
    }
    
    //测试nos上传地址的汇报错误
    {
        NSMutableArray *nosHosts = [NSMutableArray array];
        NSString *nosAddress = [lbsManager nosURL];
        XCTAssertNotNil(nosAddress);
        [nosHosts addObject:nosAddress];
        
        for (NSInteger i = 0; i < 100; i++)
        {
            BOOL fatal = i % 4 == 0;
            if (!fatal)
            {
                //3次汇报聚集成一次致命请求
                [lbsManager reportError:NIMLbsTypeNOS
                                   fatal:NO];
                [lbsManager reportError:NIMLbsTypeNOS
                                   fatal:NO];
                [lbsManager reportError:NIMLbsTypeNOS
                                   fatal:NO];
            }
            else
            {
                [lbsManager reportError:NIMLbsTypeNOS
                                   fatal:YES];
            }
            
            NSString *address = [lbsManager nosURL];
            [nosHosts addObject:address];
            
            if ([nosHosts count] > 3)
            {
                NSString *lastOne = [nosHosts lastObject];
                NSString *secondLastOne = [nosHosts objectAtIndex:[nosHosts count] - 2];
                NSString *thirdLastOne = [nosHosts objectAtIndex:[nosHosts count] - 3];
                BOOL allEqual = [lastOne isEqualToString:secondLastOne] && [lastOne isEqualToString:thirdLastOne];
                XCTAssertFalse(allEqual);
            }
        }
    }

}


- (BOOL)hostAddress:(NIMLinkAddress *)first
              equal:(NIMLinkAddress *)second
{
    return [first.address isEqualToString:second.address] &&
    first.port == second.port;
}
@end
