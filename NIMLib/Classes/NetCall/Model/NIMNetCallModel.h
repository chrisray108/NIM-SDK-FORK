//
//  NIMNetCallModel.h
//  NIMLib
//
//  Created by fenric on 15/5/12.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNetCallManagerProtocol.h"
#import "NIMNetCallSessionData.h"

//一通网络通话的细节状态
typedef NS_ENUM(NSInteger, NIMNetCallSessionStatus) {
    NIMNetCallSessionStatusInit = 0,             //初始状态
    NIMNetCallSessionStatusCallerWatingStartAck, //主叫正在等待服务器的发起响应
    NIMNetCallSessionStatusCallerPendingHangup,  //主叫过早挂断(还没拿到channel id), 正在等服务器响应以后延迟挂断
    
    NIMNetCallSessionStatusCalleeResponsed,      //被叫响应过这通请求
    
    NIMNetCallSessionStatusConnected,            //已经连上了
    NIMNetCallSessionStatusDisconnected,         //已经结束了
};


@interface NIMNetCallModel : NSObject

@property(nonatomic, assign) BOOL isCaller;
@property(nonatomic, assign) NIMNetCallType type;

@property(nonatomic, assign) BOOL isMute;
@property(nonatomic, assign) BOOL useSpeaker;

@property(nonatomic, copy)   NSString *uuid; //标识一通通话，本地生成
@property(nonatomic, assign) UInt64 channelID;

@property(nonatomic, assign) NIMNetCallSessionStatus status;
@property(nonatomic, assign) NSTimeInterval connectTimetag;

@property(nonatomic, strong) NIMNetCallSessionData *sessionData;
@property(nonatomic, assign) NSInteger  turnAddrIndex;
@property(nonatomic, assign) NSInteger  proxyAddrIndex;

@property(nonatomic, assign) BOOL isCallRecorded; //通话记录已生成

@property(nonatomic, weak)   CALayer *localPreveiwLayer;

@property(nonatomic, assign) NIMNetCallNetStatus netStatus;

@property(nonatomic, strong) NSArray *callees; //for caller only
@property(nonatomic, copy)   NSString *caller;   //for callee only


@property(nonatomic, strong) NIMNetCallOption *option;

- (id)initCallerWithCallees:(NSArray *)callees type:(NIMNetCallType)type;
- (id)initCalleeWithCaller:(NSString *)caller type:(NIMNetCallType)type channelID:(UInt64)channelID;

@end
