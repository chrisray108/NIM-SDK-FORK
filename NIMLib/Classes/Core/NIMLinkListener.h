//
//  NIMLinkListener.h
//  YixinCall
//  Yixin 链接状态监听器
//  Created by amao on 10/8/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "document.h"
#import "yixin_core.h"

@class NIMLinkListener;

@protocol NIMLinkProtocol <NSObject>
@optional
- (void)onNetChanged:(NIMLinkListener *)listener;
- (void)onDisconnect:(NIMLinkListener *)listener;
- (void)onConnectionBegin:(NIMLinkListener *)listener;
- (void)onConnectSuccess:(NIMLinkListener *)listener;
- (void)onConnectFailed:(NIMLinkListener *)listener;
- (BOOL)shouldConnectServer:(NIMLinkListener *)listener;
@end

typedef enum : NSUInteger
{
    NIMConnectStateInit,           //初始状态
    NIMConnectStateConnecting,     //正在链接
    NIMConnectStateConnected,      //已链接
} NIMConnectState;


@interface NIMLinkListener : NSObject
+ (instancetype)sharedListener;
@property (nonatomic,assign)    NIMConnectState    state;                      //链接状态
@property (nonatomic,weak)      id<NIMLinkProtocol>  delegate;              //回调

- (void)checkState;
@end

namespace nimbiz{
void    CallbackConnectLink(IAsynCallbackParam *connectParam);              //连接服务器callback
void    CallbackDisconnectLink(IAsynCallbackParam *disconnectParam);        //断开连接callback
}