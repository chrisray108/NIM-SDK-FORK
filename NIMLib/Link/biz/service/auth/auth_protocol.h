//
//  auth_protocol.h
//  YixinCall
//
//  Created by amao on 10/8/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#ifndef YixinCall_auth_protocol_h
#define YixinCall_auth_protocol_h

#include "biz/core/service.h"
#include "biz/protocol/property.h"
#include "biz/protocol/response_code.h"
#include "biz/core/yixin_core.h"

namespace nimbiz
{

enum YXAuthCID
{
    CID_LOGIN               = 2,
    CID_KICK_SAME_GENERIC   = 5,
    CID_LOGOUT              = 6,
    CID_MULTI_SPOT_LOGIN    = 7,
    CID_KICK_BY_SELF        = 8,
};


enum NIMAuthTag
{
    NIMAuthTagClientType     = 3, //客户端类型
    NIMAuthTagOS             = 4, //系统描述
    NIMAuthTagSDKVersion     = 6, //SDK版本
    NIMAuthTagLoginMode      = 8, //登录模式 1强制登录 0自动登录
    NIMAuthTagProtocolVersion= 9, //协议版本号
    NIMAuthTagCerName        = 10,//推送证书名
    NIMAuthTagPushToken      = 11, //推送证书Token
    NIMAuthTagBackground     = 12, //后台
    NIMAuthTagDeviceID       = 13, //DeviceID
    NIMAuthTagNetworkCode    = 16, //接入设备的网络状态（2g:1,3g:2,4g:3,wifi:4,wired:5,其它-1）
    NIMAuthTagLastDeviceID   = 17, //上次登录DeviceID
    NIMAuthTagAppKey         = 18, //app标示
    NIMAuthTagAppAccount     = 19, //第三方帐号
    NIMAuthTagAppBundleID    = 25, //APP BUNDLE ID
    NIMAuthTagClientSession  = 26, //客户端session号

    NIMAuthTagConnectId      = 102, //登录后分配的连接号
    NIMAuthTagIp             = 103, //ip
    NIMAuthTagLoginTime      = 109, //登录时间


    NIMAuthTagLoginToken     = 1000,//登录Token
};


enum NIMAccountType
{
    NIMAccountTypeAccount   = 0,
    NIMAccountTypeNIMID     = 1,
};


enum NIMClientType
{
    NIMClientTypeAOS         = 1,
    NIMClientTypeIOS         = 2,
    NIMClientTypePC          = 4,
    NIMClientTypeWP          = 8,
    NIMClientTypeWeb         = 16,
};

enum
{
    NIMConnectStepLinking,      //正在链接服务器
    NIMConnectStepLinked,       //链接服务器成功
};


#pragma mark - 回调Param
typedef IAsynCallbackParam CBFetchCodeParam;
typedef IAsynCallbackParam CBLogoutParam;
    
struct CBConnectStepParam : IAsynCallbackParam
{
    int32_t step_;
};

    
struct CBLoginParam : IAsynTaskCallbackParam
{
    Property info_;
};

struct CBKickoutParam : IAsynCallbackParam
{
    int32_t client_type_;
    int32_t reason_;
};


struct CBMultiLoginParam : IAsynCallbackParam
{
    uint8_t type_;
    PropertyList clients_;
};

struct CBKickOtherParam : IAsynTaskCallbackParam
{
    std::vector<UTF8String> clients_;
};


#pragma mark - IAuthService
class IAuthService : public IService
{
public:
    IAuthService() : IService(SVID_NIM_AUTH) {}
public:
    virtual void Invoke_Connect() = 0;  //链接服务器 (登录前)
    virtual void Notify_Connect(bool connected) = 0;
    virtual void RegisterConnectCallback(const IAsynCallback &callback) = 0;
    virtual void RegisterKickoutCallback(const IAsynCallback &callback) = 0;
    virtual void RegisterMultipLoginCallback(const IAsynCallback &callback) = 0;
    
    virtual int32_t Invoke_Login(const Property &param,const IAsynCallback &callback) = 0;
    virtual void    Remote_Login(const Property &param,const IAsynCallback &callback,int32_t task_id) = 0;
    
    virtual void Invoke_Logout(const IAsynCallback &callback) = 0;
    virtual void Remote_Logout(const IAsynCallback &callback) = 0;
    
    virtual int32_t Invoke_Kick(const UTF8String &device_id,const IAsynCallback &callback) = 0;
    virtual void Remote_Kick(const UTF8String &device_id,const IAsynCallback &callback,int32_t task_id) = 0;
    
    virtual bool IsIpChanged() = 0;
    virtual bool IsDeviceChanged() = 0;
};
    
}

#endif
