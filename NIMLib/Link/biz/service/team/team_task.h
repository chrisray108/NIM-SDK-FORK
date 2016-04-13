//
//  team_task.h
//  NIMLib
//
//  Created by chris on 15/3/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_team_task_h
#define NIMLib_team_task_h

#include "team_protocol.h"
#include "biz/protocol/property.h"
#include "biz/core/eim_task.h"

namespace nimbiz
{

//创建群
class CreateTeamTask: public YixinTask
{
public:
    CreateTeamTask(const Property &info,const UTF8String &postscript,const std::list<UTF8String> &users)
    : info_(info),postscript_(postscript),users_(users) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_CreateTeam(info_ ,postscript_,users_, GetTaskId());
        }
    }
private:
    Property info_;
    UTF8String  postscript_;
    std::list<UTF8String>   users_;
};

//群邀请
class TeamInviteTask: public YixinTask
{
public:
    TeamInviteTask(const UTF8String &team_id,const UTF8String &postscript,const std::list<UTF8String> &users)
    : team_id_(team_id),postscript_(postscript),users_(users) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_TeamInvite(team_id_,postscript_,users_, GetTaskId());
        }
    }
    
private:
    UTF8String  team_id_;
    UTF8String  postscript_;
    std::list<UTF8String>   users_;
};

//群踢人
class TeamKickTask: public YixinTask
{
public:
    TeamKickTask(const UTF8String &team_id,const std::list<UTF8String> &users)
    : team_id_(team_id),users_(users) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_TeamKick(team_id_, users_, GetTaskId());
        }
    }
    
private:
    UTF8String  team_id_;
    std::list<UTF8String>   users_;
};

//退群
class TeamLeaveTask: public YixinTask
{
public:
    TeamLeaveTask(const UTF8String &team_id)
    : team_id_(team_id){}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_TeamLeave(team_id_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
};

//获取单个群信息
class TeamGetInfoTask : public YixinTask
{
public:
    TeamGetInfoTask(const UTF8String &team_id)
    : team_id_(team_id){}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_GetTeamInfo(team_id_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
};

//获取单个群信息
class AsyncTeamGetInfoTask : public YixinTask
{
public:
    AsyncTeamGetInfoTask(const UTF8String &team_id)
    : team_id_(team_id) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_AsyncGetTeamInfo(team_id_);
        }
    }
private:
    UTF8String  team_id_;
};

//获取所有群信息
class TeamGetInfoBatchTask : public YixinTask
{
public:
    TeamGetInfoBatchTask() {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_GetTeamInfoBatch(GetTaskId());
        }
    }
};

//修改群信息
class TeamUpdateInfoTask : public YixinTask
{
public:
    TeamUpdateInfoTask(const Property &team_info)
    : team_info_(team_info) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_UpdateTeamInfo(team_info_, GetTaskId());
        }
    }
private:
    Property  team_info_;
};

//刷群成员
class TeamRefreshMembersTask: public YixinTask
{
public:
    TeamRefreshMembersTask(const UTF8String &team_id)
    : team_id_(team_id) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_RefreshTeamMembers(team_id_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
};

//解散群
class DismissTeamTask: public YixinTask
{
public:
    DismissTeamTask(const UTF8String &team_id)
    : team_id_(team_id) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_DismissTeam(team_id_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
};

//申请入群
class TeamApplyTask: public YixinTask
{
public:
    TeamApplyTask(const UTF8String &team_id,UTF8String apply_message)
    : team_id_(team_id),apply_message_(apply_message) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_TeamApply(team_id_, apply_message_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
    UTF8String  apply_message_;
};


//同意申请
class TeamApplyPassTask: public YixinTask
{
public:
    TeamApplyPassTask(const UTF8String &team_id,const UTF8String &accid)
    : team_id_(team_id),accid_(accid) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_TeamApplyPass(team_id_, accid_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
    UTF8String  accid_;
};


//同意申请
class TeamApplyRejectTask: public YixinTask
{
public:
    TeamApplyRejectTask(const UTF8String &team_id,const UTF8String &accid,const UTF8String &reason)
    : team_id_(team_id),accid_(accid),reason_(reason) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_TeamApplyReject(team_id_, accid_, reason_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
    UTF8String  accid_;
    UTF8String  reason_;
};

//添加管理员
class TeamAddManagerTask : public YixinTask
{
public:
    TeamAddManagerTask(const UTF8String &team_id,const std::list<UTF8String> &users)
    : team_id_(team_id),users_(users) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_AddManager(team_id_, users_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
    std::list<UTF8String>   users_;
};

//移除管理员
class TeamRemoveManagerTask : public YixinTask
{
public:
    TeamRemoveManagerTask(const UTF8String &team_id,const std::list<UTF8String> &users)
    : team_id_(team_id),users_(users) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_RemoveManager(team_id_, users_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
    std::list<UTF8String>   users_;
};

//移交群主
class TeamTransferOwner : public YixinTask
{
public:
    TeamTransferOwner(const UTF8String &team_id,const UTF8String &new_owner,bool is_leave)
    : team_id_(team_id),new_owner_(new_owner),is_leave_(is_leave) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_TransferOwner(team_id_, new_owner_, is_leave_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
    UTF8String  new_owner_;
    bool        is_leave_;
};

//修改自己的群属性
class TeamUpdateMyTListTask : public YixinTask
{
public:
    TeamUpdateMyTListTask(const Property &info)
    : info_(info) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_UpdateMyTlist(info_, GetTaskId());
        }
    }
private:
    Property    info_;
};


//修改别人的群昵称
class TeamUpdateOtherTlistTask : public YixinTask
{
public:
    TeamUpdateOtherTlistTask(const Property &info)
    : info_(info) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_UpdateOtherTList(info_, GetTaskId());
        }
    }
private:
    Property    info_;
};

//接受邀请
class TeamAcceptInvite : public YixinTask
{
public:
    TeamAcceptInvite(const UTF8String &team_id,const UTF8String &invitor_id)
    : team_id_(team_id),invitor_id_(invitor_id) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_AcceptInvite(team_id_, invitor_id_, GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
    UTF8String  invitor_id_;
};

//拒绝邀请
class TeamRejectInvite : public YixinTask
{
public:
    TeamRejectInvite(const UTF8String &team_id,const UTF8String &invitor_id,const UTF8String &reject_reason)
    : team_id_(team_id),invitor_id_(invitor_id),reject_reason_(reject_reason) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_RejectInvite(team_id_, invitor_id_, reject_reason_,GetTaskId());
        }
    }
private:
    UTF8String  team_id_;
    UTF8String  invitor_id_;
    UTF8String  reject_reason_;
};

//漫游消息
class TeamHistoryMessage : public YixinTask
{
public:
    TeamHistoryMessage(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback)
    : param_(param),callback_(callback) {}
public:
    virtual void Run()
    {
        ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
        if (service)
        {
            service->Remote_HistoryMsg(param_,callback_,GetTaskId());
        }
    }
    
private:
    SessionHistoryMsgReqeustParam param_;
    IAsynCallback callback_;
};

}
#endif
