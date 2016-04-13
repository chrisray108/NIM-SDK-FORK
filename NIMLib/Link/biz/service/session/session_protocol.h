//
//  session_protocol.h
//  NIMLib
//
//  Created by amao on 15/1/30.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_session_protocol_h
#define NIMLib_session_protocol_h

#include "biz/core/service.h"
#include "biz/protocol/property.h"
#include "biz/protocol/response_code.h"
#include "biz/core/yixin_core.h"

namespace nimbiz
{

enum
{
    CID_SAY                         = 1,    //发送消息
    CID_NOTIFY_NEW_MSG              = 2,    //收到在线消息
    CID_SYSTEM_MSG                  = 3,    //系统消息
    CID_HISTORY_MSG                 = 6,    //获取单人会话的历史消息
    CID_SEND_CUSTOM_NOTIFICATION    = 7,    //透传消息
    CID_DELETE_SESSSION             = 9,    //删除服务器会话
    CID_MSG_SEND_RECEIPT            = 11,   //发送会话消息已读回执
    CID_MSG_RECV_RECEIPT            = 12,   //通知收到会话消息已读回执
    CID_OL_SYNC_SAY                 = 101,  //发送消息后发送方的多端同步
};


enum NIMSessionTag
{
    //接收消息
    NIMSessionTagToType         =   0,  //接受者类型 0个人 1群组 2临时会话
    NIMSessionTagToAccount      =   1,  //接受者帐号
    
    //发送方消息 (客户端不用填写)
    NIMSessionTagFromAccount    =   2,  //发送者帐号
    
    NIMSessionTagClientType     =   4,  //客户端类型
    NIMSessionTagDeviceID       =   5,  //设备ID
    NIMSessionTagNick           =   6,  //发送者昵称
    
    //消息基础信息
    NIMSessionTagTime           =   7,  //时间戳 (可选)
    NIMSessionTagContentType    =   8,  //内容类型
    NIMSessionTagBody           =   9,  //消息体
    NIMSessionTagAttach         =   10, //附件内容
    NIMSessionTagClientID       =   11, //客户端生成的消息ID
    NIMSessionTagServerID       =   12, //服务器生成的消息ID
    NIMSessionTagResend         =   13, //重发标记
    NIMSessionTagUserInfoTime   =   14, //消息发送者uinfo的最后更新时间
    NIMSessionTagServerExt      =   15, //第三方拓展信息
    NIMSessionTagPushPayload    =   16, //推送Payload
    NIMSessionTagPushContent    =   17, //推送文案
    
    //服务器配置字段
    NIMSessionTagHisotryEnable  =   100,//是否存储云端历史 0:不支持，1:支持, 默认1
    NIMSessionTagRoamingEnable  =   101,//是否支持漫游 0:不支持，1:支持, 默认1
    NIMSessionTagSelfSyncEnable =   102,//是否支持发送者多端同步 0:不支持，1:支持, 默认1
    NIMSessionTagPushEnable     =   107,//是否需要推送 0:不需要 1:需要 默认1
    NIMSessionTagShouldBeCounted=   109,//是否要做消息计数 0:不需要，1:需要，默认1
    NIMSessionTagNeedPushNick   =   110,//是否需要推送前缀 0:不需要，1:需要，默认1
};

enum NIMSystemMsgTag
{
    NIMSystemMsgTagTime           =   0,  //时间戳 (可选)
    NIMSystemMsgTagType           =   1,  //通知类型
    NIMSystemMsgTagToAccount      =   2,  //接受者帐号
    NIMSystemMsgTagFromAccount    =   3,  //发送者帐号
    NIMSystemMsgTagPostscript     =   4,  //附言
    NIMSystemMsgTagAttach         =   5,  //附件
    NIMSystemMsgTagMsgID          =   6,  //消息ID
    NIMSystemMsgTagSaveFlag       =   7,  //是否需要离线，0表示不需要 1表示需要
    NIMSystemMsgTagApnsText       =   8,  //APNS通知
    NIMSystemMsgTagApnsPayload    =   9,  //APNS Payload
    
    //服务器配置字段
    NIMSystemMsgTagApnsEnable     =   107,//是否需要推送, 0:不需要,1:需要,默认1
    NIMSystemMsgTagShouldBeCounted=   109,//是否要做消息计数，0:不需要，1:需要，默认1
    NIMSystemMsgTagNeedPushNick   =   110,//需要推送昵称，0：不需要，1：需要，默认0
    
};

struct CBSendMsgParam : IAsynCallbackParam
{
    UTF8String      client_id_;
    Property        cb_msg_;
};

enum CBRecvMsgState
{
    CBRecvMsgStateOnline    =   1 << 0, //是否是在线消息  1表示是
    CBRecvMsgStateRoam      =   1 << 1, //是否是漫游消息  1表示是
    CBRecvMsgStateOnlineSync=   1 << 2, //是否是其他端在线同步消息  1表示是
};

struct CBRecvMsgsParam : IAsynCallbackParam
{
    std::vector<Property> msgs_;
    int32_t msg_state_;
    CBRecvMsgsParam()
    {
        msg_state_ = 0;
    }
};

struct CBRecvSysMsgsParam : IAsynCallbackParam
{
    std::vector<Property> msgs_;
    bool online_msg_;

    CBRecvSysMsgsParam():online_msg_(false){}
};

struct CBSendCustomNotificationParam : IAsynCallbackParam
{
    UTF8String      client_id_;
};

struct CBRecvCustomNotificationParam : IAsynCallbackParam
{
    Property msg_;
};

struct CBHistoryMsgParam : IAsynTaskCallbackParam
{
    std::list<Property> msgs_;
};

typedef IAsynTaskCallbackParam CBDeleteSessionParam;

typedef IAsynTaskCallbackParam CBMarkSessionReadParam;
    
struct CBRecvReceiptParam : IAsynCallbackParam
{
    UTF8String  uid_;
    uint64_t    timetag_;
};

struct SessionHistoryMsgReqeustParam
{
    UTF8String uid_;
    uint64_t from_time_;
    uint64_t end_time_;
    UTF8String end_msg_id;
    uint32_t limit_;
    bool reverse_;
};

struct SessionHistoryMsgReqeust : nbase::Marshallable
{
    SessionHistoryMsgReqeustParam param_;
    void marshal(nbase::Pack &p) const
    {
        p.push_varstr(param_.uid_);
        p.push_uint64(param_.from_time_);
        p.push_uint64(param_.end_time_);
        p.push_varstr_as_uint64(param_.end_msg_id);
        p.push_uint32(param_.limit_);
        p.push_bool(param_.reverse_);
    }
    YX_REQUEST_ONLY();
};

struct SessionHistoryMsgResponse : nbase::Marshallable
{
    PropertyList msgs_;
    void unmarshal(const nbase::Unpack &up)
    {
        msgs_.unmarshal(up);
    }
    YX_RESPONSE_ONLY();
};


struct SessionDeleteRequest : nbase::Marshallable
{
    StringList sessions_;
    void marshal(nbase::Pack &p) const
    {
        sessions_.marshal(p);
    }
    YX_REQUEST_ONLY();
};




#pragma mark - ISessionService
class ISessionService : public IService
{
public:
    ISessionService() : IService(SVID_NIM_SESSION) {}
public:
    
    virtual void    Invoke_SendMsg(Property &msg) = 0;
    virtual void    Remote_SendMsg(Property &msg) = 0;
    
    virtual void    Invoke_SendCustomNotification(Property &msg,const UTF8String &msg_id) = 0;
    virtual void    Remote_SendCustomNotification(Property &msg,const UTF8String &msg_id) = 0;
    
    virtual int32_t Invoke_DeleteSession(const std::list<UTF8String> &sessions,const IAsynCallback &callback) = 0;
    virtual void    Remote_DeleteSession(const std::list<UTF8String> &sessions,const IAsynCallback &callback,int32_t task_id) = 0;
    
    virtual int32_t Invoke_SendSessionReceipt(const Property &msg,const IAsynCallback &callback) = 0;
    virtual void    Remote_SendSessionReceipt(const Property &msg,const IAsynCallback &callback,int32_t task_id) = 0;
    
    virtual void    OnSendMsg(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback) = 0;
    virtual void    OnRecvMsg(LinkFrame &lf,const nbase::Unpack &up,int32_t msg_state = 0) = 0;
    
    virtual void    OnRecvSysMsgs(LinkFrame &lf, const nbase::Unpack &up) = 0;
    
    virtual int32_t Invoke_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback) = 0;
    virtual void    Remote_HistoryMsg(const SessionHistoryMsgReqeustParam &param,const IAsynCallback &callback,int32_t task_id) = 0;
    virtual void    OnHistoryMsg(LinkFrame &lf,const nbase::Unpack &up,const CoreCallback &callback) = 0;

    virtual void    Register_SendMsgCallback(const IAsynCallback &callback) = 0;
    virtual void    Register_RecvMsgsCallback(const IAsynCallback &callback)= 0;
    virtual void    Register_RecvSysMsgsCallback(const IAsynCallback &callback) = 0;
    virtual void    Register_SendCustomNotificationCallback(const IAsynCallback &callback) = 0;
    virtual void    Register_RecvMsgReceiptCallback(const IAsynCallback &callback) = 0;
    
    virtual uint64_t    GetRecvReceiptTimetag(const UTF8String &uid) = 0;
    virtual void    SaveSyncReceipt(const Property &msg) = 0;
};
    
}


#endif
