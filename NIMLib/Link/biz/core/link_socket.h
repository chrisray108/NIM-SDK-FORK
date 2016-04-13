// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/9/27
//
// This file defines the interface to send and receive data with server

#ifndef BIZ_CORE_LINK_SOCKET_H_
#define BIZ_CORE_LINK_SOCKET_H_

#include "base/network/nio_base_tcp.h"
#include "base/memory/packet.h"
#include "base/memory/blockbuffer.h"
#include "base/encrypt/encrypt_impl.h"
#include "base/synchronization/waitable_event.h"
#include "base/synchronization/lock.h"
#include "biz/protocol/linkframe.h"
#include "link_sender.h"
#include "nio_proxy.h"
#include "link_socket_type_handler.hpp"

namespace nimbiz
{

class LinkNioThread;

enum NetErrorCode
{
    kNetOk         = 0, // 无错误
    kNetError,          // 网络错误
    kPacketError,       // 解包错误
    kConnectFailed,     // 连接失败
};
   
template <class ITcpClientCallback>
class LinkNioClient : public nbase::TcpClient
{
public:
    LinkNioClient(ITcpClientCallback *link_socket,                   
                  struct event_base *event_base)
    : nbase::TcpClient(event_base), 
    link_socket_(link_socket)
    {
    }
    LinkNioClient(void){}
    ~LinkNioClient()
    {
    }
    
public:
    virtual void OnRead()       { link_socket_->OnRead(); }
	virtual void OnWrite()      { link_socket_->OnWrite(); }
	virtual void OnClose()      { link_socket_->OnClose(); }
	virtual void OnConnect()    { link_socket_->OnConnect(); }
    
private:
    ITcpClientCallback          *link_socket_;
};
    
// linksocket数据收发事件的回调接口
struct ILinkSocketCallback
{
    // 连接成功事件通知
    virtual void OnConnected(NetErrorCode error) = 0;
    // 没有出错处理，出错后直接断开连接并调用OnDisConnected
    virtual void OnDisConnected(NetErrorCode error) = 0;
    // 收包处理
    virtual void OnPacket(nbase::Unpack &up) = 0;
    // 解包出错
    virtual void OnParseError() = 0;
};
    
class LinkSocket
{
public:
    LinkSocket(void);
    ~LinkSocket(void);
    
public:
    
    
public:
    bool Create(const nbase::ProxySet *proxy = NULL);
    void Connect(const char *host, int port, int timeout = 30);
    bool SendPacket(const LinkFrame &lf, const nbase::Marshallable &req);
    void Close();
    void SetClosing();

    
    void RegisterCallback(ILinkSocketCallback *callback);
    void UnregisterCallback();
    
    
    void OnRead();
	void OnWrite();
	void OnClose();
	void OnConnect();
    
    bool IsConnected() { return connected_; }
    
    // 生成发送数据任务，交给网络线程发送
    void PostSendTask(const char *data, size_t length);
    void ExcuteSend(const char *buff, size_t length);
    
    // Helper functions, called by nio thread, socket should be manage here
    void ConnectHelper(const char *host, uint16_t port, int timeout);
    void CloseHelper();
    
    // 连接超时处理函数
    void OnConnectTimeout();
    void OnReadIdle();
    void OnHeartPingTimeout();
    
    //不同类型link的额外处理
    void FireHeartPing();
    const char * GetDescription();
    void OnReportLinkError(bool fatal);
    bool ShouldIgnoreLinkFrameBeforeEncrypted(const LinkFrame &lf);
    void SetTypeHanlder(const LinkSocketTypeHanlder &handler);
    
private:
    void ParseBuffer();
    void Dispatch(nbase::Unpack &up);
    UTF8String  GetRandomRC4Key();
    void SendEncryptPacket(const LinkFrame &lf, const nbase::Marshallable &req);
private:
    ILinkSocketCallback         *callback_;
    nbase::NLock                callback_lock_;
    
    nbase::EncryptInterface_var in_chiper_;
    nbase::EncryptInterface_var out_chiper_;
    bool                        is_encrypt_;
    
    LinkSender<LinkSocket>      *link_sender_;
    bool                        closing_;
    bool                        connected_;
    
    // 以下数据由网络线程，对他们的操作均应该通过task的方式进行
    LinkNioThread               *link_nio_thread_;
    nbase::NLock                nio_thread_lock_;
    nbase::WaitableEvent        close_socket_event_;
    LinkNioClient<LinkSocket>   *link_nio_client_;
    std::string                 in_buffer_;
    std::string                 out_buffer_;
    
    nbase::ProxySet             proxy_set_;
    
    nbase::OneShotTimer<LinkSocket> connect_timer_;         // 连接代理服务器的timer
    nbase::OneShotTimer<LinkSocket> read_idle_timer_;       // 读超时
    nbase::OneShotTimer<LinkSocket> hp_timer_;              // 心跳超时时间
    
    LinkSocketTypeHanlder socket_type_handler_;
};

    
}

#endif // BIZ_CORE_LINK_SOCKET_H_
