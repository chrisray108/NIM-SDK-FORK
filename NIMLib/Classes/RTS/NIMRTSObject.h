//
//  NIMRTSObject.h
//  NIMLib
//
//  Created by 高峰 on 15/7/15.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNVSObject.h"
#import "NIMNTSObject.h"

typedef NS_ENUM(NSInteger, NIMRTSSessionState){
    //主叫
    NIMRTSSessionStateCallerRequestSent = 1, //主叫发送请求
    NIMRTSSessionStateCallerServerResponse,  //主叫发送请求后收到了服务器响应
    NIMRTSSessionStateCallerCalleeResponse,  //主叫发送请求后收到了被叫响应
    
    //被叫
    NIMRTSSessionStateCalleeRequestReceived, //被叫收到请求
    NIMRTSSessionStateCalleeResponseSent,    //被叫发送响应
    NIMRTSSessionStateCalleeServerResponse,  //被叫发送响应后收到了服务器响应
    
    //双方
    NIMRTSSessionStateEstablish,             //调用相关服务建立会话
    NIMRTSSessionStateTermimate,             //调用相关服务结束会话
    NIMRTSSessionStateReadyToRelease,        //待释放

};



@interface NIMRTSObject : NSObject

@property (nonatomic, copy, readonly) NSString *sessionID; //本地会话ID
@property (nonatomic, assign) UInt64 serviceID;  //服务器会话ID
           
@property (nonatomic, assign) NSUInteger services;
@property (nonatomic, assign) NIMRTSSessionState state;

@property (nonatomic, strong) NIMRTSRequestHandler requestBlock;
@property (nonatomic, strong) NIMRTSResponseHandler responseBlock;

@property(nonatomic, strong) NSArray *keepNotifyUsers;
@property (nonatomic, copy)  NSString *caller;
@property(nonatomic, strong) NSDictionary *usersInfo;

@property (nonatomic, strong) NIMRTSOption *option;

@property (nonatomic, strong) NIMNTSObject *ntsObject;
@property (nonatomic, strong) NIMNVSObject *nvsObject;

- (id)initWithServices:(NSUInteger)types;

- (void)setBlockHandler:(id)block isCaller:(BOOL)caller;

@end
