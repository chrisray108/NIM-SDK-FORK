//
//  NIMHostSwitcher.h
//  NIMLib
//
//  Created by amao on 4/13/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMLbsManager.h"

@interface NIMHostSwitcher: NSObject
@property (nonatomic,assign)    NIMLbsType type;            //类型
@property (nonatomic,strong)    NSArray *hosts;             //可选host
@property (nonatomic,copy)      NSString *defaultHost;      //默认host
@property (nonatomic,assign)    NSInteger index;            //当前index
@property (nonatomic,assign)    NSInteger errTimes;         //错误次数
@property (nonatomic,assign)    NSInteger maxErrTimes;      //一个地址最大错误次数


+ (NIMHostSwitcher *)switcher:(NIMLbsType)type
                  defaultHost:(NSString *)defaultHost
                  maxErrTimes:(NSInteger)times;

- (NSString *)currentHost;
- (BOOL)outOfRange;
- (void)resetIndex;
- (void)updateHosts:(NSArray *)hosts;
- (void)reportError:(BOOL)fatal;
@end
