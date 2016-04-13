//
//  netcall_protocol.h
//  NIMLib
//
//  Created by fenric on 15/5/4.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_netcall_protocol_h
#define NIMLib_netcall_protocol_h

#include "biz/core/service.h"
#include "biz/protocol/property.h"
#include "biz/protocol/response_code.h"
#include "biz/core/yixin_core.h"

namespace nimbiz
{
enum
{
    CID_NETCALL_INIT               = 1,    //发起通话
    CID_NETCALL_NOTIFY_BECALLED    = 2,    //被呼叫
    CID_NETCALL_KEEP_CALLING       = 3,    //定时发送在线发起通话
    CID_NETCALL_CALLEE_ACK         = 4,    //被叫响应
    CID_NETCALL_NOTIFY_CALLEE_ACK  = 5,    //被叫响应通知
    CID_NETCALL_HANGUP             = 6,    //挂断
    CID_NETCALL_HANGUP_NOTIFY      = 7,    //挂断通知
    CID_NETCALL_CTRL               = 8,    //控制协议
    CID_NETCALL_NOTIFY_CTRL        = 9,    //控制协议通知
    CID_NETCALL_VALIDATE_CHANNELID = 10,   //被叫接到离线呼叫时验证一下通话是否还有效
    CID_NETCALL_NOTIFY             = 11,   //网络通话通知: 回单, 未接...
    CID_NOTIFY_OL_ACK_SYNC         = 12,   //被叫应答多端同步
};

typedef enum
{
    NIMNetcallTypeAudio         = 1,      //音频
    NIMNetcallTypeVideo         = 2,      //视频
}NIMNetcallType;
    
    
enum NIMNetcallNotifyOptionTag
{
    NIMNetcallNotifyOptionTagApnsEnable     =   1,  //int, 是否需要推送,0:不需要,>0:需要,默认1
    NIMNetcallNotifyOptionTagApnsCountBadge =   2,  //int, 是否需要角标计数,0:不需要,>0:需要,默认1
    NIMNetcallNotifyOptionTagApnsWithNick   =   3,  //int, 是否需要推送昵称,0:不需要,>0:需要,默认1
    NIMNetcallNotifyOptionTagApnsContent    =   4,  //String, 推送内容
    NIMNetcallNotifyOptionTagNotifyAttach   =   5,  //String, 自定义通知数据
    NIMNetcallNotifyOptionTagApnsPayload    =   6,  //String, JSON格式,推送payload,推送声音直接在这个payload中封装
    NIMNetcallNotifyOptionTagApnsSound      =   7,  //String, 推送声音
};


//发起
struct NetCallInitReqeust : nbase::Marshallable
{
    uint8_t call_type_; //通话类型: 音频，视频
    std::list<UTF8String> callee_users_; //被叫列表
    Property notify_;
    void marshal(nbase::Pack &p) const
    {
        p.push_uint8(call_type_);
        
        p.push_len((uint32_t)callee_users_.size());
        for (auto it = callee_users_.begin(); it!= callee_users_.end(); it++)
        {
            p.push_varstr(*it);
        }
        
        //兼容老协议, notify里面已经包含了这两个字段
        p.push_varstr("");
        p.push_varstr("");
        
        p << notify_;
    }
    YX_REQUEST_ONLY();
};

struct NetCallInitResponse : nbase::Marshallable
{
    uint64_t timetag_;
    uint64_t my_uid_;
    uint64_t channel_id_;
    std::list<UTF8String> turn_addrs_;
    std::list<UTF8String> sturn_addrs_;
    std::list<UTF8String> proxy_addrs_;
    std::list<UTF8String> keep_calling_users_;
    std::map<uint64_t, UTF8String> users_info_;
    UTF8String call_config_;

    void unmarshal(const nbase::Unpack &up)
    {
        timetag_    = up.pop_uint64();
        my_uid_     = up.pop_uint64();
        channel_id_ = up.pop_uint64();
        
        uint32_t size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String server;
            up>>server;
            turn_addrs_.push_back(server);
        }
        
        size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String server;
            up>>server;
            sturn_addrs_.push_back(server);
        }
        
        size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String server;
            up>>server;
            proxy_addrs_.push_back(server);
        }
        
        size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String server;
            up>>server;
            keep_calling_users_.push_back(server);
        }
        size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String account = up.pop_varstr();
            uint64_t uid = up.pop_uint64();
            users_info_.insert(std::pair<uint64_t, UTF8String>(uid, account));
        }
        call_config_ = up.pop_varstr();

    }
    YX_RESPONSE_ONLY();
};

struct CBNetcallInitParam : IAsynCallbackParam
{
    uint8_t call_type_;
    std::list<UTF8String> callee_users_;
    UTF8String uuid;
    
    uint64_t timetag_;
    uint64_t my_uid_;
    uint64_t channel_id_;
    std::list<UTF8String> turn_addrs_;
    std::list<UTF8String> sturn_addrs_;
    std::list<UTF8String> proxy_addrs_;
    std::list<UTF8String> keep_calling_users_;
    std::map<uint64_t, UTF8String>users_info_;
    UTF8String call_config_;
};

//被呼叫
struct NetCallBeCalledResponse : nbase::Marshallable
{
    uint64_t timetag_;
    uint8_t call_type_;
    uint64_t channel_id_;
    UTF8String caller_;
    uint64_t my_uid_;
    std::list<UTF8String> turn_addrs_;
    std::list<UTF8String> sturn_addrs_;
    std::list<UTF8String> proxy_addrs_;
    std::map<uint64_t, UTF8String>users_info_;
    UTF8String call_config_;
    UTF8String extend_message_;
    Property notify_;

    void unmarshal(const nbase::Unpack &up)
    {
        timetag_    = up.pop_uint64();
        call_type_  = up.pop_uint8();
        channel_id_ = up.pop_uint64();
        caller_     = up.pop_varstr();
        my_uid_     = up.pop_uint64();
        
        uint32_t size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String server;
            up>>server;
            turn_addrs_.push_back(server);
        }
        
        size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String server;
            up>>server;
            sturn_addrs_.push_back(server);
        }
        
        size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String server;
            up>>server;
            proxy_addrs_.push_back(server);
        }
        size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String account = up.pop_varstr();
            uint64_t uid = up.pop_uint64();
            users_info_.insert(std::pair<uint64_t, UTF8String>(uid, account));
        }
        call_config_ = up.pop_varstr();
        
        if (up.size()) {
            extend_message_ = up.pop_varstr();
        }
        if (up.size()) {
            up >> notify_;
        }
    }
    YX_RESPONSE_ONLY();
};

struct CBNetcallBeCalledParam : IAsynCallbackParam
{
    uint64_t timetag_;
    uint8_t call_type_;
    uint64_t channel_id_;
    UTF8String caller_;
    uint64_t my_uid_;
    std::list<UTF8String> turn_addrs_;
    std::list<UTF8String> sturn_addrs_;
    std::list<UTF8String> proxy_addrs_;
    std::map<uint64_t, UTF8String>users_info_;
    UTF8String call_config_;
    UTF8String extend_message_;
};

//持续发请求
struct NetCallKeepCallingReqeust : nbase::Marshallable
{
    uint8_t call_type_; //通话类型: 音频，视频
    std::list<UTF8String> callee_users_; //被叫列表
    uint64_t channel_id_;

    void marshal(nbase::Pack &p) const
    {
        p.push_uint8(call_type_);
        
        p.push_len((uint32_t)callee_users_.size());
        for (auto it = callee_users_.begin(); it!= callee_users_.end(); it++)
        {
            p.push_varstr(*it);
        }
        p.push_uint64(channel_id_);
    }
    YX_REQUEST_ONLY();
};

struct NetCallKeepCallingResponse : nbase::Marshallable
{
    std::list<UTF8String> callee_users_; //被叫列表
    
    void unmarshal(const nbase::Unpack &up)
    {
        uint32_t size = up.pop_len();
        
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String user;
            up>>user;
            callee_users_.push_back(user);
        }
    }
    YX_RESPONSE_ONLY();
};

struct CBNetcallKeepCallingParam : IAsynCallbackParam
{
    std::list<UTF8String> keep_calling_users_;
};


//被叫响应
struct NetCallCalleeAckReqeust : nbase::Marshallable
{
    UTF8String caller_;
    uint64_t channel_id_;
    uint8_t call_type_; //通话类型: 音频，视频
    bool accept_;//是否接听
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr(caller_);
        p.push_uint64(channel_id_);
        p.push_uint8(call_type_);
        p.push_bool(accept_);
    }
    YX_REQUEST_ONLY();
};

struct CBNetcallCalleeAckParam : IAsynCallbackParam
{
    uint64_t channel_id_;
    bool accept_;
};


//主叫收到被叫响应
struct NetCallRcvCalleeAckResponse : nbase::Marshallable
{
    UTF8String callee_;
    uint64_t channel_id_;
    uint8_t call_type_;
    bool accepted_;
    void unmarshal(const nbase::Unpack &up)
    {
        callee_     = up.pop_varstr();
        channel_id_ = up.pop_uint64();
        call_type_  = up.pop_uint8();
        accepted_   = up.pop_bool();
    }
    YX_RESPONSE_ONLY();
};


struct CBNetcallRcvCalledAckParam : IAsynCallbackParam
{
    UTF8String callee_;
    uint64_t channel_id_;
    uint8_t call_type_;
    bool accepted_;
};


//挂断请求
struct NetCallHangupReqeust : nbase::Marshallable
{
    uint64_t channel_id_;
    void marshal(nbase::Pack &p) const
    {
        p.push_uint64(channel_id_);
    }
    YX_REQUEST_ONLY();
};


//对方挂断通知
struct NetCallHangupNotifyResponse : nbase::Marshallable
{
    uint64_t channel_id_;
    UTF8String peer_;
    uint64_t timetag_;
    
    void unmarshal(const nbase::Unpack &up)
    {
        channel_id_ = up.pop_uint64();
        peer_       = up.pop_varstr();
        timetag_    = up.pop_uint64();
    }
    YX_RESPONSE_ONLY();
};


struct CBNetcallHangupNotifyParam : IAsynCallbackParam
{
    uint64_t channel_id_;
    UTF8String peer_;
    uint64_t timetag_;
};


//控制
struct NetCallControlReqeust : nbase::Marshallable
{
    uint64_t channel_id_;
    uint8_t control_;
    void marshal(nbase::Pack &p) const
    {
        p.push_uint64(channel_id_);
        p.push_uint8(control_);
    }
    YX_REQUEST_ONLY();
};

struct NetCallControlResponse : nbase::Marshallable
{
    UTF8String peer_;
    uint8_t control_;
    uint64_t channel_id_;

    void unmarshal(const nbase::Unpack &up)
    {
        peer_       = up.pop_varstr();
        control_    = up.pop_uint8();
        channel_id_ = up.pop_uint64();
    }
    YX_RESPONSE_ONLY();
};

struct CBNetCallControlParam : IAsynCallbackParam
{
    UTF8String peer_;
    uint8_t control_;
    uint64_t channel_id_;
};

//通知
struct CBNetCallRcvNotifyParam : IAsynCallbackParam
{
    std::vector<Property> netcalls_;
};

//被叫应答多端同步
struct NetCallOtherAckResponse : nbase::Marshallable
{
    uint64_t timetag_;
    uint64_t channel_id_;
    uint8_t call_type_;
    bool accepted_;
    uint8_t client_type_;
    
    void unmarshal(const nbase::Unpack &up)
    {
        timetag_    = up.pop_uint64();
        channel_id_ = up.pop_uint64();
        call_type_  = up.pop_uint8();
        accepted_   = up.pop_bool();
        client_type_ = up.pop_uint8();
    }
    YX_RESPONSE_ONLY();
};

struct CBNetCallOtherAckParam : IAsynCallbackParam
{
    uint64_t timetag_;
    uint64_t channel_id_;
    uint8_t call_type_;
    bool accepted_;
    uint8_t client_type_;
};


#pragma mark - INetcallService
class INetcallService : public IService
{
public:
    INetcallService() : IService(SVID_NIM_NETCALL) {}
public:
    virtual void    Invoke_InitCall(uint8_t call_type, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback) = 0;
    virtual void    Remote_InitCall(uint8_t call_type, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback) = 0;
    
    virtual void    Invoke_KeepCalling(uint8_t call_type, const std::list<UTF8String> callee_users, uint64_t channel_id, const IAsynCallback &callback) = 0;
    
    virtual void    Remote_KeepCalling(uint8_t call_type, const std::list<UTF8String> callee_users, uint64_t channel_id, const IAsynCallback &callback) = 0;

    
    virtual void    Invoke_CalleeAck(uint8_t call_type, const UTF8String caller, uint64_t channel_id, bool accept,  const IAsynCallback &callback) = 0;
    virtual void    Remote_CalleeAck(uint8_t call_type, const UTF8String caller, uint64_t channel_id, bool accept,  const IAsynCallback &callback) = 0;

    virtual void    Invoke_Hangup(uint64_t channel_id) = 0;
    virtual void    Remote_Hangup(uint64_t channel_id) = 0;

    virtual void    Invoke_Control(uint64_t channel_id, uint8_t control) = 0;
    virtual void    Remote_Control(uint64_t channel_id, uint8_t control) = 0;
    
    virtual void    RegisterBeCalledCallback(const IAsynCallback &callback) = 0;
    virtual void    RegisterRcvCalleeAckCallback(const IAsynCallback &callback) = 0;
    virtual void    RegisterRcvHangupCallback(const IAsynCallback &callback) = 0;
    virtual void    RegisterControlCallback(const IAsynCallback &callback) = 0;
    virtual void    Register_RecvNetCallsCallback(const IAsynCallback &callback) = 0;
    virtual void    Register_RecvOtherAckCallback(const IAsynCallback &callback) = 0;

};

}

#endif
