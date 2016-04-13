//
//  sync_service.h
//  NIM
//
//  Created by amao on 13-4-2.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#ifndef BIZ_SERVICE_SYNC_SYNC_SERVICE_H
#define BIZ_SERVICE_SYNC_SYNC_SERVICE_H

#include "sync_protocol.h"

namespace nimbiz
{



class SyncService : public ISyncService
{
public:
    SyncService();
    virtual ~SyncService();
    virtual void Release() {delete this;}
    
public:
    virtual bool    OnLoad();
    virtual void    OnUnLoad();
    virtual uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up);

public:
    
    virtual void    RegisterSyncCallback(const IAsynCallback &callback) {sync_callback_ = callback;}
    virtual void    Invoke_SyncAll();
    virtual void    Remote_SyncAll();

    virtual void        SetSyncTimetag(NIMSyncTag tag,uint64_t timetag);
    virtual uint64_t    GetSyncTimetag(NIMSyncTag tag);
    
    virtual void    SetPushProperty(const Property &info);
    virtual void    GetPushProperty(Property &info);
    
    virtual bool    IsInSync()  {return is_in_sync_;}

private:
    void    Remote_SyncTeamUsers();
    void    OnPacketSync(LinkFrame &lf, const nbase::Unpack &up);
private:
    IAsynCallback   sync_callback_;
    bool            is_in_sync_;
};
    
}

#endif
