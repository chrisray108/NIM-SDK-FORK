//
//  sync_service.cpp
//  NIM
//
//  Created by amao on 13-4-2.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#include "sync_service.h"
#include "biz/core/yixin_core.h"
#include "sync_task.h"
#include "base/time/time.h"
#include "biz/service/team/team_protocol.h"

namespace nimbiz
{

//同步信息
#define DN_SYNC_ITEM_TIMETAG    "timetag"
#define DN_SYNC_ITEM_PUSH       "push"


SyncService::SyncService()
:is_in_sync_(false)
{
    
}

SyncService::~SyncService()
{

}

bool    SyncService::OnLoad()
{
    return true;
}

void    SyncService::OnUnLoad()
{
}

uint32_t    SyncService::OnPacket(LinkFrame &lf, const nbase::Unpack &up)
{
    uint32_t result = NIMOnPacketSuccess;
    switch (lf.command_id_) {
        case CID_SYNC:
            OnPacketSync(lf, up);
            break;
            
        default:
            break;
    }
    
    return result;
}


#pragma mark - sync all
void    SyncService::Invoke_SyncAll()
{
    IYixinCore_Get()->PostTask(new SyncAllTask());
    is_in_sync_ = true;
}
                               
                               
void    SyncService::Remote_SyncAll()
{
    LinkFrame lf(SVID_NIM_SYNC, CID_SYNC);

    Property sync_request;
    sync_request.put_uint64(NIMSyncTagUnread,       1);
    sync_request.put_uint64(NIMSyncTagMyInfo,       GetSyncTimetag(NIMSyncTagMyInfo));
    sync_request.put_uint64(NIMSyncTagTeamInfos,    GetSyncTimetag(NIMSyncTagTeamInfos));
    sync_request.put_uint64(NIMSyncTagPush,         GetSyncTimetag(NIMSyncTagPush));
    sync_request.put_uint64(NIMSyncTagNetCall,      1);
    sync_request.put_uint64(NIMSyncTagRoamMsg,      GetSyncTimetag(NIMSyncTagRoamMsg));
    sync_request.put_uint64(NIMSyncTagRelation,     GetSyncTimetag(NIMSyncTagRelation));
    sync_request.put_uint64(NIMSyncTagUList,        GetSyncTimetag(NIMSyncTagUList));
    sync_request.put_uint64(NIMSyncTagMyFriendInfo, GetSyncTimetag(NIMSyncTagMyFriendInfo));
    sync_request.put_uint64(NIMSyncTagReceipt,      GetSyncTimetag(NIMSyncTagReceipt));

    UTF8String log = "begin to sync: \n";
    for (auto it = sync_request.props.begin(); it != sync_request.props.end(); it++)
    {
        log += nbase::StringPrintf("tag %d value %s\n", it->first,it->second.c_str());
    }
    DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"%s",log.c_str());
    
    IYixinCore_Get()->SendPacket(lf, sync_request);
    
    if (!sync_callback_.is_null())
    {
        CBSyncParam param;
        param.step_ = NIMSyncStepBegin;
        sync_callback_.Run(&param);
    }
}

void    SyncService::OnPacketSync(LinkFrame &lf, const nbase::Unpack &up)
{
    DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"sync completed %zd",lf.error_);
    if (lf.error_ == NIMResSuccess)
    {
        IYixinCore_Get()->FlushDocument();
        if (!sync_callback_.is_null())
        {
            CBSyncParam param;
            param.step_ = NIMSyncStepEnd;
            sync_callback_.Run(&param);
        }
        
        //同步完毕后进行群成员的后续同步
        Remote_SyncTeamUsers();
    }
    is_in_sync_ = false;
}

#pragma mark - sync team users
void    SyncService::Remote_SyncTeamUsers()
{
    LinkFrame lf(SVID_NIM_SYNC,CID_SYNC_TLIST);
    SyncTeamUsersRequest request;
    ITeamService *service = (ITeamService *)GetServiceFromCore(SVID_NIM_TEAM);
    if (service)
    {
        service->GetTeamUsersSyncRequest(request);
    }
    if (request.teams_.size())
    {
        IYixinCore_Get()->SendPacket(lf, request);
    }
}



#pragma mark - sync timetag
void    SyncService::SetSyncTimetag(NIMSyncTag tag, uint64_t timetag)
{
    IYixinCore_Get()->SetDataItem64Tag(DN_SYNC, DN_SYNC_ITEM_TIMETAG, tag, timetag);
}

uint64_t    SyncService::GetSyncTimetag(NIMSyncTag tag)
{
    UTF8String tag_buffer;
    IYixinCore_Get()->GetDataItemTag(DN_SYNC, DN_SYNC_ITEM_TIMETAG, tag, tag_buffer);
    return atoll(tag_buffer.c_str());
}


#pragma mark - push
void    SyncService::SetPushProperty(const Property &info)
{
    IYixinCore_Get()->SetDataItem(DN_SYNC, DN_SYNC_ITEM_PUSH, info);
}

void    SyncService::GetPushProperty(Property &info)
{
    IYixinCore_Get()->GetDataItem(DN_SYNC, DN_SYNC_ITEM_PUSH, info);
}


}