//
//  chatroom_linkservice.hpp
//  NIMLib
//
//  Created by amao on 12/8/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#ifndef chatroom_linkservice_hpp
#define chatroom_linkservice_hpp

#include "biz/protocol/linkframe.h"
#include "biz/core/link_socket.h"
#include "biz/core/yixin_core.h"
#include "base/time/timer.h"
#include "base/synchronization/lock.h"

namespace nimbiz
{
    class ChatroomLinkService : public ILinkSocketCallback
    {
    public:
        ChatroomLinkService(const UTF8String &room_id,const UTF8String &link_id);
        ~ChatroomLinkService();
        
    public:
        bool	ConnectLink(const std::string &link_addr, uint16_t port);
        
        bool	SendPacket(LinkFrame &lf, const nbase::Marshallable &req);
        
        
        
    public:
        virtual void OnConnected(NetErrorCode error);
        virtual void OnDisConnected(NetErrorCode error);
        virtual void OnParseError();
        virtual void OnPacket(nbase::Unpack &up);
        
    private:
        UTF8String      room_id_;
        UTF8String      link_id_;
        LinkSocket      *link_socket_;
    };
    
}

#endif /* chatroom_linkservice_hpp */
