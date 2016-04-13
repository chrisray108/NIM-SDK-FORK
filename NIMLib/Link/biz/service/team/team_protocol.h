//
//  team_protocol.h
//  NIMLib
//
//  Created by chris on 15/3/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_team_protocol_h
#define NIMLib_team_protocol_h
#include "biz/core/service.h"
#include "biz/protocol/property.h"
#include "biz/protocol/response_code.h"
#include "biz/core/yixin_core.h"
#include "biz/service/session/session_protocol.h"

namespace nimbiz
{

enum
{

    CID_TEAM_CREATE            = 1,
    CID_TEAM_SAY               = 2,
    CID_TEAM_NOTIFY_NEW        = 3,
    CID_TEAM_NTOIFY_MSG_LIST   = 4,
    CID_TEAM_INVITE            = 5,
    CID_TEAM_KICK              = 6,
    CID_TEAM_UPDATE_INFO       = 7,
    CID_TEAM_LEAVE             = 8,
    CID_TEAM_GET_INFO          = 9,
    CID_TEAM_GET_INFO_BATCH    = 10,
    CID_TEAM_GET_MEMBERS       = 11,
    CID_TEAM_DISMISS           = 12,
    CID_TEAM_APPLY             = 13,
    CID_TEAM_APPLY_PASS        = 14,
    CID_TEAM_APPLY_REJECT      = 15,
    CID_TEAM_ADD_MANAGER       = 16,
    CID_TEAM_REMOVE_MANAGER    = 17,
    CID_TEAM_TRANSFER_OWNER    = 18,
    CID_TEAM_UPDATE_TLIST      = 19,
    CID_TEAM_UPDATE_OTHER_TLIST = 20,
    CID_TEAM_ACCEPT_INVITE     = 21,
    CID_TEAM_REJECT_INVITE     = 22,
    CID_TEAM_HISTORY_MSG       = 23,
    CID_TEAM_SYNC_CREATE       = 101,
    CID_TEAM_OL_SYNC_SAY       = 102,
    CID_TEAM_SYNC_TINFOS       = 109,
    CID_TEAM_SYNC_TLIST        = 111,
    CID_TEAM_NOTIFY_SYNC_TLIST = 119,
};

enum NIMTeamTag
{
    NIMTeamTagID           =   1,
    NIMTeamTagAppID        =   2,
    NIMTeamTagName         =   3,
    NIMTeamTagType         =   4,
    NIMTeamTagOwner         =   5,
    NIMTeamTagLevel        =   6,
    NIMTeamTagProperty     =   7,
    NIMTeamTagValidFlag    =   8,  //群是否有效 0表示无效 非0有效
    NIMTeamTagValidNumber  =   9,
    NIMTeamTagTlistTimetag =   10,
    NIMTeamTagCreateTime   =   11,
    NIMTeamTagUpdateTime   =   12,
    NIMTeamTagMemberValid  =   13, //自己是不是在这个群里 0表示不在 非0表示在
    NIMTeamTagIntro        =   14,
    NIMTeamTagAnnouncement =   15,
    NIMTeamTagJoinMode     =   16,
    NIMTeamTagBits         =   17,
    NIMTeamTagClientCustom =   18,
    NIMTeamTagServerCustom =   19,
    
    
    //本地标签
    NIMTeamTagLocalTlistTimtag  = 1000,   //当前群成员timtag
    
};


enum NIMTeamMemberTag
{
    NIMTeamMemberTagTID        =   1,
    NIMTeamMemberTagAccountID  =   3,
    NIMTeamMemberTagType       =   4,
    NIMTeamMemberTagNick       =   5,
    NIMTeamMemberTagInvitor    =   6,
    NIMTeamMemberTagBits       =   7,
    NIMTeamMemberTagState      =   8,
    NIMTeamMemberTagValidFlag  =   9,
    NIMTeamMemberTagCreateTime =   10,
    NIMTeamMemberTagUpdateTime =   11,
};


enum NIMTListBits
{
    NIMTListBitsCloseNotify =   1 << 0,  //1表示关闭
};


enum NIMTeamActionType
{
    NIMTeamActionTypeCreate,
    NIMTeamActionTypeDismiss,
    NIMTeamActionTypeInvite,
    NIMTeamActionTypeKick,
    NIMTeamActionTypeLeave,
    NIMTeamActionTypeApply,
    NIMTeamActionTypeApplyPass,
    NIMTeamActionTypeApplyReject,
    NIMTeamActionTypeAddManager,
    NIMTeamActionTypeRemoveManager,
    NIMTeamActionTypeTransferOwner,
    NIMTeamActionTypeAcceptInvite,
    NIMTeamActionTypeRejectInvite,
    NIMTeamActionTypeRefreshMembers,
    NIMTeamActionTypeUpdateTeamInfo,
    NIMTeamActionTypeUpdateMyTList,     //主动改自己的群信息
    NIMTeamActionTypeUpdateOtherTList,  //主动改别人的群信息
    NIMTeamActionTypeFetchTeamInfo,
};

struct CBTeamParam : IAsynTaskCallbackParam
{
    NIMTeamActionType       type_;
    nimboost::any           any_;
};

struct CBTlistChangedParam : IAsynCallbackParam
{
    UTF8String  tid_;
};

enum
{
    NIMTeamChangedAdd,
    NIMTeamChangedUpdate,
    NIMTeamChangedRemove,
};

struct CBTInfoChangedParam : IAsynCallbackParam
{
    UTF8String tid_;
    int32_t type_;
};




struct SyncTeamUsersRequest : nbase::Marshallable
{
    std::map<UTF8String,uint64_t>   teams_;
    void marshal(nbase::Pack &p) const
    {
        p.push_len((uint32_t)teams_.size());
        for (auto it = teams_.begin(); it != teams_.end();it++)
        {
            p.push_varstr_as_uint64(it->first);
            p.push_uint64(it->second);
        }
    }
    YX_REQUEST_ONLY();
};



#pragma mark - ITeamService
class ITeamService : public IService
{
public:
    ITeamService() : IService(SVID_NIM_TEAM) {}
    
    virtual void RegisterActionCallback(const IAsynCallback &callback) = 0;
    virtual void RegisterTlistChangedCallback(const IAsynCallback &callback) = 0;
    virtual void RegisterTInfoChangedCallback(const IAsynCallback &callback) = 0;
    
    
    virtual int32_t Invoke_CreateTeam(const Property &info,const UTF8String &postscript,const std::list<UTF8String> &users) = 0;
    virtual void    Remote_CreateTeam(const Property &info,const UTF8String &postscript,const std::list<UTF8String> &users,int32_t task_id) = 0;
    virtual int32_t Invoke_DismissTeam(const UTF8String &team_id) = 0;
    virtual void    Remote_DismissTeam(const UTF8String &team_id,int32_t task_id) = 0;

    virtual int32_t Invoke_TeamInvite(const UTF8String &team_id,const UTF8String &postscript,const std::list<UTF8String> &users) = 0;
    virtual void    Remote_TeamInvite(const UTF8String &team_id,const UTF8String &postscript,const std::list<UTF8String> &users,int32_t task_id) = 0;
    virtual int32_t Invoke_TeamKick(const UTF8String &team_id,const std::list<UTF8String> &users) = 0;
    virtual void    Remote_TeamKick(const UTF8String &team_id,const std::list<UTF8String> &users,int32_t task_id) = 0;
    virtual int32_t Invoke_TeamLeave(const UTF8String &team_id) = 0;
    virtual void    Remote_TeamLeave(const UTF8String &team_id,int32_t task_id) = 0;

    virtual int32_t Invoke_TeamApply(const UTF8String &team_id,const UTF8String &apply_message) = 0;
    virtual void    Remote_TeamApply(const UTF8String &team_id,const UTF8String &apply_message,int32_t task_id) = 0;
    virtual int32_t Invoke_TeamApplyPass(const UTF8String &team_id,const UTF8String &accid) = 0;
    virtual void    Remote_TeamApplyPass(const UTF8String &team_id,const UTF8String &accid,int32_t task_id) = 0;
    virtual int32_t Invoke_TeamApplyReject(const UTF8String &team_id,const UTF8String &accid,const UTF8String &reason) = 0;
    virtual void    Remote_TeamApplyReject(const UTF8String &team_id,const UTF8String &accid,const UTF8String &reason,int32_t task_id) = 0;

    virtual int32_t Invoke_AddManager(const UTF8String &team_id,const std::list<UTF8String> &users) = 0;
    virtual void    Remote_AddManager(const UTF8String &team_id,const std::list<UTF8String> &users,int32_t task_id) = 0;
    virtual int32_t Invoke_RemoveManager(const UTF8String &team_id,const std::list<UTF8String> &users) = 0;
    virtual void    Remote_RemoveManager(const UTF8String &team_id,const std::list<UTF8String> &users,int32_t task_id) = 0;

    virtual int32_t Invoke_TransferOwner(const UTF8String &team_id,const UTF8String &new_owner,bool is_leave) = 0;
    virtual void    Remote_TransferOwner(const UTF8String &team_id,const UTF8String &new_owner,bool is_leave,int32_t task_id) = 0;
    
    virtual int32_t Invoke_UpdateMyTlist(const Property &info) = 0;
    virtual void    Remote_UpdateMyTlist(const Property &info,int32_t task_id) = 0;
    virtual int32_t Invoke_UpdateOtherTList(const Property &info) = 0;
    virtual void    Remote_UpdateOtherTList(const Property &info,int32_t task_id) = 0;

    
    virtual int32_t Invoke_AcceptInvite(const UTF8String &team_id,const UTF8String &invitor) = 0;
    virtual void    Remote_AcceptInvite(const UTF8String &team_id,const UTF8String &invitor,int32_t task_id) = 0;
    virtual int32_t Invoke_RejectInvite(const UTF8String &team_id,const UTF8String &invitor,const UTF8String &reason) = 0;
    virtual void    Remote_RejectInvite(const UTF8String &team_id,const UTF8String &invitor,const UTF8String &reason,int32_t task_id) = 0;
    
    virtual int32_t Invoke_UpdateTeamInfo(const Property &team_info) = 0;
    virtual void    Remote_UpdateTeamInfo(const Property &team_info,int32_t task_id) = 0;
    virtual int32_t Invoke_GetTeamInfo(const UTF8String &team_id) = 0;
    virtual void    Remote_GetTeamInfo(const UTF8String &team_id,int32_t task_id) = 0;
    virtual void    Remote_AsyncGetTeamInfo(const UTF8String &team_id) = 0;
    virtual int32_t Invoke_GetTeamInfoBatch() = 0;
    virtual void    Remote_GetTeamInfoBatch(int32_t task_id) = 0;
    virtual int32_t Invoke_RefreshTeamMembers(const UTF8String &team_id) = 0;
    virtual void    Remote_RefreshTeamMembers(const UTF8String &team_id,int32_t task_id) = 0;

    virtual int32_t Invoke_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback) = 0;
    virtual void    Remote_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback,int32_t task_id) = 0;

    
    virtual uint32_t    GetTeams(std::list<Property> &teams) = 0;
    virtual void        GetTeamById(const UTF8String &team_id,Property &info) = 0;
    virtual void        GetTeamUser(const UTF8String &team_id,const UTF8String &user_id,Property &info) = 0;
    virtual uint32_t    GetTeamUsersWithoutInfo(const UTF8String &team_id,std::list<UTF8String> &user_ids) = 0;
    virtual void        SaveTeamInfoFromLocal(const Property &info) = 0;
    virtual void        SaveTeamInfoFromServer(const Property &info) = 0;
    virtual void        SaveTeamUsers(const UTF8String &team_id,std::list<Property> users,bool raise_callback) = 0;
    virtual void        RemoveTeamUsers(const UTF8String &team_id,std::list<UTF8String> user_ids) = 0;
    virtual void        GetTeamUsersSyncRequest(SyncTeamUsersRequest &request) = 0;
    virtual void        GetLocalTeamUsers(const UTF8String &team_id,std::list<Property>& users) = 0;
    virtual bool        IsTeamOutOfData(const UTF8String &team_id) = 0;
    virtual uint32_t    GetTeamUserBits(const UTF8String &team_id) = 0;
    virtual bool        IsMyTeam(const UTF8String &tid) = 0;

};

}

#endif
