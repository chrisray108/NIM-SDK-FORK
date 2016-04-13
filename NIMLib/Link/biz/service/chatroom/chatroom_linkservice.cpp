//
//  chatroom_linkservice.cpp
//  NIMLib
//
//  Created by amao on 12/8/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#include "chatroom_linkservice.h"
#include "chatroom_task.h"
#include "biz/core/core_task.h"
#include "base/util/string_util.h"

namespace nimbiz
{
    ChatroomLinkService::ChatroomLinkService(const UTF8String &room_id,const UTF8String &link_id)
    :room_id_(room_id),link_id_(link_id)
    {
        link_socket_ = new LinkSocket;
        link_socket_->SetTypeHanlder(LinkSocketTypeHanlder(room_id_));
        link_socket_->RegisterCallback(this);
        link_socket_->Create();
    }
    
    ChatroomLinkService::~ChatroomLinkService()
    {
        link_socket_->SetClosing();
        link_socket_->RegisterCallback(NULL);
        link_socket_->Close();
        SAFE_DELETE(link_socket_);
    }
    
    bool    ChatroomLinkService::ConnectLink(const std::string &link_addr, uint16_t port)
    {
        nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Link %s address %s:%d",room_id_.c_str(),link_addr.c_str(),(int32_t)port);
        if (link_socket_)
        {
            link_socket_->Connect(link_addr.c_str(), port);
        }
        return true;
    }

    
    bool    ChatroomLinkService::SendPacket(nimbiz::LinkFrame &lf, const nbase::Marshallable &req)
    {
        return link_socket_ ? link_socket_->SendPacket(lf, req) : false;
    }
    

#pragma mark - ILinkSocketCallback
    void    ChatroomLinkService::OnConnected(NetErrorCode error)
    {
        nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "On Connect %s link id %s code %d",
                      room_id_.c_str(),link_id_.c_str(),(int32_t)error);
        IYixinCore_Get()->PostTask(new ChatroomNotifyConnectTask(room_id_,link_id_,error));
    }
    
    
    void    ChatroomLinkService::OnDisConnected(NetErrorCode error)
    {
        nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "On Disconnect %s link id %s code %d",
                      room_id_.c_str(),link_id_.c_str(),(int32_t)error);
        if (error == kConnectFailed)
        {
            IYixinCore_Get()->PostTask(new ChatroomNotifyConnectTask(room_id_,link_id_,error));
        }
        else
        {
            IYixinCore_Get()->PostTask(new ChatroomNotifyDisconnectedTask(room_id_,link_id_,error));
        }
    }
    
    
    void    ChatroomLinkService::OnPacket(nbase::Unpack &up)
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
        
        nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Receive Chatroom Packet : RID %s SID %d CID %d SER %d RES %d",
                      room_id_.c_str(),lf.service_id_,lf.command_id_,lf.serial_id_,lf.error_);
        
        //派发包
        lf.room_id_ = room_id_; //设置room id 使得后续操作都可以拿到
        PacketDispatchTask *task = new PacketDispatchTask(lf, up);
        IYixinCore_Get()->PostTask(task);
    }
    
    void    ChatroomLinkService::OnParseError()
    {
        
    }
        
}