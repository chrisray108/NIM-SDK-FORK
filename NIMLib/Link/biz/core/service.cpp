// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/10/09
//
// Service implement file, register all services here

#include "biz/core/yixin_core.h"
#include "biz/service/auth/auth_service.h"
#include "biz/service/notify/notify_service.h"
#include "biz/service/misc/misc_service.h"
#include "biz/service/session/session_service.h"
#include "biz/service/sync/sync_service.h"
#include "biz/service/user/user_service.h"
#include "biz/service/team/team_service.h"
#include "biz/service/netcall/netcall_service.h"
#include "biz/service/rts/rts_service.h"
#include "biz/service/friend/friend_service.h"
#include "biz/service/chatroom/chatroom_service.h"

namespace nimbiz
{

bool LoadPreLoginServices()
{
    IYixinCore *core = IYixinCore_Get();
    if (core)
    {
        core->RegisterService(new AuthService());


    }
    return false;
}

bool LoadCoreServices()
{
    IYixinCore *core = IYixinCore_Get();
    if (core)
    {
        core->RegisterService(new NotifyService());
        core->RegisterService(new MiscService());
        core->RegisterService(new SessionService());
        core->RegisterService(new SyncService());
        core->RegisterService(new UserService());
        core->RegisterService(new TeamService());
        core->RegisterService(new NetcallService());
        core->RegisterService(new RtsService());
        core->RegisterService(new FriendService());
        core->RegisterService(new ChatroomService());
        return true;
    }
    return false;
}

}