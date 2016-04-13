//
//  sync_protocol.h
//  NIM
//
//  Created by amao on 13-4-2.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#ifndef BIZ_SERVICE_SYNC_SYNC_PROTOCOL_H
#define BIZ_SERVICE_SYNC_SYNC_PROTOCOL_H

#include "biz/core/service.h"
#include "biz/protocol/protocol.h"
#include "biz/protocol/property.h"

namespace nimbiz
{



enum
{
    CID_SYNC                    = 1,
    CID_SYNC_TLIST              = 2,
};


enum NIMSyncStep
{
    NIMSyncStepBegin,
    NIMSyncStepEnd,
};

struct CBSyncParam : IAsynCallbackParam
{
    NIMSyncStep    step_;
};


enum NIMSyncTag
{
    NIMSyncTagMyInfo        =   1,
    NIMSyncTagUnread        =   2,
    NIMSyncTagTeamInfos     =   3,
    NIMSyncTagPush          =   4,
    NIMSyncTagNetCall       =   6,
    NIMSyncTagRoamMsg       =   7,
    NIMSyncTagRelation      =   9,
    NIMSyncTagUList         =   11,
    NIMSyncTagMyFriendInfo  =   13,
    NIMSyncTagReceipt       =   14,
};

enum NIMPushTag
{
    NIMPushTagDetail        =   1,
    NIMPushTagOpen          =   2,
    NIMPushTagFromH         =   3,
    NIMPushTagFromM         =   4,
    NIMPushTagToH           =   5,
    NIMPushTagToM           =   6,
};

class ISyncService : public IService
{
public:
    ISyncService (): IService(SVID_NIM_SYNC) {}
    
public:
    virtual void    RegisterSyncCallback(const IAsynCallback &callback) = 0;
    
    virtual void    Invoke_SyncAll() = 0;
    virtual void    Remote_SyncAll() = 0;
    
    virtual void        SetSyncTimetag(NIMSyncTag tag,uint64_t timetag) = 0;
    virtual uint64_t    GetSyncTimetag(NIMSyncTag tag) = 0;
    
    virtual void    SetPushProperty(const Property &info) = 0;
    virtual void    GetPushProperty(Property &info) = 0;
    
    virtual bool    IsInSync() = 0;
    
    
};
    
}

#endif
