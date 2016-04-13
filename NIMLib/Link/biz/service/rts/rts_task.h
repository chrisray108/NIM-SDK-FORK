//
//  rts_task.h
//  NIMLib
//
//  Created by fenric on 15/7/25.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_rts_task_h
#define NIMLib_rts_task_h

#include "rts_protocol.h"
#include "biz/protocol/property.h"
#include "biz/core/eim_task.h"

namespace nimbiz
{

class RtsNewTunTask: public YixinTask
{
public:
    RtsNewTunTask(std::list<UTF8String> services, const std::list<UTF8String> callee_users, const UTF8String &uuid, const Property notify, const IAsynCallback &callback)
    : services_(services), callee_users_(callee_users), uuid_(uuid), notify_(notify), callback_(callback) {}
public:
    virtual void Run()
    {
        IRtsService *service = (IRtsService *)GetServiceFromCore(SVID_NIM_RTS);
        if (service)
        {
            service->Remote_RtsNewTun(services_, callee_users_, uuid_, notify_,callback_);
        }
    }
    
private:
    std::list<UTF8String> services_;
    std::list<UTF8String> callee_users_;
    Property notify_;
    UTF8String uuid_;
    IAsynCallback callback_;
};

class RtsKeepNotifyTask: public YixinTask
{
public:
    RtsKeepNotifyTask(const std::list<UTF8String> &callee_users, uint64_t channel_id, const UTF8String &uuid, const IAsynCallback &callback): callee_users_(callee_users), channel_id_(channel_id), uuid_(uuid), callback_(callback){}
public:
    virtual void Run()
    {
        IRtsService *service = (IRtsService *)GetServiceFromCore(SVID_NIM_RTS);
        if (service)
        {
            service->Remote_RtsKeepNotify(callee_users_, channel_id_, uuid_, callback_);
        }
    }
    
private:
    std::list<UTF8String> callee_users_;
    uint64_t channel_id_;
    UTF8String uuid_;
    IAsynCallback callback_;
};

class RtsResponseTunTask: public YixinTask
{
public:
    RtsResponseTunTask(uint64_t channel_id, bool accept, const IAsynCallback &callback)
    : channel_id_(channel_id), accept_(accept), callback_(callback) {}
public:
    virtual void Run()
    {
        IRtsService *service = (IRtsService *)GetServiceFromCore(SVID_NIM_RTS);
        if (service)
        {
            service->Remote_RtsResponseTun(channel_id_, accept_, callback_);
        }
    }
    
private:
    uint64_t channel_id_;
    bool accept_;
    IAsynCallback callback_;
};

class RtsCloseTunTask: public YixinTask
{
public:
    RtsCloseTunTask(uint64_t channel_id)
    : channel_id_(channel_id) {}
public:
    virtual void Run()
    {
        IRtsService *service = (IRtsService *)GetServiceFromCore(SVID_NIM_RTS);
        if (service)
        {
            service->Remote_RtsCloseTun(channel_id_);
        }
    }
    
private:
    uint64_t channel_id_;
};

class RtsControlTask: public YixinTask
{
public:
    RtsControlTask(uint64_t channel_id, UTF8String &control)
    : channel_id_(channel_id), control_(control) {}
public:
    virtual void Run()
    {
        IRtsService *service = (IRtsService *)GetServiceFromCore(SVID_NIM_RTS);
        if (service)
        {
            service->Remote_RtsControl(channel_id_, control_);
        }
    }
    
private:
    uint64_t channel_id_;
    UTF8String control_;
};
}


#endif
