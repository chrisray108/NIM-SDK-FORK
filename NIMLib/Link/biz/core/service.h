// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/9/27
//
// Service Interface

#ifndef BIZ_CORE_ISERVICE_H_
#define BIZ_CORE_ISERVICE_H_

#include "boost/any.hpp"
#include "base/base_types.h"
#include "base/memory/packet.h"
#include "base/util/callback.h"
#include "eim_task.h"
#include "document_defs.h"
#include "biz/protocol/linkframe.h"
#include "biz/protocol/protocol.h"

namespace nimbiz
{

struct IAsynCallbackParam
{
    int32_t code_;
    IAsynCallbackParam():code_(0){}
    
    virtual ~IAsynCallbackParam(){} //虚函数用于dymanic_cast
};

struct IAsynTaskCallbackParam : IAsynCallbackParam
{
    int32_t task_id_;
    IAsynTaskCallbackParam ():task_id_(-1){}
};



typedef nbase::Callback<void(IAsynCallbackParam *)> IAsynCallback;

struct CoreCallback
{
    IAsynCallback   callback_;
    nimboost::any      any_;
    int32_t         task_id_;
    CoreCallback()
    {
        task_id_ = 0;
    }
};


enum 
{
    NIMOnPacketSuccess            = 0,
    NIMOnPacketCommandNotSupport  = 1,
};

struct IService
{
public:
    virtual void Release() = 0;
    
    explicit IService(uint16_t service_id)
        : service_id_(service_id)
    {}
    
    uint16_t service_id() { return service_id_; }
    
public:
    // 装载服务后
    virtual bool OnLoad() { return true; }
    // 卸载服务后
    virtual void OnUnLoad() {}
    
    // 收到网络包的处理函数
    virtual uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up)
    { 
        return NIMOnPacketCommandNotSupport;
    }
    
    virtual bool OnWaitablePacket(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback)
    {
        return false;
    }

protected:
    uint16_t    service_id_;    // 服务id
};

bool LoadPreLoginServices();
bool LoadCoreServices();
    
}
#endif  // BIZ_CORE_ISERVICE_H_
