//
//  chatroom_info.h
//  NIMLib
//
//  Created by amao on 12/8/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#ifndef chatroom_info_h
#define chatroom_info_h

#include "chatroom_linkservice.h"

namespace nimbiz
{
    struct ChatroomLinker
    {
        UTF8String              room_id_;
        UTF8String              link_id_;
        IAsynCallback           callback_;
        ChatroomLinkService     *room_link_;
        bool                    logined_;
        
        ChatroomLinker(const UTF8String &room_id,const UTF8String link_id)
        :room_id_(room_id),link_id_(link_id),logined_(false)
        {
            room_link_ = new ChatroomLinkService(room_id_,link_id_);
        }
        ~ChatroomLinker()
        {
            SAFE_DELETE(room_link_);
        }

    };
}

#endif /* chatroom_info_h */
