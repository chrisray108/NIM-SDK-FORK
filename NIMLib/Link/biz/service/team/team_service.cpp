//
//  session_service.cpp
//  NIMLib
//
//  Created by amao on 15/1/30.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#include "team_service.h"
#include "util/ios_util.h"
#include "util/ios_types.h"
#include "team_task.h"
#include "biz/service/session/session_protocol.h"
#include "biz/service/sync/sync_protocol.h"
#include "biz/service/user/user_protocol.h"


namespace nimbiz
{

#pragma mark - Request and Response
struct CreateTeamReqeust : nbase::Marshallable
{
    Property info_;
    std::list<UTF8String> users_;
    UTF8String postscript_;
    void marshal(nbase::Pack &p) const
    {
        p << info_;
        size_t size = users_.size();
        p.push_len((uint32_t)size);
        for (auto it = users_.begin(); it!= users_.end(); it++)
        {
            p.push_varstr(*it);
        }
        p.push_varstr(postscript_);
    }
    YX_REQUEST_ONLY();
};

struct DismissTeamReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
    }
    YX_REQUEST_ONLY();
};

struct SyncTeamsResponse : nbase::Marshallable
{
    uint64_t timetag_;
    PropertyList infos_;
    void unmarshal(const nbase::Unpack &up)
    {
        timetag_ = up.pop_uint64();
        infos_.unmarshal(up);
    }
    YX_RESPONSE_ONLY();
};


struct SyncTeamUsersResponse : nbase::Marshallable
{
    UTF8String tid_;
    PropertyList users_;
    uint64_t timetag_;
    void unmarshal(const nbase::Unpack &up)
    {
        tid_ = up.pop_uint64_as_str();
        users_.unmarshal(up);
        timetag_ = up.pop_uint64();
    }
    YX_RESPONSE_ONLY();
};

struct TeamInviteReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    std::list<UTF8String> users_;
    UTF8String postscript_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        size_t size = users_.size();
        p.push_len((uint32_t)size);
        for (auto it = users_.begin(); it!= users_.end(); it++)
        {
            p.push_varstr(*it);
        }
        p.push_varstr(postscript_);
    }
    YX_REQUEST_ONLY();
};

struct TeamKickReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    std::list<UTF8String> users_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        size_t size = users_.size();
        p.push_len((uint32_t)size);
        for (auto it = users_.begin(); it!= users_.end(); it++)
        {
            p.push_varstr(*it);
        }
    }
    YX_REQUEST_ONLY();
};

struct TeamLeaveReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
    }
    YX_REQUEST_ONLY();
};

struct TeamLeaveResponse : nbase::Marshallable
{
    UTF8String team_id_;
    void unmarshal(const nbase::Unpack &up)
    {
        team_id_ = up.pop_uint64_as_str();
    }
    YX_RESPONSE_ONLY();
};

struct TeamApplyReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    UTF8String apply_message_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        p.push_varstr(apply_message_);
    }
    YX_REQUEST_ONLY();
};

struct TeamApplyPassReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    UTF8String accid_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        p.push_varstr(accid_);
    }
    YX_REQUEST_ONLY();
};

struct TeamApplyRejectReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    UTF8String accid_;
    UTF8String reject_reason_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        p.push_varstr(accid_);
        p.push_varstr(reject_reason_);
    }
    YX_REQUEST_ONLY();
};

struct TeamAddManagerReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    std::list<UTF8String> users_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        size_t size = users_.size();
        p.push_len((uint32_t)size);
        for (auto it = users_.begin(); it!= users_.end(); it++)
        {
            p.push_varstr(*it);
        }
    }
    YX_REQUEST_ONLY();
};

struct TeamRemoveManagerReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    std::list<UTF8String> users_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        size_t size = users_.size();
        p.push_len((uint32_t)size);
        for (auto it = users_.begin(); it!= users_.end(); it++)
        {
            p.push_varstr(*it);
        }
    }
    YX_REQUEST_ONLY();
};

struct TeamTransferOwnerReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    UTF8String new_owner_id_;
    bool       is_leave_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        p.push_varstr(new_owner_id_);
        p.push_bool(is_leave_);
    }
    YX_REQUEST_ONLY();
};

struct TeamRejectInviteReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    UTF8String invitor_id_;
    UTF8String reject_reason_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        p.push_varstr(invitor_id_);
        p.push_varstr(reject_reason_);
    }
    YX_REQUEST_ONLY();
};

struct TeamAcceptInviteReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    UTF8String invitor_id_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        p.push_varstr(invitor_id_);
    }
    YX_REQUEST_ONLY();
};

struct TeamUpdateMyTListReqeust : nbase::Marshallable
{
    Property info_;
    void marshal(nbase::Pack &p) const
    {
        p << info_;
    }
    YX_REQUEST_ONLY();
};

struct TeamUpdateOtherInfoReqeust : nbase::Marshallable
{
    Property info_;
    void marshal(nbase::Pack &p) const
    {
        p << info_;
    }
    YX_REQUEST_ONLY();
};



struct TeamGetInfoReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
    }
    YX_REQUEST_ONLY();
};

struct TeamGetInfoBatchReqeust : nbase::Marshallable
{
    uint64_t timetag_;
    void marshal(nbase::Pack &p) const
    {
        p.push_uint64(timetag_);
    }
    YX_REQUEST_ONLY();
};

struct TeamGetInfoBatchResponse : nbase::Marshallable
{
    PropertyList teams_;
    uint64_t timetag_;
    void unmarshal(const nbase::Unpack &up)
    {
        teams_.unmarshal(up);
        timetag_  = up.pop_uint64();
    }
    YX_RESPONSE_ONLY();
};

struct TeamUpdateInfoReqeust : nbase::Marshallable
{
    Property team_info_;
    void marshal(nbase::Pack &p) const
    {
        p << team_info_;
    }
    YX_REQUEST_ONLY();
};

struct TeamRefreshMembersReqeust : nbase::Marshallable
{
    UTF8String team_id_;
    uint64_t timetag_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(team_id_);
        p.push_uint64(timetag_);
    }
    YX_REQUEST_ONLY();
};

struct TeamRefreshMembersResponse : nbase::Marshallable
{
    UTF8String team_id_;
    PropertyList members_;
    uint64_t timetag_;

    void unmarshal(const nbase::Unpack &up)
    {
        team_id_ = up.pop_uint64_as_str();
        members_.unmarshal(up);
        timetag_  = up.pop_uint64();
    }
    YX_RESPONSE_ONLY();
};

struct TeamHistoryMsgReqeust : nbase::Marshallable
{
    SessionHistoryMsgReqeustParam param_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr_as_uint64(param_.uid_);//即team id
        p.push_uint64(param_.from_time_);
        p.push_uint64(param_.end_time_);
        p.push_varstr_as_uint64(param_.end_msg_id);
        p.push_uint32(param_.limit_);
    }
    YX_REQUEST_ONLY();
};


#pragma mark - TeamService
bool    TeamService::OnLoad()
{
    return true;
}

void    TeamService::OnUnLoad()
{
}


uint32_t  TeamService::OnPacket(LinkFrame &lf, const nbase::Unpack &up)
{
    uint32_t result = NIMOnPacketSuccess;
    switch (lf.command_id_) {
        case CID_TEAM_NOTIFY_NEW:
            OnRecvMsg(lf, up);
            break;
        case CID_TEAM_OL_SYNC_SAY:
            OnRecvMsg(lf, up);
            break;
        case CID_TEAM_SYNC_TINFOS:
            OnSyncTeams(lf, up);
            break;
        case CID_TEAM_SYNC_TLIST:
            OnSyncTeamUsers(lf,up);
            break;
        case CID_TEAM_GET_INFO_BATCH:
            OnPacketTeamGetInfoBatch(lf, up);
            break;
        case CID_TEAM_GET_INFO:
            OnPacketGetTeamInfo(lf, up);
            break;
        case CID_TEAM_SYNC_CREATE:
            OnPacketOnCreateTeam(lf, up);
            break;
        case CID_TEAM_NOTIFY_SYNC_TLIST:
            OnNotifySyncTeamUsers(lf,up);
            break;
        default:
            result = NIMOnPacketCommandNotSupport;
            break;
    }
    return result;
}

bool    TeamService::OnWaitablePacket(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    bool handled = true;
    switch (lf.command_id_)
    {
        case CID_TEAM_CREATE:
            OnWaitPacketCreateTeam(lf, up, callback);
            break;
        case CID_TEAM_INVITE:
            OnWaitPacketTeamInvite(lf, up, callback);
            break;
        case CID_TEAM_KICK:
            OnWaitPacketTeamKick(lf, up, callback);
            break;
        case CID_TEAM_LEAVE:
            OnWaitPacketTeamLeave(lf, up, callback);
            break;
        case CID_TEAM_DISMISS:
            OnWaitPacketDismissTeam(lf, up, callback);
            break;
        case CID_TEAM_GET_MEMBERS:
            OnWaitPacketTeamRefreshMembers(lf, up, callback);
            break;
        case CID_TEAM_SAY:
            OnSendMsg(lf, up, callback);
            break;
        case CID_TEAM_UPDATE_INFO:
            OnWaitPacketUpdateTeamInfo(lf, up, callback);
            break;
        case CID_TEAM_APPLY:
            OnWaitPacketTeamApply(lf, up, callback);
            break;
        case CID_TEAM_APPLY_PASS:
            OnWaitPacketTeamApplyPass(lf, up, callback);
            break;
        case CID_TEAM_APPLY_REJECT:
            OnWaitPacketTeamApplyReject(lf, up, callback);
            break;
        case CID_TEAM_ADD_MANAGER:
            OnWaitPacketTeamAddManager(lf, up, callback);
            break;
        case CID_TEAM_REMOVE_MANAGER:
            OnWaitPacketTeamRemoveManager(lf, up, callback);
            break;
        case CID_TEAM_TRANSFER_OWNER:
            OnWaitPacketTeamTransferOwner(lf, up, callback);
            break;
        case CID_TEAM_ACCEPT_INVITE:
            OnWaitPacketTeamAcceptInvite(lf, up, callback);
            break;
        case CID_TEAM_REJECT_INVITE:
            OnWaitPacketTeamRejectInvite(lf, up, callback);
            break;
        case CID_TEAM_UPDATE_TLIST:
            OnWaitPacketTeamUpdateMyTList(lf,up,callback);
            break;
        case CID_TEAM_UPDATE_OTHER_TLIST:
            OnWaitPacketTeamUpdateOhterTList(lf, up, callback);
            break;
        case CID_TEAM_GET_INFO:
            OnWaitPacketTeamGetInfo(lf, up,callback);
            break;
        case CID_TEAM_HISTORY_MSG:
            OnWaitPacketHistoryMsg(lf, up, callback);
            break;
        default:
            handled = false;
            break;
    }
    return handled;
}

#pragma mark - 同步
void    TeamService::OnSyncTeams(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        SyncTeamsResponse response;
        response.unmarshal(up);
        
        for (auto it = response.infos_.list_.begin();
             it != response.infos_.list_.end(); it++)
        {
            IYixinCore_Get()->SetDataItem(DN_TINFO, it->get_string(NIMTeamTagID), *it);
        }
        
        ISyncService *sync = (ISyncService *)GetServiceFromCore(SVID_NIM_SYNC);
        if (sync)
        {
            sync->SetSyncTimetag(NIMSyncTagTeamInfos, response.timetag_);
        }
    }
}

void    TeamService::OnSyncTeamUsers(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        SyncTeamUsersResponse response;
        response.unmarshal(up);
        
        UTF8String tid = response.tid_;
        SaveTeamUsers(tid, response.users_.list_, false);
        IYixinCore_Get()->SetDataItem64Tag(DN_TINFO,tid , NIMTeamTagLocalTlistTimtag, response.timetag_);
    }
}

void    TeamService::OnNotifySyncTeamUsers(LinkFrame &lf,const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        Property tlist;
        up >> tlist;
        UTF8String team_id = tlist.get_string(NIMTeamMemberTagTID);
        std::list<Property> users;
        users.push_back(tlist);
        SaveTeamUsers(team_id, users,true);
    }
}



#pragma mark - 创建群
int32_t TeamService::Invoke_CreateTeam(const Property &info,const UTF8String &postscript,const std::list<UTF8String> &users)
{
    return IYixinCore_Get()->PostTask(new CreateTeamTask(info,postscript,users));
}


void    TeamService::Remote_CreateTeam(const Property &info, const UTF8String &postscript,const std::list<UTF8String> &users, int32_t task_id)
{
    CoreCallback cb;
    cb.task_id_ = task_id;
    
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_CREATE);
    CreateTeamReqeust req;
    req.info_ = info;
    req.users_ = users;
    req.postscript_ = postscript;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void    TeamService::OnWaitPacketCreateTeam(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeCreate);
    if (lf.error_ == NIMResSuccess || lf.error_ == NIMResTeamNotMember)
    {
        param.code_ = NIMResSuccess;
        Property info;
        up >> info;
        
        OnCreateTeam(info);
        
        UTF8String team_id = info.get_string(NIMTeamTagID);
        param.any_ = team_id;
    }
    RunTeamActionCB(param);
}

void    TeamService::OnPacketOnCreateTeam(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        Property info;
        up >> info;
        
        OnCreateTeam(info);
        
        UTF8String team_id = info.get_string(NIMTeamTagID);
        LinkFrame lf(SVID_NIM_SYNC,CID_SYNC_TLIST);
        SyncTeamUsersRequest request;
        request.teams_[team_id] = 0;
        IYixinCore_Get()->SendPacket(lf, request);
        
        RunTInfoChangedCB(team_id, NIMTeamChangedAdd);
    }
}

void    TeamService::OnCreateTeam(Property &info)
{
    info.put_int32(NIMTeamTagValidFlag, 1);
    info.put_int32(NIMTeamTagMemberValid, 1);
    
    UTF8String team_id = info.get_string(NIMTeamTagID);
    IYixinCore_Get()->SetDataItem(DN_TINFO, team_id, info);
    

    
    UTF8String uid = IYixinCore_Get()->GetUid();
    UTF8String creator = info.get_string(NIMTeamTagOwner);
    uint32_t user_type = creator == uid ? nimbiz::GetTeamMemberOwnerType() : nimbiz::GetTeamMemberNormalType();
    
    Property user;
    user.put_string(NIMTeamMemberTagTID, team_id);
    user.put_string(NIMTeamMemberTagAccountID, uid);
    user.put_uint32(NIMTeamMemberTagType,user_type);
    IYixinCore_Get()->SetDataItem(DN_TLIST, MakeItem(team_id, uid), user);

}

#pragma mark - 解散群
int32_t TeamService::Invoke_DismissTeam(const UTF8String &team_id){
    return IYixinCore_Get()->PostTask(new DismissTeamTask(team_id));
}

void  TeamService::Remote_DismissTeam(const UTF8String &team_id,int32_t task_id){
    CoreCallback cb;
    cb.task_id_ = task_id;
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_DISMISS);
    DismissTeamReqeust req;
    req.team_id_ = team_id;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void    TeamService::OnWaitPacketDismissTeam(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeDismiss);
    RunTeamActionCB(param);
}


#pragma mark - 拉人
int32_t TeamService::Invoke_TeamInvite(const UTF8String &team_id,const UTF8String &postscript,const std::list<UTF8String> &users){
    return IYixinCore_Get()->PostTask(new TeamInviteTask(team_id,postscript,users));
}

void    TeamService::Remote_TeamInvite(const UTF8String &team_id,const UTF8String &postscript,const std::list<UTF8String> &users,int32_t task_id){
    CoreCallback cb;
    cb.task_id_ = task_id;
    
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_INVITE);
    TeamInviteReqeust req;
    req.team_id_ = team_id;
    req.users_    = users;
    req.postscript_ = postscript;
    std::list<Property> list;
    for (auto it = users.begin(); it != users.end(); it++)
    {
        Property property;
        UTF8String uid   = *it;
        UTF8String my_id = IYixinCore_Get()->GetUid();
        property.put_string(NIMTeamMemberTagTID, team_id);
        property.put_string(NIMTeamMemberTagAccountID, uid);
        property.put_string(NIMTeamMemberTagInvitor, my_id);
        property.put_uint32(NIMTeamMemberTagValidFlag, 1);
        list.push_back(property);
    }
    cb.any_ = list;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}


void    TeamService::OnWaitPacketTeamInvite(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeInvite);
    if (param.code_ == NIMResSuccess || param.code_ == NIMResTeamNotMember) {
        param.code_ = NIMResSuccess;
        param.any_ = callback.any_;
    }
    RunTeamActionCB(param);
}


#pragma mark - 踢人
int32_t TeamService::Invoke_TeamKick(const UTF8String &team_id,const std::list<UTF8String> &users){
    return IYixinCore_Get()->PostTask(new TeamKickTask(team_id,users));
}

void    TeamService::Remote_TeamKick(const UTF8String &team_id,const std::list<UTF8String> &users,int32_t task_id){
    CoreCallback cb;
    cb.task_id_ = task_id;
    
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_KICK);
    TeamKickReqeust req;
    req.team_id_ = team_id;
    req.users_    = users;
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void    TeamService::OnWaitPacketTeamKick(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeKick);
    RunTeamActionCB(param);
}

#pragma mark - 退群
int32_t TeamService::Invoke_TeamLeave(const UTF8String &team_id){
    return IYixinCore_Get()->PostTask(new TeamLeaveTask(team_id));
}

void    TeamService::Remote_TeamLeave(const UTF8String &team_id,int32_t task_id){
    CoreCallback cb;
    cb.task_id_ = task_id;
    
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_LEAVE);
    TeamLeaveReqeust req;
    req.team_id_ = team_id;
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void    TeamService::OnWaitPacketTeamLeave(LinkFrame &lf,
                               const nbase::Unpack &up,
                               const CoreCallback &callback){
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeLeave);
    if (lf.error_ == NIMResSuccess) {
        TeamLeaveResponse response;
        response.unmarshal(up);
        IYixinCore_Get()->SetDataItemTag(DN_TINFO, response.team_id_, NIMTeamTagMemberValid, 0);
    }
    RunTeamActionCB(param);
}

#pragma mark - 群申请
int32_t TeamService::Invoke_TeamApply(const UTF8String &team_id,const UTF8String &apply_message){
    return IYixinCore_Get()->PostTask(new TeamApplyTask(team_id,apply_message));
}
void    TeamService::Remote_TeamApply(const UTF8String &team_id,const UTF8String &apply_message,int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_APPLY);
    TeamApplyReqeust req;
    CoreCallback cb;
    cb.task_id_ = task_id;
    req.team_id_ = team_id;
    req.apply_message_ = apply_message;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamApply(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeApply);
    if (lf.error_ == NIMResSuccess || lf.error_ == NIMResTeamApplySuccess) {
        param.code_ = NIMResSuccess;
        param.any_  = lf;
        Property info;
        up >> info;
        UTF8String team_id = info.get_string(NIMTeamTagID);
        if (lf.error_ == NIMResSuccess) {
            info.put_int32(NIMTeamTagMemberValid,1);
        }
        IYixinCore_Get()->SetDataItem(DN_TINFO, team_id, info);
    }
    RunTeamActionCB(param);
}

#pragma mark - 群申请通过
int32_t TeamService::Invoke_TeamApplyPass(const UTF8String &team_id,const UTF8String &accid){
    return IYixinCore_Get()->PostTask(new TeamApplyPassTask(team_id,accid));
}

void TeamService::Remote_TeamApplyPass(const UTF8String &team_id,const UTF8String &accid,int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_APPLY_PASS);
    TeamApplyPassReqeust req;
    CoreCallback cb;
    cb.task_id_  = task_id;
    req.team_id_ = team_id;
    req.accid_   = accid;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamApplyPass(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeApplyPass);
    if (lf.error_ == NIMResSuccess || lf.error_ == NIMResTeamAlreadyMember) {
        param.code_ = NIMResSuccess;
        param.any_  = lf;
    }
    RunTeamActionCB(param);
}

#pragma mark - 群申请拒绝
int32_t TeamService::Invoke_TeamApplyReject(const UTF8String &team_id,const UTF8String &accid,const UTF8String &reason){
    return IYixinCore_Get()->PostTask(new TeamApplyRejectTask(team_id,accid,reason));
}

void TeamService::Remote_TeamApplyReject(const UTF8String &team_id,const UTF8String &accid,const UTF8String &reason,int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_APPLY_REJECT);
    TeamApplyRejectReqeust req;
    CoreCallback cb;
    cb.task_id_  = task_id;
    req.team_id_ = team_id;
    req.accid_   = accid;
    req.reject_reason_ = reason;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamApplyReject(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeApplyReject);
    RunTeamActionCB(param);
}

#pragma mark - 添加管理员
int32_t TeamService::Invoke_AddManager(const UTF8String &team_id,const std::list<UTF8String> &users){
    return IYixinCore_Get()->PostTask(new TeamAddManagerTask(team_id,users));
}

void TeamService::Remote_AddManager(const UTF8String &team_id,const std::list<UTF8String> &users,int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_ADD_MANAGER);
    TeamAddManagerReqeust req;
    CoreCallback cb;
    cb.task_id_  = task_id;
    req.team_id_ = team_id;
    req.users_   = users;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamAddManager(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeAddManager);
    RunTeamActionCB(param);
}

#pragma mark - 移除管理员
int32_t TeamService::Invoke_RemoveManager(const UTF8String &team_id,const std::list<UTF8String> &users){
    return IYixinCore_Get()->PostTask(new TeamRemoveManagerTask(team_id,users));
}

void TeamService::Remote_RemoveManager(const UTF8String &team_id,const std::list<UTF8String> &users,int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_REMOVE_MANAGER);
    TeamRemoveManagerReqeust req;
    CoreCallback cb;
    cb.task_id_  = task_id;
    req.team_id_ = team_id;
    req.users_   = users;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamRemoveManager(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeRemoveManager);
    RunTeamActionCB(param);
}


#pragma mark - 移交群主
int32_t TeamService::Invoke_TransferOwner(const UTF8String &team_id,const UTF8String &new_owner,bool is_leave){
    return IYixinCore_Get()->PostTask(new TeamTransferOwner(team_id,new_owner,is_leave));
}


void TeamService::Remote_TransferOwner(const UTF8String &team_id,const UTF8String &new_owner,bool is_leave,int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_TRANSFER_OWNER);
    TeamTransferOwnerReqeust req;
    CoreCallback cb;
    cb.task_id_  = task_id;
    req.team_id_ = team_id;
    req.new_owner_id_ = new_owner;
    req.is_leave_ = is_leave;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamTransferOwner(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeTransferOwner);
    RunTeamActionCB(param);
}

#pragma mark - 修改自己的群属性
int32_t TeamService::Invoke_UpdateMyTlist(const Property &info){
    return IYixinCore_Get()->PostTask(new TeamUpdateMyTListTask(info));
}

void    TeamService::Remote_UpdateMyTlist(const Property &info, int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_UPDATE_TLIST);

    CoreCallback cb;
    cb.task_id_  = task_id;
    cb.any_      = info;
    
    TeamUpdateMyTListReqeust req;
    req.info_ = info;
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamUpdateMyTList(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBTeamParam param = GetParam(lf,callback,NIMTeamActionTypeUpdateMyTList);
    if (param.code_ == NIMResSuccess) {
        std::list<Property> users;
        Property info = nimboost::any_cast<Property>(callback.any_);
        UTF8String team_id = info.get_string(NIMTeamMemberTagTID);
        //自己的info不带uid,塞进去
        IYixinCore *core = IYixinCore_Get();
        if (core) {
            UTF8String uid = core->GetUid();
            info.put_string(NIMTeamMemberTagAccountID, uid);
            users.push_back(info);
            //修改自己信息，服务器不会在发notify下来，这里就要raise
            SaveTeamUsers(team_id, users, true);
        }
    }
    RunTeamActionCB(param);
}


#pragma mark - 修改别人的群昵称
int32_t TeamService::Invoke_UpdateOtherTList(const Property &info){
    return IYixinCore_Get()->PostTask(new TeamUpdateOtherTlistTask(info));
}

void    TeamService::Remote_UpdateOtherTList(const Property &info, int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_UPDATE_OTHER_TLIST);
    TeamUpdateOtherInfoReqeust req;
    CoreCallback cb;
    cb.task_id_  = task_id;
    cb.any_      = info;
    req.info_    = info;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamUpdateOhterTList(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBTeamParam param = GetParam(lf,callback,NIMTeamActionTypeUpdateOtherTList);
    if (param.code_ == NIMResSuccess) {
        std::list<Property> users;
        Property info = nimboost::any_cast<Property>(callback.any_);
        UTF8String team_id = info.get_string(NIMTeamTagID);
        users.push_back(info);
        //修改他人信息，服务器会再下发个notify下来，这里就不要再raise了
        SaveTeamUsers(team_id, users, false);
    }
    RunTeamActionCB(param);
}



#pragma mark - 接受群邀请
int32_t TeamService::Invoke_AcceptInvite(const UTF8String &team_id,const UTF8String &invitor){
    return IYixinCore_Get()->PostTask(new TeamAcceptInvite(team_id,invitor));
}

void    TeamService::Remote_AcceptInvite(const UTF8String &team_id,const UTF8String &invitor,int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_ACCEPT_INVITE);
    TeamAcceptInviteReqeust req;
    CoreCallback cb;
    cb.task_id_  = task_id;
    req.team_id_ = team_id;
    req.invitor_id_ = invitor;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);

}

void TeamService::OnWaitPacketTeamAcceptInvite(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBTeamParam param = GetParam(lf,callback,NIMTeamActionTypeAcceptInvite);
    if (lf.error_ == NIMResSuccess || lf.error_ == NIMResTeamAlreadyMember)
    {
        param.code_ = NIMResSuccess;
        Property info;
        up >> info;
        UTF8String team_id = info.get_string(NIMTeamTagID);
        info.put_int32(NIMTeamTagValidFlag, 1);
        info.put_int32(NIMTeamTagMemberValid, 1);
        IYixinCore_Get()->SetDataItem(DN_TINFO, team_id, info);
    }
    RunTeamActionCB(param);
}

#pragma mark - 拒绝群邀请
int32_t TeamService::Invoke_RejectInvite(const UTF8String &team_id,const UTF8String &invitor,const UTF8String &reason){
    return IYixinCore_Get()->PostTask(new TeamRejectInvite(team_id,invitor,reason));
}

void    TeamService::Remote_RejectInvite(const UTF8String &team_id,const UTF8String &invitor,const UTF8String &reason,int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_REJECT_INVITE);
    TeamRejectInviteReqeust req;
    CoreCallback cb;
    cb.task_id_  = task_id;
    req.team_id_ = team_id;
    req.invitor_id_ = invitor;
    req.reject_reason_ = "";
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamRejectInvite(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBTeamParam param = GetParam(lf,callback,NIMTeamActionTypeRejectInvite);
    RunTeamActionCB(param);
}


#pragma mark - 获取单个群信息 [Waitable]
int32_t TeamService::Invoke_GetTeamInfo(const UTF8String &team_id){
    return IYixinCore_Get()->PostTask(new TeamGetInfoTask(team_id));
}
void TeamService::Remote_GetTeamInfo(const UTF8String &team_id,int32_t task_id){
    CoreCallback cb;
    cb.task_id_ = task_id;
    
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_GET_INFO);
    TeamGetInfoReqeust req;
    req.team_id_ = team_id;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamGetInfo(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback)
{
    CBTeamParam param = GetParam(lf,callback,NIMTeamActionTypeFetchTeamInfo);

    if (lf.error_ == NIMResSuccess)
    {
        Property info;
        up >> info;
        param.any_ = info;
        
        UTF8String tid = info.get_string(NIMTeamTagID);
        if (IsMyTeam(tid))
        {
            IYixinCore_Get()->SetDataItem(DN_TINFO, tid, info);
        }
        
        
    }
    RunTeamActionCB(param);
}

#pragma mark - 获取单个群 [async]
void TeamService::Remote_AsyncGetTeamInfo(const UTF8String &team_id)
{
    if (frequency_controller_.IsRequestFrequencyAcceptable(team_id))
    {
        DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"fetch team info %s",team_id.c_str());
        
        LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_GET_INFO);
        TeamGetInfoReqeust req;
        req.team_id_ = team_id;
        IYixinCore_Get()->SendPacket(lf, req);
    }
    

}

void TeamService::OnPacketGetTeamInfo(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        Property info;
        up >> info;

        IYixinCore_Get()->SetDataItem(DN_TINFO, info.get_string(NIMTeamTagID), info);
    }
}


#pragma mark - 获取所有群信息
int32_t TeamService::Invoke_GetTeamInfoBatch(){
    return IYixinCore_Get()->PostTask(new TeamGetInfoBatchTask());
}

void TeamService::Remote_GetTeamInfoBatch(int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_GET_INFO_BATCH);
    TeamGetInfoBatchReqeust req;
    req.timetag_ = 0;
    IYixinCore_Get()->SendPacket(lf, req);
}

void TeamService::OnPacketTeamGetInfoBatch(LinkFrame &lf,
                                        const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        TeamGetInfoBatchResponse response;
        response.unmarshal(up);
        std::list<Property> &teams = response.teams_.list_;
        for (auto it = teams.begin(); it != teams.end(); it++)
        {
            Property info = *it;
            UTF8String team_id = info.get_string(NIMTeamTagID);
            IYixinCore_Get()->SetDataItem(DN_TINFO, team_id, info);
        }
    }
}


#pragma mark - 修改群信息
int32_t TeamService::Invoke_UpdateTeamInfo(const Property &team_info){
    return IYixinCore_Get()->PostTask(new TeamUpdateInfoTask(team_info));
}
void TeamService::Remote_UpdateTeamInfo(const Property &team_info, int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_UPDATE_INFO);
    TeamUpdateInfoReqeust req;
    req.team_info_ = team_info;
    CoreCallback cb;
    cb.any_ = team_info;
    cb.task_id_ = task_id;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketUpdateTeamInfo(LinkFrame &lf,
                                    const nbase::Unpack &up,
                                    const CoreCallback &callback)

{
    CBTeamParam param = GetParam(lf,callback,NIMTeamActionTypeUpdateTeamInfo);
    if (lf.error_ == NIMResSuccess)
    {
        Property team_info = nimboost::any_cast<Property>(callback.any_);
        UTF8String team_id = team_info.get_string(NIMTeamTagID);
        IYixinCore_Get()->SetDataItem(DN_TINFO, team_id, team_info);
        param.any_ = team_info;
    }
    RunTeamActionCB(param);
}

#pragma mark - 刷新群成员
int32_t TeamService::Invoke_RefreshTeamMembers(const UTF8String &team_id)
{
    return IYixinCore_Get()->PostTask(new TeamRefreshMembersTask(team_id));
}

void TeamService::Remote_RefreshTeamMembers(const UTF8String &team_id, int32_t task_id)
{
    uint64_t timetag = 0;
    IYixinCore_Get()->GetDataItem64Tag(DN_TINFO, team_id, NIMTeamTagLocalTlistTimtag, timetag);
    
    CoreCallback cb;
    cb.task_id_ = task_id;
    cb.any_ = team_id;
    
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_GET_MEMBERS);
    TeamRefreshMembersReqeust req;
    req.team_id_ = team_id;
    req.timetag_ = timetag;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void TeamService::OnWaitPacketTeamRefreshMembers(LinkFrame &lf,
                                                   const nbase::Unpack &up,
                                                   const CoreCallback &callback)
{
    UTF8String team_id = nimboost::any_cast<UTF8String>(callback.any_);
    CBTeamParam param = GetParam(lf, callback,NIMTeamActionTypeRefreshMembers);
    int32_t code = lf.error_;
    if (code == NIMResSuccess || code == NIMResNoModify)
    {
        param.code_ = NIMResSuccess;    //这两种情况都转换为成功

        if (code == NIMResSuccess)
        {
            TeamRefreshMembersResponse response;
            response.unmarshal(up);
            
            IYixinCore_Get()->SetDataItem64Tag(DN_TINFO, team_id, NIMTeamTagLocalTlistTimtag, response.timetag_);
            SaveTeamUsers(team_id, response.members_.list_, false);
        }
        
        std::list<Property> members;
        GetLocalTeamUsers(team_id, members);
        param.any_ = members;
    }
    RunTeamActionCB(param);
}



#pragma mark - 读取接口
uint32_t    TeamService::GetTeams(std::list<Property> &teams)
{
    teams.clear();
    std::list<UTF8String> keys;
    IYixinCore_Get()->GetDataItems(DN_TINFO, keys);
    for (auto it = keys.begin(); it != keys.end(); it++)
    {
        Property info;
        IYixinCore_Get()->GetDataItem(DN_TINFO, *it, info);
        if (IsMyTeam(*it))
        {
            teams.push_back(info);
        }
    }
    return (uint32_t)teams.size();
}

void    TeamService::GetTeamById(const UTF8String &team_id, Property &info)
{
    IYixinCore_Get()->GetDataItem(DN_TINFO, team_id, info);
    
    if (info.get_int32(NIMTeamTagUpdateTime) == 0)
    {
        IYixinCore_Get()->PostTask(new AsyncTeamGetInfoTask(team_id));
    }
}

void    TeamService::GetTeamUser(const UTF8String &team_id, const UTF8String &user_id, Property &info)
{
    UTF8String item_id = MakeItem(team_id, user_id);
    IYixinCore_Get()->GetDataItem(DN_TLIST, item_id, info);
}
    
uint32_t TeamService::GetTeamUsersWithoutInfo(const UTF8String &team_id,std::list<UTF8String> &user_ids)
{
    user_ids.clear();
    std::list<Property> users;
    GetLocalTeamUsers(team_id, users);
    IYixinCore *core = IYixinCore_Get();
    for (auto it = users.begin(); it != users.end(); it++)
    {
        UTF8String uid = it->get_string(NIMTeamMemberTagAccountID);
        uint64_t timetag = 0;
        core->GetDataItem64Tag(DN_USERS, uid, NIMUserInfoTagUpdateTime, timetag);
        if (timetag == 0)
        {
            user_ids.push_back(uid);
        }
    }
    return (uint32_t)user_ids.size();
}

void    TeamService::SaveTeamInfoFromLocal(const Property &info)
{
    UTF8String team_id = info.get_string(NIMTeamTagID);
    IYixinCore_Get()->SetDataItem(DN_TINFO, team_id, info);
}
    
void    TeamService::SaveTeamInfoFromServer(const nimbiz::Property &info)
{
    IYixinCore *core = IYixinCore_Get();
    UTF8String team_id = info.get_string(NIMTeamTagID);
    uint64_t old_timetag = 0;
    core->GetDataItem64Tag(DN_TINFO, team_id, NIMTeamTagUpdateTime, old_timetag);
    uint64_t new_timetag = info.get_uint64(NIMTeamTagUpdateTime);
    if (new_timetag > old_timetag)
    {
        core->SetDataItem(DN_TINFO, team_id, info);
    }
    
}

void    TeamService::SaveTeamUsers(const UTF8String &team_id, std::list<Property> users,bool raise_callback)
{
    for (auto it = users.begin(); it != users.end(); it++)
    {
        UTF8String item_id = MakeItem(team_id, it->get_string(NIMTeamMemberTagAccountID));
        Property info = *it;
        info.put_string(NIMTeamMemberTagTID, team_id);
        IYixinCore_Get()->SetDataItem(DN_TLIST, item_id,info);
    }
    if (users.size() && raise_callback) {
        RunTlistChangedCB(team_id);
    }
}

void    TeamService::RemoveTeamUsers(const UTF8String &team_id, std::list<UTF8String> user_ids)
{
    for (auto it = user_ids.begin(); it != user_ids.end(); it++)
    {
        UTF8String item_id = MakeItem(team_id,*it);
        IYixinCore_Get()->DeleteDataItem(DN_TLIST, item_id);
    }
    if (user_ids.size()) {
        RunTlistChangedCB(team_id);
    }
}

void    TeamService::GetTeamUsersSyncRequest(SyncTeamUsersRequest &request)
{
    std::list<Property> teams;
    GetTeams(teams);
    
    for (auto it = teams.begin(); it != teams.end(); it++)
    {
        uint64_t server_timetag = it->get_uint64(NIMTeamTagTlistTimetag);
        uint64_t local_timetag = it->get_uint64(NIMTeamTagLocalTlistTimtag);
        if (server_timetag > local_timetag)
        {
            UTF8String tid = it->get_string(NIMTeamTagID);
            request.teams_[tid] = local_timetag;
        }
    }
}

void    TeamService::GetLocalTeamUsers(const UTF8String &team_id, std::list<Property> &users)
{
    users.clear();
    std::list<Property> infos;
    UTF8String prefix = team_id + ":";
    IYixinCore_Get()->GetDataItems(DN_TLIST, prefix, infos);
    
    for (auto it = infos.begin();it != infos.end(); it++)
    {
        if (it->get_uint32(NIMTeamMemberTagValidFlag) != 0)
        {
            users.push_back(*it);

        }
    }
}

bool    TeamService::IsTeamOutOfData(const UTF8String &team_id)
{
    Property info;
    IYixinCore_Get()->GetDataItem(DN_TINFO, team_id, info);
    uint64_t server_timetag = info.get_uint64(NIMTeamTagTlistTimetag);
    uint64_t local_timetag = info.get_uint64(NIMTeamTagLocalTlistTimtag);
    return (server_timetag > local_timetag) || (info.get_uint32(NIMTeamTagValidFlag) == 0);

}

uint32_t    TeamService::GetTeamUserBits(const UTF8String &team_id)
{
    IYixinCore *core = IYixinCore_Get();
    uint32_t value = 0;
    UTF8String item = MakeItem(team_id, core->GetUid());
    IYixinCore_Get()->GetDataItemTag(DN_TLIST, item, NIMTeamMemberTagBits, value);
    return value;
}

#pragma mark - 漫游群消息
int32_t   TeamService::Invoke_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback){
    return IYixinCore_Get()->PostTask(new TeamHistoryMessage(param,callback));
}

void   TeamService::Remote_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback,int32_t task_id){
    LinkFrame lf(SVID_NIM_TEAM,CID_TEAM_HISTORY_MSG);
    TeamHistoryMsgReqeust req;
    CoreCallback cb;
    cb.task_id_ = task_id;
    cb.callback_ = callback;
    req.param_  = param;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}


void  TeamService::OnWaitPacketHistoryMsg(LinkFrame &lf,
                               const nbase::Unpack &up,
                                          const CoreCallback &callback){
   //直接丢给session service处理
    ISessionService *service = (ISessionService *)GetServiceFromCore(SVID_NIM_SESSION);
    if (service)
    {
        service->OnHistoryMsg(lf, up, callback);
    }
}


#pragma mark - 收发消息 (Team消息收取后也直接丢给session service处理)
void    TeamService::OnSendMsg(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    ISessionService *service = (ISessionService *)GetServiceFromCore(SVID_NIM_SESSION);
    if (service)
    {
        service->OnSendMsg(lf, up, callback);
    }
}

void    TeamService::OnRecvMsg(LinkFrame &lf, const nbase::Unpack &up)
{
    ISessionService *service = (ISessionService *)GetServiceFromCore(SVID_NIM_SESSION);
    if (service)
    {
        service->OnRecvMsg(lf, up);
    }
}



#pragma mark - misc
CBTeamParam    TeamService::GetParam(LinkFrame &lf, const CoreCallback &cb,NIMTeamActionType type)
{
    CBTeamParam param;
    param.code_ = lf.error_;
    param.task_id_ = cb.task_id_;
    param.type_ = type;
    return param;
}

void    TeamService::RunTeamActionCB(const CBTeamParam &param)
{
    CBTeamParam cb_param = param;
    if (!action_callback_.is_null())
    {
        action_callback_.Run(&cb_param);
    }
}

void TeamService::RunTlistChangedCB(const UTF8String &tid)
{
    CBTlistChangedParam param;
    param.tid_ = tid;
    if (!tlist_changed_callback_.is_null())
    {
        tlist_changed_callback_.Run(&param);
    }
}

void TeamService::RunTInfoChangedCB(const UTF8String &tid, int32_t type)
{
    //绝大多数群信息的更新都是可以通过action 或者 message save info来获取,但是部分需要这里主动发起回调
    //1.其他端同帐号创建群 通知
    
    CBTInfoChangedParam param;
    param.tid_ = tid;
    param.type_= type;
    if (!tinfo_changed_callback_.is_null())
    {
        tinfo_changed_callback_.Run(&param);
    }
}


UTF8String  TeamService::MakeItem(const UTF8String &tid, const UTF8String &uid)
{
    return tid + ":" + uid;
}

bool    TeamService::IsMyTeam(const UTF8String &tid)
{
    Property info;
    IYixinCore_Get()->GetDataItem(DN_TINFO, tid, info);
    return info.get_int32(NIMTeamTagValidFlag) &&
           info.get_int32(NIMTeamTagMemberValid);
}
    
}
