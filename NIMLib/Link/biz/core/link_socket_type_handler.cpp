//
//  link_socket_type_handler.cpp
//  NIMLib
//
//  Created by amao on 12/15/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#include "link_socket_type_handler.hpp"
#include "util/ios_util.h"
#include "biz/service/link/link_protocol.h"
#include "biz/core/yixin_core.h"
#include "biz/service/chatroom/chatroom_protocol.h"

namespace nimbiz
{
    LinkSocketTypeHanlder::LinkSocketTypeHanlder()
    {
        type_ = LinkSocketTypeApp;
        description_ = "(App Link)";
    }
    
    LinkSocketTypeHanlder::LinkSocketTypeHanlder(const UTF8String &room_id)
    {
        type_ = LinkSocketTypeChatroom;
        description_ = " (Room Link " + room_id + ")";
        room_id_ = room_id;
    }
    
    void    LinkSocketTypeHanlder::Ping()
    {
        if (type_ == LinkSocketTypeApp)
        {
            ILinkService *service = (ILinkService *)GetServiceFromCore(SVID_NIM_LINK);
            if (service)
            {
                service->Invoke_Ping();
            }
        }
        else if(type_ == LinkSocketTypeChatroom)
        {
            IChatroomService *service = (IChatroomService *)GetServiceFromCore(SVID_NIM_CHATROOM);
            if (service)
            {
                service->Invoke_Ping(room_id_);
            }
        }
    }
    
    
    void    LinkSocketTypeHanlder::ReportError(bool fatal)
    {
        if (type_ == LinkSocketTypeApp)
        {
            nimbiz::SetShouldSwitchLinkHost(fatal);
        }
        else if (type_ == LinkSocketTypeChatroom)
        {
            nimbiz::SetShouldSwitchChatroomHost(room_id_, fatal);
        }
    }
    
    
    const char * LinkSocketTypeHanlder::GetDescription()
    {
        return description_.c_str();
    }
    
    
    bool    LinkSocketTypeHanlder::ShouldIngore(const nimbiz::LinkFrame &lf)
    {
        if (type_ == LinkSocketTypeApp)
        {
            return lf.service_id_ != SVID_NIM_AUTH && lf.service_id_ != SVID_NIM_LINK;
        }
        else if(type_ == LinkSocketTypeChatroom)
        {
            return lf.service_id_ != SVID_NIM_CHATROOM && lf.command_id_ != CID_CR_ENTER;
        }
        return true;
    }
    
}