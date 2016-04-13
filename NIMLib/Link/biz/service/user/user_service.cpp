//
//  user_service.cpp
//  NIMLib
//
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#include "user_service.h"
#include "user_task.h"
#include "util/ios_util.h"
#include "base/log/log.h"
#include "biz/service/sync/sync_protocol.h"
#include "biz/service/session/session_protocol.h"

namespace nimbiz
{


struct UpdateTokenRequest : nbase::Marshallable
{
    UTF8String cer_name_;
    UTF8String token_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr(cer_name_);
        p.push_varstr(token_);
    }
    YX_REQUEST_ONLY();
};


struct UpdateAppBadgeRequest : nbase::Marshallable
{
    bool background_;
    uint32_t badge_;
    void marshal(nbase::Pack &p) const
    {
        p.push_bool(background_);
        p.push_uint32(badge_);
    }
    YX_REQUEST_ONLY();
};

struct UpdateOnlineStateRequest : nbase::Marshallable
{
    uint32_t state_;
    void marshal(nbase::Pack &p) const
    {
        p.push_uint32(state_);
    }
    YX_REQUEST_ONLY();
};

struct FetchFriendsRequest : nbase::Marshallable
{
    std::list<UTF8String>  uids;
    void marshal(nbase::Pack &p) const
    {
        p.push_len((uint32_t)uids.size());
        for (auto it = uids.begin(); it != uids.end();it++)
        {
            p.push_varstr(*it);
        }
    }
    YX_REQUEST_ONLY();
};

struct UpdateMyUserInfoReqeust : nbase::Marshallable
{
    Property info_;
    void marshal(nbase::Pack &p) const
    {
        p << info_;
    }
    YX_REQUEST_ONLY();
};


bool    UserService::OnLoad()
{
    return true;
}

void    UserService::OnUnLoad()
{
}


uint32_t    UserService::OnPacket(LinkFrame &lf, const nbase::Unpack &up)
{
    uint32_t result = NIMOnPacketSuccess;
    switch (lf.command_id_) {
        case CID_MARK_IN_BLACKLIST_SYNC:
            OnPacketBlacklistSync(lf, up);
            break;
        case CID_MARK_MUTELIST_SYNC:
            OnPacketMuteSync(lf, up);
            break;
        case CID_SYNC_MUTE_AND_BLACK:
            OnPacketRelationSync(lf, up);
            break;
        case CID_SYNC_MY_UINFO:
            OnPacketMyUserInfoSync(lf, up);
            break;
        case CID_SYNC_UPDATE_MY_UINFO:
            OnPacketMyUserInfoUpdate(lf, up);
            break;
        default:
            result = NIMOnPacketCommandNotSupport;
            break;
    }
    return result;
}


bool    UserService::OnWaitablePacket(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    bool handled = true;
    switch (lf.command_id_) {
        case CID_APP_APNS:
            OnWaitablePacketUpdateApns(lf, up, callback);
            break;
        case CID_SET_USER_STAT:
            OnWaitablePacketUpdateOnlineState(lf, up, callback);
            break;
        case CID_MARK_IN_BLACKLIST:
            OnWaitablePacketUpdateBlack(lf, up, callback);
            break;
        case CID_MARK_MUTELIST:
            OnWaitablePacketUpdateMute(lf, up, callback);
            break;
        case CID_GET_USER_UINFO:
            OnWaitablePacketFetchUsers(lf, up, callback);
            break;
        case CID_UPDATE_MY_UINFO:
            OnWaitablePacketUpdateMyUserInfo(lf, up, callback);
            break;
        default:
            handled = false;
            break;
    }
    return handled;
}




void    UserService::Invoke_UpdateToken()
{
    IYixinCore_Get()->PostLoginContextTask(new UpdateTokenTask());
}

void    UserService::Remote_UpdateToken()
{
    LinkFrame lf(SVID_NIM_USER,CID_UPDATE_PUSH_TOKEN);
    UpdateTokenRequest request;
    
    UTF8String cer_name = nimbiz::GetAPNSCerName();
    UTF8String token  = nimbiz::GetAPNSToken();
    if (!cer_name.empty() && !token.empty())
    {
        request.cer_name_ = cer_name;
        request.token_ = token;
        IYixinCore_Get()->SendPacket(lf, request);
    }
    else
    {
        DEFLOG(nbase::LogInterface::LV_APP,__FILE__, __LINE__,
        "invilad param token %s cer %s",token.c_str(),cer_name.c_str());
    }
}


void    UserService::Invoke_UpdateAppInfo(bool background, uint32_t badge)
{
    IYixinCore_Get()->PostTask(new UpdateBadgeTask(background,badge));
}

void    UserService::Remote_UpdateAppInfo(bool background, uint32_t badge)
{
    LinkFrame lf(SVID_NIM_USER,CID_APP_BACKGROUND);
    UpdateAppBadgeRequest request;
    request.background_ = background;
    request.badge_ = badge;
    
    IYixinCore_Get()->SendPacket(lf, request);
}

#pragma mark - push
int32_t    UserService::Invoke_UpdatePush(const Property &info, const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostTask(new UpdateApnsTask(info,callback));
}

void    UserService::Remote_UpdatePush(const Property &info, const IAsynCallback &callback,int32_t task_id)
{
    LinkFrame lf(SVID_NIM_USER,CID_APP_APNS);
    CoreCallback cb;
    cb.callback_ = callback;
    cb.any_ = info;
    cb.task_id_ = task_id;
    
    Property setting = info;
    IYixinCore_Get()->SendWaitablePacket(lf, setting, cb);
}

void    UserService::OnWaitablePacketUpdateApns(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    if (lf.error_ == NIMResSuccess)
    {
        Property info = nimboost::any_cast<Property>(callback.any_);
        ISyncService *service = (ISyncService *)GetServiceFromCore(SVID_NIM_SYNC);
        if (service)
        {
            service->SetPushProperty(info);
        }
    }
    CBUpdateApnsParam param;
    param.code_ = lf.error_;
    param.task_id_ = callback.task_id_;
    if (!callback.callback_.is_null())
    {
        callback.callback_.Run(&param);
    }
}

#pragma mark - 更新在线状态
void    UserService::Invoke_UpdateOnlineState(uint32_t state, const IAsynCallback &callback)
{
    IYixinCore_Get()->PostTask(new UpdateOnlineStateTask(state,callback));
}
void    UserService::Remote_UpdateOnlineState(uint32_t state, const IAsynCallback &callback)
{
    LinkFrame lf(SVID_NIM_USER,CID_SET_USER_STAT);
    UpdateOnlineStateRequest request;
    request.state_ = state;
    
    CoreCallback cb;
    cb.callback_ = callback;
    cb.any_ = state;
    
    IYixinCore_Get()->SendWaitablePacket(lf, request, cb);
}

void    UserService::OnWaitablePacketUpdateOnlineState(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    CBUpdateOnlineStateParam param;
    param.state_ = nimboost::any_cast<uint32_t>(callback.any_);
    param.code_ = lf.error_;
    if (!callback.callback_.is_null())
    {
        callback.callback_.Run(&param);
    }
}


#pragma mark -  更新黑名单
struct MarkBlackData : nbase::Marshallable
{
    UTF8String uid_;
    bool black_;
    
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr(uid_);
        p.push_bool(black_);
        
    }
    void unmarshal(const nbase::Unpack &up)
    {
        uid_ = up.pop_varstr();
        black_ = up.pop_bool();
    }
};

int32_t    UserService::Invoke_UpdateBlack(const UTF8String &uid, bool black, const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostTask(new UpdateBlackListTask(uid,black,callback));
}


void        UserService::Remote_UpdateBlack(const UTF8String &uid, bool black, const IAsynCallback &callback, int32_t task_id)
{
    LinkFrame lf(SVID_NIM_USER,CID_MARK_IN_BLACKLIST);
    
    MarkBlackData req;
    req.uid_ = uid;
    req.black_ = black;
    
    CoreCallback cb;
    cb.any_ = req;
    cb.task_id_ = task_id;
    cb.callback_ = callback;
    
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void        UserService::OnWaitablePacketUpdateBlack(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    if (lf.error_ == NIMResSuccess) {
        MarkBlackData data = nimboost::any_cast<MarkBlackData>(callback.any_);
        UTF8String uid = data.uid_;
        bool black = data.black_;
        
        IYixinCore_Get()->SetDataItemTag(DN_RELATION, uid, NIMRelationTagBlackList, black);
    }
    
    IAsynTaskCallbackParam param;
    param.task_id_ = callback.task_id_;
    param.code_ = lf.error_;
    if (!callback.callback_.is_null()) {
        callback.callback_.Run(&param);
    }
}

void        UserService::OnPacketBlacklistSync(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        MarkBlackData data;
        data.unmarshal(up);
        UTF8String uid = data.uid_;
        bool black = data.black_;
        
        IYixinCore_Get()->SetDataItemTag(DN_RELATION, uid, NIMRelationTagBlackList, black);
    }
}

#pragma mark - 更新通知状态
struct MarkMuteData : nbase::Marshallable
{
    UTF8String uid_;
    bool mute_;
    
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr(uid_);
        p.push_bool(mute_);
        
    }
    void unmarshal(const nbase::Unpack &up)
    {
        uid_ = up.pop_varstr();
        mute_ = up.pop_bool();
    }
};


int32_t     UserService::Invoke_UpdateMute(const UTF8String &uid, bool mute, const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostTask(new UpdateMuteTask(uid,mute,callback));
}

void        UserService::Remote_UpdateMute(const UTF8String &uid, bool mute, const IAsynCallback &callback, int32_t task_id)
{
    LinkFrame lf(SVID_NIM_USER,CID_MARK_MUTELIST);
    
    MarkMuteData req;
    req.uid_ = uid;
    req.mute_ = mute;
    
    CoreCallback cb;
    cb.any_ = req;
    cb.task_id_ = task_id;
    cb.callback_ = callback;
    
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void        UserService::OnWaitablePacketUpdateMute(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    if (lf.error_ == NIMResSuccess) {
        MarkMuteData data = nimboost::any_cast<MarkMuteData>(callback.any_);
        UTF8String uid = data.uid_;
        bool mute = data.mute_;
        
        IYixinCore_Get()->SetDataItemTag(DN_RELATION, uid, NIMRelationTagMute, mute);
    }
    
    IAsynTaskCallbackParam param;
    param.task_id_ = callback.task_id_;
    param.code_ = lf.error_;
    if (!callback.callback_.is_null()) {
        callback.callback_.Run(&param);
    }
}


void        UserService::OnPacketMuteSync(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        MarkMuteData data;
        data.unmarshal(up);
        
        UTF8String uid = data.uid_;
        bool mute = data.mute_;
        
        IYixinCore_Get()->SetDataItemTag(DN_RELATION, uid, NIMRelationTagMute, mute);
    }
}

#pragma mark - 请求用户信息

int32_t     UserService::Invoke_FetchUsers(std::list<UTF8String> &uids,const IAsynCallback &callback){
    int32_t task_id = IYixinCore_Get()->PostLoginContextTask(new FetchUsersTask(uids,callback));
    return task_id;
}

void        UserService::Remote_FetchUsers(std::list<UTF8String> &uids,const IAsynCallback &callback,int32_t task_id){
    LinkFrame lf(SVID_NIM_USER,CID_GET_USER_UINFO);
    
    FetchFriendsRequest req;
    req.uids = uids;
    
    CoreCallback cb;
    cb.any_ = req;
    cb.task_id_ = task_id;
    cb.callback_ = callback;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void        UserService::OnWaitablePacketFetchUsers(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    PropertyList users;
    if (lf.error_ == NIMResSuccess) {
        users.unmarshal(up);
        
        for (auto it = users.list_.begin(); it != users.list_.end(); it++)
        {
            Property user     = *it;
            UTF8String userId = user.get_string(NIMUserInfoTagId);
            IYixinCore_Get()->SetDataItem(DN_USERS,userId,user,false);
        }
    }
    CBUserInfoListParam param;
    param.task_id_      = callback.task_id_;
    param.code_         = lf.error_;
    param.userInfoList_ = users.list_;
    if (!callback.callback_.is_null()) {
        callback.callback_.Run(&param);
    }
}

#pragma mark - 更新自己的用户信息
int32_t UserService::Invoke_UpdateMyInfo(Property &info, const IAsynCallback &callback){
    return IYixinCore_Get()->PostTask(new UpdateMyUserInfoTask(info,callback));
}

void UserService::Remote_UpdateMyInfo(Property &info, const IAsynCallback &callback, int32_t task_id){
    LinkFrame lf(SVID_NIM_USER,CID_UPDATE_MY_UINFO);
    UpdateMyUserInfoReqeust req;
    req.info_ = info;
    
    CoreCallback cb;
    cb.any_ = info;
    cb.task_id_ = task_id;
    cb.callback_ = callback;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void UserService::OnWaitablePacketUpdateMyUserInfo(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    if (lf.error_ == NIMResSuccess) {
        uint64_t timetag = up.pop_uint64();
        UTF8String uid = IYixinCore_Get()->GetUid();
        Property info = nimboost::any_cast<Property>(callback.any_);
        info.put_uint64(NIMUserInfoTagUpdateTime, timetag);
        IYixinCore_Get()->SetDataItem(DN_USERS,uid,info);
    }
    IAsynTaskCallbackParam param;
    param.code_ = lf.error_;
    param.task_id_ = callback.task_id_;
    if (!callback.callback_.is_null()) {
        callback.callback_.Run(&param);
    }
}
    

#pragma mark - 用户信息登录同步
void    UserService::OnPacketMyUserInfoSync(LinkFrame &lf, const nbase::Unpack &up){
    if (lf.error_ == NIMResSuccess) {
        Property info;
        up >> info;
        IYixinCore *core = IYixinCore_Get();
        core->SetDataItem(DN_USERS,core->GetUid(),info);

        uint64_t timetag = up.pop_uint64();
        ISyncService *service = (ISyncService *)GetServiceFromCore(SVID_NIM_SYNC);
        if (service) {
            service->SetSyncTimetag(NIMSyncTagMyInfo, timetag);
        }
    }
}

#pragma mark - 用户信息多端同步
void    UserService::OnPacketMyUserInfoUpdate(LinkFrame &lf, const nbase::Unpack &up){
    if (lf.error_ == NIMResSuccess) {
        Property info;
        up >> info;
        IYixinCore *core = IYixinCore_Get();
        core->SetDataItem(DN_USERS,core->GetUid(),info);
    }
}


#pragma mark - 登录同步
void        UserService::OnPacketRelationSync(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        PropertyList infos;
        infos.unmarshal(up);
        
        uint64_t timetag = up.pop_uint64();
        IYixinCore *core = IYixinCore_Get();
        for (auto it = infos.list_.begin(); it != infos.list_.end(); it++)
        {
            UTF8String uid = it->get_string(NIMRelationTagId);
            core->SetDataItem(DN_RELATION, uid, *it,false);
        }
        
        ISyncService *service = (ISyncService *)GetServiceFromCore(SVID_NIM_SYNC);
        if (service) {
            service->SetSyncTimetag(NIMSyncTagRelation, timetag);
        }
    }
}


#pragma mark - 读取接口
uint32_t    UserService::GetBlackList(std::list<UTF8String> &uids)
{
    uids.clear();
    std::list<UTF8String> keys;
    IYixinCore *core = IYixinCore_Get();
    core->GetDataItems(DN_RELATION, keys);
    
    for (auto it = keys.begin(); it != keys.end(); it++) {
        if (IsUserInBlackList(*it)) {
            uids.push_back(*it);
        }
    }
    return (uint32_t)uids.size();
}

uint32_t    UserService::GetMuteList(std::list<UTF8String> &uids)
{
    uids.clear();
    std::list<UTF8String> keys;
    IYixinCore *core = IYixinCore_Get();
    core->GetDataItems(DN_RELATION, keys);
    
    for (auto it = keys.begin(); it != keys.end(); it++) {
        if (IsUserMute(*it)) {
            uids.push_back(*it);
        }
    }
    return (uint32_t)uids.size();
}

void UserService::GetUserInfo(const UTF8String &uid,Property &property)
{
    if (nimbiz::HostUserInfos())
    {
        IYixinCore *core = IYixinCore_Get();
        core->GetDataItem(DN_USERS, uid, property);
        
    }
}



bool        UserService::IsUserInBlackList(const UTF8String &uid)
{
    uint32_t result = 0;
    IYixinCore_Get()->GetDataItemTag(DN_RELATION, uid, NIMRelationTagBlackList, result);
    return result != 0;
}


bool        UserService::IsUserMute(const UTF8String &uid)
{
    uint32_t result = 0;
    IYixinCore_Get()->GetDataItemTag(DN_RELATION, uid, NIMRelationTagMute, result);
    return result != 0;

}


void        UserService::CheckUserInfo(const Property &recv_msg)
{
    IYixinCore *core = IYixinCore_Get();
    if (core)
    {
        if (HostUserInfos()) //如果用户选择托管用户信息
        {
            UTF8String from_uid         = recv_msg.get_string(NIMSessionTagFromAccount);
            uint64_t from_info_timetag  = recv_msg.get_uint64(NIMSessionTagUserInfoTime);
            
            uint64_t cached_info_timetag= 0;
            core->GetDataItem64Tag(DN_USERS, from_uid, NIMUserInfoTagUpdateTime, cached_info_timetag);
            
            if (from_info_timetag != 0 && from_info_timetag > cached_info_timetag)
            {
                if (msg_info_frequency_controller_.IsRequestFrequencyAcceptable(from_uid))
                {
                    std::list<UTF8String> uids;
                    uids.push_back(from_uid);
                    Invoke_FetchUsers(uids, IAsynCallback());
                }
            }
        }
    }
}
    
    
void    UserService::SaveUserInfoFromServer(const Property &info)
{
    IYixinCore *core = IYixinCore_Get();
    UTF8String uid = info.get_string(NIMUserInfoTagId);
    uint64_t old_timtag = 0;
    core->GetDataItem64Tag(DN_USERS, uid, NIMUserInfoTagUpdateTime, old_timtag);
    uint64_t new_timetag = info.get_uint64(NIMUserInfoTagUpdateTime);
    
    if (new_timetag > old_timtag)
    {
        core->SetDataItem(DN_USERS, info.get_string(NIMUserInfoTagId), info);
    }
}
    
bool    UserService::UserInfoExists(const UTF8String &uid)
{
    Property info;
    IYixinCore_Get()->GetDataItem(DN_USERS, uid, info);
    return info.props.size() > 0 && info.get_uint64(NIMUserInfoTagUpdateTime) > 0;
}

}
