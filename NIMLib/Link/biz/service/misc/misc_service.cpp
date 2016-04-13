//
//  misc_service.cpp
//  NIMLib
//
//  Created by amao on 1/30/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#include "misc_service.h"
#include "misc_task.h"

namespace nimbiz
{

struct GetNosTokenPackage : nbase::Marshallable
{
    uint32_t count_;
    std::list<Property> tokens_;
    void marshal(nbase::Pack &p) const
    {
        p.push_uint32(count_);
    }
    void unmarshal(const nbase::Unpack &up)
    {
        count_ =  up.pop_len();
        for (uint32_t i = 0; i < count_; i++)
        {
            Property token;
            up >> token;
            tokens_.push_back(token);
        }
    }
};

struct UploadLogRequest : nbase::Marshallable
{
    UTF8String url_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr(url_);
    }
    void unmarshal(const nbase::Unpack &up) {assert(0);}
};

uint32_t    MiscService::OnPacket(LinkFrame &lf, const nbase::Unpack &up)
{
    uint32_t result = NIMOnPacketSuccess;
    switch (lf.command_id_) {
        case CID_NOTIFY_SDKLOG_UPLOAD:
            OnNotifyUploadLog();
            break;
        default:
            result = NIMOnPacketCommandNotSupport;
            break;
    }
    return result;
}

bool    MiscService::OnWaitablePacket(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    bool handled = true;
    switch (lf.command_id_) {
        case CID_GET_NOS_TOKEN:
            OnGetTokens(lf,up,callback);
            break;
        case CID_TRANS_AUDIO:
            OnTransAudio(lf, up, callback);
            break;
        default:
            handled = false;
            break;
    }
    
    return handled;
}


#pragma mark - 获取NOS上传Token
void    MiscService::Invoke_GetNOSToken(int32_t count, const IAsynCallback &callback)
{
    IYixinCore_Get()->PostTask(new GetNOSTokenTask(count,callback));
}

void    MiscService::Remote_GetNOSToken(int32_t count, const IAsynCallback &callback)
{
    LinkFrame lf(SVID_NIM_MISC,CID_GET_NOS_TOKEN);
    GetNosTokenPackage req;
    req.count_ = (uint32_t)count;
    CoreCallback cb;
    cb.callback_ = callback;
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void    MiscService::OnGetTokens(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    CBGetTokenParam param;
    param.code_ = lf.error_;
    
    if (param.code_ == NIMResSuccess)
    {
        GetNosTokenPackage response;
        response.unmarshal(up);
        param.tokens_ = response.tokens_;
    }
    
    if (!callback.callback_.is_null())
    {
        callback.callback_.Run(&param);
    }
}

#pragma mark - 上传log url
void    MiscService::Invoke_UploadLogURL(const UTF8String &url)
{
    IYixinCore_Get()->PostTask(new UploadLogTask(url));
}

void    MiscService::Remote_UploadLogURL(const UTF8String &url)
{
    LinkFrame lf(SVID_NIM_MISC,CID_GET_SDKLOG_UPLOAD);
    UploadLogRequest req;
    req.url_ = url;
    
    IYixinCore_Get()->SendPacket(lf, req);
}

void    MiscService::OnNotifyUploadLog()
{
    if (!upload_callback_.is_null()) {
        upload_callback_.Run(0);
    }
}


#pragma mark - 语音转文字
int32_t    MiscService::Invoke_TransAudio(const Property &info, const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostTask(new TransAudioTask(info,callback));
}


void    MiscService::Remote_TransAudio(const Property &info, const IAsynCallback &callback,int32_t task_id)
{
    LinkFrame lf(SVID_NIM_MISC,CID_TRANS_AUDIO);
    
    CoreCallback cb;
    cb.task_id_ = task_id;
    cb.callback_= callback;
    
    Property req = info;
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void    MiscService::OnTransAudio(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    CBTransAudioParam param;
    param.code_ = lf.error_;
    param.task_id_ = callback.task_id_;
    
    
    if (lf.error_ == NIMResSuccess) {
        param.text_ = up.pop_varstr();
    }
    
    if (!callback.callback_.is_null()) {
        callback.callback_.Run(&param);
    }
    
}

}