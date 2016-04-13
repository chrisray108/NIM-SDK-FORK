// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/9/30
//
// Link Service header file

#ifndef BIZ_SERVICE_LINK_LINK_SERVICE_H_
#define BIZ_SERVICE_LINK_LINK_SERVICE_H_

#include "link_protocol.h"
#include "biz/core/link_socket.h"
#include "biz/core/yixin_core.h"
#include "base/time/timer.h"

namespace nimbiz
{

enum
{
    CID_ENCRYPT = 10,
};

class LinkService : public ILinkService
{
public:
	LinkService();
	~LinkService(void);
    virtual void	Release() { delete this; }
    
public:
	virtual void Invoke_Ping();
	virtual void Remote_Ping();
    
public:
	virtual bool	Create(const nbase::ProxySet *proxy = NULL);
	virtual bool	ConnectLink(const std::string &link_addr, uint16_t port);
	virtual void	SetClosing();	
	virtual bool	DisConnect();
	
	virtual void	RegisterCallback(ILinkSocketCallback *cb);
	virtual void	UnRegisterCallback();
    
    
    virtual bool	SendPacket(LinkFrame &lf, const nbase::Marshallable &req);
	virtual uint32_t	OnPacket(LinkFrame &lf, const nbase::Unpack &up);
    
    virtual void    NotifyConnectLink(bool connected);
    
private:
	LinkSocket      *link_socket_;
};

//////////////////////////////////////////////////////////////////////////
// Ping task class
class PingTask : public YixinTask
{
public:
	PingTask(){};
	~PingTask(void){};
    
	void Run()
	{
        IYixinCore *popo = IYixinCore_Get();
        if (NULL == popo || false == popo->IsLogin())
            return;
		ILinkService *link_service = (ILinkService*)popo->GetService(SVID_NIM_LINK);
		link_service->Remote_Ping();
	}
	void Release()
	{
		delete this;
	}
    
};
    
}

#endif // BIZ_SERVICE_LINK_LINK_SERVICE_H_
