//
//  session_service.h
//  NIMLib
//
//  Created by amao on 15/1/30.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef __NIMLib__session_service__
#define __NIMLib__session_service__
#include "session_protocol.h"
#include <map>

namespace nimbiz
{

enum NIMSessionInfoTag
{
    NIMSessionInfoTagSendAckTime    =   1,  //发送已读回执时间
    NIMSessionInfoTagRecvAckTime    =   2,  //接受到的已读回执时间
    NIMSessionInfoTagSyncTime       =   3,  //同步到的已读回执时间
};
    

class SessionService : public ISessionService
{
public:
    SessionService() {}
    
    virtual void Release() {delete this;}
    
    virtual bool OnLoad() { return true; }
    // 卸载服务后
    virtual void OnUnLoad() {}
    
    // 收到网络包的处理函数
    virtual uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up);
    
    virtual bool OnWaitablePacket(LinkFrame &lf,
                                  const nbase::Unpack &up,
                                  const CoreCallback &callback);
    
    virtual void    Invoke_SendMsg(Property &msg);
    virtual void    Remote_SendMsg(Property &msg);
    
    virtual void    Invoke_SendCustomNotification(Property &msg,const UTF8String &msg_id);
    virtual void    Remote_SendCustomNotification(Property &msg,const UTF8String &msg_id);
    
    virtual int32_t Invoke_DeleteSession(const std::list<UTF8String> &sessions,const IAsynCallback &callback);
    virtual void    Remote_DeleteSession(const std::list<UTF8String> &sessions,const IAsynCallback &callback,int32_t task_id);
    
    virtual int32_t Invoke_SendSessionReceipt(const Property &msg,const IAsynCallback &callback);
    virtual void    Remote_SendSessionReceipt(const Property &msg,const IAsynCallback &callback,int32_t task_id);
    
    

    
    virtual void    OnSendMsg(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback);
    virtual void    OnSendCommand(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback);
    
    virtual void    OnRecvMsg(LinkFrame &lf,const nbase::Unpack &up,int32_t msg_state = 0);
    virtual void    OnRecvSysMsgs(LinkFrame &lf, const nbase::Unpack &up);
    
    virtual int32_t Invoke_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback);
    virtual void    Remote_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback,int32_t task_id);
    virtual void    OnHistoryMsg(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback);

    virtual void    Register_SendMsgCallback(const IAsynCallback &callback) {send_msg_callback_ = callback;}
    virtual void    Register_RecvMsgsCallback(const IAsynCallback &callback) {recv_msgs_callback_ = callback;}
    virtual void    Register_RecvSysMsgsCallback(const IAsynCallback &callback) {recv_sys_msgs_callback_ = callback;}
    virtual void    Register_SendCustomNotificationCallback(const IAsynCallback &callback) {send_cn_callback_ = callback;}
    virtual void    Register_RecvMsgReceiptCallback(const IAsynCallback &callback) {recv_receipt_callback_ = callback;}
    
    virtual uint64_t    GetRecvReceiptTimetag(const UTF8String &uid);
    virtual void        SaveSyncReceipt(const Property &msg);

private:
    void    OnRecvSysMsg(LinkFrame &lf,const nbase::Unpack &up);
    void    OnRecvMsgReceipt(LinkFrame &lf,const nbase::Unpack &up);
    
    void    OnWaitPacketDeleteSession(LinkFrame &lf,
                                      const nbase::Unpack &up,
                                      const CoreCallback &callback);
    
    void    OnWaitPacketSendSessionReceipt(LinkFrame &lf,
                                      const nbase::Unpack &up,
                                      const CoreCallback &callback);
    
    
    void    RaiseReceiptCallback(const UTF8String &uid,uint64_t timetag);
    
    void        SaveP2PTimetag(const UTF8String &client_id,uint64_t timetag);
    uint64_t    GetP2PTimetag(const UTF8String &uid,const UTF8String &client_id);
    

private:
    IAsynCallback send_msg_callback_;
    IAsynCallback recv_msgs_callback_;
    IAsynCallback recv_sys_msgs_callback_;
    IAsynCallback send_cn_callback_;
    IAsynCallback recv_receipt_callback_;
    std::map<UTF8String, int32_t> messages_;
    std::map<UTF8String, uint64_t> p2p_timetag_cache_;

};
    
}
#endif /* defined(__NIMLib__session_service__) */
