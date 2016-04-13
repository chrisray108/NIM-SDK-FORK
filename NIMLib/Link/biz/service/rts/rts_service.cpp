//
//  rts_service.cpp
//  NIMLib
//
//  Created by fenric on 15/7/25.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#include "rts_service.h"
#include "rts_task.h"
#include "session_protocol.h"

namespace nimbiz
{

uint32_t    RtsService::OnPacket(LinkFrame &lf, const nbase::Unpack &up)
{
    uint32_t result = NIMOnPacketSuccess;
    switch (lf.command_id_) {
        case CID_RTS_TUN_RECEIVED:
            OnRtsTunReceivedNotify(lf, up);
            break;
        case CID_RTS_TUN_RESPONSED:
            OnRTSTunResponsedNotify(lf, up);
            break;
        case CID_RTS_TUN_CLOSED:
            OnRtsTunClosedNotify(lf, up);
            break;
        case CID_RTS_CTRL_NOTIFY:
            OnRtsControlNotify(lf, up);
            break;
        case CID_RTS_TUN_SUMMARY:
            OnRtsTunSummaryNotify(lf, up);
            break;
        case CID_RTS_OTHER_RESPONSED:
            OnRtsOtherResponsedNotify(lf, up);
            break;
        default:
            result = NIMOnPacketCommandNotSupport;
            break;
    }
    return result;
}

bool    RtsService::OnWaitablePacket(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    bool handled = true;
    switch (lf.command_id_) {
        case CID_RTS_NEW_TUN:
            OnRtsNewTunResponse(lf, up, callback);
            break;
        case CID_RTS_KEEP_NOTIFY:
            OnRTSKeepNotifyResponse(lf, up, callback);
            break;
        case CID_RTS_RESPONSE_TUN:
            OnRtsResonseTunResponse(lf, up, callback);
            break;
        default:
            handled = false;
            break;
    }
    
    
    return handled;
}


#pragma mark - 主叫创建通道
void    RtsService::Invoke_RtsNewTun(std::list<UTF8String> services, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback)
{
    IYixinCore_Get()->PostLoginContextTask(new RtsNewTunTask(services, callee_users, uuid, notify, callback));
}


void    RtsService::Remote_RtsNewTun(std::list<UTF8String> services, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback)
{
    IYixinCore *core = IYixinCore_Get();

    LinkFrame lf(SVID_NIM_RTS, CID_RTS_NEW_TUN);

    CBRtsNewTunParam param;
    param.services_ = services;
    param.callee_users_ = callee_users;
    param.uuid = uuid;
    CoreCallback cb;
    cb.any_ = param;
    cb.callback_ = callback;
    
    RtsNewTunReqeust req;
    req.services_ = services;
    req.callee_users_ = callee_users;
    req.notify_ = notify;
    
    core->SendWaitablePacket(lf, req, cb);
}

void    RtsService::OnRtsNewTunResponse(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &cb)
{
    CBRtsNewTunParam param = nimboost::any_cast<CBRtsNewTunParam>(cb.any_);
    param.code_ = lf.error_;
    if (param.code_ == NIMResSuccess) {
        param.unmarshal(up);
    }
    
    if (!cb.callback_.is_null())
    {
        cb.callback_.Run(&param);
    }
}

#pragma mark - 主叫持续呼叫离线用户
void    RtsService::Invoke_RtsKeepNotify(const std::list<UTF8String> callee_users, uint64_t channel_id, const UTF8String &uuid, const IAsynCallback &callback)
{
    IYixinCore_Get()->PostLoginContextTask(new RtsKeepNotifyTask(callee_users, channel_id, uuid, callback));
}

void    RtsService::Remote_RtsKeepNotify(const std::list<UTF8String> callee_users, uint64_t channel_id, const UTF8String &uuid, const IAsynCallback &callback)
{
    IYixinCore *core = IYixinCore_Get();
    
    LinkFrame lf(SVID_NIM_RTS, CID_RTS_KEEP_NOTIFY);
    
    CoreCallback cb;
    cb.callback_ = callback;
    
    CBRtsKeepNotifyParam param;
    param.uuid = uuid;
    cb.any_ = param;
    
    RtsKeepNotifyReqeust req;
    req.callee_users_ = callee_users;
    req.channel_id_ = channel_id;
    
    core->SendWaitablePacket(lf, req, cb);
}

void    RtsService::OnRTSKeepNotifyResponse(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &cb)
{
    if (lf.error_ == NIMResSuccess) {
        CBRtsKeepNotifyParam param = nimboost::any_cast<CBRtsKeepNotifyParam>(cb.any_);
        param.unmarshal(up);
        if (!cb.callback_.is_null()) {
            cb.callback_.Run(&param);
        }
    }
}

#pragma mark - 被叫收到创建通道请求
void    RtsService::OnRtsTunReceivedNotify(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        CBRtsTunReceivedParam param;
        param.unmarshal(up);
        if (!rts_tun_received_callback_.is_null())
        {
            rts_tun_received_callback_.Run(&param);
        }
    }
}

#pragma mark - 被叫响应请求
void    RtsService::Invoke_RtsResponseTun(uint64_t channel_id, bool accept,  const IAsynCallback &callback)
{
    IYixinCore_Get()->PostLoginContextTask(new RtsResponseTunTask(channel_id, accept, callback));

}
void    RtsService::Remote_RtsResponseTun(uint64_t channel_id, bool accept,  const IAsynCallback &callback)
{
    IYixinCore *core = IYixinCore_Get();
    
    LinkFrame lf(SVID_NIM_RTS, CID_RTS_RESPONSE_TUN);
    
    CBRtsResponseTunParam param;
    param.channel_id_ = channel_id;
    param.accept_ = accept;
    
    CoreCallback cb;
    cb.callback_ = callback;
    cb.any_ = param;

    core->SendWaitablePacket(lf, param, cb);
}

void    RtsService::OnRtsResonseTunResponse(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &cb)
{
    CBRtsResponseTunParam param = nimboost::any_cast<CBRtsResponseTunParam>(cb.any_);
    param.code_ = lf.error_;
    if (!cb.callback_.is_null()) {
        cb.callback_.Run(&param);
    }
}

#pragma mark - 主叫收到被叫响应
void RtsService::OnRTSTunResponsedNotify(LinkFrame &lf, const nbase::Unpack &up)
{
    CBRtsTunResponsedNotifyParam param;
    param.code_ = lf.error_;
    if (lf.error_ == NIMResSuccess)
    {
        param.unmarshal(up);
    }
    if (!tun_responsed_callback_.is_null())
    {
        tun_responsed_callback_.Run(&param);
    }
}

#pragma mark - 请求已被其他在线端响应
void RtsService::OnRtsOtherResponsedNotify(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        if (!rts_other_responsed_callback_.is_null())
        {
            CBRtsOtherResponsedNotifyParam param;
            up >> param;
            rts_other_responsed_callback_.Run(&param);
        }
    }
}

#pragma mark - 结束实时会话
void    RtsService::Invoke_RtsCloseTun(uint64_t channel_id)
{
    IYixinCore_Get()->PostLoginContextTask(new RtsCloseTunTask(channel_id));
}
void    RtsService::Remote_RtsCloseTun(uint64_t channel_id)
{
    IYixinCore *core = IYixinCore_Get();
    
    LinkFrame lf(SVID_NIM_RTS, CID_RTS_CLOSE_TUN);
    
    RtsCloseTunReqeust req;
    req.channel_id_ = channel_id;
    core->SendPacket(lf, req);
}

#pragma mark - 实时会话结束通知
void RtsService::OnRtsTunClosedNotify(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        CBRtsTunClosedNotifyParam param;
        param.unmarshal(up);
        if (!rts_tun_closed_callback_.is_null())
        {
            rts_tun_closed_callback_.Run(&param);
        }
    }
}

#pragma mark - 控制协议
void    RtsService::Invoke_RtsControl(uint64_t channel_id, UTF8String control)
{
    IYixinCore_Get()->PostLoginContextTask(new RtsControlTask(channel_id, control));
}
void    RtsService::Remote_RtsControl(uint64_t channel_id, UTF8String control)
{
    IYixinCore *core = IYixinCore_Get();
    
    LinkFrame lf(SVID_NIM_RTS, CID_RTS_CTRL);
    
    RtsControlReqeust req;
    req.channel_id_ = channel_id;
    req.control_ = control;
    
    core->SendPacket(lf, req);
}

#pragma mark - 控制协议通知
void    RtsService::OnRtsControlNotify(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        CBRtsControlNotifyParam param;
        param.unmarshal(up);
        if (!rts_control_callback_.is_null())
        {
            rts_control_callback_.Run(&param);
        }
    }
}

#pragma mark - 会话汇总数据
void RtsService::OnRtsTunSummaryNotify(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        Property info;
        up >> info;
        if (lf.msg_id_) {
            info.put_uint64(NIMSessionTagServerID, lf.msg_id_);
        }
        if (!rts_tun_summary_callback_.is_null())
        {
            CBRtsTunSummaryNotifyParam param;
            param.summary = info;
            rts_tun_summary_callback_.Run(&param);
        }
    }
}
    
}
