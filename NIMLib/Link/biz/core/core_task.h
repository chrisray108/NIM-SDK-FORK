//
//  core_task.h
//  NIM
//
//  Created by amao on 13-9-10.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#ifndef BIZ_CORE_CORE_TASK_H_
#define BIZ_CORE_CORE_TASK_H_

#include "base/memory/packet.h"
#include "biz/protocol/linkframe.h"
#include "biz/core/yixin_core_impl.h"
#include "eim_task.h"
#include "yixin_core.h"
#include "link_socket.h"
#include "protocol.h"
#include "ios_util.h"

namespace nimbiz
{
#pragma mark - 断开连接
class DisConnectTask : public YixinTask
{
public:
    DisConnectTask(YixinCore_Impl *impl,NetErrorCode error)
    :impl_(impl),error_(error)
    {
        
    }
    
    ~DisConnectTask()
    {
        
    }
    
 	virtual void Run()
	{
        impl_->OnDisConnectedInWorkThread(error_);
    }
    
private:
    YixinCore_Impl       *impl_;
    NetErrorCode    error_;
};


#pragma mark - Packet分发
class PacketDispatchTask : public YixinTask
{
public:
    PacketDispatchTask(LinkFrame &lf, nbase::Unpack &up) :
    linkframe_(lf),
    unpack_(up)
    {
        buffer_.append(unpack_.data(), unpack_.size());
        unpack_ = nbase::Unpack(buffer_.data(), buffer_.size());
    }
    
    ~PacketDispatchTask()
    {
        buffer_.clear();
    }
    
 	virtual void Run()
	{
		IYixinCore *core = IYixinCore_Get();
        if (NULL == core )
        {
            DEFLOG(nbase::LogInterface::LV_ERR, __FILE__,__LINE__, "core is nil");
            return;
        }
        
        if (core->HandleWaitablePacket(linkframe_, unpack_))
        {
            DEFLOG(nbase::LogInterface::LV_PRO, __FILE__,__LINE__,
                   "Waitable LinkFrame SID %d CID  %d Handled",
                   linkframe_.service_id_,linkframe_.command_id_);
        }
        else
        {
            IService *service = core->GetService(linkframe_.service_id_);
            if (NULL != service)
            {
                service->OnPacket(linkframe_, unpack_);
            }
            else
            {
                DEFLOG(nbase::LogInterface::LV_ERR, __FILE__,__LINE__, "service is nil, service id is %d",linkframe_.service_id_);
            }
        }
        

	}
    
private:
    LinkFrame     linkframe_;
    nbase::Unpack unpack_;
    ByteBuffer    buffer_;
};


#pragma mark - 登录后才执行的task，否则进行空转
const int kMinLoginWaitTime = 2; //每2秒检查一次

class LoginContextTask : public YixinTask
{
public:
    LoginContextTask(YixinTask *task,int timeout = 30)
    {
        task_ = task;
        timeout_ = timeout;
        need_delete_task_ = true;
    }
    
    ~LoginContextTask()
    {
        if (need_delete_task_)
        {
            delete task_;
        }
    }
    
    virtual void Run()
    {
        IYixinCore *core = IYixinCore_Get();
        if (!core->IsLogin() && timeout_ >= kMinLoginWaitTime)
        {
            need_delete_task_ = false;  //如果做了一次重试，就不需要删除当前task
            core->PostDelayedTask(new LoginContextTask(task_,timeout_ - kMinLoginWaitTime),
                                  kMinLoginWaitTime * 1000);
        }
        else
        {
            task_->Run();
        }
    }
    
private:
    bool        need_delete_task_;
    int         timeout_;
    YixinTask   *task_;
};


#pragma mark - 登录完成统一执行的task
class AfterLoginTask : public YixinTask
{
public:
    virtual void Run()
    {

    }
};

}


#endif
