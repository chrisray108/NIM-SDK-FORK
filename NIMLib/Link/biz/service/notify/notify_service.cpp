//
//  notify_service.cpp
//  YixinCall
//
//  Created by amao on 10/24/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#include "notify_service.h"
#include "notify_task.h"
#include "biz/core/yixin_core.h"
#include "biz/service/sync/sync_protocol.h"
#include "biz/service/session/session_protocol.h"
#include "biz/service/team/team_protocol.h"
#include "biz/service/netcall/netcall_protocol.h"
#include "util/ios_util.h"
#include "util/ios_types.h"

namespace nimbiz
{


NotifyService::NotifyService()
{
    
}

NotifyService::~NotifyService()
{
    
}



uint32_t NotifyService::OnPacket(LinkFrame &lf,
                                 const nbase::Unpack &up)
{
    if (lf.error_ != NIMResSuccess)
    {
        DEFLOG(nbase::LogInterface::LV_APP,
               __FILE__,
               __LINE__,
               "Notify Onpacket Not Success");
        return NIMOnPacketSuccess;
    }
    
    uint32_t error = NIMOnPacketSuccess;
    switch (lf.command_id_)
    {
        case CID_NOTIFY_CTOC:
        case CID_NOTIFY_STOC:
        case CID_NOTIFY_ROOM_C:
        case CID_NOTIFY_ROOM_S:
            OnpacketGetNotify(lf, up);
            break;
        case CID_NOTIFY_SYNC_UNREAD:
            OnpacketGetAllLeaveMsgs(lf, up);
            break;
        case CID_SYNC_SYSTEM_MSG:
            OnpacketGetAllSystemNotifications(lf, up);
            break;
        case CID_SYNC_PUSH:
            OnpacketGetPush(lf, up);
            break;
        case CID_SYNC_NETCALL_MSG:
            OnpacketGetAllNetCallMsgs(lf, up);
            break;
        case CID_SYNC_ROAM_MSG:
            OnpacketGetAllRoamMsgs(lf, up);
            break;
        case CID_SYNC_RECEIPT:
            OnpacketGetReceipts(lf,up);
            break;
        default:
            error = NIMOnPacketCommandNotSupport;
            break;
    }
    return error;
    
}

#pragma mark - 解包方法
void    NotifyService::OnpacketGetNotify(LinkFrame &lf, const nbase::Unpack &up)
{
    //解析NotifyFrame
    NotifyFrame notify_frame;
    notify_frame.unmarshal(up);
    
    //设置msgId
    notify_frame.lf_.msg_id_ = notify_frame.msg_id_;
    //设置可能的RoomId
    if (lf.command_id_ == CID_NOTIFY_ROOM_C ||
        lf.command_id_ == CID_NOTIFY_ROOM_S)
    {
        notify_frame.lf_.room_id_ = lf.room_id_;
    }
    
    
    DispatchNotifyMessage(notify_frame.lf_, up, notify_frame.msg_id_);
    
}

void    NotifyService::OnpacketGetAllLeaveMsgs(LinkFrame &lf, const nbase::Unpack &up)
{
    GetAllLeaveMsgsResposne response;
    response.unmarshal(up);
    
    if (!recv_msgs_callback_.is_null())
    {
        CBRecvMsgsParam param;
        param.msgs_ = response.msgs_;
        recv_msgs_callback_.Run(&param);
    }
    
    std::vector<uint64_t> p2p_msg_ids;
    std::vector<uint64_t> team_msg_ids;
    std::map<UTF8String, uint64_t> team_msg_id_maps;
    for (size_t i = 0; i < response.msgs_.size(); i++)
    {
        Property &msg = response.msgs_[i];
        uint32_t to_type = msg.get_uint32(NIMSessionTagToType);
        uint64_t msg_id  = msg.get_uint64(NIMSessionTagServerID);
        
        if (to_type == nimbiz::GetSessionP2PType())
        {
            p2p_msg_ids.push_back(msg_id);
        }
        else if (to_type == nimbiz::GetSessionTeamType())
        {
            UTF8String team_id = msg.get_string(NIMSessionTagToAccount);
            uint64_t old_msg_id = team_msg_id_maps[team_id];
            if (old_msg_id < msg_id)
            {
                team_msg_id_maps[team_id] = msg_id;
            }
        }
        else
        {
            assert(0);
            DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__,
                   "Invalid Session Type %d",to_type);
        }
    }
    
    //标记P2P消息已读
    LinkFrame p2p_link_frame(SVID_NIM_SESSION,CID_NOTIFY_NEW_MSG);
    Remote_BatchMarkRead(p2p_link_frame, p2p_msg_ids);
    
    
    //标记群消息已读
    for (auto it = team_msg_id_maps.begin();
         it != team_msg_id_maps.end(); it++)
    {
        team_msg_ids.push_back(it->second);
    }
    LinkFrame team_link_frame(SVID_NIM_TEAM,CID_TEAM_NOTIFY_NEW);
    Remote_BatchMarkRead(team_link_frame, team_msg_ids);
}

void    NotifyService::OnpacketGetAllRoamMsgs(LinkFrame &lf, const nbase::Unpack &up)
{
    AllRoamMsgsResponse response;
    response.unmarshal(up);
    
    if (!recv_msgs_callback_.is_null())
    {
        CBRecvMsgsParam param;
        param.msgs_ = response.msgs_;
        param.msg_state_ = CBRecvMsgStateRoam;
        recv_msgs_callback_.Run(&param);
    }

}


void    NotifyService::OnpacketGetAllNetCallMsgs(LinkFrame &lf, const nbase::Unpack &up)
{
    GetAllNetCallLeaveMsgsResponse response;
    response.unmarshal(up);
    
    if (!recv_netcalls_callback_.is_null())
    {
        CBNetCallRcvNotifyParam param;
        param.netcalls_ = response.netcalls_;
        recv_netcalls_callback_.Run(&param);
    }
    
    std::vector<uint64_t> msg_ids;
    for (size_t i = 0; i < response.netcalls_.size(); i++)
    {
        Property &msg = response.netcalls_[i];
        uint64_t msg_id  = msg.get_uint64(NIMSessionTagServerID);
        msg_ids.push_back(msg_id);
    }
    
    //标记已读
    LinkFrame link_frame(SVID_NIM_NETCALL, CID_NETCALL_NOTIFY);
    Remote_BatchMarkRead(link_frame, msg_ids);
}


void    NotifyService::DispatchNotifyMessage(LinkFrame &dispatch_link_frame,
                                            const nbase::Unpack &up,
                                            const uint64_t msg_id)
{
    if (dispatch_link_frame.service_id_ == SVID_NIM_NOTIFY)
    {
        DEFLOG(nbase::LogInterface::LV_APP,
               __FILE__,
               __LINE__,
               "NotifyService::OnPacket, serviceid is SVID_NIM_NOTIFY");
        return;
    }
    
    //在线的批量群消息比较奇葩,所以直接在notify service里面处理掉
    if (dispatch_link_frame.service_id_ == SVID_NIM_TEAM && dispatch_link_frame.command_id_ == CID_TEAM_NTOIFY_MSG_LIST)
    {
        OnpacketGetTeamListResponse(dispatch_link_frame, up);
        return;
    }
    
    
    uint32_t err = NIMOnPacketCommandNotSupport;
    IYixinCore *core = IYixinCore_Get();
    try
    {
        IService* service = core->GetService(dispatch_link_frame.service_id_);
        if(service)
        {
            err = service->OnPacket(dispatch_link_frame, up);
        }
        else
        {
            DEFLOG(nbase::LogInterface::LV_APP,
                   __FILE__,
                   __LINE__,
                   "NotifyService::OnPacket, Service Not Found, serviceid: %d",
                   dispatch_link_frame.service_id_
                   );
        }
        
        //输出详细log
        if (err == NIMOnPacketCommandNotSupport)
        {
            DEFLOG(nbase::LogInterface::LV_APP,
                   __FILE__,
                   __LINE__,
                   "NotifyService::OnPacket, OnPacket NIMOnPacketCommandNotSupport,SID %d CID %d",
                   dispatch_link_frame.service_id_,dispatch_link_frame.command_id_
                   );
            
        }
        else
        {
            DEFLOG(nbase::LogInterface::LV_APP,
                   __FILE__,
                   __LINE__,
                   "NotifyService::OnPacket, OnPacket success, SID %d CID %d",
                   dispatch_link_frame.service_id_,dispatch_link_frame.command_id_
                   );
        }
        
        
        if ((err == NIMOnPacketSuccess) && (msg_id)) // 只有本地能够处理的离线消息，才去服务器删除
        {
            DEFLOG(nbase::LogInterface::LV_APP,
                   __FILE__,
                   __LINE__,
                   "mark notify read, msgid=%lu",
                   msg_id
                   );
            Remote_MarkRead(dispatch_link_frame,msg_id);
        }
    }
    catch(...)
    {
        DEFLOG(nbase::LogInterface::LV_APP,
               __FILE__,
               __LINE__,
               "-----------------NotifyService::OnPacket error---------SID %d CID %d",
               dispatch_link_frame.service_id_,dispatch_link_frame.command_id_
               );
    }
}

void    NotifyService::OnpacketGetAllSystemNotifications(LinkFrame &lf, const nbase::Unpack &up)
{
    ISessionService *service = (ISessionService *)GetServiceFromCore(SVID_NIM_SESSION);
    if (service)
    {
        service->OnRecvSysMsgs(lf, up);
    }
}

void    NotifyService::OnpacketGetTeamListResponse(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        TeamListSayResponse response;
        response.unmarshal(up);
        
        if (!recv_msgs_callback_.is_null())
        {
            CBRecvMsgsParam param;
            param.msgs_ = response.msgs_;
            param.msg_state_ = CBRecvMsgStateOnline;
            recv_msgs_callback_.Run(&param);
        }
        
        std::vector<uint64_t> msg_ids;
        for (auto it = response.msgs_.begin() ; it != response.msgs_.end(); it++)
        {
            msg_ids.push_back(it->get_uint64(NIMSessionTagServerID));
        }
        
        LinkFrame team_link_frame(lf.service_id_,lf.command_id_);
        Remote_BatchMarkRead(team_link_frame, msg_ids);

    }
    
}

#pragma mark - 已读标记
void    NotifyService::Remote_MarkRead(const LinkFrame &lf,const uint64_t msg_id)
{
    LinkFrame lf_notify(SVID_NIM_NOTIFY, CID_NOTIFY_MARK_READ);
    MarkReadRequest request;
    request.msg_id_ = msg_id;
    request.lf_ = lf;
    IYixinCore_Get()->SendPacket(lf_notify, request);
}

void    NotifyService::Remote_BatchMarkRead(const LinkFrame &lf, const std::vector<uint64_t> &msg_ids)
{
    std::vector<uint64_t>  mark_msg_ids;
    for (size_t i = 0; i < msg_ids.size(); i++)
    {
        mark_msg_ids.push_back(msg_ids[i]);
        
        if (mark_msg_ids.size() >= 20)
        {
            DoBatchMarkRead(lf,mark_msg_ids);
            mark_msg_ids.clear();
        }
    }
    if (mark_msg_ids.size())
    {
         DoBatchMarkRead(lf,mark_msg_ids);
    }
}

void    NotifyService::DoBatchMarkRead(const LinkFrame &lf, const std::vector<uint64_t> &msg_ids)
{
    LinkFrame lf_noify(SVID_NIM_NOTIFY,CID_BATCH_MARK_READ);
    BatchMarkReadRequest request;
    request.sid_ = lf.service_id_;
    request.cid_ = lf.command_id_;
    request.msg_ids_ = msg_ids;
    
    IYixinCore_Get()->SendPacket(lf_noify, request);
}

#pragma mark - 推送
void    NotifyService::OnpacketGetPush(LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess)
    {
        Property info;
        up >> info;
        uint64_t timetag = up.pop_uint64();
        
        ISyncService *sync = (ISyncService *)GetServiceFromCore(SVID_NIM_SYNC);
        if (sync)
        {
            sync->SetPushProperty(info);
            sync->SetSyncTimetag(NIMSyncTagPush, timetag);
        }
    }
}
    
#pragma mark - 已读回执
void    NotifyService::OnpacketGetReceipts(nimbiz::LinkFrame &lf, const nbase::Unpack &up)
{
    if (lf.error_ == NIMResSuccess) {
        PropertyList receipts;
        receipts.unmarshal(up);
        
        ISessionService *session = (ISessionService *)GetServiceFromCore(SVID_NIM_SESSION);
        ISyncService *sync = (ISyncService *)GetServiceFromCore(SVID_NIM_SYNC);
        if (session && sync) {
            for (auto it = receipts.list_.begin(); it != receipts.list_.end(); it++) {
                session->SaveSyncReceipt(*it);
            }
            
            uint64_t timetag = up.pop_uint64();
            
            sync->SetSyncTimetag(NIMSyncTagReceipt, timetag);
        }
    }
}
    
}
