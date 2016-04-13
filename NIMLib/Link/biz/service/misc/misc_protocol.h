//
//  misc_protocol.h
//  NIMLib
//
//  Created by amao on 1/30/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef NIMLib_misc_protocol_h
#define NIMLib_misc_protocol_h

#include "biz/core/service.h"
#include "biz/protocol/property.h"
#include "biz/protocol/response_code.h"
#include "biz/core/yixin_core.h"

namespace nimbiz
{

enum
{
    CID_GET_NOS_TOKEN           = 1,
    CID_NOTIFY_SDKLOG_UPLOAD    = 3,
    CID_GET_SDKLOG_UPLOAD       = 4,
    CID_TRANS_AUDIO             = 5,
};

enum NIMNOSTokenTag
{
    NIMNOSTokenTagObject     = 1,
    NIMNOSTokenTagToken      = 2,
    NIMNOSTokenTagBucket     = 3,
};


enum NIMAudioToTextTag
{
    NIMAudioToTextTagMime    = 0,
    NIMAudioToTextTagSample  = 1,
    NIMAudioToTextTagURL     = 2,
    NIMAudioToTextTagDuration= 3,
};



struct CBGetTokenParam : IAsynCallbackParam
{
    std::list<Property> tokens_;
};

struct CBTransAudioParam : IAsynTaskCallbackParam
{
    UTF8String text_;
};

#pragma mark - IMiscService
class IMiscService : public IService
{
public:
    IMiscService() : IService(SVID_NIM_MISC) {}
public:
    
    virtual void    RegisterUploadLogCallback(const IAsynCallback &callback) = 0;
    
    virtual void    Invoke_GetNOSToken(int32_t count,const IAsynCallback &callback) = 0;
    virtual void    Remote_GetNOSToken(int32_t count,const IAsynCallback &callback) = 0;
    
    virtual void    Invoke_UploadLogURL(const UTF8String &url) = 0;
    virtual void    Remote_UploadLogURL(const UTF8String &url) = 0;
    
    virtual int32_t Invoke_TransAudio(const Property &info,const IAsynCallback &callback) = 0;
    virtual void    Remote_TransAudio(const Property &info,const IAsynCallback &callback,int32_t task_id) = 0;
};

}

#endif
