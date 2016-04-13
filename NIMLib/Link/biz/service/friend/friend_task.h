//
//  user_task.h
//  NIMLib
//
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef NIMLib_friend_task_h
#define NIMLib_friend_task_h

#include "friend_protocol.h"
#include "biz/protocol/property.h"
#include "biz/core/eim_task.h"

namespace nimbiz
{

class RequestFriendTask : public YixinTask
{
public:
    RequestFriendTask(const FriendRequest &request,const IAsynCallback &callback)
    :request_(request),callback_(callback) {}
    
    virtual void Run()
    {
        IFriendService *service = (IFriendService *)GetServiceFromCore(SVID_NIM_FRIEND);
        if (service)
        {
            service->Remote_RequestFriend(request_,callback_,GetTaskId());
        }
    }

private:
    FriendRequest   request_;
    IAsynCallback   callback_;
};

class DeleteFriendTask: public YixinTask
{
public:
    DeleteFriendTask(const UTF8String &uid,const IAsynCallback &callback)
    :uid_(uid),callback_(callback){}
public:
    virtual void Run()
    {
        IFriendService *service = (IFriendService *)GetServiceFromCore(SVID_NIM_FRIEND);
        if (service)
        {
            service->Remote_DeleteFriend(uid_, callback_, GetTaskId());
        }
    }
private:
    UTF8String uid_;
    IAsynCallback callback_;
};



class UpdateFriendTask: public YixinTask
{
public:
    UpdateFriendTask(const Property &info,const IAsynCallback &callback)
    :info_(info),callback_(callback){}
public:
    virtual void Run()
    {
        IFriendService *service = (IFriendService *)GetServiceFromCore(SVID_NIM_FRIEND);
        if (service)
        {
            service->Remote_UpdateFriend(info_, callback_, GetTaskId());
        }
    }
private:
    Property info_;
    IAsynCallback callback_;
};


}


#endif
