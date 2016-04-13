//
//  user_service.cpp
//  NIMLib
//
//  Created by amao on 2/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#include "friend_service.h"
#include "friend_task.h"
#include "util/ios_util.h"
#include "base/log/log.h"
#include "biz/service/sync/sync_protocol.h"
#include "util/ios_types.h"
#include "biz/service/user/user_protocol.h"

namespace nimbiz
{

bool        FriendService::OnLoad()
{
    return true;
}

void        FriendService::OnUnLoad()
{
}


uint32_t    FriendService::OnPacket(LinkFrame &lf, const nbase::Unpack &up)
{
    uint32_t result = NIMOnPacketSuccess;
    switch (lf.command_id_) {
        case CID_FRIEND_SYNC_ADD:
            OnPacketSyncAdd(lf, up);
            break;
        case CID_FRIEND_SYNC_DEL:
            OnPacketSyncDelete(lf, up);
            break;
        case CID_FRIEND_SYNC_UPDATE:
            OnPacketSyncUpdate(lf, up);
            break;
        case CID_FRIEND_SYNC_LIST:
            OnPacketSyncList(lf,up);
            break;
        case CID_FRIEND_SYNC_FRIEND_INFO:
            OnPacketSyncFriendInfo(lf, up);
            break;
        default:
            result = NIMOnPacketCommandNotSupport;
            break;
    }
    return result;
}

bool    FriendService::OnWaitablePacket(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    bool handled = true;
    switch (lf.command_id_) {
        case CID_FRIEND_ADD:
            OnWaitPacketAddRequest(lf, up, callback);
            break;
        case CID_FRIEND_DEL:
            OnWaitPacketDeleteFriend(lf, up, callback);
            break;
        case CID_FRIEND_UPDATE:
            OnWaitPacketUpdateFriend(lf, up, callback);
            break;
        default:
            handled = false;
            break;
    }
    return handled;
}


void        FriendService::OnPacketSyncList(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        PropertyList infos;
        infos.unmarshal(up);
        
        uint64_t timetag = up.pop_uint64();
        IYixinCore *core = IYixinCore_Get();
        
        for (auto it = infos.list_.begin(); it != infos.list_.end(); it++) {
            UTF8String uid = it->get_string(NIMUListTagId);
            core->SetDataItem(DN_FRIENDS, uid, *it,false);
        }
        
        ISyncService *service = (ISyncService *)GetServiceFromCore(SVID_NIM_SYNC);
        if (service) {
            service->SetSyncTimetag(NIMSyncTagUList, timetag);
        }
        
    }
}

void    FriendService::OnPacketSyncFriendInfo(LinkFrame &lf, const nbase::Unpack &up){
    if (lf.error_ == NIMResSuccess) {
        PropertyList infos;
        infos.unmarshal(up);
        
        uint64_t timetag = up.pop_uint64();
        IYixinCore *core = IYixinCore_Get();
        
        for (auto it = infos.list_.begin(); it != infos.list_.end(); it++) {
            UTF8String uid = it->get_string(NIMUserInfoTagId);
            core->SetDataItem(DN_USERS, uid, *it,false);
        }
        
        ISyncService *service = (ISyncService *)GetServiceFromCore(SVID_NIM_SYNC);
        if (service) {
            service->SetSyncTimetag(NIMSyncTagMyFriendInfo, timetag);
        }
        
    }
}
#pragma mark - 好友操作
int32_t     FriendService::Invoke_RequestFriend(const FriendRequest &request, const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostTask(new RequestFriendTask(request,callback));
}

void        FriendService::Remote_RequestFriend(const FriendRequest &request, const IAsynCallback &callback,int32_t task_id)
{
    LinkFrame lf(SVID_NIM_FRIEND,CID_FRIEND_ADD);
    FriendRequest req = request;
    
    CoreCallback cb;
    cb.task_id_ = task_id;
    cb.any_ = req;
    cb.callback_ = callback;
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void        FriendService::OnWaitPacketAddRequest(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    int32_t code = lf.error_;
    if (code == NIMResSuccess) {
        FriendRequest request = nimboost::any_cast<FriendRequest>(callback.any_);
        int32_t type = request.type_;
        UTF8String uid = request.uid_;
        
        if (type == nimbiz::GetFriendOperationTypeAdd() || type == nimbiz::GetFriendOperationTypeVerify()) {
            
            
            Property info;
            info.put_string(NIMUListTagId, uid);
            info.put_int32(NIMUListTagFlag, 1);
            info.put_int32(NIMUListTagBeFlag, 1);
            IYixinCore_Get()->SetDataItem(DN_FRIENDS, uid, info);
        }
    }
    
    RaiseCallback(callback.callback_,callback.task_id_,code);
}

void        FriendService::OnPacketSyncAdd(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        
        UTF8String uid = up.pop_varstr();
        uint8_t type = up.pop_uint8();
        
        if (type == nimbiz::GetFriendOperationTypeAdd() ||
            type == nimbiz::GetFriendOperationTypeVerify()) {
            
            Property ulist;
            ulist.put_string(NIMUListTagId, uid);
            ulist.put_int32(NIMUListTagFlag, 1);
            ulist.put_int32(NIMUListTagBeFlag, 1);
            IYixinCore_Get()->SetDataItem(DN_FRIENDS, uid, ulist);
        }
    }
}

#pragma mark - 删除好友
struct DeleteFriendRequest : nbase::Marshallable
{
    UTF8String uid_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr(uid_);
    }
    YX_REQUEST_ONLY();
};

int32_t     FriendService::Invoke_DeleteFriend(const UTF8String &uid, const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostTask(new DeleteFriendTask(uid,callback));
}

void        FriendService::Remote_DeleteFriend(const UTF8String &uid, const IAsynCallback &callback, int32_t task_id)
{
    LinkFrame lf(SVID_NIM_FRIEND,CID_FRIEND_DEL);
    
    DeleteFriendRequest req;
    req.uid_ = uid;
    
    CoreCallback cb;
    cb.any_ = uid;
    cb.callback_ = callback;
    cb.task_id_ = task_id;
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}


void    FriendService::OnWaitPacketDeleteFriend(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    if (lf.error_ == NIMResSuccess) {
        UTF8String uid = nimboost::any_cast<UTF8String>(callback.any_);
        MarkFriendTag(uid, false);
    }
    
    
    RaiseCallback(callback.callback_,callback.task_id_, lf.error_);
}

void    FriendService::OnPacketSyncDelete(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        UTF8String uid = up.pop_varstr();
        MarkFriendTag(uid, false);
    }
}

#pragma mark - 更新好友tag
int32_t     FriendService::Invoke_UpdateFriend(const Property &info, const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostTask(new UpdateFriendTask(info,callback));
}

void        FriendService::Remote_UpdateFriend(const Property &info, const IAsynCallback &callback, int32_t task_id)
{
    LinkFrame lf(SVID_NIM_FRIEND,CID_FRIEND_UPDATE);
    Property req = info;
    
    CoreCallback cb;
    cb.any_ = req;
    cb.callback_ = callback;
    cb.task_id_ = task_id;
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}


void    FriendService::OnWaitPacketUpdateFriend(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    if (lf.error_ == NIMResSuccess) {
        Property info = nimboost::any_cast<Property>(callback.any_);
        IYixinCore_Get()->SetDataItem(DN_FRIENDS, info.get_string(NIMUListTagId), info);
    }
    
    RaiseCallback(callback.callback_,callback.task_id_, lf.error_);
}

void    FriendService::OnPacketSyncUpdate(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        Property info;
        up >> info;
        IYixinCore_Get()->SetDataItem(DN_FRIENDS, info.get_string(NIMUListTagId), info);
    }
}

#pragma mark - 本地操作接口
uint32_t        FriendService::GetMyFriends(std::list<UTF8String> &uids)
{
    uids.clear();
    std::list<UTF8String>   keys;
    IYixinCore *core = IYixinCore_Get();
    core->GetDataItems(DN_FRIENDS, keys);
    
    for (auto it = keys.begin(); it != keys.end(); it++) {
        uint32_t flag,beflag;
        core->GetDataItemTag(DN_FRIENDS, *it, NIMUListTagFlag, flag);
        core->GetDataItemTag(DN_FRIENDS, *it, NIMUListTagBeFlag, beflag);
        
        if (flag && beflag) {
            uids.push_back(*it);
        }
    }
    return (uint32_t)uids.size();
}


void            FriendService::GetFriendInfo(const UTF8String &uid, Property &property){
    IYixinCore *core = IYixinCore_Get();
    Property info;
    core->GetDataItem(DN_FRIENDS, uid, info);
    uint32_t flag   = info.get_uint32(NIMUListTagFlag);
    if (flag) {
        property = info;
    }
}

void            FriendService::MarkFriendTag(const UTF8String &uid, bool is_friend)
{
    Property info;
    info.put_string(NIMUListTagId, uid);
    info.put_uint32(NIMUListTagFlag, is_friend);
    info.put_uint32(NIMUListTagBeFlag, is_friend);
    IYixinCore_Get()->SetDataItem(DN_FRIENDS, uid, info);
}


#pragma mark - misc
void        FriendService::RaiseCallback(const IAsynCallback &callback,int32_t task_id ,int32_t code)
{
    IAsynTaskCallbackParam param;
    param.task_id_ = task_id;
    param.code_ = code;
    if (!callback.is_null()) {
        callback.Run(&param);
    }
}
    
}
