// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/9/30
//
// 该文件定义了一个管理与link服务器的网络连接的类

#include "link_service.h"
#include <zlib.h>
#include "util/rsa_util.h"
#include "biz/service/auth/auth_protocol.h"

namespace nimbiz
{

LinkService::LinkService()
{
    link_socket_ = NULL;
}

LinkService::~LinkService()
{
    SAFE_DELETE(link_socket_);
}

void LinkService::Invoke_Ping()
{
    PingTask* task = new PingTask();
    IYixinCore *popo = IYixinCore_Get();
	popo->PostTask(task);

}

void LinkService::Remote_Ping()
{
    LinkFrame lf(SVID_NIM_LINK, CID_HEARTBEAT);			
	SendPacket(lf, nbase::Voidmable());
}


bool LinkService::Create(const nbase::ProxySet *proxy/* = NULL*/)
{
    link_socket_ = new LinkSocket();
    return link_socket_->Create(proxy);
}


bool LinkService::ConnectLink(const std::string &link_addr, uint16_t port)
{
    if (link_socket_) 
    {
        link_socket_->Connect(link_addr.c_str(), port);
    }
    return true;
}

void LinkService::SetClosing()
{
    if (link_socket_)
    {
        link_socket_->SetClosing();
    }
}


bool LinkService::DisConnect()
{
    if (link_socket_)
    {
        link_socket_->Close();
    }
    return true;
}

void LinkService::RegisterCallback(ILinkSocketCallback *cb)
{
    if (link_socket_)
    {
        link_socket_->RegisterCallback(cb);
    }
}

void LinkService::UnRegisterCallback()
{
    if (link_socket_)
    {
        link_socket_->UnregisterCallback();
    }
}

bool LinkService::SendPacket(LinkFrame &lf, const nbase::Marshallable &req)
{
    return link_socket_ ? link_socket_->SendPacket(lf, req) : false;
}

uint32_t LinkService::OnPacket(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.command_id_ == CID_ENCRYPT)
    {
        if (lf.error_ == NIMResVersionError)
        {
            int version = up.pop_uint32();
            UTF8String raw_modules_data = up.pop_varstr();
            uint32_t server_crc32 = up.pop_uint32();
            uint32_t module_crc32 =  (uint32_t)crc32(0,(const Bytef *)raw_modules_data.c_str(),(uInt)raw_modules_data.size());
            if (server_crc32 == module_crc32)
            {
                UTF8String hex_modules;
                nbase::BinaryToHexString(raw_modules_data.c_str(), raw_modules_data.size(), hex_modules);
                nimbiz::SaveRSAConfig(hex_modules, version);
            }
            else
            {
                DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "CRC32 %u vs %u",crc32,module_crc32);
            }
            
        }
    }
    return NIMOnPacketSuccess;
}


void LinkService::NotifyConnectLink(bool connected)
{
    IYixinCore *core = IYixinCore_Get();
    IAuthService *auth = (IAuthService *)core->GetService(SVID_NIM_AUTH);
    auth->Notify_Connect(connected);
}

    
}

