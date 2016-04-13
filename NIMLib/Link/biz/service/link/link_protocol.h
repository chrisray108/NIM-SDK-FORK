// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/9/30
//
// Link Service interfaces and protocol definition

#ifndef BIZ_SERVICE_LINK_LINK_PROTOCOL_H_
#define BIZ_SERVICE_LINK_LINK_PROTOCOL_H_

#include "biz/protocol/linkframe.h"
#include "biz/protocol/protocol.h"
#include "biz/core/link_socket.h"
#include "biz/core/service.h"


namespace nimbiz
{

// 协议编号
enum
{
	CID_EXCHANGE_KEY = 1,       // 交换密钥
	CID_HEARTBEAT = 2,          // 发送心跳
};


class ILinkService : public IService
{
public:
	ILinkService() : IService(SVID_NIM_LINK) {}
    
	virtual void Invoke_Ping() = 0;
	virtual void Remote_Ping() = 0;
    
	virtual bool	Create(const nbase::ProxySet *proxy = NULL) = 0 ;
	virtual bool	ConnectLink( const UTF8String &link_addr, uint16_t port) = 0;
	virtual void	SetClosing() = 0;	
	virtual bool	DisConnect() = 0;	
	virtual bool	SendPacket(LinkFrame &lf, const nbase::Marshallable &req) = 0;
    
	virtual void	RegisterCallback(ILinkSocketCallback *cb) = 0;
	virtual void	UnRegisterCallback() = 0;
    
    virtual void    NotifyConnectLink(bool connected) = 0;
};
    
}

#endif // BIZ_SERVICE_LINK_LINK_PROTOCOL_H_
