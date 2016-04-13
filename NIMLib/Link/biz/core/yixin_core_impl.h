// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/9/27
//
// POPO Core Impl

#ifndef BIZ_CORE_YixinCore_Impl_H_
#define BIZ_CORE_YixinCore_Impl_H_

#include "yixin_core.h"
#include "document.h"
#include "base/thread/framework_thread.h"
#include "base/synchronization/waitable_event.h"
#include "biz/service/link/link_service.h"
#include <string>
#include <map>

namespace nimbiz
{


struct WaitableRequest
{
    LinkFrame       lf_;
    time_t          begin_time_;
    CoreCallback    callback_;
    int32_t         timetout_;
};


class YixinCore_Impl : public IYixinCore,
                  public ILinkSocketCallback, 
                  public nbase::FrameworkThread
{
public:
    YixinCore_Impl(const char* name);
    ~YixinCore_Impl();
    
    
public:
    virtual void Release(int timeout);
    
    // 注册服务
    virtual bool RegisterService(IService *service);
    // 注销服务
    virtual void UnRegisterService(IService *service);
    // 获取服务
    virtual IService * GetService(uint16_t service_id);
    // 提交任务
    virtual int32_t PostTask(YixinTask *task);
    virtual int32_t PostLoginContextTask(YixinTask *task);
    virtual int32_t PostDelayedTask(YixinTask *task, int64_t delay_ms);
    
    // 是否已经登录
    virtual bool IsLogin() { return logined_; }
    // 设置登录/未登录状态
    virtual void SetLogin(bool logined);
    // 是否正在退出
    virtual bool IsQuiting();
    // 注销
    virtual void LogOut();
    // 设置代理
    virtual void SetProxy(const nbase::ProxySet *proxy);
    // 返回代理
    virtual nbase::ProxySet* GetProxy();

    virtual void SetUid(const UTF8String &uid);
    virtual UTF8String GetUid()
    {
        nbase::NAutoLock auto_lock(&core_data_lock_);
        return uid_;
    }
    
    virtual void SetConId(const UTF8String &cid)
    {
        nbase::NAutoLock auto_lock(&core_data_lock_);
        con_id_ = cid;
    }
    virtual UTF8String GetConId()
    {
        nbase::NAutoLock auto_lock(&core_data_lock_);
        return con_id_;
    }


    // 异步发包
    virtual uint16_t SendPacket(LinkFrame &lf,
                                nbase::Marshallable &packet);
    
    // 发送可等待包
    virtual void SendWaitablePacket(LinkFrame &lf,
                                    nbase::Marshallable &packet,
                                    const CoreCallback &callback,
                                    int32_t timeout = 15);
    virtual bool HandleWaitablePacket(LinkFrame &lf,const nbase::Unpack &up);
    virtual void AddWaitableRequest(LinkFrame &lf,int32_t timeout,const CoreCallback &callback);
    
    //是否被踢
    virtual bool IsKicked()  {return kicked_;}
    virtual void SetKicked() {kicked_ = true;}
    
    virtual bool IsWatched() {return watched_;}
    virtual void SetWatached() {watched_ = true;}
    
    virtual void RegisterDisConnectCallback(const IAsynCallback &callback) {disconnect_callback_ = callback;}

    
    virtual uint32_t DocumentStorageSize();
    
    virtual void CleanUp();
    virtual void Setup();
// Document 相关
public:
    virtual void Watch(void *watch_class,
                       IWatchHandler &handler,
                       const UTF8String &data_id = UTF8String(ALL_DOC_TYPE_STR),
                       const UTF8String &item_id = UTF8String(ALL_DOC_TYPE_STR),
                       uint32_t tag = ALL_DOC_TYPE_INT);
    virtual void Revoke(IWatchHandler &handler);
    virtual void Revoke(void *watch_class);
    virtual void RevokeAll();
    virtual bool IsWatchHandlerExist(IWatchHandler &handler);
    virtual void FlushDocument();
 
    virtual void GetAllDatas(std::list<UTF8String> &keys);

    virtual void GetDataItems(const UTF8String &data_id, std::list<UTF8String> &keys);
    virtual void GetDataItems(const UTF8String &data_id,
                              const UTF8String &prefix,
                              std::list<Property> &infos);
    virtual bool HasDataItem(const UTF8String &data_id, const UTF8String &item_id);    
    virtual void GetDataItem(const UTF8String &data_id,
                             const UTF8String &item_id,
                             Property &prop);
    virtual void SetDataItem(const UTF8String &data_id,
                             const UTF8String &item_id,
                             const Property &prop,
                             bool need_posttask = true);    
    virtual void DeleteDataItem(const UTF8String &data_id,
                                const UTF8String &item_id,
                                bool need_posttask = true);
    virtual void GetDataItemTag(const UTF8String &data_id,
                                const UTF8String &item_id,
                                const uint32_t tag_id,
                                ByteBuffer &value,
                                bool *check = NULL);    
    virtual void SetDataItemTag(const UTF8String &data_id,
                                const UTF8String &item_id,
                                const uint32_t tag_id,
                                const ByteBuffer &value,
                                bool need_posttask = true);  
    virtual void GetDataItemTag(const UTF8String &data_id,
                                const UTF8String &item_id,
                                const uint32_t tag_id,
                                uint32_t &value,
                                bool *check = NULL);    
    virtual void SetDataItemTag(const UTF8String &data_id,
                                const UTF8String &item_id,
                                const uint32_t tag_id,
                                const uint32_t &value,
                                bool need_posttask = true);
    
    virtual void GetDataItem64Tag(const UTF8String &data_id,
                                  const UTF8String &item_id,
                                  const uint32_t tag_id,
                                  uint64_t &value,
                                  bool *check = NULL);
    virtual void SetDataItem64Tag(const UTF8String &data_id,
                                  const UTF8String &item_id,
                                  const uint32_t tag_id,
                                  const uint64_t &value,
                                  bool need_posttask = true) ;
    
public:
    virtual void OnConnected(NetErrorCode error);
    virtual void OnDisConnected(NetErrorCode error);
    virtual void OnParseError();
    virtual void OnPacket(nbase::Unpack &up);
    
    void OnDisConnectedInWorkThread(NetErrorCode error);
    
    void OnCoreTimeFired();

private:
    bool        PacketCanBeSend(LinkFrame &lf);
    
    void        ClearAllWaitableRequests();
protected:
    
    std::map<uint16_t, IService *> services_;
    bool            logined_;
    
    ILinkService    *link_service_;
    Document        *document_;
    
    nbase::NLock    core_data_lock_;
    UTF8String      uid_;
    UTF8String      con_id_;
    
    nbase::ProxySet proxy_set_;
    bool            kicked_;
    bool            watched_;
    
    IAsynCallback   disconnect_callback_;
        
    nbase::Timer<YixinCore_Impl, true>  *core_timer_;
    std::map<uint16_t, WaitableRequest> waitable_requests_;
    bool            core_closing_;

};
    
}


#endif  // BIZ_CORE_YixinCore_Impl_H_
