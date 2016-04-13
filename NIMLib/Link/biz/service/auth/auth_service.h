//
//  auth_service.h
//  YixinCall
//
//  Created by amao on 10/8/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#ifndef __YixinCall__auth_service__
#define __YixinCall__auth_service__

#include "auth_protocol.h"

namespace nimbiz
{

struct UserKickOutResponse : nbase::Marshallable
{
    int     client_type;
    int     kickout_reason;
    
    void marshal(nbase::Pack &p) const
    {
        p.push_uint32(client_type);
        p.push_uint32(kickout_reason);
        
    }
    void unmarshal(const nbase::Unpack &up)
    {
        client_type = up.pop_uint32();
        kickout_reason = up.pop_uint32();
    }
};


struct KickOtherClients : nbase::Marshallable
{
    std::vector<UTF8String> device_ids_;
    
    void marshal(nbase::Pack &p) const
    {
        uint32_t len = (uint32_t)device_ids_.size();
        p.push_len(len);
        for (uint32_t i = 0; i < len; i++) {
            p.push_varstr(device_ids_[i]);
        }
        
    }
    void unmarshal(const nbase::Unpack &up)
    {
        uint32_t len = up.pop_len();
        for (uint32_t i = 0; i < len; i++) {
            device_ids_.push_back(up.pop_varstr());
        }
    }
};


class AuthService : public IAuthService
{
public:
    AuthService();
    
    virtual void Release() {delete this;}
    
    virtual bool OnLoad() { return true; }
    // 卸载服务后
    virtual void OnUnLoad() {}
    
    // 收到网络包的处理函数
    virtual uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up);
    
    virtual bool OnWaitablePacket(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);
    
public:
    virtual void Invoke_Connect();  //链接服务器 (登录前)
    virtual void Notify_Connect(bool connected);
    virtual void RegisterConnectCallback(const IAsynCallback &callback) {connect_callback_ = callback;}
    virtual void RegisterKickoutCallback(const IAsynCallback &callback) {kick_callback_ = callback;}
    virtual void RegisterMultipLoginCallback(const IAsynCallback &callback) {multi_callback_ = callback;}
    
    virtual int32_t Invoke_Login(const Property &param,const IAsynCallback &callback);
    virtual void    Remote_Login(const Property &param,const IAsynCallback &callback,int32_t task_id);
    
    virtual void Invoke_Logout(const IAsynCallback &callback);
    virtual void Remote_Logout(const IAsynCallback &callback);
    
    virtual int32_t Invoke_Kick(const UTF8String &device_id,const IAsynCallback &callback);
    virtual void Remote_Kick(const UTF8String &device_id,const IAsynCallback &callback,int32_t task_id);

    virtual bool IsIpChanged()  {return ip_changed_;}
    virtual bool IsDeviceChanged() {return device_changed_;}

private:
    
    //回包处理
    void    OnLogin(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback);
    void    OnLogout(const LinkFrame &lf, const nbase::Unpack &up,const CoreCallback &cb);
    
    void    OnPacketKickOut(LinkFrame &lf, const nbase::Unpack &up);
    void    OnPacketMultiLogin(LinkFrame &lf, const nbase::Unpack &up);
    void    OnWaitPacketKickOther(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback);

    
private:
    IAsynCallback   connect_callback_;
    IAsynCallback   kick_callback_;
    IAsynCallback   multi_callback_;
    bool            device_changed_;
    bool            ip_changed_;
    UTF8String      current_ip_;
};

}
#endif
