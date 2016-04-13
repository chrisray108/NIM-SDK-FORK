//
//  NTSClient.h
//  nts
//
//  Created by 高峰 on 15/7/10.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    NTSOSTypeUnknown = 0,
    NTSOSTypeAndroid = 1,
    NTSOSTypeIOS     = 2,
    NTSOSTypeWP      = 3,
    NTSOSTypePC      = 4,
    NTSOSTypeCamera  = 5,
}NTSOSType;

typedef enum
{
    NTSNetTypeUnknown = 0,
    NTSNetType3G      = 1,
    NTSNetTypeWifi    = 2,
    NTSNetType2G      = 11,
    NTSNetType4G      = 12,
}NTSNetType;


typedef enum
{
    NTSClientTypeYiXin     = 0, //易信客户端
    NTSClientTypeSuperCall = 1, //超级电话客户端
    NTSClientTypeNIM       = 2, //云信SDK
    NTSClientTypeHS        = 101, //恒生视频开户项目客户端
    NTSClientTypeCamera    = 201, //易信摄像头
}NTSClientType;

typedef enum
{
    //没有错误
    NTSNetNoError = 200,
    
    //未知错误
    NTSNetErrorUnknown = 10,
    
    //业务无关的底层网络库错误码
    NTSNetErrorTcpCreate  = 1000,
    NTSNetErrorTcpConnect = 1001,
    NTSNetErrorTcpConnectionClosed = 1002,
    NTSNetErrorUnpack = 1003,
    
    //与业务相关错误码
    NTSNetErrorServerConnect = 101,
    NTSNetErrorServerDisonnected = 102,
    NTSNetErrorClientDisonnected = 103,
    
}NTSNetError;


typedef enum
{
    NTSLeaveReasonTimeout = -1,
    NTSLeaveReasonNormal  = 0,
}NTSLeaveReason;


typedef enum
{
    NTSClientStateInvalid = 0,
    NTSClientStateStarted,
    NTSClientStateNetworkLost,
    NTSClientStateRelogin,
    NTSClientStateConnected,
    NTSClientStateDisonnected,
    NTSClientStateStopped,
    
}NTSClientState;

@interface NTSClientParam : NSObject

@property (nonatomic, copy)   NSString *clientName;  //节点描述名
@property (nonatomic, assign) uint64_t clientID;     //节点id

@property (nonatomic, assign) uint64_t channelID;    //频道id, 底层用
@property (nonatomic, copy)   NSString *sessionID;   //会话id, 上层用

@property (nonatomic, copy)   NSString *proxyAddr;   //代理服务器地址
@property (nonatomic, copy)   NSString *turnAddr;    //turn服务器地址
@property (nonatomic, assign) uint16_t proxyPolicy;  //客户端是否通过代理服务器
@property (nonatomic, copy)   NSString *encryptToken; //加密的频道id
@property (nonatomic, assign) uint16_t encryptType;   //加密方式
@property (nonatomic, copy)   NSString *logPath;     //log输出路径
@property (nonatomic, assign) uint16_t logLevel;     //log输出等级
@property (nonatomic, assign) NTSClientType clientType;  //客户端类型
@property (nonatomic, assign) BOOL disableRecord;    //禁用录制

@end

@interface NTSClientInfo : NSObject

@property (nonatomic, assign) uint64_t clientID;          //节点id
@property (nonatomic, assign) uint32_t version;	          //对端底层协议版本号
@property (nonatomic, assign) NTSNetType netType;         //网络类型
@property (nonatomic, assign) NTSOSType osType;            //对方系统类型

@end

@interface NTSConnectResultInfo : NSObject
@property (nonatomic, assign) NTSNetError status;
@property (nonatomic, copy)   NSString *recordAddress;
@property (nonatomic, copy)   NSString *recordName;

@end

@protocol NTSClientDelegate <NSObject>

@optional

//登陆服务器结果
- (void)onNTSConnectResult:(NTSConnectResultInfo *)info
                 sessionID:(NSString *)sessionID;

//与服务器断开连接
- (void)onNTSDisconnect:(NSString *)sessionID;

//用户加入房间
- (void)onNTSClientJoin:(NTSClientInfo *)info
              sessionID:(NSString *)sessionID;

//用户离开房间
- (void)onNTSClientLeave:(uint64_t)clientID
               forReason:(NTSLeaveReason)reason
               sessionID:(NSString *)sessionID;

//收到对端从网络库发来的用户数据
- (void)onNTSReceiveData:(NSData *)data
                    from:(uint64_t)clientID
               sessionID:(NSString *)sessionID;

//NTS网络层发生错误
- (void)onNTSError:(uint32_t)error
         sessionID:(NSString *)sessionID;

@end


@interface NTSClient : NSObject

@property (nonatomic, weak, readonly) id<NTSClientDelegate> delegate;
@property (nonatomic, assign) NTSClientState clientState;

- (BOOL)startNTSClient:(NTSClientParam *)param delegate:(id<NTSClientDelegate>)delegate;
- (BOOL)sendNTSData:(NSData *)data to:(uint64_t)clientID;
- (void)stopNTSClient;

//internal use
- (void)reloginNTS;
- (void)sendBufferData;
@end
