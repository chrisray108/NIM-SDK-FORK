//
//  chatroom_service.cpp
//  NIMLib
//
//  Created by amao on 12/8/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#include "chatroom_service.h"
#include "chatroom_task.h"
#include "util/ios_util.h"
#include "biz/core/core_task_id_generator.h"
#include "base/memory/packet.h"




namespace nimbiz
{
    ChatroomService::ChatroomService()
    {
        
    }
    
    ChatroomService::~ChatroomService()
    {
        CleanUp();
    }
    
    uint32_t    ChatroomService::OnPacket(nimbiz::LinkFrame &lf, const nbase::Unpack &up)
    {
        int32_t result = NIMOnPacketSuccess;
        switch (lf.command_id_) {
            case CID_CR_NOTIFY_SAY:
                OnpacketRecvMsg(lf, up);
                break;
            case CID_CR_NOTIFY_KICK:
                OnpacketBeKicked(lf, up);
                break;
            default:
                result = NIMOnPacketCommandNotSupport;
                break;
        }
        return result;
    }
    
    bool        ChatroomService::OnWaitablePacket(LinkFrame &lf, const nbase::Unpack &up, const CoreCallback &callback)
    {
        bool handled = true;
        switch (lf.command_id_) {
            case CID_CR_REQUEST_ROOM_ADDR:
                OnWaitPacketRequestChatroom(lf, up, callback);
                break;
            case CID_CR_ENTER:
                OnWaitPacketEnterChatroom(lf, up, callback);
                break;
            case CID_CR_EXIT:
                OnWaitPacketExitChatroom(lf, up, callback);
                break;
            case CID_CR_SAY:
                OnWaitPacketSendMsg(lf, up, callback);
                break;
            case CID_CR_FETCH_MEMBERS:
                OnWaitPacketFetchMembers(lf, up, callback);
                break;
            case CID_CR_HISTORY_MSG:
                OnWaitPacketHistoryMsgs(lf, up, callback);
                break;
            case CID_CR_UPDATE_MEMBER:
                OnWaitPacketUpdateMember(lf, up, callback);
                break;
            case CID_CR_CLOSE:
                OnWaitPacketCloseRoom(lf, up, callback);
                break;
            case CID_CR_ROOM_INFO:
                OnWaitPacketGetChatroomInfo(lf, up, callback);
                break;
            case CID_CR_MEMBER_INFO_LIST:
                OnWaitPacketFetchMembersByIds(lf, up, callback);
                break;
            case CID_CR_KICK:
                OnWaitPacketKickMember(lf, up, callback);
                break;
            default:
                handled = false;
                break;
        }
        return handled;
    }
#pragma mark - 请求Token
    int32_t ChatroomService::Invoke_RequestChatroom(const UTF8String &room_id, const IAsynCallback &callback)
    {
        return IYixinCore_Get()->PostLoginContextTask(new ChatroomRequestChatroomTask(room_id,callback));
    }
    
    void    ChatroomService::Remote_RequestChatroom(const UTF8String &room_id, const IAsynCallback &callback, int task_id)
    {
        LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_REQUEST_ROOM_ADDR);
        ChatroomRequest request;
        request.room_id_ = room_id;
        
        CoreCallback cb;
        cb.callback_ = callback;
        cb.task_id_ = task_id;
        cb.any_ = room_id;
        
        
        IYixinCore_Get()->SendWaitablePacket(lf, request, cb);
    }
    
    void    ChatroomService::OnWaitPacketRequestChatroom(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback)
    {
        CBChatroomRequestChatroomParam param;
        param.task_id_ = callback.task_id_;
        param.code_ = lf.error_;
        param.room_id_ = nimboost::any_cast<UTF8String>(callback.any_);
        
        if (lf.error_ == NIMResSuccess)
        {
            StringList addresses;
            addresses.unmarshal(up);
            
            param.addresses_ = addresses.list_;
            
        }
        
        if (!callback.callback_.is_null()) {
            callback.callback_.Run(&param);
        }
    }


#pragma mark - 连接服务器
    void     ChatroomService::Invoke_ConnectRoom(const nimbiz::LinkChatroomData &data,const IAsynCallback &callback)
    {
        IYixinCore_Get()->PostTask(new ChatroomConnectTask(data,callback));
    }
    
    void        ChatroomService::Remote_ConnectRoom(const nimbiz::LinkChatroomData &data,const IAsynCallback &callback)
    {

        DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"begin to link room %s ip %s port %d link id %s",
               data.room_id_.c_str(),data.room_ip_.c_str(),data.room_port_,data.link_id_.c_str());
        
        UTF8String room_id = data.room_id_;
        ChatroomLinker *linker = room_linkers_[room_id];
        SAFE_DELETE(linker);
        
        linker = new ChatroomLinker(room_id,data.link_id_);
        linker->callback_ = callback;
        room_linkers_[room_id] = linker;


        linker->room_link_->ConnectLink(data.room_ip_, data.room_port_);
    }
    
    void        ChatroomService::Remote_NotifyConnected(const UTF8String &room_id,const UTF8String &link_id,NetErrorCode code)
    {
        DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"get connected for %s code %d",room_id.c_str(),(int32_t)code);
        ChatroomLinker *linker = room_linkers_[room_id];
        if (linker)
        {
            if (linker->link_id_ == link_id)
            {
                IAsynCallback callback = linker->callback_;
                CBLinkChatroomParam param;
                param.room_id_ = room_id;
                param.link_id_ = link_id;
                param.connected = code == kNetOk;
                if (!callback.is_null())
                {
                    callback.Run(&param);
                }
            }
            else
            {
                DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"invalid room linker for %s  %s vs %s",
                       room_id.c_str(),linker->link_id_.c_str(),link_id.c_str());
            }
        }
        else
        {
            DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"room linker for %s not exist",room_id.c_str());
        }
    }
    
    void        ChatroomService::Remote_NotifyDisconnected(const UTF8String &room_id,const UTF8String &link_id,nimbiz::NetErrorCode code)
    {
        DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"get disconnected for room %s code %d",room_id.c_str(),(int32_t)code);
        ChatroomLinker *linker = room_linkers_[room_id];
        if (linker && link_id == linker->link_id_)
        {
            linker->logined_ = false;
        }
        
        CBDisconnectChatroomParam param;
        param.room_id_ = room_id;
        param.link_id_ = link_id;
        if (!disconnect_callback_.is_null())
        {
            disconnect_callback_.Run(&param);
        }
    }
    
    
#pragma mark - 登录
    int32_t        ChatroomService::Invoke_EnterRoom(const nimbiz::EnterChatroomRequest &request, const IAsynCallback &callback)
    {
        return IYixinCore_Get()->PostTask(new ChatroomEnterTask(request,callback));
    }
    
    
    void        ChatroomService::Remote_EnterRoom(const nimbiz::EnterChatroomRequest &data, const IAsynCallback &callback, int32_t task_id)
    {
        UTF8String room_id = data.chatroom_request_.get_string(NIMChatroomLoginTagRoomId);
        ChatroomLinker *linker = room_linkers_[room_id];
        UTF8String link_id = linker ? linker->link_id_ : "";
        
        LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_ENTER);
        lf.room_id_ =room_id;
        
        EnterChatroomRequest request = data;
    
        CoreCallback cb;
        cb.callback_ = callback;
        cb.task_id_ = task_id;
        cb.any_ = link_id;
        
        int32_t timeout = nimbiz::GetLoginTimeout();
        DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"login chatroom %s link timeout %d",room_id.c_str(),timeout);
        SendWaitablePacket(lf, request, cb,timeout);
    }

    
    void        ChatroomService::OnWaitPacketEnterChatroom(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback)
    {
        UTF8String room_id = lf.room_id_;
        UTF8String link_id = nimboost::any_cast<UTF8String>(callback.any_);
        int32_t task_id    = callback.task_id_;
        
        ChatroomLinker *linker = room_linkers_[room_id];
        if (linker)
        {
            if (linker->link_id_ == link_id)
            {
                CBEnterChatroomParam param;
                param.task_id_ = task_id;
                param.room_id_ = room_id;
                param.code_ = lf.error_;
                
                if (lf.error_ == NIMResSuccess)
                {
                    up >> param.room_;
                    up >> param.me_;
                    
                    linker->logined_ = true;
                }
                if (!callback.callback_.is_null()) {
                    callback.callback_.Run(&param);
                }
            }
            else
            {
                DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__,"room %s login callback while task id not match %s vs %s",
                       room_id.c_str(),link_id.c_str(),linker->link_id_.c_str());
            }
        }
        else
        {
            DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__,"room %s login callback while link not exists",room_id.c_str());
        }
    }
    
#pragma mark - 离开
    int32_t     ChatroomService::Invoke_ExitRoom(const UTF8String &room_id, const IAsynCallback &callback)
    {
        return IYixinCore_Get()->PostTask(new ChatroomExitTask(room_id,callback));
    }
    
    void        ChatroomService::Remote_ExitRoom(const UTF8String &room_id, const IAsynCallback &callback, int32_t task_id)
    {
        ChatroomLinker *linker = room_linkers_[room_id];
        if (linker)
        {
            //需要记录当前link id作为唯一标示
            UTF8String link_id = linker->link_id_;
            
            LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_EXIT);
            lf.room_id_ = room_id;
            
            nbase::Voidmable request;
            
            CoreCallback cb;
            cb.any_ = link_id;
            cb.task_id_ = task_id;
            cb.callback_ = callback;
            
            SendWaitablePacket(lf, request, cb,5);
        }
        else
        {
            CBExitChatroomParam param;
            param.room_id_ = room_id;
            param.code_ = NIMResNotExist;
            if (!callback.is_null())
            {
                callback.Run(&param);
            }
        }
    }
    
    
    
    void        ChatroomService::OnWaitPacketExitChatroom(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback)
    {
        UTF8String room_id = lf.room_id_;
        UTF8String link_id = nimboost::any_cast<UTF8String>(callback.any_);
        
        CBExitChatroomParam param;
        param.room_id_ = room_id;
        param.task_id_ = callback.task_id_;
        param.code_    = lf.error_;
        
        ChatroomLinker *linker = room_linkers_[room_id];
        if (linker)
        {
            if (linker->link_id_ == link_id)
            {
                SAFE_DELETE(linker);
                room_linkers_.erase(room_id);
            }
            else
            {
                DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"link id not match while exiting room %s  %s vs %s"
                       ,room_id.c_str(),linker->link_id_.c_str(),link_id.c_str());
            }

        }
              
        if (!callback.callback_.is_null()) {
            callback.callback_.Run(&param);
        }
    }
    
#pragma mark - 获取聊天室成员
#pragma mark - 成员列表
    int32_t ChatroomService::Invoke_FetchRoomMember(const ChatroomMembersRequest &request, const IAsynCallback &callback){
        return IYixinCore_Get()->PostTask(new ChatroomFetchMembersTask(request,callback));
    }
    
    void ChatroomService::Remote_FetchRoomMember(const ChatroomMembersRequest &request, const IAsynCallback &callback, int32_t task_id){
        
        CoreCallback cb;
        cb.task_id_ = task_id;
        cb.callback_ = callback;
        
        LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_FETCH_MEMBERS);
        lf.room_id_ = request.room_id_;
        
        ChatroomMembersRequest req = request;
        SendWaitablePacket(lf, req, cb);
    }
    
    void ChatroomService::OnWaitPacketFetchMembers(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback){
        PropertyList members;
        if (lf.error_ == NIMResSuccess) {
            members.unmarshal(up);
        }
        CBChatroomFetchMembersParam param;
        param.task_id_ = callback.task_id_;
        param.code_    = lf.error_;
        param.members_ = members.list_;
        param.room_id_ = lf.room_id_;
        
        if (!callback.callback_.is_null()) {
            callback.callback_.Run(&param);
        }
    }
#pragma mark - 按ID获取
    int32_t ChatroomService::Invoke_FetchMembersByIds(const nimbiz::ChatroomMembersRequestByIds &request, const IAsynCallback &callback)
    {
        return IYixinCore_Get()->PostTask(new ChatroomFetchMembersByIdsTask(request,callback));
    }
    
    void ChatroomService::Remote_FetchMembersByIds(const nimbiz::ChatroomMembersRequestByIds &request, const IAsynCallback &callback, int32_t task_id)
    {
        CoreCallback cb;
        cb.task_id_ = task_id;
        cb.callback_ = callback;
        
        LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_MEMBER_INFO_LIST);
        lf.room_id_ = request.room_id_;
        
        ChatroomMembersRequestByIds req = request;
        SendWaitablePacket(lf, req, cb);
    }
    
    void ChatroomService::OnWaitPacketFetchMembersByIds(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback)
    {
        PropertyList members;
        if (lf.error_ == NIMResSuccess) {
            members.unmarshal(up);
        }
        CBChatroomFetchMembersParam param;
        param.task_id_ = callback.task_id_;
        param.code_    = lf.error_;
        param.members_ = members.list_;
        param.room_id_ = lf.room_id_;
        
        if (!callback.callback_.is_null()) {
            callback.callback_.Run(&param);
        }
    }
    
#pragma mark - 获取消息历史
    int32_t ChatroomService::Invoke_HistoryMsg(const nimbiz::ChatroomHistoryMsgReqeust &request, const IAsynCallback &callback)
    {
        return IYixinCore_Get()->PostTask(new ChatroomHistoryMsgTask(request,callback));
    }
    
    void ChatroomService::Remote_HistoryMsg(const nimbiz::ChatroomHistoryMsgReqeust &request, const IAsynCallback &callback, int32_t task_id)
    {
        CoreCallback cb;
        cb.task_id_ = task_id;
        cb.callback_ = callback;
        
        LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_HISTORY_MSG);
        lf.room_id_ = request.room_id_;
        
        ChatroomHistoryMsgReqeust req = request;
        SendWaitablePacket(lf, req, cb);
    }
    
    void  ChatroomService::OnWaitPacketHistoryMsgs(LinkFrame &lf,
                                    const nbase::Unpack &up,
                                    const CoreCallback &callback)
    {
        PropertyList msgs;
        if (lf.error_ == NIMResSuccess) {
            msgs.unmarshal(up);
        }
        CBChatroomHistoryMsgParam param;
        param.task_id_ = callback.task_id_;
        param.code_    = lf.error_;
        param.msgs_    = msgs.list_;
        param.room_id_ = lf.room_id_;
        
        if (!callback.callback_.is_null()) {
            callback.callback_.Run(&param);
        }
    }

#pragma mark - 标记聊天室成员身份
    int32_t ChatroomService::Invoke_UpdateMember(const ChatroomMemberUpdateRequest &request,const IAsynCallback &callback)
    {
        return IYixinCore_Get()->PostTask(new ChatroomUpdateMemberTask(request,callback));
    }
    
    void    ChatroomService::Remote_UpdateMember(const ChatroomMemberUpdateRequest &request,const IAsynCallback &callback,int32_t task_id)
    {
        CoreCallback cb;
        cb.task_id_ = task_id;
        cb.callback_ = callback;
        
        LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_UPDATE_MEMBER);
        lf.room_id_ = request.room_id_;
        
        ChatroomMemberUpdateRequest req = request;
        SendWaitablePacket(lf, req, cb);
    }
    
    void   ChatroomService::OnWaitPacketUpdateMember(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback)
    {
        CBChatroomUpdateMemberParam param;
        param.task_id_ = callback.task_id_;
        param.code_    = lf.error_;
        param.room_id_ = lf.room_id_;
        if (param.code_ == NIMResSuccess) {
            up >> param.member_;
        }

        if (!callback.callback_.is_null()) {
            callback.callback_.Run(&param);
        }
    }

    
    
#pragma mark - 关闭聊天室
    int32_t ChatroomService::Invoke_CloseRoom(const nimbiz::ChatroomCloseRoomRequest &request, const IAsynCallback &callback)
    {
        return IYixinCore_Get()->PostTask(new ChatroomCloseRoomTask(request,callback));
    }
    
    void ChatroomService::Remote_CloseRoom(const nimbiz::ChatroomCloseRoomRequest &request, const IAsynCallback &callback, int32_t task_id)
    {
        ChatroomLinker *linker = room_linkers_[request.room_id_];
        if (linker)
        {
            UTF8String link_id = linker->link_id_;
            
            LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_CLOSE);
            lf.room_id_ = request.room_id_;
            
            nbase::Voidmable request;
            
            CoreCallback cb;
            cb.any_ = link_id;
            cb.task_id_ = task_id;
            cb.callback_ = callback;
            
            SendWaitablePacket(lf, request, cb);
        }
        else
        {
            CBCloseChatroomParam param;
            param.room_id_ = request.room_id_;
            param.code_ = NIMResNotExist;
            if (!callback.is_null())
            {
                callback.Run(&param);
            }
        }
        
    }
    
    void ChatroomService::OnWaitPacketCloseRoom(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback)
    {
        UTF8String room_id = lf.room_id_;
        UTF8String link_id = nimboost::any_cast<UTF8String>(callback.any_);
        
        CBCloseChatroomParam param;
        param.room_id_ = room_id;
        param.task_id_ = callback.task_id_;
        param.code_    = lf.error_;
        if (lf.error_ == NIMResSuccess) {
            ChatroomLinker *linker = room_linkers_[room_id];
            if (linker)
            {
                if (linker->link_id_ == link_id)
                {
                    SAFE_DELETE(linker);
                    room_linkers_.erase(room_id);
                }
                else
                {
                    DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"link id not match while close room %s  %s vs %s"
                           ,room_id.c_str(),linker->link_id_.c_str(),link_id.c_str());
                }
            }
        }
        
        if (!callback.callback_.is_null()) {
            callback.callback_.Run(&param);
        }
        
    }
    
#pragma mark - 获取聊天室信息
    int32_t ChatroomService::Invoke_GetRoomInfo(const UTF8String &room_id, const IAsynCallback &callback)
    {
        return IYixinCore_Get()->PostTask(new ChatroomGetRoomInfoTask(room_id,callback));
    }
    
    void ChatroomService::Remote_GetRoomInfo(const UTF8String &room_id, const IAsynCallback &callback, int32_t task_id)
    {
        CoreCallback cb;
        cb.task_id_ = task_id;
        cb.callback_ = callback;
        
        LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_ROOM_INFO);
        lf.room_id_ = room_id;
        
        nbase::Voidmable req;
        SendWaitablePacket(lf, req, cb);
    }
    
    void ChatroomService::OnWaitPacketGetChatroomInfo(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback)
    {
        CBChatroomInfoParam param;
        param.room_id_ = lf.room_id_;
        param.task_id_ = callback.task_id_;
        param.code_    = lf.error_;
        if (param.code_ == NIMResSuccess) {
            up >> param.room_;
        }
        if (!callback.callback_.is_null()) {
            callback.callback_.Run(&param);
        }
    }


#pragma mark - 踢掉特定的成员
    int32_t ChatroomService::Invoke_KickMember(const nimbiz::ChatroomMemberKickRequest &request, const IAsynCallback &callback)
    {
        return IYixinCore_Get()->PostTask(new ChatroomKickTask(request,callback));
    }
    
    void ChatroomService::Remote_KickMember(const nimbiz::ChatroomMemberKickRequest &request, const IAsynCallback &callback, int32_t task_id)
    {
        CoreCallback cb;
        cb.task_id_ = task_id;
        cb.callback_ = callback;
        
        LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_KICK);
        lf.room_id_ = request.room_id_;
        
        ChatroomMemberKickRequest req = request;
        SendWaitablePacket(lf, req, cb);
    }
    
    void ChatroomService::OnWaitPacketKickMember(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback)
    {
        CBKickChatroomParam param;
        param.room_id_ = lf.room_id_;
        param.task_id_ = callback.task_id_;
        param.code_    = lf.error_;
        
        if (!callback.callback_.is_null()) {
            callback.callback_.Run(&param);
        }
    }

#pragma mark - Service 收发包处理
    uint16_t ChatroomService::SendPacket(LinkFrame &lf, nbase::Marshallable &packet)
    {
        uint16_t serial_id = GenerateSerialID();
        lf.serial_id_ = serial_id;
        
        UTF8String room_id = lf.room_id_;
        ChatroomLinker *linker = room_linkers_[room_id];
        if (linker && linker->room_link_)
        {
            linker->room_link_->SendPacket(lf, packet);
        }
        else
        {
            assert(0);
            DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"linker for %s not exist",room_id.c_str());
        }
        return serial_id;
    }
    
    
    void ChatroomService::SendWaitablePacket(LinkFrame &lf,
                                            nbase::Marshallable &packet,
                                            const CoreCallback &callback,
                                            int32_t timeout)
    {
        
        if (!CanConnectInternet() || !PacketCanBeSend(lf))
        {
            lf.error_       = NIMResTimeoutError;
            lf.key_         = IYixinCore_Get()->GetUid();
            
            nbase::Unpack unpackbuffer(NULL,0);
            OnWaitablePacket(lf, unpackbuffer, callback);
            return;
        }
        
        SendPacket(lf, packet);
        IYixinCore_Get()->AddWaitableRequest(lf, timeout, callback);
    }
    
    
#pragma mark - 收发消息
    #define DefaultRetryTimes   (3)
    #define MaxTimeoutDuration  (30)
    #define WaitTimeDruation    (2)
    
    void ChatroomService::Invoke_Say(nimbiz::Property &msg,int32_t retry_duration)
    {
        IYixinCore_Get()->PostTask(new ChatroomSendMsgTask(msg,retry_duration));
    }
    
    void ChatroomService::Remote_Say(nimbiz::Property &msg,int32_t retry_duration)
    {
        UTF8String room_id =  msg.get_string(NIMChatroomMsgTagRoomId);
        
        //检查当前是否需要等待
        if (retry_duration <= MaxTimeoutDuration)
        {
            ChatroomLinker *linker = room_linkers_[room_id];
            bool logined = linker != NULL && linker->logined_;
            if (!logined)
            {
                retry_duration += WaitTimeDruation;
                IYixinCore_Get()->PostDelayedTask(new ChatroomSendMsgTask(msg, retry_duration),WaitTimeDruation * 1000);
                return;
            }

        }

        
        //构建LinkFrame
        LinkFrame lf(SVID_NIM_CHATROOM,CID_CR_SAY);
        lf.room_id_  = room_id;
    
        
        //设置重试标记
        bool is_resend = msg.get_int32(NIMChatroomMsgTagResendFlag) != 0;
        if (!is_resend)
        {
            UTF8String client_id = msg.get_string(NIMChatroomMsgTagClientId);
            messages_[client_id] = DefaultRetryTimes;
        }

        CoreCallback cb;
        cb.any_ = msg;
        SendWaitablePacket(lf, msg, cb);
    }
    
    void ChatroomService::OnWaitPacketSendMsg(nimbiz::LinkFrame &lf, const nbase::Unpack &up, const nimbiz::CoreCallback &callback)
    {
        Property msg = nimboost::any_cast<Property>(callback.any_);
        UTF8String client_id = msg.get_string(NIMChatroomMsgTagClientId);
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
            msg.put_int32(NIMChatroomMsgTagResendFlag, 1);
            Invoke_Say(msg);
        }
        else
        {
            messages_.erase(client_id);
            
            if (!send_msg_callback_.is_null())
            {
                CBChatroomSendMsgParam param;
                param.room_id_      = lf.room_id_;
                param.code_         = error;
                param.client_id_    = client_id;
                
                send_msg_callback_.Run(&param);
            }
        }

    }
    
    void    ChatroomService::OnpacketRecvMsg(nimbiz::LinkFrame &lf, const nbase::Unpack &up)
    {
        if (lf.error_ == NIMResSuccess)
        {
            Property msg;
            up >> msg;
            
            CBChatroomReceiveMsgParam param;
            param.room_id_ = lf.room_id_;
            param.cb_msg_ = msg;
            if (!receive_msg_callback_.is_null()) {
                receive_msg_callback_.Run(&param);
            }
        }
    }
    
    
#pragma mark - 被踢
    void   ChatroomService::OnpacketBeKicked(LinkFrame &lf, const nbase::Unpack &up)
    {
        if (lf.error_ == NIMResSuccess) {
            UTF8String room_id = lf.room_id_;
            CBChatroomBeKickedParam param;
            param.reason_  = up.pop_uint32();
            param.room_id_ = room_id;
            
            ChatroomLinker *linker = room_linkers_[room_id];
            if (linker)
            {
                SAFE_DELETE(linker);
                room_linkers_.erase(room_id);
            }
            
            if (!kick_callback_.is_null()) {
                kick_callback_.Run(&param);
            }
        }
    }
    
#pragma mark - Ping
    void    ChatroomService::Invoke_Ping(const UTF8String &room_id)
    {
        IYixinCore_Get()->PostLoginContextTask(new ChatroomPingTask(room_id));
    }
    
    void    ChatroomService::Remote_Ping(const UTF8String &room_id)
    {
        static uint8_t chatroomPingServiceId = 1;
        static uint8_t chatroomPingCommandId = 2;
        
        LinkFrame lf(chatroomPingServiceId, chatroomPingCommandId);
        lf.room_id_ = room_id;
        nbase::Voidmable request;
        SendPacket(lf, request);
    }
    
#pragma mark - clean up
    void ChatroomService::CleanUp()
    {
        for (auto it = room_linkers_.begin(); it != room_linkers_.end(); it++)
        {
            SAFE_DELETE(it->second);
        }
        room_linkers_.clear();
    }
#pragma mark - misc
    bool    ChatroomService::PacketCanBeSend(const nimbiz::LinkFrame &lf)
    {
        bool can_be_send = false;
        UTF8String room_id = lf.room_id_;
        ChatroomLinker *linker = room_linkers_[room_id];
        if (linker)
        {
            if (linker->logined_)
            {
                can_be_send = true;
                
            }
            else
            {
                can_be_send = lf.service_id_ == SVID_NIM_CHATROOM && lf.command_id_ == CID_CR_ENTER;
            }
        }
        else
        {
            DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__,"linker for %s not exist",room_id.c_str());
        }
        if (!can_be_send)
        {
            nbase::DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Warning: Room %s Packet Ignored SID %d CID %d Before Being Logined",
                          room_id.c_str(),lf.service_id_,lf.command_id_);
        }
        return can_be_send;
        
    }
    
}