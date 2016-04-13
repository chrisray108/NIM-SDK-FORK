//
//  session_task.h
//  NIMLib
//
//  Created by amao on 15/1/30.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_session_task_h
#define NIMLib_session_task_h

#include "session_protocol.h"
#include "biz/protocol/property.h"
#include "biz/core/eim_task.h"

namespace nimbiz
{

class SendMsgTask: public YixinTask
{
public:
    SendMsgTask(const Property &msg)
    : msg_(msg) {}
public:
    virtual void Run()
    {
        ISessionService *service = (ISessionService *)GetServiceFromCore(SVID_NIM_SESSION);
        if (service)
        {
            service->Remote_SendMsg(msg_);
        }
    }
    
private:
    Property msg_;
};


class SendCNTask: public YixinTask
{
public:
    SendCNTask(const Property &msg,const UTF8String &msg_id)
    : msg_(msg),msg_id_(msg_id) {}
public:
    virtual void Run()
    {
        ISessionService *service = (ISessionService *)GetServiceFromCore(SVID_NIM_SESSION);
        if (service)
        {
            service->Remote_SendCustomNotification(msg_,msg_id_);
        }
    }
    
private:
    Property msg_;
    UTF8String msg_id_;
};


class HistoryMsgTask: public YixinTask
{
public:
    HistoryMsgTask(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback)
    : param_(param),callback_(callback){}
public:
    virtual void Run()
    {
        ISessionService *service = (ISessionService *)GetServiceFromCore(SVID_NIM_SESSION);
        if (service)
        {
            service->Remote_HistoryMsg(param_,callback_,GetTaskId());
        }
    }

private:
    SessionHistoryMsgReqeustParam param_;
    IAsynCallback callback_;
};


class DeleteSessionsTask: public YixinTask
{
public:
    DeleteSessionsTask(const std::list<UTF8String> &sessions,const IAsynCallback &callback)
    : sessions_(sessions),callback_(callback){}
public:
    virtual void Run()
    {
        ISessionService *service = (ISessionService *)GetServiceFromCore(SVID_NIM_SESSION);
        if (service)
        {
            service->Remote_DeleteSession(sessions_, callback_, GetTaskId());
        }
    }
    
private:
    std::list<UTF8String> sessions_;
    IAsynCallback callback_;
};
    
    
class MarkSessionReadTask: public YixinTask
{
public:
    MarkSessionReadTask(const Property &msg,const IAsynCallback &callback)
    : msg_(msg),callback_(callback){}
public:
    virtual void Run()
    {
        ISessionService *service = (ISessionService *)GetServiceFromCore(SVID_NIM_SESSION);
        if (service)
        {
            service->Remote_SendSessionReceipt(msg_,callback_,GetTaskId());
        }
    }
        
private:
    Property msg_;
    IAsynCallback callback_;
};
    
}


#endif
