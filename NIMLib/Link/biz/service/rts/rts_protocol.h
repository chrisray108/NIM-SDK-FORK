//
//  rts_protocol.h
//  NIMLib
//
//  Created by fenric on 15/7/25.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_rts_protocol_h
#define NIMLib_rts_protocol_h

#include "biz/core/service.h"
#include "biz/protocol/property.h"
#include "biz/protocol/response_code.h"
#include "biz/core/yixin_core.h"

namespace nimbiz
{

enum
{
    CID_RTS_NEW_TUN           = 1,    //主叫创建通道
    CID_RTS_KEEP_NOTIFY       = 2,    //主叫持续呼叫离线用户
    CID_RTS_TUN_RECEIVED      = 3,    //被叫收到创建通道请求
    CID_RTS_RESPONSE_TUN      = 4,    //被叫响应请求
    CID_RTS_TUN_RESPONSED     = 5,    //主叫收到被叫响应
    CID_RTS_OTHER_RESPONSED   = 6,    //请求已被其他在线端响应
    CID_RTS_INVITE_OTHERS     = 7,    //邀请其他人加入
    CID_RTS_CLOSE_TUN         = 8,    //结束实时会话
    CID_RTS_TUN_CLOSED        = 9,    //实时会话结束通知
    CID_RTS_CTRL              = 10,   //控制协议
    CID_RTS_CTRL_NOTIFY       = 11,   //控制协议通知
    CID_RTS_TUN_SUMMARY       = 12,   //会话汇总数据
};

enum NIMRtsTunInfoTag
{
    NIMRtsTunInfoTagChannelId   = 0, //uint64
    NIMRtsTunInfoTagTurnAddrs   = 1, //string
    NIMRtsTunInfoTagProxyAddrs  = 2, //string
    NIMRtsTunInfoTagStunAddrs   = 3, //string
    NIMRtsTunInfoTagServiceType = 4, //string....
};

enum NIMRtsServiceType
{
    NIMRtsServiceTypeAudio = 1,
    NIMRtsServiceTypeTcp   = 2,
    NIMRtsServiceTypeUdp   = 3,
};
    
enum NIMRtsNotifyOptionTag
{
    NIMRtsNotifyOptionTagApnsEnable     =   1,  //int, 是否需要推送,0:不需要,>0:需要,默认1
    NIMRtsNotifyOptionTagApnsCountBadge =   2,  //int, 是否需要角标计数,0:不需要,>0:需要,默认1
    NIMRtsNotifyOptionTagApnsWithNick   =   3,  //int, 是否需要推送昵称,0:不需要,>0:需要,默认1
    NIMRtsNotifyOptionTagApnsContent    =   4,  //String, 推送内容
    NIMRtsNotifyOptionTagNotifyAttach   =   5,  //String, 自定义通知数据
    NIMRtsNotifyOptionTagApnsPayload    =   6,  //String, JSON格式,推送payload,推送声音直接在这个payload中封装
    NIMRtsNotifyOptionTagApnsSound      =   7,  //String, 推送声音
};


#pragma mark - 主叫创建通道
struct RtsNewTunReqeust : nbase::Marshallable
{
    std::list<UTF8String> services_;
    std::list<UTF8String> callee_users_;
    Property notify_;
    
    void marshal(nbase::Pack &p) const
    {
        p.push_len((uint32_t)services_.size());
        for (auto it = services_.begin(); it!= services_.end(); it++)
        {
            p.push_varstr(*it);
        }
        
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

struct RtsNewTunResponse : nbase::Marshallable
{
    uint64_t timetag_;
    uint64_t my_uid_;
    uint64_t channel_id_;
    std::vector<Property> services_info_;
    std::list<UTF8String> keep_calling_users_;
    std::map<uint64_t, UTF8String> users_info_;
    bool enable_p2p_;
    UTF8String call_config_;

    void unmarshal(const nbase::Unpack &up)
    {
        timetag_    = up.pop_uint64();
        my_uid_     = up.pop_uint64();
        channel_id_ = up.pop_uint64();
        
        uint32_t size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            Property service_info;
            up >> service_info;
            services_info_.push_back(service_info);
        }
        
        size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String user;
            up >> user;
            keep_calling_users_.push_back(user);
        }
        size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String account = up.pop_varstr();
            uint64_t uid = up.pop_uint64();
            users_info_.insert(std::pair<uint64_t, UTF8String>(uid, account));
        }
        enable_p2p_ = up.pop_bool();
        call_config_ = up.pop_varstr();

    }
    YX_RESPONSE_ONLY();
};

struct CBRtsNewTunParam : IAsynCallbackParam, RtsNewTunResponse
{
    std::list<UTF8String> services_;
    std::list<UTF8String> callee_users_;
    UTF8String uuid;
    
};

#pragma mark - 主叫持续呼叫离线用户
struct RtsKeepNotifyReqeust : nbase::Marshallable
{
    std::list<UTF8String> callee_users_;
    uint64_t channel_id_;
    
    void marshal(nbase::Pack &p) const
    {
        p.push_len((uint32_t)callee_users_.size());
        for (auto it = callee_users_.begin(); it!= callee_users_.end(); it++)
        {
            p.push_varstr(*it);
        }
        p.push_uint64(channel_id_);
    }
    YX_REQUEST_ONLY();
};

struct RtsKeepNotifyResponse : nbase::Marshallable
{
    std::list<UTF8String> callee_users_;
    
    void unmarshal(const nbase::Unpack &up)
    {
        uint32_t size = up.pop_len();
        
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String user;
            up >> user;
            callee_users_.push_back(user);
        }
    }
    YX_RESPONSE_ONLY();
};

struct CBRtsKeepNotifyParam : IAsynCallbackParam, RtsKeepNotifyResponse
{
    UTF8String uuid;
};


#pragma mark - 被叫收到创建通道请求
struct RtsTunReceivedNotify : nbase::Marshallable
{
    uint64_t timetag_;
    UTF8String caller_;
    uint64_t channel_id_;
    std::vector<Property> services_info_;
    std::map<uint64_t, UTF8String> users_info_;
    bool enable_p2p_;
    UTF8String extend_message_;
    uint64_t my_uid_;
    UTF8String call_config_;
    Property notify_;

    void unmarshal(const nbase::Unpack &up)
    {
        timetag_    = up.pop_uint64();
        caller_     = up.pop_varstr();
        channel_id_ = up.pop_uint64();
        
        uint32_t size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            Property service_info;
            up >> service_info;
            services_info_.push_back(service_info);
        }
        
        size = up.pop_len();
        for (uint32_t i = 0; i < size; i ++)
        {
            UTF8String account = up.pop_varstr();
            uint64_t uid = up.pop_uint64();
            users_info_.insert(std::pair<uint64_t, UTF8String>(uid, account));
        }
        enable_p2p_ = up.pop_bool();
        extend_message_ = up.pop_varstr();
        
        my_uid_     = up.pop_uint64();
        call_config_ = up.pop_varstr();
        
        if (up.size()) {
            up >> notify_;
        }
    }
    YX_RESPONSE_ONLY();
};

struct CBRtsTunReceivedParam : IAsynCallbackParam, RtsTunReceivedNotify {};



#pragma mark - 被叫响应请求
struct RtsResponseTunReqeust : nbase::Marshallable
{
    uint64_t channel_id_;
    bool accept_;
    void marshal(nbase::Pack &p) const
    {
        p.push_uint64(channel_id_);
        p.push_bool(accept_);
    }
    YX_REQUEST_ONLY();
};

struct CBRtsResponseTunParam : IAsynCallbackParam, RtsResponseTunReqeust
{
    
};


#pragma mark - 主叫收到被叫响应
struct RtsTunResponsedNotify : nbase::Marshallable
{
    uint64_t channel_id_;
    UTF8String callee_;
    bool accepted_;
    void unmarshal(const nbase::Unpack &up)
    {
        channel_id_ = up.pop_uint64();
        callee_     = up.pop_varstr();
        accepted_   = up.pop_bool();
    }
    YX_RESPONSE_ONLY();
};


struct CBRtsTunResponsedNotifyParam : IAsynCallbackParam, RtsTunResponsedNotify
{
};

#pragma mark - 请求已被其他在线端响应
struct RtsOtherResponsedNotify : nbase::Marshallable
{
    uint64_t timetag_;
    uint64_t channel_id_;
    bool accepted_;
    Property client_info_;
    
    void unmarshal(const nbase::Unpack &up)
    {
        timetag_    = up.pop_uint64();
        channel_id_ = up.pop_uint64();
        accepted_   = up.pop_bool();
        up >> client_info_;
    }
    YX_RESPONSE_ONLY();
};

struct CBRtsOtherResponsedNotifyParam : IAsynCallbackParam, RtsOtherResponsedNotify{};

#pragma mark - 结束实时会话
struct RtsCloseTunReqeust : nbase::Marshallable
{
    uint64_t channel_id_;
    void marshal(nbase::Pack &p) const
    {
        p.push_uint64(channel_id_);
    }
    YX_REQUEST_ONLY();
};


#pragma mark - 实时会话结束通知
struct RtsTunClosedNotify : nbase::Marshallable
{
    uint64_t timetag_;
    uint64_t channel_id_;
    UTF8String peer_;
    
    void unmarshal(const nbase::Unpack &up)
    {
        timetag_    = up.pop_uint64();
        channel_id_ = up.pop_uint64();
        peer_       = up.pop_varstr();
    }
    YX_RESPONSE_ONLY();
};


struct CBRtsTunClosedNotifyParam : IAsynCallbackParam, RtsTunClosedNotify{};


#pragma mark - 控制协议
struct RtsControlReqeust : nbase::Marshallable
{
    uint64_t channel_id_;
    UTF8String control_;
    void marshal(nbase::Pack &p) const
    {
        p.push_uint64(channel_id_);
        p.push_uint8(0); //这个客户端并没用上
        p.push_varstr(control_);
    }
    YX_REQUEST_ONLY();
};

#pragma mark - 控制协议通知
struct RtsControlNotify : nbase::Marshallable
{
    UTF8String peer_;
    UTF8String control_;
    uint64_t channel_id_;

    void unmarshal(const nbase::Unpack &up)
    {
        peer_       = up.pop_varstr();
        up.pop_uint8();//这个客户端并没用上
        control_    = up.pop_varstr();
        channel_id_ = up.pop_uint64();
    }
    YX_RESPONSE_ONLY();
};

struct CBRtsControlNotifyParam : IAsynCallbackParam, RtsControlNotify {};

#pragma mark - 会话汇总数据
struct CBRtsTunSummaryNotifyParam : IAsynCallbackParam
{
    Property summary;
};



#pragma mark - IRtsService
class IRtsService : public IService
{
public:
    IRtsService() : IService(SVID_NIM_RTS) {}
public:
    virtual void    Invoke_RtsNewTun(std::list<UTF8String> services, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback) = 0;
    virtual void    Remote_RtsNewTun(std::list<UTF8String> services, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback) = 0;
    
    virtual void    Invoke_RtsKeepNotify(const std::list<UTF8String> callee_users, uint64_t channel_id, const UTF8String &uuid, const IAsynCallback &callback) = 0;
    virtual void    Remote_RtsKeepNotify(const std::list<UTF8String> callee_users, uint64_t channel_id, const UTF8String &uuid, const IAsynCallback &callback) = 0;
    
    virtual void    Invoke_RtsResponseTun(uint64_t channel_id, bool accept,  const IAsynCallback &callback) = 0;
    virtual void    Remote_RtsResponseTun(uint64_t channel_id, bool accept,  const IAsynCallback &callback) = 0;

    virtual void    Invoke_RtsCloseTun(uint64_t channel_id) = 0;
    virtual void    Remote_RtsCloseTun(uint64_t channel_id) = 0;

    virtual void    Invoke_RtsControl(uint64_t channel_id, UTF8String control) = 0;
    virtual void    Remote_RtsControl(uint64_t channel_id, UTF8String control) = 0;
    
    virtual void    RegisterRtsTunReceivedCallback(const IAsynCallback &callback) = 0;
    virtual void    RegisterRtsTunResponsedCallback(const IAsynCallback &callback) = 0;
    virtual void    RegisterRtsTunClosedCallback(const IAsynCallback &callback) = 0;
    virtual void    RegisterRtsControlNotifyCallback(const IAsynCallback &callback) = 0;
    virtual void    RegisterRtsTunSummaryCallback(const IAsynCallback &callback) = 0;
    virtual void    RegisterRtsOtherResponsedCallback(const IAsynCallback &callback) = 0;

};

    
}

#endif
