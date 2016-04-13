//
//  auth_task.h
//  YixinCall
//
//  Created by amao on 10/8/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#ifndef YixinCall_auth_task_h
#define YixinCall_auth_task_h

#include "biz/service/link/link_protocol.h"
#include "ios_util.h"

namespace nimbiz
{

#pragma mark - 链接服务器
class ConnectLinkTask : public YixinTask
{
public:
    ConnectLinkTask(const IAsynCallback &callback) :
    callback_(callback) {}
    
public:
    virtual void Run()
    {
        IYixinCore *popo = IYixinCore_Get();

        std::string link_server;
        uint16_t link_port;
        
        nimbiz::GetLinkAddress(link_server, link_port);
        nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,
                      "Login Step: GetLinkAddress OK, addr: %s, port: %d", link_server.c_str(), link_port);
        
        
        if (popo->IsKicked())
        {
            param_.step_ = NIMConnectStepLinked;
            param_.code_ = NIMResConnectionError;
            RaiseCallback();
            
            DEFLOG(nbase::LogInterface::LV_APP,
                   __FILE__,
                   __LINE__,
                   "Connect Don't Excuted Because of Kicked",
                   NIMResConnectionError);
            return;
        }
        
        ILinkService *link_service = (ILinkService *)popo->GetService(SVID_NIM_LINK);
        PTR_VOID(link_service);
        // 转换IP
        if (inet_addr(link_server.c_str()) == INADDR_NONE)
        {
            struct hostent *link_host = NULL;
            char *link_ip = (char *)link_server.c_str();
            for (int i = 0; i < 3; i++)
            {
                link_host=gethostbyname(link_ip);//Just for WMemulator
                if (link_host)
                {
                    break;
                }
                sleep(1);
            }
            
            if (link_host)
            {
                for (int i = 0; link_host!= NULL && link_host->h_addr_list[i] != NULL; i++)
                {
                    link_ip = inet_ntoa(*(struct in_addr*)link_host->h_addr_list[i]);
                    if (link_ip)
                    {
                        link_server.assign(link_ip, strlen(link_ip));
                        break;
                    }
                }
            }
            else
            {
                param_.step_ = NIMConnectStepLinking;
                param_.code_ = NIMResConnectionError;
                RaiseCallback();
                
                DEFLOG(nbase::LogInterface::LV_APP,
                       __FILE__,
                       __LINE__,
                       "Get Link host addr error, code: %d",
                       NIMResConnectionError
                       );
                return;
            }
        }
        
        // 建立连接
        nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Begin to Connect Link Server");
        param_.step_   = NIMConnectStepLinking;
        param_.code_   = NIMResSuccess;
        RaiseCallback();
        link_service->ConnectLink(link_server, link_port);

    }
    virtual void OnException(const nbase::NException *e)
    {
        param_.step_ = NIMConnectStepLinking;
        param_.code_ = NIMResConnectionError;
        RaiseCallback();
        DEFLOG(nbase::LogInterface::LV_APP,
               __FILE__,
               __LINE__,
               "connect link server exception thrown, msg: %s",
               e->what()
               );
    }
private:
    void    RaiseCallback()
    {
        if (!callback_.is_null())
        {
            callback_.Run(&param_);
        }
    }
    
private:
    IAsynCallback       callback_;
    CBConnectStepParam  param_;
};


#pragma mark - 登录
class LoginTask : public YixinTask
{
public:
    LoginTask(const Property &param,const IAsynCallback &callback) :
    param_(param),callback_(callback) {}
    
public:
    virtual void Run()
    {
        IAuthService *service = (IAuthService *)GetServiceFromCore(SVID_NIM_AUTH);
        if (service)
        {
            service->Remote_Login(param_, callback_,GetTaskId());
        }
    }
private:
    IAsynCallback       callback_;
    Property            param_;
};

#pragma mark - 登出
class LogoutTask : public YixinTask
{
public:
    LogoutTask(const IAsynCallback &callback)
    :callback_(callback){}
    
public:
    virtual void Run()
    {
        IYixinCore *core = IYixinCore_Get();
        IAuthService *service = (IAuthService *)core->GetService(SVID_NIM_AUTH);
        if (service)
        {
            service->Remote_Logout(callback_);
        }
    }
private:
    IAsynCallback callback_;
};

#pragma mark - 踢人
class KickOtherClientTask : public YixinTask
{
public:
    KickOtherClientTask(const UTF8String &device_id,const IAsynCallback &callback)
    :device_id_(device_id),callback_(callback){}
    
public:
    virtual void Run()
    {
        IYixinCore *core = IYixinCore_Get();
        IAuthService *service = (IAuthService *)core->GetService(SVID_NIM_AUTH);
        if (service)
        {
            service->Remote_Kick(device_id_, callback_,GetTaskId());
        }
    }
private:
    IAsynCallback callback_;
    UTF8String device_id_;
};
    
}


#endif
