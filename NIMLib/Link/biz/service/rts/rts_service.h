//
//  rts_service.h
//  NIMLib
//
//  Created by fenric on 15/7/25.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef __NIMLib__rts_service__
#define __NIMLib__rts_service__
#include "rts_protocol.h"

namespace nimbiz
{

class RtsService : public IRtsService
{
public:
    RtsService() {}
    
    virtual void Release() {delete this;}
    
    virtual bool OnLoad() { return true; }
    // 卸载服务后
    virtual void OnUnLoad() {}
    
    // 收到网络包的处理函数
    virtual uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up);
    
    virtual bool OnWaitablePacket(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);
    
//主叫创建通道
public:
    virtual void    Invoke_RtsNewTun(std::list<UTF8String> services, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback);
    virtual void    Remote_RtsNewTun(std::list<UTF8String> services, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback);
private:
    virtual void    OnRtsNewTunResponse(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback);

//主叫持续呼叫离线用户
public:
    virtual void    Invoke_RtsKeepNotify(const std::list<UTF8String> callee_users, uint64_t channel_id, const UTF8String &uuid, const IAsynCallback &callback);
    
    virtual void    Remote_RtsKeepNotify(const std::list<UTF8String> callee_users, uint64_t channel_id, const UTF8String &uuid, const IAsynCallback &callback);
private:
    virtual void    OnRTSKeepNotifyResponse(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback);


//被叫收到创建通道请求
public:
    virtual void    RegisterRtsTunReceivedCallback(const IAsynCallback &callback) {rts_tun_received_callback_ = callback;}
private:
    virtual void OnRtsTunReceivedNotify(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   rts_tun_received_callback_;
    
//被叫响应请求
public:
    virtual void    Invoke_RtsResponseTun(uint64_t channel_id, bool accept,  const IAsynCallback &callback);
    virtual void    Remote_RtsResponseTun(uint64_t channel_id, bool accept,  const IAsynCallback &callback);
private:
    virtual void    OnRtsResonseTunResponse(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &cb);

//主叫收到被叫响应
public:
    virtual void    RegisterRtsTunResponsedCallback(const IAsynCallback &callback) {tun_responsed_callback_ = callback;};
private:
    virtual void    OnRTSTunResponsedNotify(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   tun_responsed_callback_;

//请求已被其他在线端响应
public:
    virtual void    RegisterRtsOtherResponsedCallback(const IAsynCallback &callback) {rts_other_responsed_callback_ = callback;};
private:
    virtual void    OnRtsOtherResponsedNotify(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   rts_other_responsed_callback_;
    
//结束实时会话
public:
    virtual void    Invoke_RtsCloseTun(uint64_t channel_id);
    virtual void    Remote_RtsCloseTun(uint64_t channel_id);

//实时会话结束通知
public:
    virtual void    RegisterRtsTunClosedCallback(const IAsynCallback &callback) {rts_tun_closed_callback_ = callback;};
private:
    virtual void    OnRtsTunClosedNotify(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   rts_tun_closed_callback_;

//控制协议
public:
    virtual void    Invoke_RtsControl(uint64_t channel_id, UTF8String control);
    virtual void    Remote_RtsControl(uint64_t channel_id, UTF8String control);

//控制协议通知
public:
    virtual void    RegisterRtsControlNotifyCallback(const IAsynCallback &callback) {rts_control_callback_ = callback;};
private:
    virtual void    OnRtsControlNotify(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   rts_control_callback_;

//会话汇总数据
public:
    virtual void    RegisterRtsTunSummaryCallback(const IAsynCallback &callback) {rts_tun_summary_callback_ = callback;};
private:
    virtual void    OnRtsTunSummaryNotify(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   rts_tun_summary_callback_;
    
};
    
}
#endif
