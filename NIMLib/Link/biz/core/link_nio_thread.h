// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/9/27
//
// This file defines the interface to send and receive data with server

#ifndef BIZ_CORE_LINK_NIO_THREAD_H_
#define BIZ_CORE_LINK_NIO_THREAD_H_

#include "base/thread/framework_thread.h"
#include "base/framework/task.h"
#include "link_socket.h"

namespace nimbiz
{

class LinkNioThread : public nbase::FrameworkThread
{
public:
    LinkNioThread()
    :FrameworkThread("LinkNioThread")
    {
        //event_init();
        signal(SIGPIPE, SIG_IGN);
    }
    
    void PostTask(nbase::Task *task)
    {
        if (IsRunning())
        {
            message_loop()->PostTask(task);
        }
    }
};

class SendPacketTask : public nbase::Task 
{
public:
    SendPacketTask(LinkSocket *link_socket, const char *buf, size_t length)
    :link_socket_(link_socket)
    {
        buff_.assign(buf, length);
    }
    virtual void Run()
    {
        link_socket_->ExcuteSend(buff_.c_str(), buff_.size());
    }
    
private:
    LinkSocket      *link_socket_;
    std::string     buff_;
};

class ConnectSocketTask : public nbase::Task
{
public:
    ConnectSocketTask(LinkSocket *link_socket, const char *host, uint16_t port, int timeout)
    : link_socket_(link_socket), port_(port), timeout_(timeout)
    {
        host_.assign(host, strlen(host));
    }
    virtual void Run()
    {
        link_socket_->ConnectHelper(host_.c_str(), port_, timeout_);
    }
    
private:
    LinkSocket      *link_socket_;
    std::string     host_;
    uint16_t        port_;
    int             timeout_;
};

class CloseSocketTask : public nbase::Task
{
public:
    CloseSocketTask(LinkSocket *link_socket)
    : link_socket_(link_socket)
    {
        
    }
    virtual void Run()
    {
        link_socket_->CloseHelper();
    }

private:
    LinkSocket      *link_socket_;
};

}
#endif // BIZ_CORE_LINK_NIO_THREAD_H_
