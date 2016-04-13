//
//  NIMDatabaseUpgrader.h
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NIMDatabase;

@interface NIMDatabaseUpgrader : NSObject
+ (instancetype)upgrader:(NIMDatabase *)database
               tablename:(NSString *)tablename;

- (void)addColumn:(NSString *)name
             type:(NSString *)type;
@end
