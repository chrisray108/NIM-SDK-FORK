//
//  friend_protocol.h
//  NIMLib
//
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef NIMLib_friend_protocol_h
#define NIMLib_friend_protocol_h


#include "biz/core/service.h"
#include "biz/protocol/property.h"
#include "biz/protocol/response_code.h"
#include "biz/core/yixin_core.h"

namespace nimbiz
{

enum
{
    CID_FRIEND_ADD              = 1,//添加好友
    CID_FRIEND_DEL              = 2,//删除好友
    CID_FRIEND_UPDATE           = 3,//更新好友信息

    CID_FRIEND_SYNC_LIST        = 5,//同步好友列表
    CID_FRIEND_SYNC_FRIEND_INFO = 6,//同步好友信息

    CID_FRIEND_SYNC_ADD         = 101,//添加好友多端同步
    CID_FRIEND_SYNC_DEL         = 102,//删除好友多端同步
    CID_FRIEND_SYNC_UPDATE      = 103,//更新好友多端同步
};

enum
{
    NIMUListTagId       =   4,
    NIMUListTagFlag     =   5,
    NIMUListTagBeFlag   =   6,
    NIMUListTagAlias    =   8,
    NIMUListTagEx       =   10,
};


struct FriendRequest : nbase::Marshallable
{
    UTF8String uid_;
    int32_t type_;
    UTF8String msg_;
    
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr(uid_);
        p.push_uint8((uint8_t)type_);
        p.push_varstr(msg_);
    }
    YX_REQUEST_ONLY();
};



#pragma mark - ISessionService
class IFriendService : public IService
{
public:
    IFriendService() : IService(SVID_NIM_FRIEND) {}
public:
    virtual int32_t     Invoke_RequestFriend(const FriendRequest &request,const IAsynCallback &callback) = 0;
    virtual void        Remote_RequestFriend(const FriendRequest &request,const IAsynCallback &callback,int32_t task_id) = 0;
    
    virtual int32_t     Invoke_DeleteFriend(const UTF8String &uid,const IAsynCallback &callback) = 0;
    virtual void        Remote_DeleteFriend(const UTF8String &uid,const IAsynCallback &callback,int32_t task_id) = 0;
    
    
    virtual int32_t     Invoke_UpdateFriend(const Property &info,const IAsynCallback &callback) = 0;
    virtual void        Remote_UpdateFriend(const Property &info,const IAsynCallback &callback,int32_t task_id) = 0;
    

    
    virtual uint32_t    GetMyFriends(std::list<UTF8String> &uids) = 0;
    virtual void        GetFriendInfo(const UTF8String &uid,Property &property) = 0;
    virtual void        MarkFriendTag(const UTF8String &uid,bool is_friend) = 0;
    
    

};

}

#endif
