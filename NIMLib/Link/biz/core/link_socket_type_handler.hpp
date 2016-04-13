//
//  link_socket_type_handler.hpp
//  NIMLib
//
//  Created by amao on 12/15/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#ifndef link_socket_type_handler_hpp
#define link_socket_type_handler_hpp
#include "biz/protocol/linkframe.h"

//对于不同类型的操作,为安全起见直接使用硬编码,不使用接口/继承的方式实现

namespace nimbiz
{
    enum LinkSocketType
    {
        LinkSocketTypeApp,
        LinkSocketTypeChatroom,
    };
    
    class LinkSocketTypeHanlder
    {
    public:
        LinkSocketTypeHanlder();
        LinkSocketTypeHanlder(const UTF8String &room_id);
    public:
        void    Ping();
        void    ReportError(bool fatal);
        const char *GetDescription();
        bool    ShouldIngore(const LinkFrame &lf);
        
    private:
        LinkSocketType  type_;
        UTF8String      description_;
        UTF8String      room_id_;
    };
}

#endif /* link_socket_type_handler_hpp */
