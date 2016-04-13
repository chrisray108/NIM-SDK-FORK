//
//  misc_service.h
//  NIMLib
//
//  Created by amao on 1/30/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef __NIMLib__misc_service__
#define __NIMLib__misc_service__

#include "misc_protocol.h"

namespace nimbiz
{

class MiscService : public IMiscService
{
public:
    MiscService() {}
    
    virtual void Release() {delete this;}
    
    virtual bool OnLoad() { return true; }
    // 卸载服务后
    virtual void OnUnLoad() {}
    
    // 收到网络包的处理函数
    virtual uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up);
    
    virtual bool OnWaitablePacket(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);
public:
    virtual void    RegisterUploadLogCallback(const IAsynCallback &callback) {upload_callback_ = callback;};
    
    virtual void    Invoke_GetNOSToken(int32_t count,const IAsynCallback &callback);
    virtual void    Remote_GetNOSToken(int32_t count,const IAsynCallback &callback);
    
    virtual void    Invoke_UploadLogURL(const UTF8String &url);
    virtual void    Remote_UploadLogURL(const UTF8String &url);
    
    virtual int32_t Invoke_TransAudio(const Property &info,const IAsynCallback &callback);
    virtual void    Remote_TransAudio(const Property &info,const IAsynCallback &callback,int32_t task_id);
private:
    void    OnGetTokens(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback);
    void    OnTransAudio(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback);
    void    OnNotifyUploadLog();

private:
    IAsynCallback upload_callback_;
};
}

#endif
