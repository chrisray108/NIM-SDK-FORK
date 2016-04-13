//
//  session_service.cpp
//  NIMLib
//
//  Created by amao on 15/1/30.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#include "session_service.h"
#include "session_task.h"
#include "biz/service/user/user_protocol.h"
#include "biz/service/team/team_protocol.h"
#include "biz/service/notify/notify_protocol.h"
#include "util/ios_util.h"
#include "util/ios_types.h"


namespace nimbiz
{

#define DefaultRetryTimes 3

uint32_t    SessionService::OnPacket(LinkFrame &lf, const nbase::Unpack &up)
{
    uint32_t result = NIMOnPacketSuccess;
    switch (lf.command_id_) {
        case CID_NOTIFY_NEW_MSG:
            OnRecvMsg(lf,up);
            break;
        case CID_OL_SYNC_SAY:
            OnRecvMsg(lf, up,CBRecvMsgStateOnlineSync);
            break;
        case CID_SYSTEM_MSG:
            OnRecvSysMsg(lf, up);
            break;
        case CID_MSG_RECV_RECEIPT:
            OnRecvMsgReceipt(lf, up);
            break;
        default:
            result = NIMOnPacketCommandNotSupport;
            break;
    }
    return result;
}

bool    SessionService::OnWaitablePacket(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    bool handled = true;
    switch (lf.command_id_) {
        case CID_SAY:
            OnSendMsg(lf, up, callback);
            break;
        case CID_SEND_CUSTOM_NOTIFICATION:
            OnSendCommand(lf, up, callback);
            break;
        case CID_HISTORY_MSG:
            OnHistoryMsg(lf, up, callback);
            break;
        case CID_DELETE_SESSSION:
            OnWaitPacketDeleteSession(lf, up, callback);
            break;
        case CID_MSG_SEND_RECEIPT:
            OnWaitPacketSendSessionReceipt(lf, up, callback);
            break;
        default:
            handled = false;
            break;
    }
    
    
    return handled;
}


#pragma mark - 发送消息
void    SessionService::Invoke_SendMsg(Property &msg)
{
    IYixinCore_Get()->PostLoginContextTask(new SendMsgTask(msg));
}


void    SessionService::Remote_SendMsg(Property &msg)
{
    IYixinCore *core = IYixinCore_Get();
    
    //设置重试标记
    UTF8String client_id = msg.get_string(NIMSessionTagClientID);
    bool is_resend = msg.get_int32(NIMSessionTagResend) != 0;
    if (!is_resend)
    {
        messages_[client_id] = DefaultRetryTimes;
    }
    
    //调整发包目的地
    uint32_t to_type = msg.get_uint32(NIMSessionTagToType);
    LinkFrame lf(SVID_NIM_SESSION,CID_SAY);
    if (to_type == nimbiz::GetSessionTeamType())
    {
        lf = LinkFrame(SVID_NIM_TEAM, CID_TEAM_SAY);
    }
    
    //添加自己的时间戳
    uint64_t info_timetag = 0;
    core->GetDataItem64Tag(DN_USERS, core->GetUid(), NIMUserInfoTagUpdateTime, info_timetag);
    if (info_timetag != 0)
    {
        msg.put_uint64(NIMSessionTagUserInfoTime, info_timetag);
    }
    

    CoreCallback cb;
    cb.any_ = msg;
    core->SendWaitablePacket(lf, msg, cb);
}

void    SessionService::OnSendMsg(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    Property msg = nimboost::any_cast<Property>(callback.any_);
    UTF8String client_id = msg.get_string(NIMSessionTagClientID);
    uint32_t error = lf.error_;
    
    bool should_resend = false;
    if (error == NIMResTimeoutError)
    {
        int32_t retry_times = messages_[client_id];
        if (retry_times > 0)
        {
            messages_[client_id] = retry_times - 1;
            should_resend = true;
        }
    }
    
    if (should_resend)
    {
        msg.put_int32(NIMSessionTagResend, 1);
        Invoke_SendMsg(msg);
    }
    else
    {
        messages_.erase(client_id);
        
        if (!send_msg_callback_.is_null())
        {
            CBSendMsgParam param;
            param.code_         = error;
            param.client_id_    = client_id;
            
            if (error == NIMResSuccess)
            {
                Property cb_msg;
                up >> cb_msg;
                param.cb_msg_ = cb_msg;
                
                
                //缓存P2P时间戳备用
                uint32_t to_type = msg.get_uint32(NIMSessionTagToType);
                if (to_type == nimbiz::GetSessionP2PType())
                {
                    uint64_t timetag = cb_msg.get_uint64(NIMSessionTagTime);
                    SaveP2PTimetag(client_id, timetag);
                }
                
            }
            
            send_msg_callback_.Run(&param);
        }
    }
}

#pragma mark - 发送指令
void    SessionService::Invoke_SendCustomNotification(Property &msg,const UTF8String &msg_id)
{
    IYixinCore_Get()->PostTask(new SendCNTask(msg,msg_id));
}

void    SessionService::Remote_SendCustomNotification(Property &msg,const UTF8String &msg_id)
{
    LinkFrame lf(SVID_NIM_SESSION,CID_SEND_CUSTOM_NOTIFICATION);
    CoreCallback cb;
    cb.any_ = msg_id;
    IYixinCore_Get()->SendWaitablePacket(lf, msg, cb);
    
}

void    SessionService::OnSendCommand(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    UTF8String message_id = nimboost::any_cast<UTF8String>(callback.any_);
    CBSendCustomNotificationParam param;
    param.code_ = lf.error_;
    param.client_id_ = message_id;
    
    if (!send_cn_callback_.is_null())
    {
        send_cn_callback_.Run(&param);
    }
}

#pragma mark - 删除会话
int32_t SessionService::Invoke_DeleteSession(const std::list<UTF8String> &sessions,const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostLoginContextTask(new DeleteSessionsTask(sessions,callback));
}

void    SessionService::Remote_DeleteSession(const std::list<UTF8String> &sessions,const IAsynCallback &callback, int32_t task_id)
{
    LinkFrame lf(SVID_NIM_SESSION,CID_DELETE_SESSSION);
    SessionDeleteRequest req;
    req.sessions_.list_ = sessions;
    
    CoreCallback cb;
    cb.callback_ = callback;
    cb.task_id_ = task_id;
    
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
}

void    SessionService::OnWaitPacketDeleteSession(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
{
    CBDeleteSessionParam param;
    param.task_id_ = callback.task_id_;
    param.code_ = lf.error_;
    
    if (!callback.callback_.is_null()) {
        callback.callback_.Run(&param);
    }
}
    
    
#pragma mark - 已读回执
int32_t    SessionService::Invoke_SendSessionReceipt(const nimbiz::Property &msg, const IAsynCallback &callback)
{
    return IYixinCore_Get()->PostTask(new MarkSessionReadTask(msg,callback));
}
    

void    SessionService::Remote_SendSessionReceipt(const nimbiz::Property &msg, const IAsynCallback &callback, int32_t task_id)
{
    IYixinCore *core = IYixinCore_Get();
    UTF8String uid = msg.get_string(NIMSessionTagToAccount);
    uint64_t timetag = msg.get_uint64(NIMSessionTagTime);
    UTF8String client_id = msg.get_string(NIMSessionTagClientID);
    
    uint64_t old_timetag = 0;
    core->GetDataItem64Tag(DN_SESSION, uid, NIMSessionInfoTagSendAckTime, old_timetag);
    
    if (timetag == 0 || timetag > old_timetag)
    {
        Property req;
        req.put_string(NIMSessionTagToAccount, uid);
        req.put_string(NIMSessionTagClientID, client_id);
        
        LinkFrame lf(SVID_NIM_SESSION,CID_MSG_SEND_RECEIPT);
        CoreCallback cb;
        cb.callback_ = callback;
        cb.task_id_ = task_id;
        cb.any_ = msg;
        
        
        IYixinCore_Get()->SendWaitablePacket(lf, req, cb);
    }
    else
    {
        DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__,
               "send receipt ignored (old-%llu vs new-%llu)", old_timetag,timetag);
        
        CBMarkSessionReadParam param;
        param.task_id_ = task_id;
        param.code_ = NIMResExist;
        
        if (!callback.is_null()) {
            callback.Run(&param);
        }
    }
}
    
void    SessionService::OnWaitPacketSendSessionReceipt(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback)
{
    CBMarkSessionReadParam param;

    param.task_id_ = callback.task_id_;
    param.code_ = lf.error_;
    
    if (lf.error_ == NIMResSuccess) {
        
        Property ack_msg;
        up >> ack_msg;
        uint64_t ack_timetag = ack_msg.get_uint64(NIMSessionTagTime);
        
        Property send_msg = nimboost::any_cast<Property>(callback.any_);
        UTF8String uid = send_msg.get_string(NIMSessionTagToAccount);
        uint64_t send_timetag = send_msg.get_uint64(NIMSessionTagTime);
        
        //发送时间 和 服务器回包消息 取最小值记为当前发送回执的时间戳,避免本地消息时间过大而导致略过后续已读回执
        uint64_t timetag = std::min(ack_timetag, send_timetag);
        IYixinCore_Get()->SetDataItem64Tag(DN_SESSION, uid, NIMSessionInfoTagSendAckTime, timetag);
    }
    
    if (!callback.callback_.is_null()) {
        callback.callback_.Run(&param);
    }
}
    
uint64_t    SessionService::GetRecvReceiptTimetag(const UTF8String &uid)
{
    uint64_t value = 0;
    IYixinCore_Get()->GetDataItem64Tag(DN_SESSION, uid, NIMSessionInfoTagRecvAckTime, value);
    return value;
}
    
void    SessionService::OnRecvMsgReceipt(nimbiz::LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        
        IYixinCore *core = IYixinCore_Get();
        
        Property msg;
        up >> msg;
        
        UTF8String uid = msg.get_string(NIMSessionTagFromAccount);
        UTF8String client_id = msg.get_string(NIMSessionTagClientID);
        uint64_t timetag = msg.get_uint64(NIMSessionTagTime);
        uint64_t msg_timetag = GetP2PTimetag(uid, client_id);
        uint64_t old_msg_timetag = 0;
        core->GetDataItem64Tag(DN_SESSION, uid, NIMSessionInfoTagRecvAckTime, old_msg_timetag);
        
        DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__,"on get receipt %s client id %s msg_timetag %llu old_msg_timetag %llu timetag %llu",
              uid.c_str(),client_id.c_str(),msg_timetag,old_msg_timetag,timetag);
        
        msg_timetag = msg_timetag > 0 ? std::min(msg_timetag, timetag) : timetag;
        
        
        //如果本地存的已读时间戳比收到的小,忽略当前通知
        if (msg_timetag > old_msg_timetag) {
            
            core->SetDataItem64Tag(DN_SESSION, uid, NIMSessionInfoTagRecvAckTime, msg_timetag);
            core->SetDataItem64Tag(DN_SESSION, uid, NIMSessionInfoTagSyncTime, timetag);
            
            RaiseReceiptCallback(uid, msg_timetag);
        }
        else{
            DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__,"receipt timetag (new)%llu (old)%llu for %s ignored",
                   msg_timetag,old_msg_timetag,uid.c_str());
        }
    }
}
    
void    SessionService::SaveSyncReceipt(const Property &msg)
{
    UTF8String uid = msg.get_string(NIMSessionTagFromAccount);
    uint64_t sync_timetag = msg.get_uint64(NIMSessionTagTime);
    
    uint64_t old_sync_timetag = 0;
    IYixinCore_Get()->GetDataItem64Tag(DN_SESSION, uid, NIMSessionInfoTagSyncTime, old_sync_timetag);
    if (sync_timetag > old_sync_timetag) {
        
        IYixinCore *core = IYixinCore_Get();
        core->SetDataItem64Tag(DN_SESSION, uid, NIMSessionInfoTagRecvAckTime, sync_timetag);
        core->SetDataItem64Tag(DN_SESSION, uid, NIMSessionInfoTagSyncTime, sync_timetag);
        
        RaiseReceiptCallback(uid, sync_timetag);
        
    }
    else
    {
        DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__,"receipt sync timetag (new)%llu (old)%llu for %s ignored",sync_timetag,old_sync_timetag,uid.c_str());
    }
}
    
void    SessionService::RaiseReceiptCallback(const UTF8String &uid, uint64_t timetag)
{
    CBRecvReceiptParam param;
    param.uid_ = uid;
    param.timetag_ = timetag;
    
    if (!recv_receipt_callback_.is_null()) {
        recv_receipt_callback_.Run(&param);
    }
}
    
#pragma mark - 已发送P2P消息时间戳
void    SessionService::SaveP2PTimetag(const UTF8String &client_id, uint64_t timetag)
{
    p2p_timetag_cache_[client_id] = timetag;
}
    
uint64_t    SessionService::GetP2PTimetag(const UTF8String &uid, const UTF8String &client_id)
{
    uint64_t timetag = p2p_timetag_cache_[client_id];
    return timetag ? : nimbiz::GetP2PTimetagByDB(uid, client_id);
}
    

#pragma mark - 收取消息
void    SessionService::OnRecvMsg(LinkFrame &lf, const nbase::Unpack &up,int32_t msg_state)
{
    if (lf.error_ == NIMResSuccess)
    {
        Property msg;
        up >> msg;
        
        if (lf.msg_id_)
        {
            msg.put_uint64(NIMSessionTagServerID, lf.msg_id_);
        }
        
        if (!recv_msgs_callback_.is_null())
        {
            CBRecvMsgsParam param;
            param.msgs_.push_back(msg);
            param.msg_state_ = CBRecvMsgStateOnline | msg_state;
            recv_msgs_callback_.Run(&param);
        }


    }
}

#pragma mark - 收取系统消息
void    SessionService::OnRecvSysMsg(LinkFrame &lf, const nbase::Unpack &up){
    if (lf.error_ == NIMResSuccess)
    {
        Property msg;
        up >> msg;
        
        if (lf.msg_id_)
        {
            msg.put_uint64(NIMSystemMsgTagMsgID, lf.msg_id_);
        }
        
        if (!recv_sys_msgs_callback_.is_null())
        {
            CBRecvSysMsgsParam param;
            param.online_msg_ = true;
            param.msgs_.push_back(msg);
            recv_sys_msgs_callback_.Run(&param);
        }
    }
}

void    SessionService::OnRecvSysMsgs(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        std::vector<uint64_t> msg_ids;
        uint32_t size = up.pop_len();
        CBRecvSysMsgsParam param;
        param.online_msg_ = false;
        for (uint32_t i = 0; i < size; i++)
        {
            Property msg;
            up >> msg;
            param.msgs_.push_back(msg);
            msg_ids.push_back(msg.get_uint64(NIMSystemMsgTagMsgID));
        }
        if (!recv_sys_msgs_callback_.is_null())
        {
            recv_sys_msgs_callback_.Run(&param);
        }
        
        if (msg_ids.size())
        {
            INotifyService *service = (INotifyService *)GetServiceFromCore(SVID_NIM_NOTIFY);
            if (service)
            {
                LinkFrame lf(SVID_NIM_SESSION,CID_SYSTEM_MSG);
                service->Remote_BatchMarkRead(lf, msg_ids);
            }
        }
    }
}

#pragma mark - 漫游消息
int32_t   SessionService::Invoke_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback){
    return IYixinCore_Get()->PostTask(new HistoryMsgTask(param,callback));
}


void    SessionService::Remote_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback,int32_t task_id){
    LinkFrame lf(SVID_NIM_SESSION,CID_HISTORY_MSG);
    SessionHistoryMsgReqeust req;
    CoreCallback cb;
    cb.task_id_ = task_id;
    cb.callback_ = callback;
    req.param_  = param;
    IYixinCore_Get()->SendWaitablePacket(lf, req, cb);

}

void SessionService::OnHistoryMsg(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback){
    CBHistoryMsgParam param;
    param.code_ = lf.error_;
    param.task_id_ = callback.task_id_;
    if (lf.error_ == NIMResSuccess)
    {
        SessionHistoryMsgResponse response;
        response.unmarshal(up);
        param.msgs_ = response.msgs_.list_;
    }
    
    if (!callback.callback_.is_null()) {
        callback.callback_.Run(&param);
    }
    
}

    
}



