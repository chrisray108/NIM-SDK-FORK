//
//  netcall_service.cpp
//  NIMLib
//
//  Created by fenric on 15/5/4.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#include "netcall_service.h"
#include "netcall_task.h"
#include "session_protocol.h"

namespace nimbiz
{

uint32_t    NetcallService::OnPacket(LinkFrame &lf, const nbase::Unpack &up)
{
    uint32_t result = NIMOnPacketSuccess;
    switch (lf.command_id_) {
        case CID_NETCALL_NOTIFY_BECALLED:
            OnBeCalled(lf, up);
            break;
        case CID_NETCALL_NOTIFY_CALLEE_ACK:
            OnRcvCalleeAck(lf, up);
            break;
        case CID_NETCALL_HANGUP_NOTIFY:
            OnHangup(lf, up);
            break;
        case CID_NETCALL_NOTIFY_CTRL:
            OnControl(lf, up);
            break;
        case CID_NETCALL_NOTIFY:
            OnNotify(lf, up);
            break;
        case CID_NOTIFY_OL_ACK_SYNC:
            OnRcvOtherAckNotify(lf, up);
            break;
        default:
            result = NIMOnPacketCommandNotSupport;
            break;
    }
    return result;
}

bool    NetcallService::OnWaitablePacket(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    bool handled = true;
    switch (lf.command_id_) {
        case CID_NETCALL_INIT:
            OnInitCall(lf, up, callback);
            break;
        case CID_NETCALL_KEEP_CALLING:
            OnKeepCalling(lf, up, callback);
            break;
        case CID_NETCALL_CALLEE_ACK:
            OnCalleeAck(lf, up, callback);
            break;
        default:
            handled = false;
            break;
    }
    
    
    return handled;
}


#pragma mark - 主叫发起通话
void    NetcallService::Invoke_InitCall(uint8_t call_type, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback)
{
    IYixinCore_Get()->PostLoginContextTask(new InitCallTask(call_type, callee_users, uuid, notify, callback));
}


void    NetcallService::Remote_InitCall(uint8_t call_type, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback)
{
    IYixinCore *core = IYixinCore_Get();

    LinkFrame lf(SVID_NIM_NETCALL, CID_NETCALL_INIT);

    CBNetcallInitParam param;
    param.call_type_ = call_type;
    param.callee_users_ = callee_users;
    param.uuid = uuid;
    CoreCallback cb;
    cb.any_ = param;
    cb.callback_ = callback;
    
    NetCallInitReqeust req;
    req.call_type_ = call_type;
    req.callee_users_ = callee_users;
    req.notify_ = notify;
    
    core->SendWaitablePacket(lf, req, cb);
}

void    NetcallService::OnInitCall(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &cb)
{
    CBNetcallInitParam param = nimboost::any_cast<CBNetcallInitParam>(cb.any_);
    param.code_ = lf.error_;
    if (param.code_ == NIMResSuccess) {
        NetCallInitResponse response;
        response.unmarshal(up);
        param.timetag_     = response.timetag_;
        param.my_uid_      = response.my_uid_;
        param.channel_id_  = response.channel_id_;
        param.turn_addrs_  = response.turn_addrs_;
        param.sturn_addrs_ = response.sturn_addrs_;
        param.proxy_addrs_ = response.proxy_addrs_;
        param.keep_calling_users_ = response.keep_calling_users_;
        param.users_info_ = response.users_info_;
        param.call_config_ = response.call_config_;
    }
    
    if (!cb.callback_.is_null())
    {
        cb.callback_.Run(&param);
    }
}

#pragma mark - 被叫接到通话
void    NetcallService::OnBeCalled(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        NetCallBeCalledResponse response;
        response.unmarshal(up);
        CBNetcallBeCalledParam param;
        param.timetag_ = response.timetag_;
        param.call_type_ = response.call_type_;
        param.channel_id_ = response.channel_id_;
        param.caller_ = response.caller_;
        param.my_uid_ = response.my_uid_;
        param.turn_addrs_ = response.turn_addrs_;
        param.sturn_addrs_ = response.sturn_addrs_;
        param.proxy_addrs_ = response.proxy_addrs_;
        param.call_config_ = response.call_config_;
        param.extend_message_ = response.extend_message_;
                
        param.users_info_ = response.users_info_;
        if (!callee_be_called_callback_.is_null())
        {
            callee_be_called_callback_.Run(&param);
        }
    }
}

#pragma mark - 持续呼叫
void    NetcallService::Invoke_KeepCalling(uint8_t call_type, const std::list<UTF8String> callee_users, uint64_t channel_id, const IAsynCallback &callback)
{
    IYixinCore_Get()->PostLoginContextTask(new KeepCallingTask(call_type, callee_users, channel_id, callback));
}

void    NetcallService::Remote_KeepCalling(uint8_t call_type, const std::list<UTF8String> callee_users, uint64_t channel_id, const IAsynCallback &callback)
{
    IYixinCore *core = IYixinCore_Get();
    
    LinkFrame lf(SVID_NIM_NETCALL, CID_NETCALL_KEEP_CALLING);
    
    CoreCallback cb;
    cb.callback_ = callback;
    
    NetCallKeepCallingReqeust req;
    req.call_type_ = call_type;
    req.callee_users_ = callee_users;
    req.channel_id_ = channel_id;
    
    core->SendWaitablePacket(lf, req, cb);
}

void    NetcallService::OnKeepCalling(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &cb)
{
    if (lf.error_ == NIMResSuccess) {
        NetCallKeepCallingResponse response;
        response.unmarshal(up);
        CBNetcallKeepCallingParam param;
        param.keep_calling_users_ = response.callee_users_;
        if (!cb.callback_.is_null()) {
            cb.callback_.Run(&param);
        }
    }
}

#pragma mark - 被叫响应呼叫
void    NetcallService::Invoke_CalleeAck(uint8_t call_type, const UTF8String caller, uint64_t channel_id, bool accept, const IAsynCallback &callback)
{
    IYixinCore_Get()->PostLoginContextTask(new CalleeAckTask(call_type, caller, channel_id, accept, callback));

}
void    NetcallService::Remote_CalleeAck(uint8_t call_type, const UTF8String caller, uint64_t channel_id, bool accept, const IAsynCallback &callback)
{
    IYixinCore *core = IYixinCore_Get();
    
    LinkFrame lf(SVID_NIM_NETCALL, CID_NETCALL_CALLEE_ACK);
    
    NetCallCalleeAckReqeust req;
    req.caller_ = caller;
    req.channel_id_ = channel_id;
    req.call_type_ = call_type;
    req.accept_ = accept;

    CBNetcallCalleeAckParam param;
    param.channel_id_ = channel_id;
    param.accept_ = accept;
    
    CoreCallback cb;
    cb.callback_ = callback;
    cb.any_ = param;

    core->SendWaitablePacket(lf, req, cb);
}

void    NetcallService::OnCalleeAck(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &cb)
{
    CBNetcallCalleeAckParam param = nimboost::any_cast<CBNetcallCalleeAckParam>(cb.any_);
    param.code_ = lf.error_;
    if (!cb.callback_.is_null()) {
        cb.callback_.Run(&param);
    }
}


#pragma mark - 主叫收到被叫响应
void NetcallService::OnRcvCalleeAck(LinkFrame &lf, const nbase::Unpack &up)
{
    CBNetcallRcvCalledAckParam param;
    param.code_ = lf.error_;
    if (lf.error_ == NIMResSuccess)
    {
        NetCallRcvCalleeAckResponse response;
        response.unmarshal(up);
        param.callee_ = response.callee_;
        param.channel_id_ = response.channel_id_;
        param.accepted_ = response.accepted_;
    }
    if (!rcv_callee_ack_callback_.is_null())
    {
        rcv_callee_ack_callback_.Run(&param);
    }
}

#pragma mark - 挂断电话
void    NetcallService::Invoke_Hangup(uint64_t channel_id)
{
    IYixinCore_Get()->PostLoginContextTask(new HangupTask(channel_id));
}
void    NetcallService::Remote_Hangup(uint64_t channel_id)
{
    IYixinCore *core = IYixinCore_Get();
    
    LinkFrame lf(SVID_NIM_NETCALL, CID_NETCALL_HANGUP);
    
    NetCallHangupReqeust req;
    req.channel_id_ = channel_id;
    core->SendPacket(lf, req);
}

#pragma mark - 收到挂断通知
void NetcallService::OnHangup(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        NetCallHangupNotifyResponse response;
        response.unmarshal(up);
        CBNetcallHangupNotifyParam param;
        param.channel_id_ = response.channel_id_;
        param.peer_ = response.peer_;
        param.timetag_ = response.timetag_;
        if (!rcv_hangup_callback_.is_null())
        {
            rcv_hangup_callback_.Run(&param);
        }
    }
}

#pragma mark - 发送控制
void    NetcallService::Invoke_Control(uint64_t channel_id, uint8_t control)
{
    IYixinCore_Get()->PostLoginContextTask(new ControlTask(channel_id, control));
}
void    NetcallService::Remote_Control(uint64_t channel_id, uint8_t control)
{
    IYixinCore *core = IYixinCore_Get();
    
    LinkFrame lf(SVID_NIM_NETCALL, CID_NETCALL_CTRL);
    
    NetCallControlReqeust req;
    req.channel_id_ = channel_id;
    req.control_ = control;
    
    core->SendPacket(lf, req);
}

#pragma mark - 收到控制通知
void    NetcallService::OnControl(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        NetCallControlResponse response;
        response.unmarshal(up);
        CBNetCallControlParam param;
        param.peer_ = response.peer_;
        param.channel_id_ = response.channel_id_;
        param.control_ = response.control_;
        if (!control_callback_.is_null())
        {
            control_callback_.Run(&param);
        }
    }
}

#pragma mark - 通知
void NetcallService::OnNotify(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        Property msg;
        up >> msg;
        if (lf.msg_id_) {
            msg.put_uint64(NIMSessionTagServerID, lf.msg_id_);
        }
        if (!recv_netcalls_callback_.is_null())
        {
            CBNetCallRcvNotifyParam param;
            param.netcalls_.push_back(msg);
            recv_netcalls_callback_.Run(&param);
        }
    }
}


#pragma mark - 被叫应答多端同步
void NetcallService::OnRcvOtherAckNotify(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        NetCallOtherAckResponse response;
        up >> response;
        if (!rcv_other_ack_callback_.is_null())
        {
            CBNetCallOtherAckParam param;
            param.timetag_ = response.timetag_;
            param.channel_id_ = response.channel_id_;
            param.call_type_ = response.call_type_;
            param.accepted_ = response.accepted_;
            param.client_type_ = response.client_type_;
            rcv_other_ack_callback_.Run(&param);
        }
    }
}

}