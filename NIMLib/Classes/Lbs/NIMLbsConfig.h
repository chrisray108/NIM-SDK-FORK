//
//  NIMLbsConfig.h
//  NIMLib
//
//  Created by amao on 4/13/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMTimer.h"
#import "NIMLbsManager.h"

@class NIMHostSwitcher;

@interface NIMLbsConfig : NSObject
@property (nonatomic,copy)      NSString *cachedLbs;
@property (nonatomic,assign)    BOOL isQuery;
@property (nonatomic,strong)    NIMTimer *timer;
@property (atomic,assign)       BOOL everFetched;

- (NSString *)name;

- (NSString *)lbsURL;

- (NSDictionary *)parseData:(NSData *)data;

- (NSDictionary *)readConfig;

- (void)saveConfig:(NSData *)data;
@end

