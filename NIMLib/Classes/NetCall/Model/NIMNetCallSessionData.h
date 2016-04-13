//
//  NIMNetCallSessionData.h
//  NIMLib
//
//  Created by fenric on 15/5/4.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "netcall_protocol.h"
#import "NIMNVSObject.h"

@interface NIMNetCallSessionData : NIMNVSObject

@property(nonatomic, strong) NSArray *callees;
@property(nonatomic, strong) NSString *caller;
@property(nonatomic, strong) NSDictionary *usersInfo;

@property(nonatomic, strong) NSArray *keepCallingCallees;

@property(nonatomic, copy)   NSString *extendMessage;

-(id)initWithNetcallInitParam:(nimbiz::CBNetcallInitParam *)param;
-(id)initWithNetcallBeCalledParam:(nimbiz::CBNetcallBeCalledParam *)param;

@end
