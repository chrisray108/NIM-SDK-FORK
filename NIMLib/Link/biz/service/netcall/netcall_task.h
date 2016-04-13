//
//  netcall_task.h
//  NIMLib
//
//  Created by fenric on 15/5/4.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_netcall_task_h
#define NIMLib_netcall_task_h

#include "netcall_protocol.h"
#include "biz/protocol/property.h"
#include "biz/core/eim_task.h"

namespace nimbiz
{

class InitCallTask: public YixinTask
{
public:
    InitCallTask(uint8_t call_type, const std::list<UTF8String> &callee_users, const UTF8String &uuid, const Property &notify, const IAsynCallback &callback)
    : call_type_(call_type), callee_users_(callee_users), uuid_(uuid), notify_(notify), callback_(callback) {}
public:
    virtual void Run()
    {
        INetcallService *service = (INetcallService *)GetServiceFromCore(SVID_NIM_NETCALL);
        if (service)
        {
            service->Remote_InitCall(call_type_, callee_users_, uuid_, notify_, callback_);
        }
    }
    
private:
    uint8_t call_type_;
    std::list<UTF8String> callee_users_;
    UTF8String uuid_;
    IAsynCallback callback_;
    Property notify_;
};

class CalleeAckTask: public YixinTask
{
public:
    CalleeAckTask(uint8_t call_type, const UTF8String caller, uint64_t channel_id, bool accept, const IAsynCallback &callback)
    : call_type_(call_type), caller_(caller), channel_id_(channel_id), accept_(accept), callback_(callback) {}
public:
    virtual void Run()
    {
        INetcallService *service = (INetcallService *)GetServiceFromCore(SVID_NIM_NETCALL);
        if (service)
        {
            service->Remote_CalleeAck(call_type_, caller_, channel_id_, accept_, callback_);
        }
    }
    
private:
    uint8_t call_type_;
    UTF8String caller_;
    uint64_t channel_id_;
    bool accept_;
    IAsynCallback callback_;
};

class HangupTask: public YixinTask
{
public:
    HangupTask(uint64_t channel_id)
    : channel_id_(channel_id) {}
public:
    virtual void Run()
    {
        INetcallService *service = (INetcallService *)GetServiceFromCore(SVID_NIM_NETCALL);
        if (service)
        {
            service->Remote_Hangup(channel_id_);
        }
    }
    
private:
    uint64_t channel_id_;
};

class KeepCallingTask: public YixinTask
{
public:
    KeepCallingTask(uint8_t call_type, const std::list<UTF8String> &callee_users, uint64_t channel_id, const IAsynCallback &callback): call_type_(call_type), callee_users_(callee_users), channel_id_(channel_id), callback_(callback){}
public:
    virtual void Run()
    {
        INetcallService *service = (INetcallService *)GetServiceFromCore(SVID_NIM_NETCALL);
        if (service)
        {
            service->Remote_KeepCalling(call_type_, callee_users_, channel_id_, callback_);
        }
    }

private:
    uint8_t call_type_;
    std::list<UTF8String> callee_users_;
    uint64_t channel_id_;
    IAsynCallback callback_;
};

class ControlTask: public YixinTask
{
public:
    ControlTask(uint64_t channel_id, uint8_t control)
    : channel_id_(channel_id), control_(control) {}
public:
    virtual void Run()
    {
        INetcallService *service = (INetcallService *)GetServiceFromCore(SVID_NIM_NETCALL);
        if (service)
        {
            service->Remote_Control(channel_id_, control_);
        }
    }
    
private:
    uint64_t channel_id_;
    uint8_t control_;
};

}

#endif
