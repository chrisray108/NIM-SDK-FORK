//
//  chatroom_service.hpp
//  NIMLib
//
//  Created by amao on 12/8/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#ifndef chatroom_service_hpp
#define chatroom_service_hpp

#include <map>
#include "chatroom_linkservice.h"
#include "chatroom_protocol.h"
#include "chatroom_linker.h"

namespace nimbiz
{
    
    struct ChatroomRequest : nbase::Marshallable
    {
        UTF8String room_id_;
        void marshal(nbase::Pack &p) const
        {
            p.push_varstr_as_uint64(room_id_);
            
        }
        YX_REQUEST_ONLY();
    };
    
    
    class ChatroomService : public IChatroomService
    {
    public:
        ChatroomService();
        ~ChatroomService();
        
        virtual void Release() {delete this;}
        
        // 收到网络包的处理函数
        virtual uint32_t OnPacket(LinkFrame &lf, const nbase::Unpack &up);
        
        virtual bool OnWaitablePacket(LinkFrame &lf,
                                      const nbase::Unpack &up,
                                      const CoreCallback &callback);
        
        // 异步发包
        virtual uint16_t SendPacket(LinkFrame &lf,
                                    nbase::Marshallable &packet);
        
        // 发送可等待包
        virtual void SendWaitablePacket(LinkFrame &lf,
                                        nbase::Marshallable &packet,
                                        const CoreCallback &callback,
                                        int32_t timeout = 15);
        
        
    public:
        virtual int32_t Invoke_RequestChatroom(const UTF8String &room_id,const IAsynCallback &callback);
        virtual void    Remote_RequestChatroom(const UTF8String &room_id,const IAsynCallback &callback,int task_id);
        
        virtual void    Invoke_ConnectRoom(const LinkChatroomData &data,const IAsynCallback &callback);
        virtual void    Remote_ConnectRoom(const LinkChatroomData &data,const IAsynCallback &callback);
        virtual void    Register_DisconnectCallback(const IAsynCallback &callback) {disconnect_callback_ = callback;}
        virtual void    Remote_NotifyConnected(const UTF8String &room_id,const UTF8String &link_id,NetErrorCode code);;
        virtual void    Remote_NotifyDisconnected(const UTF8String &room_id,const UTF8String &link_id,NetErrorCode code);
        
        
        virtual int32_t Invoke_EnterRoom(const EnterChatroomRequest &request,const IAsynCallback &callback);
        virtual void    Remote_EnterRoom(const EnterChatroomRequest &request,const IAsynCallback &callback,int32_t task_id);
        
        
        virtual int32_t Invoke_ExitRoom(const UTF8String &room_id,const IAsynCallback &callback);
        virtual void    Remote_ExitRoom(const UTF8String &room_id,const IAsynCallback &callback,int32_t task_id);
        
        virtual void    Invoke_Say(Property &msg,int32_t retry_duration = 0);
        virtual void    Remote_Say(Property &msg,int32_t retry_duration = 0);
        
        virtual void    Invoke_Ping(const UTF8String &room_id);
        virtual void    Remote_Ping(const UTF8String &room_id);
        
        virtual void    Register_SendMsgCallback(const IAsynCallback &callback) {send_msg_callback_ = callback;}
        virtual void    Register_RecvMsgsCallback(const IAsynCallback &callback) {receive_msg_callback_ = callback;}
        virtual void    Register_KickCallback(const IAsynCallback &callback) {kick_callback_ = callback;}
        
        virtual int32_t Invoke_FetchRoomMember(const ChatroomMembersRequest &request,const IAsynCallback &callback);
        virtual void    Remote_FetchRoomMember(const ChatroomMembersRequest &request,const IAsynCallback &callback,int32_t task_id);
        
        virtual int32_t Invoke_HistoryMsg(const ChatroomHistoryMsgReqeust &request,const IAsynCallback &callback);
        virtual void    Remote_HistoryMsg(const ChatroomHistoryMsgReqeust &request,const IAsynCallback &callback,int32_t task_id);
        
        virtual int32_t Invoke_UpdateMember(const ChatroomMemberUpdateRequest &request,const IAsynCallback &callback);
        virtual void    Remote_UpdateMember(const ChatroomMemberUpdateRequest &request,const IAsynCallback &callback,int32_t task_id);
        
        virtual int32_t Invoke_CloseRoom(const ChatroomCloseRoomRequest &request,const IAsynCallback &callback);
        virtual void    Remote_CloseRoom(const ChatroomCloseRoomRequest &request,const IAsynCallback &callback,int32_t task_id);
        
        virtual int32_t Invoke_GetRoomInfo(const UTF8String &room_id,const IAsynCallback &callback);
        virtual void    Remote_GetRoomInfo(const UTF8String &room_id,const IAsynCallback &callback,int32_t task_id);
        
        virtual int32_t Invoke_FetchMembersByIds(const ChatroomMembersRequestByIds &request,const IAsynCallback &callback);
        virtual void    Remote_FetchMembersByIds(const ChatroomMembersRequestByIds &request,const IAsynCallback &callback,int32_t task_id);
        
        virtual int32_t Invoke_KickMember(const ChatroomMemberKickRequest &request,const IAsynCallback &callback);
        virtual void    Remote_KickMember(const ChatroomMemberKickRequest &request,const IAsynCallback &callback,int32_t task_id);

        
        virtual void    CleanUp();
        
    private:
        bool    PacketCanBeSend(const LinkFrame &lf);
        
        void    OnWaitPacketSendMsg(LinkFrame &lf,
                                    const nbase::Unpack &up,
                                    const CoreCallback &callback);
        
        void    OnWaitPacketRequestChatroom(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);

        void    OnWaitPacketEnterChatroom(LinkFrame &lf,
                                          const nbase::Unpack &up,
                                          const CoreCallback &callback);
        
        void    OnWaitPacketExitChatroom(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);
        
        void    OnpacketRecvMsg(LinkFrame &lf, const nbase::Unpack &up);
        
        void    OnpacketBeKicked(LinkFrame &lf, const nbase::Unpack &up);

        
        void    OnWaitPacketFetchMembers(LinkFrame &lf,
                                    const nbase::Unpack &up,
                                    const CoreCallback &callback);
        
        void    OnWaitPacketHistoryMsgs(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);
        
        void    OnWaitPacketUpdateMember(LinkFrame &lf,
                                        const nbase::Unpack &up,
                                        const CoreCallback &callback);
        
        void    OnWaitPacketCloseRoom(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);
        
        void    OnWaitPacketGetChatroomInfo(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);
        
        void    OnWaitPacketFetchMembersByIds(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);
        
        void    OnWaitPacketKickMember(LinkFrame &lf,
                                         const nbase::Unpack &up,
                                         const CoreCallback &callback);
        
    private:
        std::map<UTF8String,ChatroomLinker *> room_linkers_;
        IAsynCallback   disconnect_callback_;
        IAsynCallback   send_msg_callback_;
        IAsynCallback   receive_msg_callback_;
        IAsynCallback   kick_callback_;
        std::map<UTF8String, int32_t> messages_;
    };
}



#endif /* chatroom_service_hpp */
