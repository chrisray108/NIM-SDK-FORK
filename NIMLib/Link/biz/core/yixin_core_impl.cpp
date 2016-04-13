// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/9/27
//
// POPO Core Impl


#include "yixin_core_impl.h"
#include "base/file/file_util.h"
#include "core_task.h"
#include "ios_util.h"
#include <sys/stat.h>
#include "core_checker.h"
#include "biz/service/chatroom/chatroom_protocol.h"

namespace nimbiz
{

YixinCore_Impl::YixinCore_Impl(const char* name)
    : nbase::FrameworkThread(name),
      logined_(false),
      document_(NULL),
      kicked_(false),
      core_timer_(NULL),
      core_closing_(false),
      watched_(false)
{
    link_service_       = NULL;
    proxy_set_.type_    = nbase::kProxyTypeNone;
    
    CoreChecker::CheckDocumentEntries();
}

YixinCore_Impl::~YixinCore_Impl()
{
    SAFE_DELETE(core_timer_);
    
    // 删除Document
    if (document_)
        delete document_;
}

void YixinCore_Impl::Release(int timeout)
{
    core_closing_ = true;
    //设置link service关闭
    DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Set Link Service Closing");
    if (link_service_) 
    {
        link_service_->SetClosing();
    }
    
    
    // 停止线程
    DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Stop Thread");
    Stop();
    
    // 注销
    DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Logout");
    LogOut();
    
    DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Delete Self");
    delete this;
}

void YixinCore_Impl::CleanUp()
{
    if (core_timer_)
    {
        core_timer_->Stop();
    }
    IChatroomService *chatroom = (IChatroomService *)GetService(SVID_NIM_CHATROOM);
    if (chatroom)
    {
        chatroom->CleanUp();
    }
}



void YixinCore_Impl::LogOut()
{
    // 断开网络链接
    if (link_service_)
    {
        link_service_->UnRegisterCallback();
        link_service_->DisConnect();
    }
    link_service_ = NULL;
    
    // 卸载所有服务
    for (std::map<uint16_t, IService *>::const_iterator iter = services_.begin();
         iter != services_.end();
         ++iter)
    {
        iter->second->OnUnLoad();
    }
    
    // 保存数据 Document
    FlushDocument();
    
    // 销毁document
    SAFE_DELETE(document_); 
    
    // 释放所有服务
    for (std::map<uint16_t, IService *>::const_iterator iter = services_.begin();
         iter != services_.end();
         ++iter)
    {
        iter->second->Release();
        services_[iter->first] = NULL;
    }
    services_.clear();
    
    // 重置登录状态
    SetLogin(false);
}

void YixinCore_Impl::SetProxy(const nbase::ProxySet *proxy)
{
    if (proxy)
    {
        proxy_set_.host_    = proxy->host_;
        proxy_set_.port_    = proxy->port_;
        proxy_set_.type_    = proxy->type_;
        proxy_set_.username_ = proxy->username_;
        proxy_set_.password_ = proxy->password_;
    }
}

nbase::ProxySet* YixinCore_Impl::GetProxy()
{
    return &proxy_set_;
}

void YixinCore_Impl::SetUid(const UTF8String &uid)
{
    //保存uid 加锁
    {
        nbase::NAutoLock auto_lock(&core_data_lock_);
        uid_ = uid;
    }
    //载入Document和Service
    if (document_ == NULL)
    {
        document_ = new Document();
        document_->Load();
        LoadCoreServices();
    }
}


bool YixinCore_Impl::RegisterService(IService *service)
{
    assert(service && service->service_id() != SVID_NODEF);
    if (services_.find(service->service_id()) == services_.end())
    {
        services_.insert(std::pair<uint16_t, IService *>(service->service_id(), service));
        return service->OnLoad();
    }
    else
    {
        service->Release();
    }
    return true;
}

void YixinCore_Impl::UnRegisterService(IService *service)
{
    assert(service);
    service->OnUnLoad();
    services_.erase(services_.find(service->service_id()));
}

IService * YixinCore_Impl::GetService(uint16_t service_id)
{
    std::map<uint16_t, IService *>::const_iterator iter = services_.find(service_id);
    if (iter != services_.end())
        return iter->second;
    
    return NULL;
}

int32_t YixinCore_Impl::PostTask(YixinTask *task)
{
    int32_t task_id = task->GetTaskId();
    if (IsRunning() && !core_closing_)
    {
        message_loop()->PostNonNestableTask(task->GetTask());
    }
    return task_id;
}

int32_t YixinCore_Impl::PostLoginContextTask(YixinTask *task)
{
    int32_t task_id = task->GetTaskId();
    PostTask(new LoginContextTask(task));
    return task_id;
}

int32_t YixinCore_Impl::PostDelayedTask(YixinTask *task, int64_t delay_ms)
{
    int32_t task_id = task->GetTaskId();
    if (IsRunning())
    {
        message_loop()->PostNonNestableDelayedTask(task->GetTask(), delay_ms);

    }
    return task_id;
}

void YixinCore_Impl::SetLogin(bool logined)
{
    logined_ = logined;
}


bool YixinCore_Impl::IsQuiting()
{
    return (IsRunning() == false || IsStopping());
}


uint16_t YixinCore_Impl::SendPacket(LinkFrame &lf, nbase::Marshallable &packet)
{
    uint16_t serial_id = GenerateSerialID();
    lf.serial_id_ = serial_id;
    
    if (!PacketCanBeSend(lf))
    {
        return lf.serial_id_;
    }
    
    if (link_service_)
    {
        link_service_->SendPacket(lf, packet);
    }
    return serial_id;
}


void YixinCore_Impl::SendWaitablePacket(LinkFrame &lf,
                                        nbase::Marshallable &packet,
                                        const CoreCallback &callback,
                                        int32_t timeout)
{
    
    if (!nimbiz::CanConnectInternet() || !PacketCanBeSend(lf))
    {
        lf.error_       = NIMResTimeoutError;
        lf.key_         = GetUid();
        IService *service = GetService(lf.service_id_);
        if (service)
        {
            nbase::Unpack unpackbuffer(NULL,0);
            service->OnWaitablePacket(lf,unpackbuffer,callback);
        }
        return;
    }
    
    SendPacket(lf, packet);
    AddWaitableRequest(lf, timeout, callback);
}

bool YixinCore_Impl::HandleWaitablePacket(LinkFrame &lf,const nbase::Unpack &up)
{
    bool handled = false;
    std::map<uint16_t, WaitableRequest>::iterator it = waitable_requests_.find(lf.serial_id_);
    if (it != waitable_requests_.end())
    {
        
        LinkFrame stored_lf = it->second.lf_;
        if (stored_lf.service_id_ != lf.service_id_)
        {
            assert(0);
            DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "Service ID Not Match, %d vs %d",stored_lf.service_id_,lf.service_id_);
            return false;
        }
        
        //回包时command id可能会改变，需要重置为存储的command id
        LinkFrame dispatch_lf = lf;
        dispatch_lf.command_id_ = stored_lf.command_id_;
        
        
        
        IService *service = GetService(stored_lf.service_id_);
        if (service)
        {
            handled = service->OnWaitablePacket(dispatch_lf, up, it->second.callback_);
        }
        if (handled)
        {
            waitable_requests_.erase(it);
        }
    }
    return handled;
}
    
void    YixinCore_Impl::AddWaitableRequest(LinkFrame &lf, int32_t timeout, const CoreCallback &callback)
{
    WaitableRequest request;
    request.lf_ = lf;
    request.begin_time_ = nbase::Time::Now().ToTimeT();
    request.timetout_ = timeout;
    request.callback_ = callback;
        
    waitable_requests_[lf.serial_id_] = request;
        
    if (core_timer_ == NULL)
    {
        core_timer_ = new nbase::Timer<YixinCore_Impl, true>();
        core_timer_->Start(nbase::TimeDelta::FromSeconds(5), this, &YixinCore_Impl::OnCoreTimeFired);
    }
}


uint32_t YixinCore_Impl::DocumentStorageSize()
{
#ifdef DEBUG    //DEBUG时用于检查当前Document是否占用太多内存
    return document_ ? document_->DocumentStorageSize() : 0;
#endif
    return 0;
}

void YixinCore_Impl::Watch(void *watch_class,
                     IWatchHandler &handler,
                     const UTF8String &data_id,
                     const UTF8String &item_id,
                     uint32_t tag)
{
    if (document_)
        document_->Watch(watch_class, handler, data_id, item_id, tag);
}

void YixinCore_Impl::Revoke(IWatchHandler &handler)
{
    if (document_)
        document_->Revoke(handler);
}

void YixinCore_Impl::Revoke(void *watch_class)
{
    if (document_)
        document_->Revoke(watch_class);
}

void YixinCore_Impl::RevokeAll()
{
    if (document_)
        document_->RevokeAll();
}

bool YixinCore_Impl::IsWatchHandlerExist(IWatchHandler &handler)
{
    if (NULL == document_)
        return false;
    return document_->IsWatchHandlerExist(handler);
}

void YixinCore_Impl::FlushDocument()
{
    if (document_)
    {
        try {
            document_->Save();
        } catch (...)
        {
            DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__,
                   "Save Document Failed");
        }
        
    }
        
}


void YixinCore_Impl::GetAllDatas(std::list<UTF8String> &keys)
{
    if (document_)
        document_->GetAllDatas(keys);
}




void YixinCore_Impl::GetDataItems(const UTF8String &data_id, std::list<UTF8String> &keys) 
{
    if (document_)
        document_->GetDataItems(data_id, keys);
}

void YixinCore_Impl::GetDataItems(const UTF8String &data_id,
                                  const UTF8String &prefix,
                                  std::list<Property> &infos)
{
    if (document_)
    {
        document_->GetDataItems(data_id,
                                prefix,
                                infos);
    }
}



bool YixinCore_Impl::HasDataItem(const UTF8String &data_id, const UTF8String &item_id) 
{
    if (document_)
        return document_->HasDataItem(data_id, item_id);
    return false;
}

void YixinCore_Impl::GetDataItem(const UTF8String &data_id,
                            const UTF8String &item_id,
                            Property &prop)
{
    if (document_)
        document_->GetDataItem(data_id, item_id, prop);
}

void YixinCore_Impl::SetDataItem(const UTF8String &data_id,
                            const UTF8String &item_id,
                            const Property &prop,
                            bool need_posttask)
{
    if (document_)
    {
        DocTask *task = document_->SetDataItem(data_id, item_id, prop);
        if (need_posttask)
            PostTask(task);
        else
            task->Release();
    }
}

void YixinCore_Impl::DeleteDataItem(const UTF8String &data_id,
                               const UTF8String &item_id,
                               bool need_posttask)
{
    if (document_)
    {
        DocTask *task = document_->DeleteDataItem(data_id, item_id);
        if (need_posttask)
            PostTask(task);
        else
            task->Release();
    }
}

void YixinCore_Impl::GetDataItemTag(const UTF8String &data_id,
                               const UTF8String &item_id,
                               const uint32_t tag_id,
                               ByteBuffer &value,
                               bool *check) 
{
    if (document_)
        document_->GetDataItemTag(data_id, item_id, tag_id, value, check);
}

void YixinCore_Impl::SetDataItemTag(const UTF8String &data_id,
                               const UTF8String &item_id,
                               const uint32_t tag_id,
                               const ByteBuffer &value,
                               bool need_posttask)
{
    if (document_)
    {
        DocTask *task = document_->SetDataItemTag(data_id, item_id, tag_id, value);
        if (need_posttask)
            PostTask(task);
        else
            task->Release();
    }
}

void YixinCore_Impl::GetDataItemTag(const UTF8String &data_id,
                               const UTF8String &item_id,
                               const uint32_t tag_id,
                               uint32_t &value,
                               bool *check) 
{
    value = 0;
    ByteBuffer value_buf;
    GetDataItemTag(data_id, item_id, tag_id, value_buf, check);
    if (!value_buf.empty())
        value = atoi(value_buf.c_str());
}

void YixinCore_Impl::SetDataItemTag(const UTF8String &data_id,
                               const UTF8String &item_id,
                               const uint32_t tag_id,
                               const uint32_t &value,
                               bool need_posttask)
{
    nbase::UTF8Char str[16];
    memset(str, 0, 16);
    sprintf(str, "%u", value);        
    ByteBuffer value_buf = str;
    SetDataItemTag(data_id, item_id, tag_id, value_buf, need_posttask);
}

void YixinCore_Impl::GetDataItem64Tag(const UTF8String &data_id,
                                      const UTF8String &item_id,
                                      const uint32_t tag_id,
                                      uint64_t &value,
                                      bool *check)
{
    value = 0;
    ByteBuffer value_buf;
    GetDataItemTag(data_id, item_id, tag_id, value_buf, check);
    if (!value_buf.empty())
        value = (unsigned long long)atoll(value_buf.c_str());
}

void YixinCore_Impl::SetDataItem64Tag(const UTF8String &data_id,
                                      const UTF8String &item_id,
                                      const uint32_t tag_id,
                                      const uint64_t &value,
                                      bool need_posttask)
{
    nbase::UTF8Char str[32];
    memset(str, 0, 32);
    sprintf(str, UINT64_FORMAT, value);
    ByteBuffer value_buf = str;
    SetDataItemTag(data_id, item_id, tag_id, value_buf, need_posttask);
}

void YixinCore_Impl::OnConnected(NetErrorCode error)
{
    if (error == kNetOk)
    {
        link_service_->NotifyConnectLink(true);
    }
}

void YixinCore_Impl::OnDisConnectedInWorkThread(NetErrorCode error)
{
    SetLogin(false);    //先设置登录状态
    
    DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Disconnected from server, error: %s", error==kConnectFailed?"kConnectFailed":"kNetError");
	if(link_service_)
	{
		// 如果还没有连接上，告诉上面连接不上
		if (error == kConnectFailed)
		{
			link_service_->NotifyConnectLink(false);
		}
	}

    // 产生事件，防止有task正在等待网络包,并清理掉所有等待包
    ClearAllWaitableRequests();
    
    if (!disconnect_callback_.is_null())
    {
        disconnect_callback_.Run(0);
    }

}

void YixinCore_Impl::OnDisConnected(NetErrorCode error)
{
    //抛到工作线程进行同步
    PostTask(new DisConnectTask(this,error));
}

void YixinCore_Impl::OnParseError()
{
}

void YixinCore_Impl::OnPacket(nbase::Unpack &up)
{
    LinkFrame lf;
    up >> lf;
    
    CompressInfo compress_info;
    if (lf.is_compressed())
    {
        if (compress_info.uncompress(up))
        {
            lf.clear_compressed();
            up = nbase::Unpack(compress_info.data(), compress_info.length());
        }
        else
        {
            OnParseError();
        }
    }
    
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Receive Packet : SID %d CID %d SER %d RES %d",
                  lf.service_id_,lf.command_id_,lf.serial_id_,lf.error_);
     
    // 派发包
    PacketDispatchTask *task = new PacketDispatchTask(lf, up);
    this->PostTask(task);
}


void    YixinCore_Impl::ClearAllWaitableRequests()
{
    std::vector<LinkFrame> requests;
    for (std::map<uint16_t, WaitableRequest>::iterator it = waitable_requests_.begin();
         it != waitable_requests_.end(); it++)
    {
        WaitableRequest &request = it->second;
        requests.push_back(request.lf_);
    }
    if (requests.size())
    {
        DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Info: %d Waitable Requests",requests.size());
    }
    
    for (size_t i = 0; i < requests.size(); i++)
    {
        LinkFrame lf = requests[i];
        lf.error_ = NIMResTimeoutError;
        lf.key_   = GetUid();
        nbase::Unpack unpackbuffer(NULL,0);
        HandleWaitablePacket(lf, unpackbuffer);
    }
    waitable_requests_.clear();
}

void    YixinCore_Impl::OnCoreTimeFired()
{
    time_t now = nbase::Time::Now().ToTimeT();
    std::vector<LinkFrame> requests;
    for (std::map<uint16_t, WaitableRequest>::iterator it = waitable_requests_.begin();
         it != waitable_requests_.end(); it++)
    {
        WaitableRequest &request = it->second;
        if (now - request.begin_time_ >= request.timetout_)
        {
            requests.push_back(request.lf_);
        }
    }
    for (size_t i = 0; i < requests.size(); i++)
    {
        LinkFrame lf = requests[i];
        lf.error_ = NIMResTimeoutError;
        lf.key_ = GetUid();
        
        DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "On Timeout SID %d CID %d",lf.service_id_,lf.command_id_);

        nbase::Unpack unpackbuffer(NULL,0);
        HandleWaitablePacket(lf, unpackbuffer);
    }
}


#pragma mark - 辅助方法
bool    YixinCore_Impl::PacketCanBeSend(LinkFrame &lf)
{
    bool can_be_send = true;
    if (!IsLogin()) //未登录时不允许发非登陆协议的包，因为发了也是无效的
    {
        if (lf.service_id_ != SVID_NIM_AUTH)
        {
            can_be_send = false;
        }
        else    //即使是登陆协议，有些包也要求是登陆完成了才能发送
        {
        }
    }
    
    if (!can_be_send)
    {
        nbase::DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Warning: Packet Ignored SID %d CID %d Before Being Logined",
                      lf.service_id_,lf.command_id_);
    }
    return can_be_send;
}

void    YixinCore_Impl::Setup()
{
    //启动线程
    Start();
    //创建LinkService
    if (link_service_ == NULL)
    {
        link_service_ = new LinkService();
        nbase::ProxySet *proxy = NULL;
        if (proxy_set_.type_ != nbase::kProxyTypeNone)
            proxy = &proxy_set_;
        link_service_->Create(proxy);
        RegisterService(link_service_);
        link_service_->RegisterCallback(this);
    }
}


////////////////////////////////////////////////////////////////////////
IYixinCore *g_yixin = NULL;

bool IYixinCore_Create()
{
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "create core begin");
    if (NULL != g_yixin)
        return true;
    
    try 
    {
        YixinCore_Impl *popo = new YixinCore_Impl("popo");
        popo->Setup();
        g_yixin = popo;
        
    }
    catch (...) 
    {
        g_yixin = NULL;
        return false;
    }
    assert(g_yixin);
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "create core end");
    return (g_yixin != NULL);
}

IYixinCore* IYixinCore_Get()
{
    return g_yixin;
}

bool IYixinCore_Close(uint32_t timeout)
{
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "close core begin");
    if (NULL != g_yixin)
    {
        g_yixin->Release(timeout);
        g_yixin = NULL;
        return true;
    }
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "close core end");
    return true;
}

IService *GetServiceFromCore(uint16_t service_id)
{
    IYixinCore *core = IYixinCore_Get();
    return core ? core->GetService(service_id) : NULL;
}


}