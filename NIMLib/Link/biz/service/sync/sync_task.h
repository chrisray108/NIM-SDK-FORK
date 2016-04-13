//
//  sync_task.h
//  NIM
//
//  Created by amao on 13-4-2.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#ifndef BIZ_SERVICE_SYNC_SYNC_TASK_H
#define BIZ_SERVICE_SYNC_SYNC_TASK_H

#include "biz/core/yixin_core.h"
#include "biz/core/eim_task.h"
#include "biz/protocol/property.h"
#include "biz/core/service.h"
#include "sync_protocol.h"

namespace nimbiz
{

class SyncAllTask : public YixinTask
{
public:
    SyncAllTask() {}
    
public:
    virtual void Run()
    {
        IYixinCore *core = IYixinCore_Get();
        ISyncService *service = (ISyncService *)core->GetService(SVID_NIM_SYNC);
        if (service)
        {
            service->Remote_SyncAll();
        }
    }
};
    
}

#endif
