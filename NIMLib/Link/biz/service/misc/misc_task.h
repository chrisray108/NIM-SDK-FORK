//
//  misc_task.h
//  NIMLib
//
//  Created by amao on 1/30/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef NIMLib_misc_task_h
#define NIMLib_misc_task_h

#include "misc_protocol.h"
#include "biz/core/eim_task.h"

namespace nimbiz
{

class GetNOSTokenTask: public YixinTask
{
public:
    GetNOSTokenTask(int32_t count, const IAsynCallback &callback)
    : count_(count),callback_(callback) {}
public:
    virtual void Run()
    {
        IMiscService *service = (IMiscService *)GetServiceFromCore(SVID_NIM_MISC);
        if (service)
        {
            service->Remote_GetNOSToken(count_, callback_);
        }
    }
    
private:
    int32_t count_;
    IAsynCallback callback_;
};

class UploadLogTask: public YixinTask
{
public:
    UploadLogTask(const UTF8String &url)
    :url_(url) {}
public:
    virtual void Run()
    {
        IMiscService *service = (IMiscService *)GetServiceFromCore(SVID_NIM_MISC);
        if (service)
        {
            service->Remote_UploadLogURL(url_);
        }
    }
    
private:
    UTF8String url_;
};


class TransAudioTask: public YixinTask
{
public:
    TransAudioTask(const Property &info,const IAsynCallback &callback)
    : info_(info),callback_(callback){}
public:
    virtual void Run()
    {
        IMiscService *service = (IMiscService *)GetServiceFromCore(SVID_NIM_MISC);
        if (service)
        {
            service->Remote_TransAudio(info_, callback_,GetTaskId());
        }
    }
    
private:
    Property info_;
    IAsynCallback callback_;
};
    
}

#endif
