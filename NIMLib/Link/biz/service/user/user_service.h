//
//  user_service.h
//  NIMLib
//
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef __NIMLib__user_service__
#define __NIMLib__user_service__

#include "user_protocol.h"
#include "biz/core/frequency_controller.h"

namespace nimbiz
{

class UserService : public IUserService
{
public:
    UserService() {}
    
    virtual void Release() {delete this;}
    
    virtual bool OnLoad();
    // 卸载服务后
    virtual void OnUnLoad();
    
    // 收到网络包的处理函数
    virtual uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up);
    
    virtual bool OnWaitablePacket(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);

public:
    virtual void    Invoke_UpdateToken();
    virtual void    Remote_UpdateToken();
    
    virtual void    Invoke_UpdateAppInfo(bool background,uint32_t badge);
    virtual void    Remote_UpdateAppInfo(bool background,uint32_t badge);
    
    virtual int32_t Invoke_UpdatePush(const Property &info,const IAsynCallback &callback);
    virtual void    Remote_UpdatePush(const Property &info,const IAsynCallback &callback,int32_t task_id);
    
    virtual void    Invoke_UpdateOnlineState(uint32_t state,const IAsynCallback &callback);
    virtual void    Remote_UpdateOnlineState(uint32_t state,const IAsynCallback &callback);
    
    virtual int32_t Invoke_UpdateBlack(const UTF8String &uid,bool black,const IAsynCallback &callback);
    virtual void    Remote_UpdateBlack(const UTF8String &uid,bool black,const IAsynCallback &callback,int32_t task_id);
    
    
    virtual int32_t Invoke_UpdateMute(const UTF8String &uid,bool mute,const IAsynCallback &callback);
    virtual void    Remote_UpdateMute(const UTF8String &uid,bool mute,const IAsynCallback &callback,int32_t task_id);
    
    
    virtual int32_t Invoke_FetchUsers(std::list<UTF8String> &uids,const IAsynCallback &callback);
    virtual void    Remote_FetchUsers(std::list<UTF8String> &uids,const IAsynCallback &callback,int32_t task_id);

    virtual int32_t Invoke_UpdateMyInfo(Property &info,const IAsynCallback &callback);
    virtual void    Remote_UpdateMyInfo(Property &info,const IAsynCallback &callback,int32_t task_id);

    
    virtual uint32_t    GetBlackList(std::list<UTF8String> &uids);
    virtual uint32_t    GetMuteList(std::list<UTF8String> &uids);
    virtual void        GetUserInfo(const UTF8String &uid,Property &property);
    virtual bool        IsUserInBlackList(const UTF8String &uid);
    virtual bool        IsUserMute(const UTF8String &uid);
    virtual void        CheckUserInfo(const Property &recv_msg);
    virtual void        SaveUserInfoFromServer(const Property &info);
    virtual bool        UserInfoExists(const UTF8String &uid);

private:
    void    OnWaitablePacketUpdateApns(LinkFrame &lf,
                                       const nbase::Unpack &up,
                                       const CoreCallback &callback);
    
    void    OnWaitablePacketUpdateOnlineState(LinkFrame &lf,
                                              const nbase::Unpack &up,
                                              const CoreCallback &callback);
    
    void    OnWaitablePacketUpdateBlack(LinkFrame &lf,
                                        const nbase::Unpack &up,
                                        const CoreCallback &callback);

    
    void    OnWaitablePacketUpdateMute(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);
    
    void    OnWaitablePacketFetchUsers(LinkFrame &lf,
                                       const nbase::Unpack &up,
                                       const CoreCallback &callback);
    
    void    OnWaitablePacketUpdateMyUserInfo(LinkFrame &lf,
                                       const nbase::Unpack &up,
                                       const CoreCallback &callback);
    
    void    OnPacketBlacklistSync(LinkFrame &lf, const nbase::Unpack &up);
    void    OnPacketMuteSync(LinkFrame &lf, const nbase::Unpack &up);
    void    OnPacketRelationSync(LinkFrame &lf, const nbase::Unpack &up);
    void    OnPacketMyUserInfoSync(LinkFrame &lf, const nbase::Unpack &up);
    void    OnPacketMyUserInfoUpdate(LinkFrame &lf, const nbase::Unpack &up);
private:
    FrequencyController msg_info_frequency_controller_;
    FrequencyController info_frequency_controller_;
};

}
#endif /* defined(__NIMLib__user_service__) */
