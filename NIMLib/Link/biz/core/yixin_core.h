// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/9/27
//
// POPO Core

#ifndef BIZ_CORE_IYixinCore_H_
#define BIZ_CORE_IYixinCore_H_

#include <string>
#include "service.h"
#include "document.h"
#include "biz/protocol/linkframe.h"
#include "nio_base.h"
#include "core_task_id_generator.h"

namespace nimbiz
{


class ResendableRequest;


struct IYixinCore
{
public:
    virtual void Release(int timeout) = 0;
    
public:
    // 注册服务
    virtual bool RegisterService(IService *service) = 0;
    // 注销服务
    virtual void UnRegisterService(IService *service) = 0;
    // 获取服务
    virtual IService * GetService(uint16_t service_id) = 0;
    // 提交任务
    virtual int32_t PostTask(YixinTask *task) = 0;
    virtual int32_t PostLoginContextTask(YixinTask *task) = 0;
    virtual int32_t PostDelayedTask(YixinTask *task, int64_t delay_ms) = 0;
    
    // 是否已经登录
    virtual bool IsLogin() = 0;
    // 设置登录/未登录状态
    virtual void SetLogin(bool logined) = 0;
    // 是否正在退出
    virtual bool IsQuiting() = 0;
    // 注销
    virtual void LogOut() = 0;
    // 设置代理
    virtual void SetProxy(const nbase::ProxySet *proxy) = 0;
    //返回代理
    virtual nbase::ProxySet* GetProxy() = 0; 
    
    //用户唯一标示
    virtual void SetUid(const UTF8String &uid) = 0;
    virtual UTF8String GetUid() = 0;
    
    //当前连接号
    virtual void SetConId(const UTF8String &cid) = 0;
    virtual UTF8String GetConId() = 0;
    
    // 异步发包
    virtual uint16_t SendPacket(LinkFrame &lf, nbase::Marshallable &packet) = 0;
    
    // 发送可等待包
    virtual void SendWaitablePacket(LinkFrame &lf,
                                    nbase::Marshallable &packet,
                                    const CoreCallback &callback,
                                    int32_t timeout = 15) = 0;
    virtual bool HandleWaitablePacket(LinkFrame &lf,const nbase::Unpack &up) = 0;
    
    // 添加到等待队列
    virtual void AddWaitableRequest(LinkFrame &lf,int32_t timeout,const CoreCallback &callback) = 0;
    
    //是否被踢
    virtual bool IsKicked() = 0;
    virtual void SetKicked() = 0;
    
    //是否已设置watch
    virtual bool IsWatched() = 0;
    virtual void SetWatached() = 0;
    
    virtual void RegisterDisConnectCallback(const IAsynCallback &callback) = 0;
    
    virtual uint32_t DocumentStorageSize() = 0;
    
// Document
public:
    virtual void Watch(void *watch_class,
                       IWatchHandler &handler,
                       const UTF8String &data_id = UTF8String(ALL_DOC_TYPE_STR),
                       const UTF8String &item_id = UTF8String(ALL_DOC_TYPE_STR),
                       uint32_t tag = ALL_DOC_TYPE_INT) = 0;
    virtual void Revoke(IWatchHandler &handler) = 0;
    virtual void Revoke(void *watch_class) = 0;
    virtual void RevokeAll() = 0;
    virtual bool IsWatchHandlerExist(IWatchHandler &handler) = 0;
    virtual void FlushDocument() = 0;
    virtual void GetAllDatas(std::list<UTF8String> &keys) = 0;

    virtual void GetDataItems(const UTF8String &data_id,
                              const UTF8String &prefix,
                              std::list<Property> &infos) = 0;
    virtual void GetDataItems(const UTF8String &data_id, std::list<UTF8String> &keys) = 0;
    virtual bool HasDataItem(const UTF8String &data_id, const UTF8String &item_id) = 0;
    virtual void GetDataItem(const UTF8String &data_id,
                             const UTF8String &item_id,
                             Property &prop) = 0;
    virtual void SetDataItem(const UTF8String &data_id,
                             const UTF8String &item_id,
                             const Property &prop,
                             bool need_posttask = true) = 0;    
    virtual void DeleteDataItem(const UTF8String &data_id,
                                const UTF8String &item_id,
                                bool need_posttask = true) = 0;
    virtual void GetDataItemTag(const UTF8String &data_id,
                                const UTF8String &item_id,
                                const uint32_t tag_id,
                                ByteBuffer &value,
                                bool *check = NULL) = 0;    
    virtual void SetDataItemTag(const UTF8String &data_id,
                                const UTF8String &item_id,
                                const uint32_t tag_id,
                                const ByteBuffer &value,
                                bool need_posttask = true) = 0;
    virtual void GetDataItemTag(const UTF8String &data_id,
                                const UTF8String &item_id,
                                const uint32_t tag_id,
                                uint32_t &value,
                                bool *check = NULL) = 0;    
    virtual void SetDataItemTag(const UTF8String &data_id,
                                const UTF8String &item_id,
                                const uint32_t tag_id,
                                const uint32_t &value,
                                bool need_posttask = true) = 0;
    
    virtual void GetDataItem64Tag(const UTF8String &data_id,
                                const UTF8String &item_id,
                                const uint32_t tag_id,
                                uint64_t &value,
                                bool *check = NULL) = 0;
    virtual void SetDataItem64Tag(const UTF8String &data_id,
                                const UTF8String &item_id,
                                const uint32_t tag_id,
                                const uint64_t &value,
                                bool need_posttask = true) = 0;

protected:
};

bool IYixinCore_Create();
IYixinCore* IYixinCore_Get();
bool IYixinCore_Close(uint32_t timeout);
IService *GetServiceFromCore(uint16_t service_id);

}
#endif  // BIZ_CORE_IYixinCore_H_
