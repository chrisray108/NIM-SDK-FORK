//
//  auth_service.cpp
//  YixinCall
//
//  Created by amao on 10/8/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#include "auth_service.h"
#include "auth_task.h"
#include "util/ios_types.h"
#include "util/ios_util.h"
#include "biz/service/sync/sync_protocol.h"

namespace nimbiz
{

#pragma mark - Packet
struct FetchCodeRequest : nbase::Marshallable
{
    UTF8String number_;
    Property tags_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr(number_);
        p << tags_;
    }
    YX_REQUEST_ONLY();
};


#pragma mark - Service
AuthService::AuthService()
:ip_changed_(true),  //Ip默认都是改变的
device_changed_(false)
{
    
}

void    AuthService::Invoke_Connect()
{
    IYixinCore_Get()->PostTask(new ConnectLinkTask(connect_callback_));
}

void    AuthService::Notify_Connect(bool connected)
{
    CBConnectStepParam param;
    param.step_ = NIMConnectStepLinked;
    param.code_ = connected ? NIMResSuccess : NIMResConnectionError;
    if (!connect_callback_.is_null())
    {
        connect_callback_.Run(&param);
    }
}


#pragma mark - 收发包
uint32_t    AuthService::OnPacket(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ != NIMResSuccess)
    {
        DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__,
               "Warning: Auth On Packet Error %d %d", lf.command_id_,lf.error_);
    }
    uint32_t error = NIMOnPacketSuccess;
    switch (lf.command_id_)
    {
        case CID_KICK_SAME_GENERIC:
            OnPacketKickOut(lf, up);
            break;
        case CID_MULTI_SPOT_LOGIN:
            OnPacketMultiLogin(lf, up);
            break;
        default:
            error = NIMOnPacketCommandNotSupport;
            break;
    }
    return error;
}

bool    AuthService::OnWaitablePacket(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    bool    handled = true;
    switch (lf.command_id_)
    {
        case CID_LOGIN:
            OnLogin(lf,up,callback);
            break;
        case CID_LOGOUT:
            OnLogout(lf, up, callback);
            break;
        case CID_KICK_BY_SELF:
            OnWaitPacketKickOther(lf, up, callback);
            break;
        default:
            handled = false;
            break;
    }
    return handled;
}



#pragma mark - 登录
struct LoginCBAttachedParam
{
    UTF8String uid_;
    int32_t task_id_;
};

int32_t    AuthService::Invoke_Login(const Property &param,const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostTask(new LoginTask(param,callback));
}


void    AuthService::Remote_Login(const Property &param,const IAsynCallback &callback,int32_t task_id)
{
    LinkFrame lf(SVID_NIM_AUTH,CID_LOGIN);

    Property login_request = param;
    
    CoreCallback cb;
    cb.callback_ = callback;
    
    LoginCBAttachedParam cb_param;
    cb_param.task_id_ = task_id;
    cb_param.uid_ =  param.get_string(NIMAuthTagAppAccount);
    cb.any_ = cb_param;
    
    int32_t timeout = nimbiz::GetLoginTimeout();
    DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"login app link timeout %d",timeout);
    IYixinCore_Get()->SendWaitablePacket(lf, login_request, cb,timeout);
}

void    AuthService::OnLogin(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    LoginCBAttachedParam cb_param = nimboost::any_cast<LoginCBAttachedParam>(callback.any_);
    
    CBLoginParam param;
    param.task_id_ = cb_param.task_id_;
    
    CBMultiLoginParam mulitParam;
    mulitParam.type_ = nimbiz::GetMultiLoginInitType();
    
    param.code_ = lf.error_;
    if (param.code_ == NIMResSuccess)
    {
        //解析登陆状态
        IYixinCore_Get()->SetLogin(true);
        up >> param.info_;
        
        //uid
        UTF8String uid = cb_param.uid_;
        IYixinCore_Get()->SetUid(uid);

        //ip
        UTF8String ip = param.info_.get_string(NIMAuthTagIp);
        ip_changed_ = ip != current_ip_;
        current_ip_ = ip;
        
        //设备Id
        UTF8String local_device_id = nimbiz::GetDeviceID();
        UTF8String remote_device_id = param.info_.get_string(NIMAuthTagLastDeviceID);
        device_changed_ = local_device_id != remote_device_id;
        
        //连接号
        UTF8String connectId = param.info_.get_string(NIMAuthTagConnectId);
        
        
        DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"\n\nlogin success %s\nip %s\nlocal device id %s\nremote device id %s\nconnect id %s\n",
               uid.c_str(),ip.c_str(),local_device_id.c_str(),remote_device_id.c_str(),connectId.c_str());
        
        IYixinCore_Get()->SetConId(connectId);
        
        //解析当前登录的其他端信息
        if (up.size())
        {
            mulitParam.clients_.unmarshal(up);
        }
    }
    
    if (!callback.callback_.is_null())
    {
        callback.callback_.Run(&param);
    }
    
    
    if (param.code_ == NIMResSuccess)
    {
        
        if (!multi_callback_.is_null())
        {
            multi_callback_.Run(&mulitParam);
        }
        
        ISyncService *sync = (ISyncService *)GetServiceFromCore(SVID_NIM_SYNC);
        if (sync)
        {
            DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"begin to sync");
            sync->Invoke_SyncAll();
        }
    }
}

#pragma mark - 登出
void AuthService::Invoke_Logout(const IAsynCallback &callback)
{
    IYixinCore_Get()->PostTask(new LogoutTask(callback));
}

void AuthService::Remote_Logout(const IAsynCallback &callback)
{
    LinkFrame lf(SVID_NIM_AUTH,CID_LOGOUT);
    nbase::Voidmable request;
    CoreCallback cb;
    cb.callback_ = callback;
    IYixinCore_Get()->SendWaitablePacket(lf, request, cb, 5);
}

void AuthService::OnLogout(const LinkFrame &lf, const nbase::Unpack &up,const CoreCallback &cb)
{
    if (lf.error_ != NIMResSuccess)
    {
        DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Warning: Send Logout Request Failed: %d",lf.error_);
    }
    if (!cb.callback_.is_null())
    {
        CBLogoutParam param;
        param.code_ = lf.error_;
        cb.callback_.Run(&param);
    }
}

#pragma mark - 踢人
int32_t    AuthService::Invoke_Kick(const UTF8String &device_id, const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostTask(new KickOtherClientTask(device_id,callback));
}


void    AuthService::Remote_Kick(const UTF8String &device_id, const IAsynCallback &callback,int32_t task_id)
{
    LinkFrame lf(SVID_NIM_AUTH,CID_KICK_BY_SELF);
    KickOtherClients req;
    req.device_ids_.push_back(device_id);
    
    CoreCallback cb;
    cb.callback_ = callback;
    cb.task_id_ = task_id;
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void    AuthService::OnWaitPacketKickOther(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    CBKickOtherParam param;
    param.code_ = lf.error_;
    param.task_id_ = callback.task_id_;
    
    if (lf.error_  == NIMResSuccess)
    {
        KickOtherClients response;
        response.unmarshal(up);
        param.clients_ = response.device_ids_;
    }
    
    if (!callback.callback_.is_null()) {
        callback.callback_.Run(&param);
    }
}




#pragma mark - 被踢
void    AuthService::OnPacketKickOut(LinkFrame &lf, const nbase::Unpack &p)
{
    if (lf.error_ != NIMResSuccess)
    {
        DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__,
               "Get Kicked But Error is %d",lf.error_);
        return;
    }
    
    UserKickOutResponse response;
    response.unmarshal(p);
    IYixinCore *core = IYixinCore_Get();
    
    int client_type = response.client_type;
    int reason = response.kickout_reason;
    
    core->SetKicked();
    
    DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Warning: Be Kicked, ClientType %d Reason %d ",client_type,reason);
    
    if (!kick_callback_.is_null())
    {
        CBKickoutParam param;
        param.reason_ = reason;
        param.client_type_ = client_type;
        kick_callback_.Run(&param);
    }
}

#pragma mark - 多端登录
void    AuthService::OnPacketMultiLogin(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        CBMultiLoginParam param;
        param.type_ = up.pop_uint8();
        param.clients_.unmarshal(up);
        
        if (!multi_callback_.is_null())
        {
            multi_callback_.Run(&param);
        }
    }
}
    
}
