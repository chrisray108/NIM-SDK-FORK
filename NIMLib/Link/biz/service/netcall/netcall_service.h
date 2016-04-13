//
//  netcall_service.h
//  NIMLib
//
//  Created by fenric on 15/5/4.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef __NIMLib__netcall_service__
#define __NIMLib__netcall_service__
#include "netcall_protocol.h"

namespace nimbiz
{

class NetcallService : public INetcallService
{
public:
    NetcallService() {}
    
    virtual void Release() {delete this;}
    
    virtual bool OnLoad() { return true; }
    // 卸载服务后
    virtual void OnUnLoad() {}
    
    // 收到网络包的处理函数
    virtual uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up);
    
    virtual bool OnWaitablePacket(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);
    
//主叫发起通话
public:
    virtual void    Invoke_InitCall(uint8_t call_type, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback);
    virtual void    Remote_InitCall(uint8_t call_type, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback);
private:
    virtual void    OnInitCall(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback);

//被叫接到通话
public:
    virtual void    RegisterBeCalledCallback(const IAsynCallback &callback) {callee_be_called_callback_ = callback;}
private:
    virtual void OnBeCalled(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   callee_be_called_callback_;
    
//持续呼叫
public:
    virtual void    Invoke_KeepCalling(uint8_t call_type, const std::list<UTF8String> callee_users, uint64_t channel_id, const IAsynCallback &callback);
    
    virtual void    Remote_KeepCalling(uint8_t call_type, const std::list<UTF8String> callee_users, uint64_t channel_id, const IAsynCallback &callback);
private:
    virtual void    OnKeepCalling(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback);

    
//被叫响应呼叫
public:
    virtual void    Invoke_CalleeAck(uint8_t call_type, const UTF8String caller, uint64_t channel_id, bool accept,  const IAsynCallback &callback);
    virtual void    Remote_CalleeAck(uint8_t call_type, const UTF8String caller, uint64_t channel_id, bool accept,  const IAsynCallback &callback);
private:
    virtual void    OnCalleeAck(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &cb);

//主叫收到被叫响应
public:
    virtual void    RegisterRcvCalleeAckCallback(const IAsynCallback &callback) {rcv_callee_ack_callback_ = callback;};
private:
    virtual void    OnRcvCalleeAck(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   rcv_callee_ack_callback_;

//挂断电话
public:
    virtual void    Invoke_Hangup(uint64_t channel_id);
    virtual void    Remote_Hangup(uint64_t channel_id);

//收到挂断电话的通知
public:
    virtual void    RegisterRcvHangupCallback(const IAsynCallback &callback) {rcv_hangup_callback_ = callback;};
private:
    virtual void    OnHangup(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   rcv_hangup_callback_;

//通知
public:
    virtual void    Register_RecvNetCallsCallback(const IAsynCallback &callback) {recv_netcalls_callback_ = callback;};
private:
    virtual void    OnNotify(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   recv_netcalls_callback_;

//发送控制
public:
    virtual void    Invoke_Control(uint64_t channel_id, uint8_t control);
    virtual void    Remote_Control(uint64_t channel_id, uint8_t control);

//收到控制
public:
    virtual void    RegisterControlCallback(const IAsynCallback &callback) {control_callback_ = callback;};
private:
    virtual void    OnControl(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   control_callback_;
//被叫应答多端同步
public:
    virtual void    Register_RecvOtherAckCallback(const IAsynCallback &callback) {rcv_other_ack_callback_ = callback;};
private:
    virtual void    OnRcvOtherAckNotify(LinkFrame &lf, const nbase::Unpack &up);
    IAsynCallback   rcv_other_ack_callback_;
};
    
}
#endif
