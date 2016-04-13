//
//  notify_protocol.h
//  YixinCall
//
//  Created by amao on 10/24/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#ifndef YixinCall_notify_protocol_h
#define YixinCall_notify_protocol_h

#include "biz/core/service.h"
#include "biz/protocol/property.h"

namespace nimbiz
{

enum
{
    CID_NOTIFY_CTOC             = 1,		//点对点的通知
    CID_NOTIFY_STOC             = 2,		//服务器－》客户端的通知
    CID_NOTIFY_MARK_READ        = 3,        //标记通知已读
    CID_NOTIFY_SYNC_UNREAD      = 4,        //同步未读离线消息
    CID_BATCH_MARK_READ         = 5,        //批量标记已读
    CID_SYNC_SYSTEM_MSG         = 6,        //获取离线消息
    CID_SYNC_PUSH               = 7,        //获取推送信息
    CID_SYNC_NETCALL_MSG        = 8,        //获取离线网络电话消息
    CID_SYNC_ROAM_MSG           = 9,        //获取漫游消息
    CID_NOTIFY_ROOM_C           = 10,       //聊天室的在线消息
    CID_NOTIFY_ROOM_S           = 11,       //聊天室的离线消息
    CID_SYNC_RECEIPT            = 12,       //已读回执
};

class INotifyService : public IService
{
public:
    INotifyService() : IService(SVID_NIM_NOTIFY) {}
    
    
public:
    virtual void    Register_RecvMsgsCallback(const IAsynCallback &callback) = 0;
    virtual void    Register_RecvNetCallsCallback(const IAsynCallback &callback) = 0;
    virtual void    Remote_BatchMarkRead(const LinkFrame &lf,const std::vector<uint64_t> &msg_ids) = 0;
};

}


#endif
