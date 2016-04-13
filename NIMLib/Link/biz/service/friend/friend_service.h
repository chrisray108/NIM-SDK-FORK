//
//  user_service.h
//  NIMLib
//
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef __NIMLib__friend_service__
#define __NIMLib__friend_service__

#include "friend_protocol.h"

namespace nimbiz
{

class FriendService : public IFriendService
{
public:
    FriendService() {}
    
    virtual void Release() {delete this;}
    
    virtual bool OnLoad();
    // 卸载服务后
    virtual void OnUnLoad();
    
    // 收到网络包的处理函数
    virtual uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up);
    
    virtual bool OnWaitablePacket(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);
    
public:
    virtual int32_t     Invoke_RequestFriend(const FriendRequest &request,const IAsynCallback &callback);
    virtual void        Remote_RequestFriend(const FriendRequest &request,const IAsynCallback &callback,int32_t task_id);
    
    virtual int32_t     Invoke_DeleteFriend(const UTF8String &uid,const IAsynCallback &callback);
    virtual void        Remote_DeleteFriend(const UTF8String &uid,const IAsynCallback &callback,int32_t task_id);
    
    virtual int32_t     Invoke_UpdateFriend(const Property &info,const IAsynCallback &callback);
    virtual void        Remote_UpdateFriend(const Property &info,const IAsynCallback &callback,int32_t task_id);
    
    virtual uint32_t    GetMyFriends(std::list<UTF8String> &uids);
    virtual void        GetFriendInfo(const UTF8String &uid,Property &property);
    virtual void        MarkFriendTag(const UTF8String &uid,bool is_friend);
private:
    void    OnWaitPacketAddRequest(LinkFrame &lf,
                                   const nbase::Unpack &up,
                                   const CoreCallback &callback);
    void    OnWaitPacketDeleteFriend(LinkFrame &lf,
                                     const nbase::Unpack &up,
                                     const CoreCallback &callback);
    
    void    OnWaitPacketUpdateFriend(LinkFrame &lf,
                                     const nbase::Unpack &up,
                                     const CoreCallback &callback);
    
    void    OnPacketSyncAdd(LinkFrame &lf, const nbase::Unpack &up);
    void    OnPacketSyncDelete(LinkFrame &lf, const nbase::Unpack &up);
    void    OnPacketSyncUpdate(LinkFrame &lf, const nbase::Unpack &up);
    void    OnPacketSyncList(LinkFrame &lf, const nbase::Unpack &up);
    void    OnPacketSyncFriendInfo(LinkFrame &lf, const nbase::Unpack &up);

    void    RaiseCallback(const IAsynCallback &callback,int32_t task_id,int32_t code);
};

}
#endif /* defined(__NIMLib__user_service__) */
