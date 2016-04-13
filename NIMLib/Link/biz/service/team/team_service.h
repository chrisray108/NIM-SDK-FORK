//
//  team_service.h
//  NIMLib
//
//  Created by chris on 15/3/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef __NIMLib__team_service__
#define __NIMLib__team_service__
#include "team_protocol.h"
#include <map>
#include "biz/core/frequency_controller.h"

namespace nimbiz
{


class TeamService : public ITeamService
{
public:
    TeamService() {}
    
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
    virtual void RegisterActionCallback(const IAsynCallback &callback) {action_callback_ = callback;};
    virtual void RegisterTlistChangedCallback(const IAsynCallback &callback) {tlist_changed_callback_ = callback;};
    virtual void RegisterTInfoChangedCallback(const IAsynCallback &callback) {tinfo_changed_callback_ = callback;};
    
    virtual int32_t Invoke_CreateTeam(const Property &info,const UTF8String &postscript,const std::list<UTF8String> &users);
    virtual void    Remote_CreateTeam(const Property &info,const UTF8String &postscript,const std::list<UTF8String> &users,int32_t task_id);
    virtual int32_t Invoke_DismissTeam(const UTF8String &team_id);
    virtual void    Remote_DismissTeam(const UTF8String &team_id,int32_t task_id);

    virtual int32_t Invoke_TeamInvite(const UTF8String &team_id,const UTF8String &postscript,const std::list<UTF8String> &users);
    virtual void    Remote_TeamInvite(const UTF8String &team_id,const UTF8String &postscript,const std::list<UTF8String> &users,int32_t task_id);
    virtual int32_t Invoke_TeamKick(const UTF8String &team_id,const std::list<UTF8String> &users);
    virtual void    Remote_TeamKick(const UTF8String &team_id,const std::list<UTF8String> &users,int32_t task_id);
    virtual int32_t Invoke_TeamLeave(const UTF8String &team_id);
    virtual void    Remote_TeamLeave(const UTF8String &team_id,int32_t task_id);
    virtual int32_t Invoke_TeamApply(const UTF8String &team_id,const UTF8String &apply_message);
    virtual void    Remote_TeamApply(const UTF8String &team_id,const UTF8String &apply_message,int32_t task_id);
    virtual int32_t Invoke_TeamApplyPass(const UTF8String &team_id,const UTF8String &accid);
    virtual void    Remote_TeamApplyPass(const UTF8String &team_id,const UTF8String &accid,int32_t task_id);
    virtual int32_t Invoke_TeamApplyReject(const UTF8String &team_id,const UTF8String &accid,const UTF8String &reason);
    virtual void    Remote_TeamApplyReject(const UTF8String &team_id,const UTF8String &accid,const UTF8String &reason,int32_t task_id);
    virtual int32_t Invoke_AddManager(const UTF8String &team_id,const std::list<UTF8String> &users);
    virtual void    Remote_AddManager(const UTF8String &team_id,const std::list<UTF8String> &users,int32_t task_id);
    virtual int32_t Invoke_RemoveManager(const UTF8String &team_id,const std::list<UTF8String> &users);
    virtual void    Remote_RemoveManager(const UTF8String &team_id,const std::list<UTF8String> &users,int32_t task_id);
    virtual int32_t Invoke_TransferOwner(const UTF8String &team_id,const UTF8String &new_owner,bool is_leave);
    virtual void    Remote_TransferOwner(const UTF8String &team_id,const UTF8String &new_owner,bool is_leave,int32_t task_id);
    virtual int32_t Invoke_UpdateMyTlist(const Property &info);
    virtual void    Remote_UpdateMyTlist(const Property &info,int32_t task_id);
    virtual int32_t Invoke_UpdateOtherTList(const Property &info);
    virtual void    Remote_UpdateOtherTList(const Property &info,int32_t task_id);
    virtual int32_t Invoke_AcceptInvite(const UTF8String &team_id,const UTF8String &invitor);
    virtual void    Remote_AcceptInvite(const UTF8String &team_id,const UTF8String &invitor,int32_t task_id);
    virtual int32_t Invoke_RejectInvite(const UTF8String &team_id,const UTF8String &invitor,const UTF8String &reason);
    virtual void    Remote_RejectInvite(const UTF8String &team_id,const UTF8String &invitor,const UTF8String &reason,int32_t task_id);
    virtual int32_t Invoke_UpdateTeamInfo(const Property &team_info);
    virtual void    Remote_UpdateTeamInfo(const Property &team_info,int32_t task_id);
    virtual int32_t Invoke_GetTeamInfo(const UTF8String &team_id);
    virtual void    Remote_GetTeamInfo(const UTF8String &team_id,int32_t task_id);
    virtual void    Remote_AsyncGetTeamInfo(const UTF8String &team_id);
    virtual int32_t Invoke_GetTeamInfoBatch();
    virtual void    Remote_GetTeamInfoBatch(int32_t task_id);
    virtual int32_t Invoke_RefreshTeamMembers(const UTF8String &team_id);
    virtual void    Remote_RefreshTeamMembers(const UTF8String &team_id,int32_t task_id);
    
    virtual int32_t Invoke_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback);
    virtual void    Remote_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback,int32_t task_id);

    
    virtual uint32_t    GetTeams(std::list<Property> &teams);
    virtual void        GetTeamById(const UTF8String &team_id,Property &info);
    virtual void        GetTeamUser(const UTF8String &team_id,const UTF8String &user_id,Property &info);
    virtual uint32_t    GetTeamUsersWithoutInfo(const UTF8String &team_id,std::list<UTF8String> &user_ids);
    virtual void        SaveTeamInfoFromLocal(const Property &info);
    virtual void        SaveTeamInfoFromServer(const Property &info);
    virtual void        SaveTeamUsers(const UTF8String &team_id,std::list<Property> users,bool raise_callback);
    virtual void        RemoveTeamUsers(const UTF8String &team_id,std::list<UTF8String> user_ids);
    virtual void        GetTeamUsersSyncRequest(SyncTeamUsersRequest &request);
    virtual void        GetLocalTeamUsers(const UTF8String &team_id,std::list<Property>& users);
    virtual bool        IsTeamOutOfData(const UTF8String &team_id);
    virtual uint32_t    GetTeamUserBits(const UTF8String &team_id);
    
    virtual bool        IsMyTeam(const UTF8String &tid);
    
private:
    void    OnPacketGetTeamInfo(LinkFrame &lf,
                                const nbase::Unpack &up);
    
    void    OnPacketOnCreateTeam(LinkFrame &lf,const nbase::Unpack &up);
    
    void    OnWaitPacketCreateTeam(LinkFrame &lf,
                                    const nbase::Unpack &up,
                                    const CoreCallback &callback);
    void    OnWaitPacketDismissTeam(LinkFrame &lf,
                                      const nbase::Unpack &up,
                                     const CoreCallback &callback);
    void    OnSendMsg(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback);
    void    OnRecvMsg(LinkFrame &lf,const nbase::Unpack &up);
    void    OnSyncTeams(LinkFrame &lf,const nbase::Unpack &up);
    void    OnSyncTeamUsers(LinkFrame &lf,const nbase::Unpack &up);
    void    OnNotifySyncTeamUsers(LinkFrame &lf,const nbase::Unpack &up);

    void    OnPacketTeamGetInfoBatch(LinkFrame &lf,
                                 const nbase::Unpack &up);

    void    OnWaitPacketTeamGetInfo(LinkFrame &lf,
                                    const nbase::Unpack &up,
                                    const CoreCallback &callback);
    
    void    OnWaitPacketTeamInvite(LinkFrame &lf,
                                    const nbase::Unpack &up,
                                    const CoreCallback &callback);
    void    OnWaitPacketTeamKick(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);
    void    OnWaitPacketTeamLeave(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);
    void    OnWaitPacketUpdateTeamInfo(LinkFrame &lf,
                                               const nbase::Unpack &up,
                                               const CoreCallback &callback);
    void    OnWaitPacketTeamRefreshMembers(LinkFrame &lf,
                                   const nbase::Unpack &up,
                                   const CoreCallback &callback);
    void    OnWaitPacketTeamApply(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);
    void    OnWaitPacketTeamApplyPass(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);
    void    OnWaitPacketTeamApplyReject(LinkFrame &lf,
                                      const nbase::Unpack &up,
                                      const CoreCallback &callback);
    void    OnWaitPacketTeamAddManager(LinkFrame &lf,
                                        const nbase::Unpack &up,
                                        const CoreCallback &callback);
    void    OnWaitPacketTeamRemoveManager(LinkFrame &lf,
                                       const nbase::Unpack &up,
                                       const CoreCallback &callback);
    void    OnWaitPacketTeamTransferOwner(LinkFrame &lf,
                                          const nbase::Unpack &up,
                                          const CoreCallback &callback);
    void    OnWaitPacketTeamAcceptInvite(LinkFrame &lf,
                                          const nbase::Unpack &up,
                                          const CoreCallback &callback);
    void    OnWaitPacketTeamRejectInvite(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);
    void    OnWaitPacketTeamUpdateMyTList(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);
    void    OnWaitPacketTeamUpdateOhterTList(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);
    void    OnWaitPacketHistoryMsg(LinkFrame &lf,
                                   const nbase::Unpack &up,
                                   const CoreCallback &callback);
    
    CBTeamParam GetParam(LinkFrame &lf,const CoreCallback &cb,NIMTeamActionType type);
    void RunTeamActionCB(const CBTeamParam &param);
    void RunTlistChangedCB(const UTF8String &tid);
    void RunTInfoChangedCB(const UTF8String &tid,int32_t type);

    UTF8String MakeItem(const UTF8String &tid,const UTF8String &uid);
    void    OnCreateTeam(Property &info);
    
private:
    IAsynCallback action_callback_;
    IAsynCallback tlist_changed_callback_;
    IAsynCallback tinfo_changed_callback_;
    FrequencyController frequency_controller_;
    
};
    
}
#endif /* defined(__NIMLib__team_service__) */
