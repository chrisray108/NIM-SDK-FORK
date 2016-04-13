//
//  user_task.h
//  NIMLib
//
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef NIMLib_user_task_h
#define NIMLib_user_task_h

#include "user_protocol.h"
#include "biz/protocol/property.h"
#include "biz/core/eim_task.h"

namespace nimbiz
{

class UpdateTokenTask: public YixinTask
{
public:
    UpdateTokenTask(){}
public:
    virtual void Run()
    {
        IUserService *service = (IUserService *)GetServiceFromCore(SVID_NIM_USER);
        if (service)
        {
            service->Remote_UpdateToken();
        }
    }
};

class UpdateBadgeTask: public YixinTask
{
public:
    UpdateBadgeTask(bool background,uint32_t badge)
    :background_(background),badge_(badge) {}
public:
    virtual void Run()
    {
        IUserService *service = (IUserService *)GetServiceFromCore(SVID_NIM_USER);
        if (service)
        {
            service->Remote_UpdateAppInfo(background_,badge_);
        }
    }
    
private:
    bool background_;
    uint32_t badge_;
};


class UpdateApnsTask: public YixinTask
{
public:
    UpdateApnsTask(const Property &info,const IAsynCallback &callback)
    :info_(info),callback_(callback){}
public:
    virtual void Run()
    {
        IUserService *service = (IUserService *)GetServiceFromCore(SVID_NIM_USER);
        if (service)
        {
            service->Remote_UpdatePush(info_, callback_,GetTaskId());
        }
    }
private:
    Property info_;
    IAsynCallback callback_;
};

class UpdateOnlineStateTask: public YixinTask
{
public:
    UpdateOnlineStateTask(uint32_t state,const IAsynCallback &callback)
    :state_(state),callback_(callback){}
public:
    virtual void Run()
    {
        IUserService *service = (IUserService *)GetServiceFromCore(SVID_NIM_USER);
        if (service)
        {
            service->Remote_UpdateOnlineState(state_, callback_);
        }
    }
private:
    uint32_t state_;
    IAsynCallback callback_;
};


class  UpdateBlackListTask: public YixinTask
{
public:
    UpdateBlackListTask(const UTF8String &uid,bool black,const IAsynCallback &callback)
    :uid_(uid),black_(black),callback_(callback){}
public:
    virtual void Run()
    {
        IUserService *service = (IUserService *)GetServiceFromCore(SVID_NIM_USER);
        if (service)
        {
            service->Remote_UpdateBlack(uid_, black_, callback_, GetTaskId());
        }
    }
private:
    UTF8String uid_;
    bool black_;
    IAsynCallback callback_;
};


class  UpdateMuteTask: public YixinTask
{
public:
    UpdateMuteTask(const UTF8String &uid,bool mute,const IAsynCallback &callback)
    :uid_(uid),mute_(mute),callback_(callback){}
public:
    virtual void Run()
    {
        IUserService *service = (IUserService *)GetServiceFromCore(SVID_NIM_USER);
        if (service)
        {
            service->Remote_UpdateMute(uid_, mute_, callback_, GetTaskId());
        }
    }
private:
    UTF8String uid_;
    bool mute_;
    IAsynCallback callback_;
};


class  FetchUsersTask: public YixinTask
{
public:
    FetchUsersTask(std::list<UTF8String> &uids,const IAsynCallback &callback)
    :uids_(uids),callback_(callback){}
public:
    virtual void Run()
    {
        IUserService *service = (IUserService *)GetServiceFromCore(SVID_NIM_USER);
        if (service)
        {
            service->Remote_FetchUsers(uids_, callback_, GetTaskId());
        }
    }
private:
    std::list<UTF8String> uids_;
    IAsynCallback callback_;
};

    

class  UpdateMyUserInfoTask: public YixinTask
{
public:
    UpdateMyUserInfoTask(Property &info,const IAsynCallback &callback)
    :info_(info),callback_(callback){}
public:
    virtual void Run()
    {
        IUserService *service = (IUserService *)GetServiceFromCore(SVID_NIM_USER);
        if (service)
        {
            service->Remote_UpdateMyInfo(info_, callback_, GetTaskId());
        }
    }
private:
    Property info_;
    IAsynCallback callback_;
};
    
}


#endif
